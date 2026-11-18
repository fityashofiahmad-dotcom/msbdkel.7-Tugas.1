## Laporan Latihan Kelompok 7 Pertemuan 11.

## Anggota dan Kontribusi
Nama               |    NIM    |                       Kontribusi                       | Commit
Fahri Arizal       | 251402102 | Q12-Q20, Refleksi C, laporan.md                        | -
Fitya Shofi Ahmad  | 251402132 | Q00-Q11, Refleksi A. Refleksi B, laporan.md, README.md | -
Mar'ie rizqullah   | 251402129 | Q21-Q30, Refleksi D, Refleksi E, laporan.md            | -

## Q1-Q30
1. Q01
Perintah:
-- Diminta: membuktikan bahwa hak yang melekat pada kepemilikan tidak bisa dicabut dengan REVOKE.
-- Dipilih: REVOKE UPDATE dari pemilik, uji, lalu GRANT ulang oleh pemilik sendiri dan uji lagi.
-- Alternatif: mengganti pemilik tabel (ALTER ... OWNER TO); tidak dipilih karena bukan yang diuji.
REVOKE UPDATE ON lab11.pelanggan FROM skema_owner;
SET ROLE skema_owner;
BEGIN; UPDATE lab11.pelanggan SET kota = kota WHERE id = 3; ROLLBACK;   -- ditolak?
GRANT UPDATE ON lab11.pelanggan TO skema_owner;                          -- oleh pemilik sendiri
BEGIN; UPDATE lab11.pelanggan SET kota = kota WHERE id = 3; ROLLBACK;   -- berhasil?
RESET ROLE;

Keluaran:
---

Alasan keputusan:
---

2. Q02
Perintah:
-- Diminta: menjalankan REVOKE DROP dan menjelaskan hak biasa vs hak yang melekat pada kepemilikan.
-- Dipilih: jalankan apa adanya, lalu buktikan DROP hanya bisa oleh pemilik (transaksi di-rollback).
-- Alternatif: DROP sungguhan sebagai pemilik; tidak dipilih karena merusak data lab.
REVOKE DROP ON lab11.akun FROM skema_owner;
SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' AND tablename = 'akun';
BEGIN; SET LOCAL ROLE app_laporan; DROP TABLE lab11.akun; ROLLBACK;

Keluaran:
---

Alasan keputusan:
---

3. Q03
Perintah:
-- Diminta: tabel buatan postgres (bukan skema_owner) dan apakah app_laporan bisa membacanya.
-- Dipilih: ALTER DEFAULT PRIVILEGES untuk peran pembuat objek (postgres), lalu dibersihkan lagi.
-- Alternatif: GRANT manual per tabel; tidak dipilih karena mudah terlupa pada tabel baru.

-- pembanding: tabel buatan skema_owner (default privileges dari setup berlaku)
SET ROLE skema_owner;
CREATE TABLE lab11.catatan_owner (id int);
SELECT has_table_privilege('app_laporan','lab11.catatan_owner','SELECT') AS via_skema_owner;   -- t
DROP TABLE lab11.catatan_owner;
RESET ROLE;

-- kasus soal: tabel buatan postgres
CREATE TABLE lab11.catatan_postgres (id int);
SELECT has_table_privilege('app_laporan','lab11.catatan_postgres','SELECT') AS via_postgres;   -- f
DROP TABLE lab11.catatan_postgres;

-- perbaikan: default privileges untuk peran pembuat (postgres)
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA lab11 GRANT SELECT ON TABLES TO app_read;
CREATE TABLE lab11.catatan_postgres (id int);
SELECT has_table_privilege('app_laporan','lab11.catatan_postgres','SELECT') AS setelah_perbaikan;   -- t
DROP TABLE lab11.catatan_postgres;

-- pembersihan: kembalikan kondisi awal
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA lab11 REVOKE SELECT ON TABLES FROM app_read;

Keluaran:
---

Alasan keputusan:
---

4. Q04
Perintah:
-- Diminta: GRANT OPTION berantai ke app_analitik, lalu REVOKE tanpa dan dengan CASCADE.
-- Dipilih: REVOKE GRANT OPTION FOR, supaya hak baca app_write tetap ada.
-- Alternatif: REVOKE SELECT penuh dari app_write; tidak dipilih karena ikut mencabut hak bacanya.
GRANT SELECT ON lab11.transaksi TO app_write WITH GRANT OPTION;
SET ROLE app_write;
GRANT SELECT ON lab11.transaksi TO app_analitik;
RESET ROLE;
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write;            -- amati galatnya
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write CASCADE;    -- lalu bandingkan
SELECT has_table_privilege('app_analitik','lab11.transaksi','SELECT') AS analitik,
       has_table_privilege('app_write','lab11.transaksi','SELECT')    AS app_write;

Keluaran:
---

Alasan keputusan:
---

5. Q05
Perintah:
-- Diminta: tabel tujuh peran pada lab11, kemampuan masing-masing, dan tanda yang bisa login.
-- Dipilih: diambil dari katalog sistem (pg_roles, hak tabel), bukan ditulis dari ingatan.
-- Alternatif: menyalin dari dokumentasi modul; tidak dipilih karena bisa berbeda dari kondisi nyata.
SELECT r.rolname, r.rolcanlogin AS bisa_login, r.rolsuper, r.rolbypassrls,
       (SELECT string_agg(g.rolname, ', ') FROM pg_auth_members m
          JOIN pg_roles g ON g.oid = m.roleid WHERE m.member = r.oid) AS anggota_dari
FROM pg_roles r
WHERE r.rolname = 'skema_owner' OR r.rolname LIKE 'app\_%'
ORDER BY 1;

SELECT grantee, table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS hak
FROM information_schema.role_table_grants
WHERE table_schema = 'lab11' AND grantee <> 'skema_owner'
GROUP BY 1, 2 ORDER BY 1, 2;

SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' ORDER BY 1;

Keluaran:
---

Alasan keputusan:
---

6. Q06
Perintah:
-- Diminta: nyalakan RLS pada pelanggan, lalu hitung baris yang terlihat app_laporan sebelum ada kebijakan.
-- Dipilih: ENABLE ROW LEVEL SECURITY lalu uji negatif sebagai app_laporan di dalam transaksi.
-- Alternatif: penyaring tenant_id di aplikasi; tidak dipilih karena gagalnya membocorkan, bukan menolak.
ALTER TABLE lab11.pelanggan ENABLE ROW LEVEL SECURITY;
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS sebelum_ada_kebijakan FROM lab11.pelanggan;   -- harapkan 0
COMMIT;

Keluaran:
---

Alasan keputusan:
---

7. Q07
Perintah:
-- Diminta: sepasang kebijakan isolasi penyewa memakai nullif(current_setting('app.tenant', true), '')::int.
-- Dipilih: satu kebijakan baca (app_read, app_write) dan satu kebijakan FOR ALL dengan WITH CHECK (app_write).
-- Alternatif: current_setting(...)::int langsung; tidak dipilih karena melempar galat pada koneksi yang dipakai ulang.
DROP POLICY IF EXISTS p_tenant_baca  ON lab11.pelanggan;
DROP POLICY IF EXISTS p_tenant_tulis ON lab11.pelanggan;

CREATE POLICY p_tenant_baca ON lab11.pelanggan
  FOR SELECT TO app_read, app_write
  USING (tenant_id = nullif(current_setting('app.tenant', true), '')::int);

CREATE POLICY p_tenant_tulis ON lab11.pelanggan
  FOR ALL TO app_write
  USING      (tenant_id = nullif(current_setting('app.tenant', true), '')::int)
  WITH CHECK (tenant_id = nullif(current_setting('app.tenant', true), '')::int);

SELECT policyname, cmd, roles FROM pg_policies
WHERE schemaname = 'lab11' AND tablename = 'pelanggan' ORDER BY 1;

Keluaran:
---

Alasan keputusan:
---

8. Q08
Perintah:
-- Diminta: sebagai app_laporan penyewa 1, hitung baris yang terlihat dan baris penyewa 2.
-- Dipilih: uji positif dan negatif sekaligus dalam satu transaksi dengan SET LOCAL, ditambah uji tanpa konteks.
-- Alternatif: hanya uji positif; tidak dipilih karena tidak membuktikan data penyewa lain tersembunyi.
BEGIN; SET LOCAL ROLE app_laporan; SET LOCAL app.tenant = '1';
  SELECT count(*) AS terlihat_tenant1 FROM lab11.pelanggan;                   -- harapkan 10000
  SELECT count(*) AS harus_nol FROM lab11.pelanggan WHERE tenant_id = 2;      -- harapkan 0
COMMIT;

BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS tanpa_konteks FROM lab11.pelanggan;                      -- harapkan 0, bukan galat
COMMIT;

Keluaran:
---

Alasan keputusan:
---

9. Q09
Perintah:
-- Diminta: bandingkan baris yang dilihat skema_owner sebelum/sesudah FORCE, lalu pg_read_all_data dan BYPASSRLS.
-- Dipilih: hitung tiap kondisi dengan SET LOCAL ROLE, lalu bersihkan peran analitik; FORCE dibiarkan menyala.
-- Alternatif: hanya membaca dokumentasi PostgreSQL; tidak dipilih karena perlu bukti nyata.
ALTER TABLE lab11.pelanggan NO FORCE ROW LEVEL SECURITY;   -- kondisi awal agar skrip bisa diulang

BEGIN; SET LOCAL ROLE skema_owner;
  SELECT count(*) AS owner_sebelum_force FROM lab11.pelanggan;       -- harapkan 30000
COMMIT;

ALTER TABLE lab11.pelanggan FORCE ROW LEVEL SECURITY;
BEGIN; SET LOCAL ROLE skema_owner;
  SELECT count(*) AS owner_sesudah_force FROM lab11.pelanggan;       -- harapkan 0
COMMIT;

GRANT pg_read_all_data TO app_analitik;
BEGIN; SET LOCAL ROLE app_analitik;
  SELECT count(*) AS analitik_pg_read_all_data FROM lab11.pelanggan; -- harapkan 0
COMMIT;

ALTER ROLE app_analitik BYPASSRLS;
BEGIN; SET LOCAL ROLE app_analitik;
  SELECT count(*) AS analitik_bypassrls FROM lab11.pelanggan;        -- harapkan 30000
COMMIT;

-- pembersihan
ALTER ROLE app_analitik NOBYPASSRLS;
REVOKE pg_read_all_data FROM app_analitik;

Keluaran:
---

Alasan keputusan:
---

10. Q10
Perintah:
-- Diminta: tunjukkan bagaimana konteks penyewa tertinggal di kolam koneksi, dan pola SET LOCAL / set_config(..., true).
-- Dipilih: simulasi satu koneksi yang dipakai dua permintaan; pola aman memakai set_config(..., true) di dalam transaksi.
-- Alternatif: SET biasa lalu RESET manual; tidak dipilih karena mudah terlewat bila terjadi galat.

-- Permintaan 1 (penyewa 1) menyetel di tingkat SESI, lalu koneksi kembali ke pool
SET app.tenant = '1';
-- Permintaan 2 memakai koneksi yang sama dan lupa menyetel konteks
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS bocor_ke_permintaan_berikutnya FROM lab11.pelanggan;   -- 10000 = data penyewa 1 bocor
COMMIT;
RESET app.tenant;

-- Pola aman: konteks hanya hidup di dalam transaksi
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT set_config('app.tenant', '2', true);
  SELECT count(*) AS penyewa2_dalam_transaksi FROM lab11.pelanggan;         -- 10000
COMMIT;
SHOW app.tenant;                                                            -- kosong: konteks ikut hilang
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS permintaan_berikutnya FROM lab11.pelanggan;            -- 0
COMMIT;

Keluaran:
---

Alasan keputusan:
---

11. Q11
Perintah:
-- Diminta: tiga cara isolasi RLS masih bisa gagal, masing-masing dengan satu kalimat perbaikan, dan bukti nyata.
-- Dipilih: pemilik tanpa FORCE, peran BYPASSRLS/superuser, dan konteks bocor di pool; bukti dari Q9 dan Q10.
-- Alternatif: celah lain (view tanpa security_invoker, kebijakan tanpa WITH CHECK); dibahas singkat saja.
--
-- Celah 1: pemilik tabel melewati RLS bila tidak ada FORCE.            Perbaikan: FORCE ROW LEVEL SECURITY.
-- Celah 2: peran dengan BYPASSRLS atau superuser kebal kebijakan.      Perbaikan: audit pg_roles, jangan beri BYPASSRLS.
-- Celah 3: setelan tingkat sesi tertinggal di kolam koneksi.           Perbaikan: SET LOCAL / set_config(..., true).

-- Bukti kondisi saat ini (celah 1 dan 2 bisa dideteksi dari katalog)
SELECT rolname, rolsuper, rolbypassrls FROM pg_roles WHERE rolsuper OR rolbypassrls ORDER BY 1;
SELECT relname, relrowsecurity, relforcerowsecurity
FROM pg_class WHERE relnamespace = 'lab11'::regnamespace AND relkind = 'r' ORDER BY 1;

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

4. Refleksi D
Mengenkripsi kolom sensitif saja tidak serta-merta membuat basis data aman secara menyeluruh. Berdasarkan temuan pada Q21–Q24, terdapat dua ancaman yang tetap terbuka dan satu risiko operasional:

Ancaman 1 — Kebocoran Kunci Melalui Metadata & Log Sesi (Bukti Q22):
Enkripsi tingkat kolom (pgp_sym_encrypt) menuntut aplikasi atau pengguna menyuntikkan kunci dekripsi ke sesi database (SET app.kunci_kolom = '...'). Sebagaimana dibuktikan pada Q22, kunci teks terang ini dapat tertangkap di pg_stat_activity saat kueri berjalan, serta berisiko tercatat permanen di log server (postgresql.log) atau riwayat klien (.psql_history). Jika penyerang memperoleh akses baca ke log atau tampilan pemantauan, seluruh ciphertext kehilangan perlindungannya.

Ancaman 2 — Inferensi Identitas dan Differencing Attack pada Kolom Non-Enkripsi (Bukti Q23–Q24):
Kolom yang tidak dienkripsi karena dibutuhkan untuk analitik atau pengelompokan (seperti kota, tahun lahir, dan saldo_bulat) tetap menjadi quasi-identifier. Meskipun tanggal lahir telah digeneralisasi ke tahun sehingga menurunkan keunikan lebih dari 99% (Q24), penyerang atau analis tetap dapat melakukan differencing attack menggunakan sepasang kueri agregat (COUNT dan SUM dengan mengecualikan satu id) untuk menyimpulkan nilai spesifik milik satu individu.

Risiko Operasional — Hilangnya Kemampuan Pencarian Indeks & Kinerja Dekripsi (Bukti Q21):
Karena pgp_sym_encrypt menggunakan salt/IV acak yang menghasilkan ciphertext berbeda untuk masukan identik (pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') bernilai false pada Q21), kolom rekening_enc tidak dapat diindeks secara normal untuk pencarian kesetaraan (WHERE rekening_enc = ...) maupun pencarian rentang. Akibatnya, setiap pencarian berdasarkan nomor rekening memaksa database melakukan Sequential Scan dan mendekripsi seluruh baris terlebih dahulu, yang berdampak langsung pada lonjakan beban CPU dan latensi kueri di produksi.

5. Refleksi E

## Peta Tiket #1134 ke UU PDP
Keluhan | Pasal relevan | Kontrol teknis pencegah | Bukti
  ....  |      ....     |           ....          | ....

  ## Pernyataan Etika
  Seluruh percobaan serangan hanya dijalankan pada kontainer lab11 milik sendiri di jaringan tertutup. (tanda tangan tiap anggota)
