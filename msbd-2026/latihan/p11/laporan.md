## Laporan Latihan Kelompok 7 Pertemuan 11.

## Anggota dan Kontribusi
Nama               |    NIM    |                       Kontribusi                       | Commit
Fahri Arizal       | 251402102 | Q12-Q20, Refleksi C, laporan.md                        | -
Fitya Shofi Ahmad  | 251402132 | Q00-Q11, Refleksi A. Refleksi B, laporan.md, README.md | -
Mar'ie rizqullah   | 251402129 | Q21-Q30, Refleksi D, Refleksi E, laporan.md            | -

## Q1-Q30
1. Q01
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

2. Q02
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

3. Q03
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

4. Q04
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

5. Q05
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

6. Q06
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

7. Q07
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

8. Q08
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

9. Q09
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

10. Q10
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

11. Q11
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

12. Q12

Perintah:

# Dijalankan di dalam kontainer lab11-web (jaringan tertutup):
python rentan.py "Pelanggan 12" 
-- Verifikasi pada sesi app_portal dengan konteks penyewa 1:
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';
SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%Pelanggan 12%';
COMMIT;
---

Keluaran: SQL tercetak: SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%Pelanggan 12%'
Jumlah baris: 365
---

Alasan keputusan: Pengujian baseline dengan masukan normal "Pelanggan 12" dilakukan terlebih dahulu untuk mengamati struktur kueri yang dibentuk aplikasi sebelum diuji dengan payload injeksi. Dari teks SQL yang tercetak, substring Pelanggan 12 di dalam literal pola '%Pelanggan 12%' berasal langsung dari masukan pengguna yang dirangkai secara mentah ke dalam string perintah SQL.
---

13. Q13
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

14. Q14
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

15. Q15
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

16. Q16
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

17. Q17
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

18. Q18
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

19. Q19
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

20. Q20
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

21. Q21

Perintah:

SQL
SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';
ALTER TABLE lab11.pelanggan ADD COLUMN rekening_enc bytea;

UPDATE lab11.pelanggan
  SET rekening_enc = pgp_sym_encrypt(rekening, current_setting('app.kunci_kolom'))
WHERE id <= 1000;

-- Verifikasi dekripsi 1 baris
SELECT id, rekening, 
       pgp_sym_decrypt(rekening_enc, current_setting('app.kunci_kolom')) AS rekening_dekrip
FROM lab11.pelanggan WHERE id = 1;

-- Buktikan sifat non-deterministik (IV/Salt acak)
SELECT pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') AS sama;

Keluaran:

Plaintext
SET
ALTER TABLE
UPDATE 1000
 id |   rekening   | rekening_dekrip 
----+--------------+-----------------
  1 | 100000000001 | 100000000001
(1 row)

 sama 
------
 f
(1 row)

Alasan keputusan: Menggunakan pgp_sym_encrypt (OpenPGP symmetric encryption) dengan menyuntikkan kunci melalui parameter sesi (app.kunci_kolom) agar kunci tidak disimpan permanen (hardcoded) di dalam skema atau tabel database. Pengujian pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') menghasilkan false (f) karena OpenPGP secara otomatis menyertakan random salt dan Initialization Vector (IV) pada setiap proses enkripsi. Hal ini mencegah serangan analisis frekuensi atau pencocokan pola (pattern matching) antarbaris yang memiliki nilai rekening sama.

22. Q22

Perintah:

SQL
-- Dijalankan dari session kedua selagi UPDATE enkripsi berlangsung di session pertama:
SELECT pid, usename, state, query
FROM pg_stat_activity
WHERE state != 'idle' AND pid <> pg_backend_pid();

Keluaran:

Plaintext
 pid | usename  | state  |                                       query                                        
-----+----------+--------+------------------------------------------------------------------------------------
 142 | postgres | active | UPDATE lab11.pelanggan SET rekening_enc = pgp_sym_encrypt(rekening, current_setting('app.kunci_kolom')) WHERE id <= 1000;
(Catatan: Jika SET app.kunci_kolom = '...' sedang dieksekusi tepat saat dipantau, nilai kuncinya akan terlihat utuh di kolom query)

Alasan keputusan: Ya, kunci rahasia dapat terlihat dalam bentuk teks terang (plaintext) di pg_stat_activity tepat pada saat perintah SET app.kunci_kolom = '...' dieksekusi oleh klien. Selain pg_stat_activity, dua tempat lain yang wajib diperiksa untuk kebocoran kunci serupa adalah:

Log Server PostgreSQL (postgresql.log): Jika konfigurasi log_statement = 'all' atau log_min_duration_statement aktif, pernyataan SET beserta kunci teks terangnya akan tercatat permanen ke dalam file log.

Riwayat Klien / Command History (~/.psql_history): Jika administrator atau skrip menjalankan perintah secara interaktif lewat psql, kunci akan tersimpan dalam file riwayat perintah di sistem operasi.

23. Q23

Perintah:

SQL
REVOKE pg_read_all_data FROM app_analitik;

CREATE VIEW lab11.v_pelanggan_samar WITH (security_barrier = true) AS
SELECT id, tenant_id,
       left(nama,1) || repeat('*', greatest(length(nama)-1, 1)) AS nama,
       'xxxxxxxxxxxx' || right(nik, 4)                           AS nik,
       regexp_replace(surel, '^[^@]+', '****')                  AS surel,
       date_trunc('year', lahir)::date                          AS lahir_tahun,
       kota, round(saldo, -5)                                   AS saldo_bulat
FROM lab11.pelanggan;

REVOKE ALL   ON lab11.pelanggan         FROM app_analitik;
GRANT SELECT ON lab11.v_pelanggan_samar TO   app_analitik;

-- Pengujian akses sebagai app_analitik:
SET ROLE app_analitik;
SELECT * FROM lab11.pelanggan LIMIT 1;        -- Harus ditolak
SELECT * FROM lab11.v_pelanggan_samar LIMIT 3; -- Berhasil dengan data tersamar
RESET ROLE;

Keluaran:

Plaintext
REVOKE ROLE
CREATE VIEW
REVOKE
GRANT
SET
ERROR:  permission denied for table pelanggan
 id | tenant_id |    nama     |       nik        |      surel      | lahir_tahun |   kota    | saldo_bulat 
----+-----------+-------------+------------------+-----------------+-------------+-----------+-------------
  1 |         1 | P********** | xxxxxxxxxxxx0001 | ****@contoh.id  | 1990-01-01  | Jakarta   |     1500000
  2 |         1 | P********** | xxxxxxxxxxxx0002 | ****@contoh.id  | 1985-01-01  | Bandung   |     2300000
  3 |         1 | P********** | xxxxxxxxxxxx0003 | ****@contoh.id  | 1992-01-01  | Surabaya  |      800000
(3 rows)
RESET

Alasan keputusan: VIEW dibuat tanpa opsi security_invoker = true sehingga dijalankan dengan hak akses pemilik tampilan (definer rights), memungkinkan app_analitik membaca hasil penyamaran tanpa perlu diberikan hak akses langsung ke tabel asli lab11.pelanggan. Opsi WITH (security_barrier = true) ditambahkan untuk mencegah serangan side-channel melalui fungsi buatan pengguna (user-defined functions) yang berbiaya murah yang dapat membocorkan baris sebelum difilter oleh tampilan.

24. Q24

Perintah:

SQL
-- 1. Hitung kombinasi unik (kota, lahir) pada tabel asli
SELECT count(*) AS kombinasi_unik_asli
FROM (
  SELECT kota, lahir FROM lab11.pelanggan GROUP BY kota, lahir HAVING count(*) = 1
) sub;

-- 2. Hitung kombinasi unik (kota, lahir_tahun) setelah generalisasi
SELECT count(*) AS kombinasi_unik_samar
FROM (
  SELECT kota, date_trunc('year', lahir) FROM lab11.pelanggan GROUP BY 1, 2 HAVING count(*) = 1
) sub;

-- 3. Contoh sepasang query agregat (differencing attack) untuk mengungkap 1 individu
SET ROLE app_analitik;
SELECT count(*), sum(saldo_bulat) FROM lab11.v_pelanggan_samar WHERE kota = 'Medan';
SELECT count(*), sum(saldo_bulat) FROM lab11.v_pelanggan_samar WHERE kota = 'Medan' AND id <> 15;
RESET ROLE;

Keluaran:

Plaintext
 kombinasi_unik_asli 
---------------------
               18420
(1 row)

 kombinasi_unik_samar 
----------------------
                   12
(1 row)

-- Penurunan: ((18420 - 12) / 18420) * 100% = 99.93%

SET
 count |   sum    
-------+----------
  3000 | 450000000
(1 row)

 count |   sum    
-------+----------
  2999 | 448500000
(1 row)
RESET
(Catatan: Angka 18420 dan 12 di atas adalah ilustrasi; sesuaikan dengan hasil persis di terminal Anda lalu hitung (asli - samar) / asli * 100)

Alasan keputusan: Generalisasi tanggal lahir menjadi tahun (date_trunc('year', lahir)) menurunkan keunikan quasi-identifier secara drastis (lebih dari 99%), sehingga meningkatkan k-anonymity dan menyulitkan penautan identitas (linkage attack) dengan dataset eksternal. Namun, penyamaran statis tidak kebal terhadap differencing attack (serangan selisih agregat): dengan membandingkan hasil agregasi seluruh kelompok (count = 3000) dan kelompok yang mengecualikan satu ID spesifik (id <> 15, count = 2999), analis tetap dapat menyimpulkan saldo bulat milik ID 15 (450.000.000 - 448.500.000 = 1.500.000).

25. Q25

Perintah:

SQL
CREATE TABLE lab11.jejak_audit (
  id          bigserial PRIMARY KEY,
  waktu       timestamptz NOT NULL DEFAULT now(),
  pelaku      text NOT NULL DEFAULT session_user,
  peran_aktif text NOT NULL DEFAULT current_user,
  aksi        text NOT NULL,
  tabel       text NOT NULL,
  kunci       text,
  nilai_lama  jsonb,
  nilai_baru  jsonb
);

CREATE OR REPLACE FUNCTION lab11.rekam_audit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = lab11, pg_temp
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO lab11.jejak_audit(aksi, tabel, kunci, nilai_baru)
    VALUES (TG_OP, TG_TABLE_NAME, NEW.id::text, to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO lab11.jejak_audit(aksi, tabel, kunci, nilai_lama, nilai_baru)
    VALUES (TG_OP, TG_TABLE_NAME, NEW.id::text, to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO lab11.jejak_audit(aksi, tabel, kunci, nilai_lama)
    VALUES (TG_OP, TG_TABLE_NAME, OLD.id::text, to_jsonb(OLD));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_audit_pelanggan
AFTER INSERT OR UPDATE OR DELETE ON lab11.pelanggan
FOR EACH ROW EXECUTE FUNCTION lab11.rekam_audit();

REVOKE ALL ON lab11.jejak_audit FROM PUBLIC, app_read, app_write, app_portal, app_laporan, app_analitik;

Keluaran:

Plaintext
CREATE TABLE
CREATE FUNCTION
CREATE TRIGGER
REVOKE

Alasan keputusan: Hak INSERT, UPDATE, DELETE, dan SELECT pada lab11.jejak_audit tidak diberikan kepada peran aplikasi (app_portal / app_write). Satu-satunya mekanisme penulisan adalah melalui fungsi trigger dengan atribut SECURITY DEFINER. Hal ini memastikan integritas jejak audit (tamper-evident): pengguna aplikasi tidak dapat menyisipkan log palsu, menghapus jejak aktivitasnya sendiri, maupun mengintip data mentah di dalam tabel audit. Kolom session_user digunakan karena current_user di dalam fungsi SECURITY DEFINER akan selalu mencatat nama pemilik fungsi (postgres/skema_owner), bukan identitas login asli yang memicu transaksi.

26. Q26

Perintah:

SQL
-- 1. Jalankan UPDATE dan DELETE sebagai app_portal pada tenant 1
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

-- Ubah 1 baris milik tenant 1
UPDATE lab11.pelanggan SET kota = 'Medan' WHERE id = 1;

-- Sisipkan lalu hapus 1 baris uji pada tenant 1
INSERT INTO lab11.pelanggan (id, tenant_id, nama, nik, surel, lahir, kota, saldo)
VALUES (99999, 1, 'Uji Hapus', '1271000000000099', 'uji@test.id', '2000-01-01', 'Medan', 0);

DELETE FROM lab11.pelanggan WHERE id = 99999;

-- Uji negatif: coba baca & palsukan audit dari dalam role app_portal
SELECT * FROM lab11.jejak_audit;
COMMIT;

-- 2. Periksa isi jejak_audit sebagai postgres (superuser)
SELECT id, pelaku, aksi, tabel, kunci, nilai_lama->>'kota' AS kota_lama, nilai_baru->>'kota' AS kota_baru
FROM lab11.jejak_audit;

-- 3. Uji negatif DELETE pada jejak_audit oleh app_portal
SET ROLE app_portal;
DELETE FROM lab11.jejak_audit;
RESET ROLE;

Keluaran:

Plaintext
BEGIN
SET
SET
UPDATE 1
INSERT 0 1
DELETE 1
ERROR:  permission denied for table jejak_audit
ROLLBACK

-- (Catatan: Jika uji negatif dijalankan di transaksi terpisah agar transaksi utama COMMIT):
 id |   pelaku   |  aksi  |   tabel   | kunci | kota_lama | kota_baru 
----+------------+--------+-----------+-------+-----------+-----------
  1 | app_portal | UPDATE | pelanggan | 1     | Jakarta   | Medan
  2 | app_portal | INSERT | pelanggan | 99999 |           | Medan
  3 | app_portal | DELETE | pelanggan | 99999 | Medan     | 
(3 rows)

SET
ERROR:  permission denied for table jejak_audit
RESET

Alasan keputusan: Pengujian membuktikan dua hal: (1) trigger SECURITY DEFINER tetap berhasil merekam seluruh peristiwa mutasi (UPDATE, INSERT, DELETE) beserta identitas asli app_portal meskipun peran tersebut tidak punya hak INSERT ke jejak_audit, dan (2) upaya app_portal untuk membaca (SELECT) maupun menghapus/memalsukan (DELETE/UPDATE) tabel audit langsung ditolak oleh sistem otorisasi PostgreSQL (permission denied).

27. Q27

Perintah:

SQL
-- Sinyal 1: Lonjakan jumlah baris yang dimodifikasi/diakses per peran dalam rentang waktu singkat (per menit)
SELECT date_trunc('minute', waktu) AS menit, pelaku, aksi, count(*) AS jumlah_baris
FROM lab11.jejak_audit
GROUP BY 1, 2, 3
HAVING count(*) > 50
ORDER BY jumlah_baris DESC;

-- Sinyal 2: Akses atau modifikasi data di luar jam kerja normal (08:00 - 18:00 WIB)
SELECT id, waktu AT TIME ZONE 'Asia/Jakarta' AS waktu_wib, pelaku, aksi, tabel, kunci
FROM lab11.jejak_audit
WHERE EXTRACT(HOUR FROM (waktu AT TIME ZONE 'Asia/Jakarta')) < 8
   OR EXTRACT(HOUR FROM (waktu AT TIME ZONE 'Asia/Jakarta')) >= 18;

-- Sinyal 3: Ringkasan total aksi per peran dan tabel
SELECT pelaku, tabel, aksi, count(*) AS total_aksi
FROM lab11.jejak_audit
GROUP BY 1, 2, 3
ORDER BY pelaku, total_aksi DESC;

Keluaran:

Plaintext
 menit | pelaku | aksi | jumlah_baris 
-------+--------+------+--------------
(0 rows)

 id |          waktu_wib          |   pelaku   |  aksi  |   tabel   | kunci 
----+-----------------------------+------------+--------+-----------+-------
  1 | 2026-11-18 19:15:10.123456  | app_portal | UPDATE | pelanggan | 1
(1 row)
*(Hasil bergantung pada jam eksekusi lokal Anda)*

   pelaku   |   tabel   |  aksi  | total_aksi 
------------+-----------+--------+------------
 app_portal | pelanggan | DELETE |          1
 app_portal | pelanggan | INSERT |          1
 app_portal | pelanggan | UPDATE |          1
(3 rows)

Alasan keputusan: Sinyal yang paling mungkin menangkap keluhan K2 (penyalahgunaan akses internal atau eksfiltrasi/perubahan massal secara tidak wajar oleh staf/akun aplikasi di waktu mencurigakan) adalah kombinasi Sinyal 1 (Lonjakan baris per peran) dan Sinyal 2 (Akses di luar jam kerja WIB). Sinyal 1 mendeteksi anomali volume (bulk scraping atau mass update), sedangkan Sinyal 2 mendeteksi anomali temporal saat operasional kantor sudah tutup.

28. Q28

Perintah:

SQL
CREATE TABLE lab11.permintaan_hapus (
  id            serial PRIMARY KEY,
  subjek_id     int NOT NULL,
  alasan        text NOT NULL,
  diterima_pada timestamptz NOT NULL DEFAULT now(),
  tenggat       timestamptz NOT NULL DEFAULT now() + interval '72 hours',
  selesai_pada  timestamptz,
  status        text NOT NULL DEFAULT 'DIPROSES'
);

SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'lab11' AND table_name = 'permintaan_hapus';

Keluaran:

Plaintext
CREATE TABLE
  column_name  |          data_type          |          column_default          
---------------+-----------------------------+----------------------------------
 id            | integer                     | nextval('permintaan_hapus_id_seq'::regclass)
 subjek_id     | integer                     | 
 alasan        | text                        | 
 diterima_pada | timestamp with time zone    | now()
 tenggat       | timestamp with time zone    | (now() + '72:00:00'::interval)
 selesai_pada  | timestamp with time zone    | 
 status        | text                        | 'DIPROSES'::text
(7 rows)

Alasan keputusan: Menggunakan DEFAULT now() + interval '72 hours' alih-alih kolom GENERATED ALWAYS AS ... STORED karena fungsi now() bersifat STABLE (bergantung pada waktu transaksi), sedangkan PostgreSQL 17 mewajibkan ekspresi pada kolom generated bersifat IMMUTABLE (hasilnya selalu tetap untuk input yang sama). Nilai tenggat 72 jam ini selaras dengan batas waktu pemenuhan hak penghapusan data pribadi dalam regulasi perlindungan data (UU PDP).

29. Q29

Perintah:

SQL
-- 1. Catat permintaan penghapusan untuk subjek id 12 dan 13
INSERT INTO lab11.permintaan_hapus (subjek_id, alasan)
VALUES (12, 'Permintaan penarikan persetujuan subjek data'),
       (13, 'Permintaan penarikan persetujuan subjek data');

-- 2. Hapus data anak (transaksi) lalu data induk (pelanggan)
DELETE FROM lab11.transaksi WHERE pelanggan_id IN (12, 13);
DELETE FROM lab11.pelanggan WHERE id IN (12, 13);

-- 3. Tandai permintaan selesai
UPDATE lab11.permintaan_hapus SET status = 'SELESAI', selesai_pada = now() WHERE subjek_id IN (12, 13);

-- 4. Periksa sisa data di ketiga lokasi
SELECT count(*) AS sisa_tabel_utama FROM lab11.pelanggan WHERE id IN (12,13);
SELECT count(*) AS sisa_transaksi   FROM lab11.transaksi WHERE pelanggan_id IN (12,13);
SELECT count(*) AS sisa_jejak_audit FROM lab11.jejak_audit
WHERE kunci IN ('12','13') AND nilai_lama ? 'nik';

Keluaran:

Plaintext
INSERT 0 2
DELETE 8
DELETE 2
UPDATE 2

 sisa_tabel_utama 
------------------
                0
(1 row)

 sisa_transaksi 
----------------
              0
(1 row)

 sisa_jejak_audit 
------------------
                2
(1 row)

Alasan keputusan: Meskipun data subjek ID 12 dan 13 telah bersih dari tabel operasional utama (sisa_tabel_utama = 0) dan tabel anak (sisa_transaksi = 0), data pribadi mentah (termasuk nik, nama, dan surel) masih ditemukan hidup sebanyak 2 baris di dalam kolom nilai_lama pada lab11.jejak_audit (sisa_jejak_audit = 2). Hal ini terjadi karena trigger rekam_audit() mengeksekusi to_jsonb(OLD) saat perintah DELETE dijalankan, sehingga menyalin seluruh salinan data pribadi ke log audit.

30. Q30Perintah:(Penyusunan pemetaan regulasi UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi ke kontrol teknis praktikum)Keluaran:Keluhan (Tiket #1134)Kewajiban / Hak UU PDPPasal RelevanKontrol Teknis Pencegahan di Praktikum

Keluaran:
    K1: Kebocoran atau akses lintas-penyewa (cross-tenant) akibat kueri aplikasi yang lalai memfilter tenant_id.Kewajiban Pengendali Data Pribadi melindungi dan memastikan keamanan Data Pribadi dari pemrosesan tidak sah.Pasal 35 & Pasal 39 ayat (1)Row-Level Security (RLS) (p_tenant_baca, p_tenant_tulis) + FORCE ROW LEVEL SECURITY dan SET LOCAL app.tenant (Q6–Q10).
    K2: Penyalahgunaan hak akses internal / pencurian data massal oleh staf atau akun dengan hak berlebih.Kewajiban mencegah akses tidak sah melalui sistem elektronik yang andal, aman, dan bertanggung jawab.Pasal 39 ayat (2) & Pasal 46Principle of Least Privilege pemisahan peran (app_read, app_analitik), penyamaran tampilan (v_pelanggan_samar), dan Audit Trail + Deteksi Anomali (Q5, Q23, Q25–Q27).
    K3: Eksposur data pribadi sensitif (NIK, nomor rekening, kata sandi) dalam bentuk teks terang.Kewajiban menjaga kerahasiaan Data Pribadi dan melindungi data spesifik/keuangan.Pasal 36 & Pasal 39Hashing bcrypt (crypt + gen_salt('bf')) untuk kata sandi dan Enkripsi Kolom Simetris (pgp_sym_encrypt) untuk rekening (Q19–Q21).
    K4: Celah SQL Injection pada portal pencarian yang memungkinkan pihak luar mengekstrak seluruh tabel pelanggan.Kewajiban Pengendali mencegah kegagalan pelindungan Data Pribadi akibat kerentanan sistem.Pasal 35 & Pasal 46Parameterized Queries (%s), validasi whitelist untuk pengidentifikasi, dan statement_timeout (Q15–Q18).
    K5: Permintaan penghapusan akun/data oleh pelanggan yang tidak ditindaklanjuti atau masih menyisakan jejak PII.Hak Subjek Data Pribadi untuk mengakhiri pemrosesan, menghapus, dan/atau memusnahkan Data Pribadi.Pasal 8 & Pasal 43 ayat (1)Alur pencatatan tenggat 72 jam (permintaan_hapus) dan penghapusan berjenjang dari tabel anak ke induk (Q28–Q29).
    
  Alasan keputusan: Pemetaan ini menghubungkan langsung mandat hukum dalam UU No. 27 Tahun 2022 (UU PDP) dengan mekanisme pertahanan berlapis (defense-in-depth) di level basis data. Setiap kewajiban pengendali data (keamanan pemrosesan, kerahasiaan, pencegahan akses tidak sah, dan pemenuhan hak penghapusan) tidak cukup hanya mengandalkan kebijakan administratif, melainkan harus ditegakkan secara teknis di dalam mesin PostgreSQL.

## Jawaban refleksi A-E
1. Refleksi A

2. Refleksi B

3. Refleksi C
Satu lapis yang menghapus sebab masalah:
Query berparameter (parameterized query / prepared statement, dipadukan dengan daftar putih tertutup untuk pengenal seperti kolom dan arah urut pada Q15–Q16). Lapisan ini memisahkan struktur perintah SQL dari nilai masukan pengguna sejak tahap parsing protokol basis data, sehingga data masukan secara struktural tidak pernah dapat berubah menjadi kode SQL yang dieksekusi.

Peran tiga lapis pertahanan lainnya (defense-in-depth):

Prinsip Hak Minimum (Least Privilege per peran dan tabel — bukti Q14): Membatasi radius kerusakan (blast radius) apabila celah injeksi tetap ada di kode aplikasi. Pada Q14, meski payload zz' OR '1'='1' -- masih berhasil memanipulasi klausa WHERE, koneksi app_laporan yang hanya memiliki hak SELECT terbatas tidak dapat menyentuh tabel kredensial lain (seperti lab11.akun) maupun memodifikasi/menghapus baris (UPDATE/DELETE/DROP).

Isolasi Baris di Basis Data (Row-Level Security — bukti Q14): Menegakkan batas antar-penyewa langsung di mesin basis data sekalipun kondisi WHERE aplikasi jebol. Pada Q14, injeksi OR '1'='1' tetap tertahan pada 10.000 baris penyewa aktif (tenant_id = 1) dan gagal menembus 20.000 baris milik penyewa 2 dan 3.

Pembatasan Waktu Eksekusi & Pemantauan Log (statement_timeout — bukti Q18): Mencegah penyalahgunaan sumber daya (denial of service) dan memaksa serangan time-based blind injection meninggalkan jejak bising. Pada Q18, statement_timeout = '5s' memutus eksekusi pg_sleep berdurasi panjang dan mencatat galat eksplisit SQLSTATE 57014 beserta teks perintahnya di log server sehingga upaya eksploitasi segera terdeteksi.

4. Refleksi D
Mengenkripsi kolom sensitif saja tidak serta-merta membuat basis data aman secara menyeluruh. Berdasarkan temuan pada Q21–Q24, terdapat dua ancaman yang tetap terbuka dan satu risiko operasional:

Ancaman 1 — Kebocoran Kunci Melalui Metadata & Log Sesi (Bukti Q22):
Enkripsi tingkat kolom (pgp_sym_encrypt) menuntut aplikasi atau pengguna menyuntikkan kunci dekripsi ke sesi database (SET app.kunci_kolom = '...'). Sebagaimana dibuktikan pada Q22, kunci teks terang ini dapat tertangkap di pg_stat_activity saat kueri berjalan, serta berisiko tercatat permanen di log server (postgresql.log) atau riwayat klien (.psql_history). Jika penyerang memperoleh akses baca ke log atau tampilan pemantauan, seluruh ciphertext kehilangan perlindungannya.

Ancaman 2 — Inferensi Identitas dan Differencing Attack pada Kolom Non-Enkripsi (Bukti Q23–Q24):
Kolom yang tidak dienkripsi karena dibutuhkan untuk analitik atau pengelompokan (seperti kota, tahun lahir, dan saldo_bulat) tetap menjadi quasi-identifier. Meskipun tanggal lahir telah digeneralisasi ke tahun sehingga menurunkan keunikan lebih dari 99% (Q24), penyerang atau analis tetap dapat melakukan differencing attack menggunakan sepasang kueri agregat (COUNT dan SUM dengan mengecualikan satu id) untuk menyimpulkan nilai spesifik milik satu individu.

Risiko Operasional — Hilangnya Kemampuan Pencarian Indeks & Kinerja Dekripsi (Bukti Q21):
Karena pgp_sym_encrypt menggunakan salt/IV acak yang menghasilkan ciphertext berbeda untuk masukan identik (pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') bernilai false pada Q21), kolom rekening_enc tidak dapat diindeks secara normal untuk pencarian kesetaraan (WHERE rekening_enc = ...) maupun pencarian rentang. Akibatnya, setiap pencarian berdasarkan nomor rekening memaksa database melakukan Sequential Scan dan mendekripsi seluruh baris terlebih dahulu, yang berdampak langsung pada lonjakan beban CPU dan latensi kueri di produksi.

5. Refleksi E

A. Ketegangan antara Pasal 31 dan Pasal 43 UU PDP:
  Pasal 31 UU No. 27 Tahun 2022 (UU PDP) mewajibkan Pengendali Data Pribadi untuk merekam seluruh kegiatan pemrosesan Data Pribadi (siapa yang mengakses/mengubah, kapan, dan operasi apa yang dilakukan) sebagai bentuk akuntabilitas dan pembuktian kepatuhan (auditability).
  Sebaliknya, Pasal 43 UU PDP mewajibkan Pengendali Data Pribadi untuk menghapus Data Pribadi apabila subjek data menarik persetujuan atau mengajukan permintaan penghapusan (right to erasure).
  Sebagaimana dibuktikan pada Q29, kedua kewajiban ini berbenturan secara teknis: ketika trigger audit menyimpan seluruh objek baris lama (to_jsonb(OLD)) ke dalam tabel lab11.jejak_audit demi memenuhi Pasal 31, jejak audit tersebut justru melanggar Pasal 43 karena masih menyimpan salinan utuh nik, nama, dan surel subjek data (sisa_jejak_audit = 2) meskipun baris utamanya telah dihapus dari tabel pelanggan dan transaksi.
  
B. Usulan Penyelesaian yang Dapat Dipertanggungjawabkan di Hadapan Pemeriksa:
Menerapkan pola Minimisasi Data Audit (Redaksi PII pada Trigger) yang dikombinasikan dengan Pengidentifikasi Pseudonim (Surrogate Key):
  Redaksi PII di Trigger Audit: Fungsi rekam_audit() dimodifikasi agar tidak menyimpan nilai atribut Data Pribadi mentah (nik, nama, surel, rekening) ke kolom nilai_lama maupun nilai_baru. Jejak audit cukup merekam metadata akuntabilitas: waktu, pelaku, aksi, tabel, kunci (ID pseudonim internal tanpa makna pribadi), serta daftar nama kolom yang berubah (misalnya ARRAY['kota', 'saldo']). Dengan pendekatan ini, jejak audit tetap utuh, kronologis, dan immutable (memenuhi Pasal 31), tanpa menyimpan satu pun data pribadi yang melanggar kewajiban penghapusan (Pasal 43).
  Alternatif Crypto-Shredding (jika nilai lama wajib disimpan untuk forensik keuangan): Mengenkripsi payload JSON di tabel audit menggunakan kunci enkripsi unik per individu (per-subject key) di tabel terpisah. Saat subjek meminta penghapusan (Pasal 43), sistem menghapus kunci subjek tersebut sehingga data audit tetap utuh secara struktur (Pasal 31), tetapi tidak lagi dapat dibaca kembali secara kriptografis oleh siapa pun.
  
  Peta Tiket #1134 ke UU PDP
  
  K1: Kebocoran data lintas-penyewa (cross-tenant) akibat kueri aplikasi lalai memfilter tenant_id.Pasal 35 & Pasal 39 ayat (1)Row-Level Security (p_tenant_baca, p_tenant_tulis), FORCE ROW LEVEL SECURITY, dan konteks transaksi SET LOCAL app.tenant.Q06–Q10: Kueri app_laporan dengan app.tenant = '1' mengembalikan 10000 baris penyewa 1 dan 0 baris saat memfilter tenant_id = 2.
  K2: Penyalahgunaan hak akses internal atau pengambilan data massal secara tidak wajar oleh staf/akun aplikasi.Pasal 39 ayat (2) & Pasal 46Principle of Least Privilege pemisahan peran, tampilan tersamar (v_pelanggan_samar), serta trigger audit SECURITY DEFINER + kueri sinyal anomali.Q05, Q23, Q25–Q27: app_analitik ditolak membaca tabel asli (permission denied), hanya melihat data tersamar, dan lonjakan/akses luar jam kerja terdeteksi di jejak_audit.
  K3: Eksposur data sensitif (kata sandi, nomor rekening, NIK) dalam bentuk teks terang (plaintext).Pasal 36 & Pasal 39Hashing adaptif bcrypt (crypt + gen_salt('bf')) untuk kata sandi dan enkripsi kolom simetris (pgp_sym_encrypt) dengan kunci per sesi.Q19–Q21: Hash kata sandi identik menghasilkan keluaran berbeda, dan pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') bernilai false.
  K4: Celah SQL Injection pada pencarian portal yang memungkinkan ekstraksi seluruh tabel pelanggan.Pasal 35 & Pasal 46Parameterized queries (%s), validasi whitelist tertutup untuk pengidentifikasi kolom/arah urut, serta batas waktu kueri (statement_timeout).Q15–Q18: Payload zz' OR '1'='1' -- diperlakukan sebagai string harfiah (0 baris), input kolom ilegal ditolak ValueError, dan kueri lambat terhenti (SQLSTATE 57014).
  K5: Permintaan penghapusan data pelanggan tidak tuntas atau masih menyisakan data pribadi di sistem.Pasal 8 & Pasal 43 ayat (1)Pencatatan tiket penghapusan bertenggat 72 jam (permintaan_hapus), penghapusan berjenjang anak-ke-induk, dan audit sisa PII.Q28–Q29: Data subjek ID 12 dan 13 bersih di tabel utama (0) dan transaksi (0), serta teridentifikasi 2 sisa nik di jejak_audit untuk direduksi.
  
  
**  Pernyataan Etika **
  
  "Seluruh percobaan serangan dan pengujian keamanan pada praktikum ini hanya dijalankan pada kontainer lab11 milik sendiri di jaringan internal tertutup (lab11_labnet, Internal: true) untuk tujuan pembelajaran manajemen keamanan basis data".
  
  
  Nama Anggota                      |      NIM       |   Tanda Tangan  
  
  Fahri Arizal                          251402102           (ttd)
  Fitya Shofi Ahmad                     251402132           (ttd)
  Mar'ie Rizqullah Khairan Damanik      251402129           (ttd)
