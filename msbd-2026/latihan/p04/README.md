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