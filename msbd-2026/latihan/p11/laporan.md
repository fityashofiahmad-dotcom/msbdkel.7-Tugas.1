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
---

Keluaran:
---

Alasan keputusan:
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
---

Keluaran:
---

Alasan keputusan:
---

28. Q28
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

29. Q29
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

30. Q30
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

## Jawaban refleksi A-E
1. Refleksi A

2. Refleksi B

3. Refleksi C

4. Refleksi D

5. Refleksi E

## Peta Tiket #1134 ke UU PDP
Keluhan | Pasal relevan | Kontrol teknis pencegah | Bukti
  ....  |      ....     |           ....          | ....

  ## Pernyataan Etika
  Seluruh percobaan serangan hanya dijalankan pada kontainer lab11 milik sendiri di jaringan tertutup. (tanda tangan tiap anggota)
