# Laporan Latihan Kelompok 7 Pert.4

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |

| Andika Chairul Ilham | 251402047 | Langkah 6, Refleksi E, Laporan | Commit |
| Fahri Arizal | 251402102 | Langkah 3, Refleksi B, Laporan | Commit |
| Fitya Shofi Ahmad | 251402132 | Langkah 1, Langkah 2, Reflektif A, Laporan | Commit |
| Mar'ie Rizqullah | 251402129 | Langkah 4, Langkah 5, Refleksi C, Refleksi D, Laporan | Commit |

## Q1_Q21
### Q1 (q01_view_film_murah.sql)
1. Perintah:
CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99;
2. Keluaran:
Pesan status eksekusi berhasil (Query returned successfully in 0.008s / Update rows: 0), dan view lab4.film_murah berhasil terbentuk di dalam database.
3. Alasan:
Perintah ini digunakan untuk membuat virtual table (view) bernama film_murah di dalam skema lab4 yang menyaring data film dengan ketentuan harga sewa (rental_rate) maksimal 0.99 secara spesifik tanpa klausul tambahan check option.

### Q2 (q02_baris_menghilang.sql)
1. Perintah: 
-- Mencoba menyisipkan data di luar kriteria filter view --
INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (1001, 'Film Mahal Banget', 4.99, 'PG');

-- Mengecek keberadaan data di view vs tabel dasar --
SELECT * FROM lab4.film_murah WHERE film_id = 1001;
SELECT * FROM lab4.film WHERE film_id = 1001;
2. Keluaran: 
a. Saat insert: INSERT 0 1 (berhasil masuk ke tabel dasar).
b. Saat dicek di lab4.film_murah: Baris tidak ditemukan (kosong).
c. Saat dicek di lab4.film: Baris data (1001, 'Film Mahal Banget', 4.99, 'PG') benar-benar tersimpan
3. Alasan: Karena view dibuat tanpa WITH CHECK OPTION, PostgreSQL mengizinkan data baru masuk ke tabel fisik di baliknya (lab4.film). Namun, data tersebut langsung "menghilang" atau tidak tampak saat diakses melalui view karena melanggar batasan filter klausa WHERE rental_rate <= 0.99.

### Q3 (q03_check_option.sql)
1. Perintah:
-- Membuat ulang view dengan CASCADED CHECK OPTION --
CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99
WITH CASCADED CHECK OPTION;

-- Mencoba menyisipkan data dengan harga di luar batas filter --
INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (1002, 'Film Gagal Masuk', 4.99, 'PG');
2. Keluaran: ERROR: new row violates check option for view "film_murah"
DETAIL: Failing row contains (1002, Film Gagal Masuk, null, null, null, null, null, null, null, 4.99, null, PG, null).
3. Alasan: Penggunaan klausul WITH CASCADED CHECK OPTION memaksa PostgreSQL untuk memvalidasi setiap data yang akan dimasukkan melalui view. Karena nilai rental_rate (4.99) melanggar syarat filter view (<= 0.99), maka operasi insert ditolak secara mutlak oleh sistem.

### Q4 (q04_view_pendapatan_kategori.sql)
1. Perintah: 
CREATE OR REPLACE VIEW lab4.pendapatan_kategori AS
SELECT c.name AS category_name, SUM(p.amount) AS total_revenue
FROM public.category c
JOIN public.film_category fc ON c.category_id = fc.category_id
JOIN public.inventory i ON fc.film_id = i.film_id
JOIN public.rental r ON i.inventory_id = r.inventory_id
JOIN public.payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

-- Uji coba insert ke view agregasi --
INSERT INTO lab4.pendapatan_kategori VALUES ('Action', 50000);
2. Keluaran: ERROR: cannot insert into view "pendapatan_kategori"
  Detail: Views containing GROUP BY are not automatically updatable.
  Hint: To enable inserting into the view, provide an INSTEAD OF INSERT trigger or an unconditional ON INSERT DO INSTEAD rule.
3. Alasan: View yang melibatkan fungsi agregasi (SUM) dan pengelompokan (GROUP BY) bersama join banyak tabel dikategorikan sebagai read-only oleh PostgreSQL. Sistem tidak bisa secara otomatis memetakan atau memecah balik data sisipan ke tabel-tabel dasarnya, sehingga operasi insert langsung ditolak.

### Q5 (q05_query_dasar_akses.sql)

1. Perintah:
   \timing on
SELECT date_trunc('month', a.waktu) AS bulan,
       a.kanal,
       count(*) AS jumlah_akses,
       count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2;
2. Keluaran: Hasil agregasi 500.000 baris data tercetak dengan catatan waktu eksekusi: 142.350 ms.
3. Alasan: Query ini mengukur baseline kecepatan pemrosesan agregasi langsung pada tabel fisik besar sebelum dioptimasi menggunakan Materialized View.

### Q6 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q7 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q8 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q9 (q09_trigger_audit_baris.sql)
1. Perintah:
CREATE TABLE lab4.audit_harga (
    audit_id bigserial PRIMARY KEY,
    film_id integer NOT NULL,
    harga_lama numeric(5,2),
    harga_baru numeric(5,2),
    diubah_oleh text NOT NULL DEFAULT current_user,
    diubah_pada timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION lab4.catat_perubahan_harga()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    VALUES (OLD.film_id, OLD.rental_rate, NEW.rental_rate);
    RETURN NEW;
END;
$$;

CREATE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_perubahan_harga();

2. Keluaran: Tabel audit, fungsi trigger, dan trigger film_audit_harga berhasil dibuat.

3. Alasan: Dipilih AFTER UPDATE OF rental_rate dengan WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate) untuk mengeliminasi pencatatan log audit palsu.

### Q10 (q10_uji_audit_baris.sql)
1. Perintah:
UPDATE lab4.film SET rental_rate = 2.99 WHERE film_id = 1;
UPDATE lab4.film SET rental_rate = 2.99 WHERE film_id = 1;
UPDATE lab4.film SET title = 'ACADEMY DINOSAUR UPDATED' WHERE film_id = 1;

SELECT * FROM lab4.audit_harga WHERE film_id = 1;

2. Keluaran: Hanya 1 baris record audit yang terbentuk (berasal dari UPDATE pertama).

3. Alasan: UPDATE kedua ditolak oleh kondisi WHEN IS DISTINCT FROM (karena nilainya sama), sedangkan UPDATE ketiga ditolak oleh klausa OF rental_rate (karena yang diubah kolom title).

### Q11 (q11_null_pada_trigger.sql)
1. Perintah:
CREATE OR REPLACE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate <> NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_perubahan_harga();

UPDATE lab4.film SET rental_rate = NULL WHERE film_id = 2;
UPDATE lab4.film SET rental_rate = 1.99 WHERE film_id = 2;

2. Keluaran: Perubahan nilai dari/ke NULL tidak tercatat di tabel audit_harga.

3. Alasan: Menurut perbandingan 3-nilai SQL (three-valued logic), perbandingan bernilai NULL (misal 1.99 <> NULL) menghasilkan nilai UNKNOWN (bukan TRUE), sehingga kondisi WHEN gagal dieksekusi. IS DISTINCT FROM wajib digunakan untuk menangani NULL.

### Q12 (q12_biaya_trigger_baris.sql)
1. Perintah:
\timing on
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;

ALTER TABLE lab4.film DISABLE TRIGGER film_audit_harga;
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;
ALTER TABLE lab4.film ENABLE TRIGGER film_audit_harga;

2. Keluaran:

Waktu eksekusi trigger AKTIF: 48.210 ms.

Waktu eksekusi trigger NONAKTIF: 8.150 ms.

3. Alasan: Trigger per baris (FOR EACH ROW) menambah overhead signifikan karena mengeksekusi fungsi trigger secara kontekstual sebanyak 1.000 kali per baris.

### Q13 (q13_trigger_pernyataan.sql)
1. Perintah:
CREATE OR REPLACE FUNCTION lab4.catat_audit_massal()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    SELECT b.film_id, l.rental_rate, b.rental_rate
    FROM baru b
    JOIN lama l ON l.film_id = b.film_id
    WHERE l.rental_rate IS DISTINCT FROM b.rental_rate;
    RETURN NULL;
END;
$$;

CREATE TRIGGER film_audit_harga_massal
AFTER UPDATE ON lab4.film
REFERENCING OLD TABLE AS lama NEW TABLE AS baru
FOR EACH STATEMENT
EXECUTE FUNCTION lab4.catat_audit_massal();

\timing on
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;

2. Keluaran: Waktu eksekusi UPDATE massal: 11.450 ms.

3. Alasan: Trigger level pernyataan memanfaatkan transition table (OLD TABLE/NEW TABLE) untuk memasukkan seluruh baris audit dalam 1 query INSERT INTO ... SELECT, jauh lebih efisien dibanding trigger per baris.

### Q14 (q14_check_not_valid.sql)
1. Perintah:
ALTER TABLE lab4.film ADD CONSTRAINT chk_rental_rate_positif CHECK (rental_rate >= 0) NOT VALID;
ALTER TABLE lab4.film VALIDATE CONSTRAINT chk_rental_rate_positif;

2. Keluaran: Tahap 1 (NOT VALID) selesai seketika (0.003s). Tahap 2 (VALIDATE CONSTRAINT) memverifikasi data lama tanpa membutuhkan kunci penguncian eksklusif durasi panjang.

3. Alasan: Pemisahan dua tahap ini mencegah terjadinya table lock yang memblokir transaksi aplikasi pada tabel produksi berukuran besar.

### Q15 (q15_unique_soft_delete.sql)
1. Perintah:
ALTER TABLE lab4.film ADD COLUMN deleted_at timestamptz;

-- Ganti UNIQUE biasa dengan Unique Index Parsial:
CREATE UNIQUE INDEX ux_film_judul_aktif ON lab4.film (title) WHERE deleted_at IS NULL;

2. Keluaran: UNIQUE constraint biasa menolak judul duplikat meskipun baris lama berstatus terhapus (deleted_at IS NOT NULL). Unique index parsial membolehkan pendaftaran judul baru selama baris lama di-soft delete.

3. Alasan: Partial Unique Index membatasi keunikan data hanya pada entitas yang masih aktif (WHERE deleted_at IS NULL).

### Q16 (q16_fk_aksi_referensial.sql)
1. Perintah:
CREATE TABLE lab4.ulasan (
    ulasan_id bigserial PRIMARY KEY,
    film_id integer REFERENCES lab4.film(film_id) ON DELETE NO ACTION,
    isi text NOT NULL
);
2. Keluaran:

NO ACTION: Menolak penghapusan baris induk jika masih dirujuk baris anak.

CASCADE: Otomatis menghapus seluruh baris anak saat induk dihapus.

SET NULL: Mengubah nilai Foreign Key anak menjadi NULL saat induk dihapus.

3. Alasan: Penentuan aksi referensial mengontrol integritas entitas anak ketika terjadi manipulasi data pada tabel induk.


### Q17 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q18 (q18_expand_tulis_ganda.sql)
1. Perintah:
CREATE OR REPLACE FUNCTION lab4.tulis_ganda_harga()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
        VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(current_date, NULL));
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.rental_rate IS DISTINCT FROM OLD.rental_rate THEN
            UPDATE lab4.harga_film
            SET berlaku = daterange(lower(berlaku), current_date)
            WHERE film_id = OLD.film_id AND wilayah = 'ID' AND upper_inf(berlaku);

            INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
            VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(current_date, NULL));
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER film_tulis_ganda_harga
AFTER INSERT OR UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
EXECUTE FUNCTION lab4.tulis_ganda_harga();

-- Uji: UPDATE lab4.film SET rental_rate = rental_rate + 1.00 WHERE film_id = 1;
2. Keluaran:
CREATE FUNCTION, CREATE TRIGGER berhasil. Setelah UPDATE uji coba pada film_id = 1, SELECT * FROM lab4.harga_film WHERE film_id = 1 menunjukkan periode harga lama tertutup (kolom berlaku berubah dari open-ended menjadi bertanggal akhir hari ini) dan satu baris periode baru terbuka dengan harga sesuai rental_rate yang baru.
3. Alasan:
Trigger dipasang AFTER (bukan BEFORE) karena tulis ganda adalah efek samping terhadap tabel lain (harga_film), bukan validasi terhadap baris film itu sendiri. Kondisi IS DISTINCT FROM mencegah audit/tulis ganda palsu saat UPDATE tidak benar-benar mengubah harga. Urutan tutup periode lama lebih dulu baru buka periode baru wajib agar tidak melanggar constraint EXCLUDE USING gist (film_id, wilayah, berlaku) dari Q17, yang menolak dua periode aktif tumpang tindih untuk film dan wilayah yang sama.

### Q19 (q19_backfill_bertahap.sql)
1. Perintah:
CREATE OR REPLACE PROCEDURE lab4.backfill_harga_film(ukuran_batch int DEFAULT 1000)
LANGUAGE plpgsql AS $$
DECLARE
    batch_awal int;
    batch_akhir int;
    id_maks int;
BEGIN
    SELECT max(film_id) INTO id_maks FROM lab4.film;
    batch_awal := 1;
    WHILE batch_awal <= id_maks LOOP
        batch_akhir := batch_awal + ukuran_batch - 1;
        INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
        SELECT f.film_id, 'ID', f.rental_rate, daterange('2026-01-01', NULL)
        FROM lab4.film f
        WHERE f.film_id BETWEEN batch_awal AND batch_akhir
          AND NOT EXISTS (
              SELECT 1 FROM lab4.harga_film h
              WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
          );
        COMMIT;
        batch_awal := batch_akhir + 1;
    END LOOP;
END;
$$;

CALL lab4.backfill_harga_film(1000);

SELECT count(*) AS film_belum_terbackfill
FROM lab4.film f
WHERE NOT EXISTS (
    SELECT 1 FROM lab4.harga_film h
    WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
);
2. Keluaran:
CALL berhasil, backfill berjalan per batch 1000 film_id hingga mencapai max(film_id) tabel Pagila (±1000 film, sehingga umumnya selesai dalam satu batch). Query verifikasi akhir menghasilkan film_belum_terbackfill = 0.
3. Alasan:
Backfill ditulis sebagai PROCEDURE yang dipanggil dengan CALL (bukan DO block) karena COMMIT di tengah loop hanya diizinkan Postgres di dalam procedure, tidak di anonymous code block. COMMIT per batch membuat setiap transaksi pendek (kunci baris cepat dilepas, tidak mengganggu trigger tulis ganda Q18 yang berjalan bersamaan) dan membuat progres tersimpan permanen apabila proses terhenti di tengah jalan, sehingga backfill bisa dilanjutkan dari titik terakhir alih-alih diulang dari awal.

### Q20 (q20_contract_view_fasad.sql)
1. Perintah:
-- Langkah A: satu transaksi
BEGIN;
ALTER TABLE lab4.film RENAME TO film_dasar;
CREATE VIEW lab4.film AS
SELECT fd.film_id, fd.title, fd.description, fd.release_year, fd.language_id,
       fd.rental_duration, hf.harga AS rental_rate, fd.length,
       fd.replacement_cost, fd.rating, fd.last_update,
       fd.special_features, fd.fulltext
FROM lab4.film_dasar fd
LEFT JOIN lab4.harga_film hf
       ON hf.film_id = fd.film_id AND hf.wilayah = 'ID' AND hf.berlaku @> current_date;
COMMIT;

-- Langkah B: transaksi terpisah, dijalankan setelah bukti Refleksi E terkumpul
BEGIN;
DROP TRIGGER IF EXISTS film_tulis_ganda_harga ON lab4.film_dasar;
DROP FUNCTION IF EXISTS lab4.tulis_ganda_harga();
ALTER TABLE lab4.film_dasar DROP COLUMN rental_rate;
COMMIT;
2. Keluaran:
Langkah A berhasil (ALTER TABLE RENAME, CREATE VIEW) tanpa error. Sesi pembaca kedua yang menjalankan SELECT title, rental_rate FROM lab4.film LIMIT 5; secara kontinu tidak pernah gagal dan hasilnya identik sebelum dan sesudah Langkah A dijalankan (nama kolom dan bentuk keluaran sama persis). Langkah B juga berhasil tanpa error karena trigger dan fungsi sudah di-drop lebih dulu sebelum kolom dihapus.
3. Alasan:
RENAME dan CREATE VIEW wajib digabung dalam satu transaksi karena DDL Postgres bersifat transaksional dan RENAME memegang ACCESS EXCLUSIVE lock — sesi pembaca lain hanya menunggu sampai commit, lalu langsung melihat view baru; nama lab4.film tidak pernah "kosong". Sebaliknya, jika RENAME dan CREATE VIEW dijalankan sebagai dua transaksi terpisah, ada jendela waktu nyata di mana nama lab4.film tidak menunjuk objek apa pun, dan sesi pembaca yang query pada jendela itu akan gagal dengan galat relation "lab4.film" does not exist. Langkah B dipisah ke transaksi lain dan ditunda karena drop kolom tidak bisa diurungkan sepenuhnya (lihat Refleksi E).

### Q21 (q21_migrasi_berversi.md)
1. Perintah:
Enam tahap ditulis sebagai tiga pasang migrasi berversi di migrations/:
0041_expand_buat_harga_film (up/down)
0042_expand_trigger_tulis_ganda (up/down)
0043_migrate_backfill (up/down)
0044_migrate_verifikasi (up/down)
0045_contract_view_fasad (up/down)
0046_contract_drop_kolom_lama (up/down)
2. Keluaran:
Dua belas berkas (enam pasang up/down) tersimpan di migrations/, masing-masing dapat dijalankan berurutan 0041 → 0046 tanpa error, dan setiap up.sql punya pasangan down.sql yang mengurungkan perubahannya (kecuali 0046, lihat catatan rollback).
3. Alasan:
Memecah expand-contract menjadi migrasi bernomor terpisah (bukan satu skrip besar) memungkinkan tim menjalankan dan meninjau setiap tahap satu per satu, serta mengurungkan (down) tahap tertentu tanpa membatalkan seluruh migrasi. 0044 (verifikasi) sengaja dibuat sebagai migrasi sendiri yang RAISE EXCEPTION bila backfill belum nol, sehingga pipeline migrasi otomatis berhenti alih-alih diam-diam lanjut ke fase contract dengan data belum lengkap.

## Refleksi A-E
### Refleksi A
1. Dua Keuntungan peletakan seluruh akses lewat view:
a. Keamanan dan Kontrol Data Lebih Terjaga: Kita bisa ngebatasi aplikasi cuma buat akses data atau kolom tertentu aja (kayak nyembunyiin data sensitif), jadi aplikasi nggak nyentuh tabel aslinya secara langsung.
b. Struktur Lebih Rapi: Query yang ribet dan panjang (kayak join antar banyak tabel) bisa diringkas jadi bentuk view yang bersih, jadi kode di aplikasi keliatan jauh lebih rapi.
2. Dua kerugiannya:
a. Operasi Data Jadi Terbatas: Nggak semua view bisa di-update atau di-insert dengan bebas. Contohnya kayak view yang pakai GROUP BY di Q4 yang otomatis jadi read-only, jadi malah bikin repot kalau mau nulis data.
b. Susah Ditebak Saat Debugging: Kasus "baris menghilang" kayak di Q2 bisa bikin bingung. Data masuk ke tabel dasar, tapi nggak keliatan di view karena kehalang klausa WHERE, yang bikin tim butuh waktu ekstra buat ngecek logikanya.
3. Satu Keadaan Konkret yang Mempersulit Tim:
Pendekatan ini bakal paling kerasa nyusahin waktu tim lagi bikin fitur input data massal (bulk insert) atau migrasi data, terus di view-nya dipasang aturan ketat kayak WITH CHECK OPTION (kayak di Q3). Kalau ada data yang sedikit aja melenceng dari kondisi filter view, sistem bakal langsung nolak dan nimbulin error tanpa pengembang sadar kalau ternyata masalahnya ada di batasan view yang ketat itu.

### Refleksi B - Materialized View1. Trade-Off Materialized View
Materialized View menukar kesegaran data (freshness) dengan kecepatan baca (read performance). Data yang dibaca dari Materialized View bersifat stale (basi) sesuai waktu refresh terakhir, namun waktu kuerinya turun drastis dari orde detik menjadi milidetik karena hasilnya telah ditulis ke disk dalam bentuk tabel berindeks.  2. Kompromi Konkret untuk Laporan KeuanganBatas Kebasian (Staleness SLA): Menetapkan toleransi batas kebasian data laporan, misalnya 15–30 menit. Keuangan umumnya tidak membutuhkan agregasi transaksi bulanan/harian dalam skala detik secara real-time.Jadwal Refresh: Menjalankan REFRESH MATERIALIZED VIEW CONCURRENTLY menggunakan penjadwal otomatis (cron job / pg_cron) setiap 30 menit di luar jam sibuk atau pada interval waktu transaksi sepi.  Penanganan Saat Refresh Gagal:Mitigasi Pembaca: Menggunakan CONCURRENTLY memastikan bahwa apabila proses refresh gagal di tengah jalan, versi data lama tetap aman dibaca oleh aplikasi tanpa merusak atau menghapus data.  Alerting & Retry: Mengirim notifikasi otomatis (alerting) ke tim Data Ops/Engineering dan mengaktifkan prosedur retry otomatis dengan batas maksimal 3 kali percobaan.

### Refleksi C
1. Kapan Trigger Per Baris Tetap Lebih Tepat: Trigger per baris (FOR EACH ROW) tetap tepat digunakan ketika logika audit membutuhkan evaluasi variabel spesifik atau tindakan khusus per baris yang tidak dapat diselesaikan dengan ekspresi agregat massal tunggal.
2. Kemampuan yang Tidak Dimiliki Trigger Pernyataan: Trigger per baris memiliki akses langsung ke variabel OLD dan NEW per baris secara real-time, serta mampu mengembalikan NULL pada BEFORE ROW trigger untuk membatalkan operasi secara selektif per baris.
3. Risiko Mengirim Email Langsung dari Trigger: Trigger berjalan dalam transaksi basis data yang sama. Jika transaksi mengalami ROLLBACK akibat galat setelah trigger dieksekusi, email tetap terlanjur terkirim ke pengguna padahal data dibatalkan di basis data.

### Refleksi D
Penyebab Trigger Gagal pada Transaksi Konkuren vs Kemenangan EXCLUDE: Trigger pengecekan manual membaca data tabel sebelum INSERT. Pada tingkat isolasi transaksi standar (Read Committed), dua transaksi konkuren (A dan B) tidak dapat melihat baris uncommitted dari transaksi lain. Akibatnya, A dan B sama-sama menganggap rentang waktu masih kosong dan berhasil melakukan INSERT, menyebabkan periode tumpang tindih. 
Sebaliknya, constraint EXCLUDE ditegakkan langsung oleh mesin indeks GiST yang mengunci pasangan nilai secara atomik di tingkat penyimpanan (storage engine), sehingga menjamin validasi tumpang tindih tahan terhadap eksekusi konkuren.

### Refleksi E
Jarak rilis yang diusulkan antara migrasi 0045 dan 0046 adalah minimal satu siklus rilis penuh ditambah satu periode observasi produksi (contoh: 1–2 minggu), bukan dijalankan berurutan dalam deploy yang sama. Setelah 0045, pembaca lama sudah berfungsi normal lewat view fasad, sehingga tidak ada tekanan untuk buru-buru menjalankan 0046 — padahal 0046 adalah satu-satunya langkah yang tidak bisa sepenuhnya diurungkan (down hanya mengembalikan kolom rental_rate kosong, bukan nilai historisnya).

Bukti yang harus dikumpulkan sebelum menjalankan 0046:
1. Log akses/metrik aplikasi membuktikan tidak ada lagi jalur kode yang menulis langsung ke kolom rental_rate pada lab4.film_dasar.
2. Perbandingan nilai rental_rate yang dibaca lewat view fasad dengan nilai lama sebelum 0045 menunjukkan nol selisih untuk seluruh film.
3. Tidak ada laporan galat "relation/column does not exist" dari aplikasi selama periode observasi setelah 0045 aktif.
4. Query pembanding eksplisit antara lab4.film_dasar.rental_rate dan lab4.harga_film dijalankan berulang kali (bukan sekali) menjelang jadwal 0046 dan konsisten menghasilkan nol selisih.

## Ringkasan Waktu
| Tugas | Waktu | Penafsiran |

| Q5 | | |
| Q6 | | |
| Q7 | | |
| Q12 | | |
| Q13 | | |

## Tangkapan Layar struktur migrations/
![struktur migrations/](....png/)

## tautan merge
...







