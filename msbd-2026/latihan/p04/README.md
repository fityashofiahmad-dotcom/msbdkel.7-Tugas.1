## Prasyarat Sistem
1. Docker & Docker Compose terinstal dan aktif.
2. DBeaver atau klien PostgreSQL lainnya yang terhubung ke kontainer basis data lab pada port 5434 (skema lab4, bukan public).
3. Git untuk manajemen versi dan kolaborasi kelompok.

## Cara Menjalankan Setup q00_setup.sql
1. Pastikan Anda berada di direktori akar proyek yang aktif di branch latihan/p04-sql2.
2. Jalankan layanan Docker menggunakan Compose:
docker compose up -d
docker compose ps
3. Buka DBeaver atau terminal psql, pastikan terhubung ke port 5434, lalu eksekusi isi berkas latihan/p04/q00_setup.sql untuk membuat skema lab4, tabel data uji film, serta tabel jejak_akses dengan 500.000 baris data acak.

## Urutan Pengerjaan soal (Q1-Q21)
Seluruh berkas jawaban disimpan di dalam direktori latihan/p04/ dengan format nama qNN_nama_singkat.sql. Setiap berkas wajib diawali dengan tiga baris komentar standar (permintaan soal, keputusan SQL beserta alasannya, serta satu alternatif yang tidak dipilih).

1. Q1–Q4 (View & Check Option): Mempelajari pembuatan view fasad, perilaku updatable view, serta penerapan WITH CASCADED CHECK OPTION.
2. Q5–Q8 (Materialized View): Pengukuran kinerja kueri agregasi, pembuatan materialized view dengan indeks unik, hingga mekanisme refresh concurrently yang aman bagi pembaca. 
3. Q9–Q13 (Trigger Audit): Implementasi audit log tingkat baris (AFTER UPDATE OF dengan kondisi IS DISTINCT FROM), perbandingan kinerja (timing), hingga trigger tingkat pernyataan (statement-level) dengan transition table.
4. Q14–Q17 (Constraint sebagai Kontrak Data): Penggunaan CHECK NOT VALID, unique index parsial untuk soft-delete, aksi referensial Foreign Key, serta exclusion constraint (btree_gist) untuk rentang harga.
5. Q18–Q21 (Expand–Contract): Pola migrasi aman untuk mengganti kolom tanpa mengganggu pembaca lama melalui enam tahap berurutan (Expand, Tulis Ganda, Backfill bertahap, Verifikasi nol, View Fasad, dan Contract/Drop kolom lama).

## Catatan Khusus Sesi Ganda (Q8 & Q20)
Beberapa pengujian memerlukan simulasi dua sesi paralel (concurrent sessions) di psql atau DBeaver:
1. Q8 (Refresh Concurrently): Sesi 1 melakukan penyisipan data masif (200.000 baris) dan menjalankan REFRESH MATERIALIZED VIEW CONCURRENTLY, sementara Sesi 2 terus memantau pembacaan data tanpa mengalami pemblokiran (blocking).
2. Q20 (Expand–Contract Fasad): Sesi 2 bertindak sebagai pembaca lama yang menjalankan SELECT title, rental_rate FROM lab4.film LIMIT 5; secara kontinu untuk membuktikan bahwa transisi arsitektur kolom tidak memutus akses aplikasi yang belum diperbarui.

## Peringatan Kritis Migrasi (0046)
1. Migrasi 0046 (0046_contract_drop_kolom_lama.up.sql) bersifat DESTRUKTIF. Tindakan drop kolom lama pada tabel fisik tidak dapat diurungkan sepenuhnya melalui skrip down (.down.sql hanya mampu mengembalikan struktur kolom kosong, bukan nilai data historisnya).
2. Jangan pernah menjalankan tahap 0046 sebelum seluruh bukti verifikasi backfill menghasilkan nilai nol (0) dan kestabilan view fasad teruji sempurna pada sesi pembaca.

## Detail Implementasi Q18–Q21 (Expand–Contract)

Berkas jawaban: `latihan/p04/q18_expand_tulis_ganda.sql`, `q19_backfill_bertahap.sql`, `q20_contract_view_fasad.sql`, `q21_migrasi_berversi.md`.

1. **Q18 (Expand — Tulis Ganda):** Fungsi trigger `lab4.tulis_ganda_harga()` dipasang `AFTER INSERT OR UPDATE OF rental_rate ON lab4.film`. Pada `UPDATE` yang benar-benar mengubah harga (`IS DISTINCT FROM`), periode harga lama yang masih terbuka (`upper_inf(berlaku)`) ditutup ke tanggal hari ini lebih dulu, baru periode baru dibuka — urutan tutup-lalu-buka ini wajib agar tidak melanggar `EXCLUDE USING gist (film_id, wilayah, berlaku)` dari Q17.
2. **Q19 (Migrate — Backfill Bertahap):** Backfill dijalankan lewat `PROCEDURE lab4.backfill_harga_film(1000)` yang dipanggil dengan `CALL`, bukan `DO` block, karena hanya prosedur yang bisa `COMMIT` di tengah loop. Setiap batch memproses 1000 `film_id` lalu `COMMIT`, sehingga kunci baris singkat dan progres tidak hilang bila proses terhenti di tengah jalan.
3. **Q20 (Contract — View Fasad):** Dijalankan sebagai dua transaksi terpisah:
   - **Langkah A** (atomik, satu `BEGIN...COMMIT`): `ALTER TABLE lab4.film RENAME TO film_dasar`, langsung diikuti `CREATE VIEW lab4.film` yang menyusun ulang kolom lama (`rental_rate` kini diambil dari `lab4.harga_film`). Kedua statement **harus** dalam satu transaksi — kalau dipisah, ada jendela nyata di mana nama `lab4.film` tidak menunjuk objek apa pun, dan sesi pembaca akan gagal dengan galat `relation "lab4.film" does not exist`.
   - **Langkah B** (transaksi terpisah, dijalankan belakangan): `DROP TRIGGER` + `DROP FUNCTION` tulis ganda, lalu `ALTER TABLE lab4.film_dasar DROP COLUMN rental_rate`.
4. **Q21 (Migrasi Berversi):** Enam tahap ditulis sebagai tiga pasang migrasi:

   | Migrasi | Fase | Isi |
   |---|---|---|
   
   | `0041_expand_buat_harga_film` | Expand | Buat `lab4.harga_film` + `EXCLUDE` gist |
   | `0042_expand_trigger_tulis_ganda` | Expand | Trigger tulis ganda |
   | `0043_migrate_backfill` | Migrate | Backfill bertahap 1000 film/batch |
   | `0044_migrate_verifikasi` | Migrate | `RAISE EXCEPTION` jika backfill belum nol |
   | `0045_contract_view_fasad` | Contract | Rename + view fasad atomik |
   | `0046_contract_drop_kolom_lama` | Contract | Drop trigger + drop kolom lama |

   Jarak rilis yang diusulkan antara `0045` dan `0046`: minimal satu siklus rilis penuh, dengan empat bukti terkumpul lebih dulu — tidak ada penulisan langsung ke kolom lama, view fasad konsisten dengan sumber lama, tidak ada galat pembaca selama observasi, dan perbandingan eksplisit nol-selisih yang diulang beberapa kali. Rincian lengkap ada di `q21_migrasi_berversi.md`.
