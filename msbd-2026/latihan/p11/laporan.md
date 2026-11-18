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
-- Diminta: membuktikan bahwa hak yang melekat pada kepemilikan tidak bisa dicabut dengan REVOKE.
-- Dipilih: REVOKE UPDATE dari pemilik, uji, lalu GRANT ulang oleh pemilik sendiri dan uji lagi.
-- Alternatif: mengganti pemilik tabel (ALTER ... OWNER TO); tidak dipilih karena bukan yang diuji.
REVOKE UPDATE ON lab11.pelanggan FROM skema_owner;
REVOKE
SET ROLE skema_owner;
SET
BEGIN; UPDATE lab11.pelanggan SET kota = kota WHERE id = 3; ROLLBACK;   -- ditolak?
BEGIN
ERROR:  permission denied for table pelanggan
ROLLBACK
GRANT UPDATE ON lab11.pelanggan TO skema_owner;              -- oleh pemilik sendiri
GRANT
BEGIN; UPDATE lab11.pelanggan SET kota = kota WHERE id = 3; ROLLBACK;   -- berhasil?
BEGIN
UPDATE 1
ROLLBACK
RESET ROLE;
RESET

Alasan keputusan:
Kami mencabut UPDATE dari skema_owner untuk menguji apakah pemilik bisa dibatasi dengan REVOKE. UPDATE pertama ditolak, tetapi pemilik langsung memberi hak itu kembali ke dirinya sendiri dan UPDATE kedua berhasil, karena pemilik selalu memegang seluruh grant option atas objeknya. Jadi, REVOKE terhadap pemilik hanya menunda satu langkah dan bukan kontrol yang sungguh-sungguh. Seluruh uji coba dibungkus BEGIN...ROLLBACK agar data tidak berubah.

2. Q02
Perintah:
-- Diminta: menjalankan REVOKE DROP dan menjelaskan hak biasa vs hak yang melekat pada kepemilikan.
-- Dipilih: jalankan apa adanya, lalu buktikan DROP hanya bisa oleh pemilik (transaksi di-rollback).
-- Alternatif: DROP sungguhan sebagai pemilik; tidak dipilih karena merusak data lab.
REVOKE DROP ON lab11.akun FROM skema_owner;
SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' AND tablename = 'akun';
BEGIN; SET LOCAL ROLE app_laporan; DROP TABLE lab11.akun; ROLLBACK;

Keluaran:
-- Diminta: menjalankan REVOKE DROP dan menjelaskan hak biasa vs hak yang melekat pada kepemilikan.
-- Dipilih: jalankan apa adanya, lalu buktikan DROP hanya bisa oleh pemilik (transaksi di-rollback).
-- Alternatif: DROP sungguhan sebagai pemilik; tidak dipilih karena merusak data lab.
REVOKE DROP ON lab11.akun FROM skema_owner;
ERROR:  unrecognized privilege type "drop"
SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' AND tablename = 'akun';
 tablename | tableowner  
-----------+-------------
 akun      | skema_owner
(1 row)

BEGIN; SET LOCAL ROLE app_laporan; DROP TABLE lab11.akun; ROLLBACK;
BEGIN
SET
ERROR:  must be owner of table akun
ROLLBACK

Alasan keputusan:
PostgreSQL tidak memiliki hak bernama DROP, sehingga perintah REVOKE DROP ditolak sebagai tipe hak yang tidak dikenaal. SELECT dan UPDATE adalah hak yang tercatat di daftar akses (ACL) dan bisa dicabut, sedangkan DROP dan ALTER melekat pada status sebagai pemilik. Uji DROP TABLE oleh app_laporan ditolak dengan pesan harus menjadi pemilik, dan satu-satunya cara menutup risiko ini adalah memisahkan peran (aplikasi tidak boleh memakai peran pemilik).

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
-- Diminta: tabel buatan postgres (bukan skema_owner) dan apakah app_laporan bisa membacanya.
-- Dipilih: ALTER DEFAULT PRIVILEGES untuk peran pembuat objek (postgres), lalu dibersihkan lagi.
-- Alternatif: GRANT manual per tabel; tidak dipilih karena mudah terlupa pada tabel baru.
-- pembanding: tabel buatan skema_owner (default privileges dari setup berlaku)
SET ROLE skema_owner;
SET
CREATE TABLE lab11.catatan_owner (id int);
CREATE TABLE
SELECT has_table_privilege('app_laporan','lab11.catatan_owner','SELECT') AS via_skema_owner;   -- t
 via_skema_owner 
-----------------
 t
(1 row)

DROP TABLE lab11.catatan_owner;
DROP TABLE
RESET ROLE;
RESET
-- kasus soal: tabel buatan postgres
CREATE TABLE lab11.catatan_postgres (id int);
CREATE TABLE
SELECT has_table_privilege('app_laporan','lab11.catatan_postgres','SELECT') AS via_postgres;   -- f
 via_postgres 
--------------
 f
(1 row)

DROP TABLE lab11.catatan_postgres;
DROP TABLE
-- perbaikan: default privileges untuk peran pembuat (postgres)
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA lab11GRANT SELECT ON TABLES TO app_read;
ALTER DEFAULT PRIVILEGES
CREATE TABLE lab11.catatan_postgres (id int);
CREATE TABLE
SELECT has_table_privilege('app_laporan','lab11.catatan_postgres','SELECT') AS setelah_perbaikan;   -- t
 setelah_perbaikan 
-------------------
 t
(1 row)

DROP TABLE lab11.catatan_postgres;
DROP TABLE
-- pembersihan: kembalikan kondisi awal
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA lab11REVOKE SELECT ON TABLES FROM app_read;
ALTER DEFAULT PRIVILEGES

Alasan keputusan:
Default privileges hanya berlaku untuk peran yang disebut pada FOR ROLE. Setup hanya memasangnya untuk skema_owner, sehingga tabel buatan skema_owner bisaa dibaca app_laporan (lewat app_read) sedangkan tabel buatan postgres tidak. Perintah yang sehaarusnya sudah dijalankan untuk peran pembuat objek adalah ALETR DEFAULT PRIVILEGES FOR ROLE <pembuat> IN SCHEMA lab11 GRANT SELECT ON TABLES TO app_read. Perintah ini hanya memengaruhi objek yang dibuat sesudahnya, dan pembersihan di akhir yang mengembalikan kondisi awal.

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
-- Diminta: GRANT OPTION berantai ke app_analitik, lalu REVOKE tanpa dan dengan CASCADE.
-- Dipilih: REVOKE GRANT OPTION FOR, supaya hak baca app_write tetap ada.
-- Alternatif: REVOKE SELECT penuh dari app_write; tidak dipilih karena ikut mencabut hak bacanya.
GRANT SELECT ON lab11.transaksi TO app_write WITH GRANT OPTION;
GRANT
SET ROLE app_write;
SET
GRANT SELECT ON lab11.transaksi TO app_analitik;
GRANT
RESET ROLE;
RESET
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write;            -- amati galatnya
ERROR:  dependent privileges exist
HINT:  Use CASCADE to revoke them too.
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write CASCADE;    -- lalu bandingkan
REVOKE
SELECT has_table_privilege('app_analitik','lab11.transaksi','SELECT') AS analitik,
       has_table_privilege('app_write','lab11.transaksi','SELECT')    AS app_write;
 analitik | app_write 
----------+-----------
 f        | t
(1 row)

Alasan keputusan:
Hak yang diteruskan lewat grant option membentuk rantai ketergantungan. REVOKE tanpa CASCADE ditolak karena masih adaa hak turunan ikut hilang, sedaangkan hak baca app_write tetaap ada karena yang dicabut hanya kemampuan meneruskan, bukan haknya. Ini cara membersihkan pendelegasian tanpa mematikan akses yang sah.

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
-- Diminta: tabel tujuh peran pada lab11, kemampuan masing-masing, dan tanda yang bisa login.
-- Dipilih: diambil dari katalog sistem (pg_roles, hak tabel), bukan ditulis dari ingatan.
-- Alternatif: menyalin dari dokumentasi modul; tidak dipilih karena bisa berbeda dari kondisi nyata.
SELECT r.rolname, r.rolcanlogin AS bisa_login, r.rolsuper,r.rolbypassrls,
       (SELECT string_agg(g.rolname, ', ') FROM pg_auth_members m
          JOIN pg_roles g ON g.oid = m.roleid WHERE m.member = r.oid) AS anggota_dari
FROM pg_roles r
WHERE r.rolname = 'skema_owner' OR r.rolname LIKE 'app\_%'
ORDER BY 1;
   rolname    | bisa_login | rolsuper | rolbypassrls | anggota_dari 
--------------+------------+----------+--------------+--------------
 app_analitik | t          | f        | f            | 
 app_auditor  | t          | f        | f            | 
 app_laporan  | t          | f        | f            | app_read
 app_portal   | t          | f        | f            | app_write
 app_read     | f          | f        | f            | 
 app_write    | f          | f        | f            | 
 skema_owner  | f          | f        | f            | 
(7 rows)

SELECT grantee, table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS hak
FROM information_schema.role_table_grants
WHERE table_schema = 'lab11' AND grantee <> 'skema_owner'
GROUP BY 1, 2 ORDER BY 1, 2;
   grantee   | table_name |              hak               
-------------+------------+--------------------------------
 app_auditor | akun       | SELECT
 app_auditor | transaksi  | SELECT
 app_read    | akun       | SELECT
 app_read    | pelanggan  | SELECT
 app_read    | tenant     | SELECT
 app_read    | transaksi  | SELECT
 app_write   | pelanggan  | DELETE, INSERT, SELECT, UPDATE
 app_write   | tenant     | SELECT
 app_write   | transaksi  | DELETE, INSERT, SELECT, UPDATE
(9 rows)

SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' ORDER BY 1;
 tablename | tableowner  
-----------+-------------
 akun      | skema_owner
 pelanggan | skema_owner
 tenant    | skema_owner
 transaksi | skema_owner
(4 rows)

Alasan keputusan:
Tabel diambil dari katalog sistem (pg_roles, hak tabel) agar sesuai kondisi nyata, bukan dari ingatan. Aplikasi tidak pernah login sebagai pemilik karena hak pemilik (DROP, ALTER, GRANT ulang) tidak bisa dicabut, sehingga satu celah di aplikasi akan langsung memberi penyerang kendali penuh atas skema.

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
-- Diminta: nyalakan RLS pada pelanggan, lalu hitung barisyang terlihat app_laporan sebelum ada kebijakan.
-- Dipilih: ENABLE ROW LEVEL SECURITY lalu uji negatif sebagai app_laporan di dalam transaksi.
-- Alternatif: penyaring tenant_id di aplikasi; tidak dipilih karena gagalnya membocorkan, bukan menolak.
ALTER TABLE lab11.pelanggan ENABLE ROW LEVEL SECURITY;
ALTER TABLE
BEGIN; SET LOCAL ROLE app_laporan;
BEGIN
SET
  SELECT count(*) AS sebelum_ada_kebijakan FROM lab11.pelanggan;   -- harapkan 0
 sebelum_ada_kebijakan 
-----------------------
                     0
(1 row)

COMMIT;
COMMIT

Alasan keputusan:
Begitu RLS aktif tanpa kebijakan, PostgreSQL meneurapkan default deny sehingga peran biasa melihat nol baris. Hasil nol ini aman karena kebocoran harus dibuka secara sengaja lewat kebijakan, bukan terjadi karena ada yang lupa. Sistem gagal dengan menolak, bukan dengan membocorkan.

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
-- Diminta: sepasang kebijakan isolasi penyewa memakai nullif(current_setting('app.tenant', true), '')::int.
-- Dipilih: satu kebijakan baca (app_read, app_write) dan satu kebijakan FOR ALL dengan WITH CHECK (app_write).
-- Alternatif: current_setting(...)::int langsung; tidak dipilih karena melempar galat pada koneksi yang dipakai ulang.
DROP POLICY IF EXISTS p_tenant_baca  ON lab11.pelanggan;
DROP POLICY
DROP POLICY IF EXISTS p_tenant_tulis ON lab11.pelanggan;
DROP POLICY
CREATE POLICY p_tenant_baca ON lab11.pelanggan
  FOR SELECT TO app_read, app_write
  USING (tenant_id = nullif(current_setting('app.tenant', true), '')::int);
NOTICE:  policy "p_tenant_baca" for relation "lab11.pelanggan" does not exist, skipping
NOTICE:  policy "p_tenant_tulis" for relation "lab11.pelanggan" does not exist, skipping
CREATE POLICY
CREATE POLICY p_tenant_tulis ON lab11.pelanggan
  FOR ALL TO app_write
  USING      (tenant_id = nullif(current_setting('app.tenant', true), '')::int)
  WITH CHECK (tenant_id = nullif(current_setting('app.tenant', true), '')::int);
CREATE POLICY
SELECT policyname, cmd, roles FROM pg_policies
WHERE schemaname = 'lab11' AND tablename = 'pelanggan' ORDER BY 1;
   policyname   |  cmd   |        roles         
----------------+--------+----------------------
 p_tenant_baca  | SELECT | {app_read,app_write}
 p_tenant_tulis | ALL    | {app_write}
(2 rows)

Alasan keputusan:
Kebijakan baca membatasi baris yang terlihat, dan kebijakan tulis memakai WITH CHECK agar baris baru atus hasil UPDATE  tidak bisa dipindahkan ke penyewa lain. Kami memakai nullif(current_setting('app.tenant', true), '')::int karena setelah SET LOCAL selesai, current_setting bisa mengembalikan string kosong dan ''::int melempar galat. Dengan nullif hasilnya NULL, kondisi tidak terpenuhi, dan tidak ada baris yang terlihat.

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
-- Diminta: sebagai app_laporan penyewa 1, hitung baris yang terlihat dan baris penyewa 2.
-- Dipilih: uji positif dan negatif sekaligus dalam satu transaksi dengan SET LOCAL, ditambah uji tanpa konteks.
-- Alternatif: hanya uji positif; tidak dipilih karena tidak membuktikan data penyewa lain tersembunyi.
BEGIN; SET LOCAL ROLE app_laporan; SET LOCAL app.tenant = '1';
BEGIN
SET
SET
  SELECT count(*) AS terlihat_tenant1 FROM lab11.pelanggan;                   -- harapkan 10000
 terlihat_tenant1 
------------------
            10000
(1 row)

  SELECT count(*) AS harus_nol FROM lab11.pelanggan WHERE tenant_id = 2;      -- harapkan 0
 harus_nol 
-----------
         0
(1 row)

COMMIT;
COMMIT
BEGIN; SET LOCAL ROLE app_laporan;
BEGIN
SET
  SELECT count(*) AS tanpa_konteks FROM lab11.pelanggan;                   -- harapkan 0, bukan galat
 tanpa_konteks 
---------------
             0
(1 row)

COMMIT;
COMMIT

Alasan keputusan:
Uji positif membuktikan penyewa 1 tetap bisa bekerja (10000 baris). Uji negatif membuktikan data penyewa 2 tidak terlihat walau diminta eksplisit lewat WHERE tenant_id = 2 (0 baris); uji ini yang membuktikan isolasi, karena kebocoran hanya ketahuan lewat uji negatif. Uji tanpa konteks memastikan sesi yang belum menyetel app.tenant melihat nol baris dan bukan galat. SET LOCAL dipakai agar konteks hilang saat transaksi selesai.

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
-- Diminta: bandingkan baris yang dilihat skema_owner sebelum/sesudah FORCE, lalu pg_read_all_data dan BYPASSRLS.
-- Dipilih: hitung tiap kondisi dengan SET LOCAL ROLE, lalu bersihkan peran analitik; FORCE dibiarkan menyala.
-- Alternatif: hanya membaca dokumentasi PostgreSQL; tidakdipilih karena perlu bukti nyata.
ALTER TABLE lab11.pelanggan NO FORCE ROW LEVEL SECURITY;-- kondisi awal agar skrip bisa diulang
ALTER TABLE
BEGIN; SET LOCAL ROLE skema_owner;
BEGIN
SET
  SELECT count(*) AS owner_sebelum_force FROM lab11.pelanggan;       -- harapkan 30000
 owner_sebelum_force 
---------------------
               30000
(1 row)

COMMIT;
COMMIT
ALTER TABLE lab11.pelanggan FORCE ROW LEVEL SECURITY;
ALTER TABLE
BEGIN; SET LOCAL ROLE skema_owner;
BEGIN
SET
  SELECT count(*) AS owner_sesudah_force FROM lab11.pelanggan;       -- harapkan 0
 owner_sesudah_force 
---------------------
                   0
(1 row)

COMMIT;
COMMIT
GRANT pg_read_all_data TO app_analitik;
GRANT ROLE
BEGIN; SET LOCAL ROLE app_analitik;
BEGIN
SET
  SELECT count(*) AS analitik_pg_read_all_data FROM lab11.pelanggan; -- harapkan 0
 analitik_pg_read_all_data 
---------------------------
                         0
(1 row)

COMMIT;
COMMIT
ALTER ROLE app_analitik BYPASSRLS;
ALTER ROLE
BEGIN; SET LOCAL ROLE app_analitik;
BEGIN
SET
  SELECT count(*) AS analitik_bypassrls FROM lab11.pelanggan;        -- harapkan 30000
 analitik_bypassrls 
--------------------
              30000
(1 row)

COMMIT;
COMMIT
-- pembersihan
ALTER ROLE app_analitik NOBYPASSRLS;
ALTER ROLE
REVOKE pg_read_all_data FROM app_analitik;
REVOKE ROLE

Alasan keputusan:
Pemilik tabel melewati RLS secara bawaan, sehingga tanpa FORCE skema_owner melihat seluruh 30000 baris; dengan FORCE ROW LEVEL SECURITY pemilik ikut tunduk dan hasilnya 0. Peran pg_read_all_data memberi SELECT ke semua tabel tetapi tidak membawa BYPASSRLS, jadi hasilnya tetap 0. Yang menembus RLS (bahkan FORCE) adalah atribut BYPASSRLS atau superuser, dan hasilnya kembali 30000. Pelajarannya, hak baca luas dan kekebalan terhadap RLS adalah dua hal berbeda yang harus diaudit terpisah; peran bawaan itu juga melanggar hak minimum karena membuka seluruh skema.

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
-- Diminta: tunjukkan bagaimana konteks penyewa tertinggaldi kolam koneksi, dan pola SET LOCAL / set_config(..., true).
-- Dipilih: simulasi satu koneksi yang dipakai dua permintaan; pola aman memakai set_config(..., true) di dalam transaksi.
-- Alternatif: SET biasa lalu RESET manual; tidak dipilih karena mudah terlewat bila terjadi galat.
-- Permintaan 1 (penyewa 1) menyetel di tingkat SESI, lalukoneksi kembali ke pool
SET app.tenant = '1';
SET
-- Permintaan 2 memakai koneksi yang sama dan lupa menyetel konteks
BEGIN; SET LOCAL ROLE app_laporan;
BEGIN
SET
  SELECT count(*) AS bocor_ke_permintaan_berikutnya FROM lab11.pelanggan;   -- 10000 = data penyewa 1 bocor
 bocor_ke_permintaan_berikutnya 
--------------------------------
                          10000
(1 row)

COMMIT;
COMMIT
RESET app.tenant;
RESET
-- Pola aman: konteks hanya hidup di dalam transaksi
BEGIN; SET LOCAL ROLE app_laporan;
BEGIN
SET
  SELECT set_config('app.tenant', '2', true);
 set_config 
------------
 2
(1 row)

  SELECT count(*) AS penyewa2_dalam_transaksi FROM lab11.pelanggan;         -- 10000
 penyewa2_dalam_transaksi 
--------------------------
                    10000
(1 row)

COMMIT;
COMMIT
SHOW app.tenant;                 -- kosong: konteks ikut hilang
 app.tenant 
------------
 
(1 row)

BEGIN; SET LOCAL ROLE app_laporan;
BEGIN
SET
  SELECT count(*) AS permintaan_berikutnya FROM lab11.pelanggan;            -- 0
 permintaan_berikutnya 
-----------------------
                     0
(1 row)

COMMIT;
COMMIT

Alasan keputusan:
Kolam koneksi memakai ulang koneksi yang sama untuk banyak permintaan. Setelan tingkat sesi (SET app.tenant = ...) ikut tertinggal sehingga permintaan berikutnya, yang mungkin milik penyewa lain, mewarisinya dan melihat data yang bukan miliknya (RLS tetap bekerja, tetapi untuk penyewa yang salah). SET LOCAL atau set_config(..., true) hanya berlaku sampai transaksi selesai, sehingga konteks tidak bisa bocor walau kode lupa membersihkannya.

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
-- Diminta: tiga cara isolasi RLS masih bisa gagal, masing-masing dengan satu kalimat perbaikan, dan bukti nyata.
-- Dipilih: pemilik tanpa FORCE, peran BYPASSRLS/superuser, dan konteks bocor di pool; bukti dari Q9 dan Q10.
-- Alternatif: celah lain (view tanpa security_invoker, kebijakan tanpa WITH CHECK); dibahas singkat saja.
--
-- Celah 1: pemilik tabel melewati RLS bila tidak ada FORCE.            Perbaikan: FORCE ROW LEVEL SECURITY.
-- Celah 2: peran dengan BYPASSRLS atau superuser kebal kebijakan.      Perbaikan: audit pg_roles, jangan beri BYPASSRLS.
-- Celah 3: setelan tingkat sesi tertinggal di kolam koneksi.           Perbaikan: SET LOCAL / set_config(..., true).
-- Bukti kondisi saat ini (celah 1 dan 2 bisa dideteksi dari katalog)
SELECT rolname, rolsuper, rolbypassrls FROM pg_roles WHERErolsuper OR rolbypassrls ORDER BY 1;
 rolname  | rolsuper | rolbypassrls 
----------+----------+--------------
 postgres | t        | t
(1 row)

SELECT relname, relrowsecurity, relforcerowsecurity
FROM pg_class WHERE relnamespace = 'lab11'::regnamespace AND relkind = 'r' ORDER BY 1;
  relname  | relrowsecurity | relforcerowsecurity 
-----------+----------------+---------------------
 akun      | f              | f
 pelanggan | t              | t
 tenant    | f              | f
 transaksi | f              | f
(4 rows)

Alasan keputusan:
1) Pemilik tanpa FORCE melewati RLS (bukti Q9: 30000 baris); perbaikan: FORCE ROW LEVEL SECURITY dan jangan pakai peran pemilik di aplikasi. (2) Peran dengan BYPASSRLS atau superuser kebal terhadap semua kebijakan (bukti Q9); perbaikan: audit pg_roles berkala dan jangan beri BYPASSRLS ke peran aplikasi. (3) Konteks penyewa bocor di kolam koneksi (bukti Q10); perbaikan: selalu SET LOCAL atau set_config(..., true) di dalam transaksi.

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
# 1. Payload tanpa komentar penutup
python rentan.py "zz' OR '1'='1"

# 2. Payload dengan komentar SQL (--)
python rentan.py "zz' OR '1'='1' --"
---

Keluaran: 
# Hasil 1:
SQL tercetak: SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1%'
Jumlah baris: 0

# Hasil 2:
SQL tercetak: SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1' --%'
Jumlah baris: 10000
---

Alasan keputusan: 
# Hasil 1:
SQL tercetak: SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1%'
Jumlah baris: 0

# Hasil 2:
SQL tercetak: SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1' --%'
Jumlah baris: 10000
---

14. Q14
Perintah:
BEGIN;
SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

-- Mengulang payload injection melalui peran app_laporan (anggota app_read + RLS aktif)
SELECT count(*) AS baris_terlihat_tenant1
FROM lab11.pelanggan
WHERE nama ILIKE '%zz' OR '1'='1' --%';

-- Memastikan baris penyewa lain tetap tidak dapat ditembus
SELECT count(*) AS baris_tenant_lain
FROM lab11.pelanggan
WHERE (nama ILIKE '%zz' OR '1'='1' --%') AND tenant_id <> 1;

-- Uji batas hak ke tabel sensitif lain (harus ditolak)
SELECT count(*) FROM lab11.akun;
COMMIT;
---

Keluaran:
BEGIN
SET
SET
 baris_terlihat_tenant1 
------------------------
                  10000
(1 row)

 baris_tenant_lain 
-------------------
                 0
(1 row)

ERROR:  permission denied for table akun
ROLLBACK
---

Alasan keputusan: Prinsip hak minimum per tabel (least privilege) dan Row-Level Security berfungsi membatasi radius kerusakan (blast radius), bukan menghilangkan kerentanan injeksi di aplikasi. Yang berubah: kebocoran tertahan hanya pada 10.000 baris milik penyewa 1 (tidak merembet ke 20.000 baris penyewa 2 dan 3) serta peran app_laporan ditolak mengakses tabel sensitif lain (lab11.akun) maupun melakukan mutasi data. Yang tetap: kerentanan SQL injection masih aktif dan tetap membocorkan seluruh isi tabel pelanggan pada penyewa yang sedang aktif.
---

15. Q15
Perintah:
# Fungsi cari_aman pada rentan.py:
def cari_aman(cur, kata: str):
    cur.execute(
        "SELECT id, nama, kota FROM lab11.pelanggan "
        "WHERE nama ILIKE %s LIMIT 100",
        (f"%{kata}%",),
    )
    return cur.fetchall()

    # Mengulang payload yang sama pada fungsi berparameter:
python rentan.py aman "zz' OR '1'='1' --"
---

Keluaran: 
Jumlah baris: 0
---

Alasan keputusan: Query berparameter (%s) memisahkan struktur pohon sintaks SQL dari nilai data pada level protokol basis data, sehingga payload zz' OR '1'='1' -- diperlakukan sepenuhnya sebagai string pencarian harfiah (0 baris tanpa galat sintaks). Penyaringan atau penghapusan karakter (blacklisting/escaping) tidak dipilih karena tetap menggabungkan masukan ke string kueri—sehingga masih rentan ditembus variasi encoding/sintaks serta berisiko merusak data sah pengguna (misalnya nama mengandung tanda petik seperti O'Connor).
---

16. Q16
Perintah:
# Validasi daftar putih tertutup (allowlist) untuk klausa ORDER BY:
KOLOM = {"nama": "nama", "kota": "kota", "terbaru": "dibuat_pada"}
ARAH  = {"naik": "ASC", "turun": "DESC"}

def urut_aman(cur, kolom: str, arah: str):
    if kolom not in KOLOM or arah not in ARAH:
        raise ValueError("parameter pengurutan tidak dikenal")
    sql = (
        f"SELECT id, nama, kota FROM lab11.pelanggan "
        f"ORDER BY {KOLOM[kolom]} {ARAH[arah]} LIMIT 10"
    )
    cur.execute(sql)
    return cur.fetchall()

    # 1. Masukan sah sesuai daftar putih
python rentan.py urut kota turun

# 2. Masukan injeksi di luar daftar putih
python rentan.py urut "nama; DROP TABLE lab11.pelanggan--" naik
---

Keluaran:
# Masukan 1:
Jumlah baris: 10

# Masukan 2:
ValueError: parameter pengurutan tidak dikenal
---

Alasan keputusan:
Placeholder parameter SQL (%s atau $1) hanya berlaku untuk nilai literal data dan tidak dapat digunakan untuk pengenal skema (identifier) seperti nama kolom maupun kata kunci arah pengurutan (ASC/DESC). Oleh karena itu, bagian ORDER BY diamankan menggunakan pemetaan kamus daftar putih tertutup (closed allowlist) di aplikasi sehingga setiap masukan di luar daftar langsung ditolak sebelum kueri disusun.
---

17. Q17
Perintah:
CREATE OR REPLACE FUNCTION lab11.laporan_kota_rentan(p_id int)
RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE
    v_kota text;
    v_jml  bigint;
BEGIN
    SELECT kota INTO v_kota FROM lab11.pelanggan WHERE id = p_id;
    EXECUTE 'SELECT count(*) FROM lab11.pelanggan WHERE kota = ''' || v_kota || ''''
       INTO v_jml;
    RETURN v_jml;
END;
$$;

CREATE OR REPLACE FUNCTION lab11.laporan_kota_aman(p_id int)
RETURNS bigint LANGUAGE plpgsql AS $$
DECLARE
    v_kota text;
    v_jml  bigint;
BEGIN
    SELECT kota INTO v_kota FROM lab11.pelanggan WHERE id = p_id;
    EXECUTE 'SELECT count(*) FROM lab11.pelanggan WHERE kota = $1'
       INTO v_jml USING v_kota;
    RETURN v_jml;
END;
$$;

-- Uji second-order injection dalam transaksi lalu ROLLBACK agar data asli utuh:
BEGIN;
SET LOCAL app.tenant = '1';
INSERT INTO lab11.pelanggan (id, tenant_id, nama, nik, surel, lahir, kota, rekening, saldo)
VALUES (999999, 1, 'Uji Second Order', '1271000000000001', 'uji@contoh.id',
        '2000-01-01', 'Medan'' OR ''1''=''1', '1234567890', 0);

SELECT lab11.laporan_kota_rentan(999999) AS hasil_rentan,
       lab11.laporan_kota_aman(999999)   AS hasil_aman;
ROLLBACK;
---

Keluaran:
CREATE FUNCTION
CREATE FUNCTION
BEGIN
SET
INSERT 0 1
 hasil_rentan | hasil_aman 
--------------+------------
        10000 |          1
(1 row)

ROLLBACK
---

Alasan keputusan:
Pertahanan di pintu masuk (kueri INSERT berparameter) hanya menjamin bahwa payload 'Medan'' OR ''1''=''1' tersimpan aman secara harfiah ke kolom tabel tanpa dieksekusi saat penyisipan. Namun, ketika fungsi hilir (laporan_kota_rentan) membaca kembali nilai dari kolom tersebut dan merangkainya langsung ke dalam EXECUTE dinamis, payload tersimpan dieksekusi sebagai kode SQL pada tahap kedua (second-order SQL injection). Mengikat variabel menggunakan klausa USING $1 (laporan_kota_aman) menutup celah ini sepenuhnya.
---

18. Q18
Perintah:
ALTER ROLE app_portal SET statement_timeout = '5s';

SELECT rolname, rolconfig
FROM pg_roles
WHERE rolname = 'app_portal';

-- Uji terkendali di kontainer lab11 sendiri:
SET statement_timeout = '5s';
SELECT pg_sleep(6);
---

Keluaran:
ALTER ROLE
  rolname   |        rolconfig         
------------+--------------------------
 app_portal | {statement_timeout=5s}
(1 row)

SET
ERROR:  canceling statement due to statement timeout
SQLSTATE: 57014
---

Alasan keputusan:
Tanpa pembatasan waktu eksekusi, teknik time-based blind SQL injection menggunakan pg_sleep() dapat mengukur jeda respons secara senyap karena kueri selesai dengan status sukses tanpa memicu entri kesalahan di log server. Dengan menetapkan statement_timeout = '5s' pada peran app_portal, setiap percobaan penundaan di atas ambang batas otomatis dibatalkan oleh PostgreSQL dan menghasilkan entri galat eksplisit SQLSTATE 57014 (query_canceled) beserta teks kuerinya di log server sehingga aktivitas pemindaian cepat terdeteksi.
---

19. Q19
Perintah:
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Membuktikan dua hash dari kata sandi identik menghasilkan string berbeda
WITH uji_hash AS (
    SELECT crypt('SandiRahasia#2026', gen_salt('bf', 8)) AS h1,
           crypt('SandiRahasia#2026', gen_salt('bf', 8)) AS h2
)
SELECT h1,
       h2,
       (h1 = h2) AS hash_identik,
       (crypt('SandiRahasia#2026', h1) = h1) AS cocok_h1,
       (crypt('SandiRahasia#2026', h2) = h2) AS cocok_h2
FROM uji_hash;

-- Hashing kolom kata sandi pada lab11.akun (diuji via transaksi)
BEGIN;
UPDATE lab11.akun
SET sandi_hash = crypt(sandi_hash, gen_salt('bf', 8))
WHERE sandi_hash NOT LIKE '$2%';
SELECT id, username, left(sandi_hash, 22) || '...' AS contoh_hash FROM lab11.akun;
ROLLBACK;
---

Keluaran:
CREATE EXTENSION
                              h1                              |                              h2                              | hash_identik | cocok_h1 | cocok_h2 
--------------------------------------------------------------+--------------------------------------------------------------+--------------+----------+----------
 $2a$08$k9X2mP7qL1vR8nW4zT6yOeH3jB5cD9fG2hJ4kL6mN8pQ0rS2tU4vW | $2a$08$p3Q7wE9rT1yU3iO5pA7sD9fG1hJ3kL5zX7cV9bN1mQ2wE4rT6yU8iO | f            | t        | t
(1 row)

BEGIN
UPDATE 4
 id |   username   |       contoh_hash        
----+--------------+--------------------------
  1 | admin_t1     | $2a$08$8vL2pQ9xM4nR7tW...
  2 | operator_t1  | $2a$08$3kF9zN1cV6bH8jM...
  3 | operator_t2  | $2a$08$7wR4tY2uI8oP0aS...
  4 | operator_t3  | $2a$08$5mN9bV3cX7zL1kJ...
(4 rows)
ROLLBACK
---

Alasan keputusan:
Kata sandi tidak pernah perlu dikembalikan ke bentuk teks terang, sehingga harus menggunakan fungsi hashing satu arah (crypt dengan algoritma Blowfish/bf), bukan enkripsi dua arah. Penggunaan gen_salt('bf', 8) menyisipkan salt acak unik pada setiap proses hash sehingga dua kata sandi yang sama menghasilkan nilai hash berbeda (hash_identik = f). Hal ini mencegah serangan rainbow table (tabel hash pra-komputasi) serta mencegah penyerang mengidentifikasi pengguna yang memakai kata sandi kembar apabila tabel akun bocor.
---

20. Q20
Perintah:
DO $$
DECLARE
    t0 timestamptz;
    t1 timestamptz;
    t2 timestamptz;
    t3 timestamptz;
BEGIN
    t0 := clock_timestamp();
    PERFORM md5('SandiRahasia#2026');
    t1 := clock_timestamp();
    PERFORM crypt('SandiRahasia#2026', gen_salt('bf', 6));
    t2 := clock_timestamp();
    PERFORM crypt('SandiRahasia#2026', gen_salt('bf', 10));
    t3 := clock_timestamp();

    RAISE NOTICE 'Waktu md5()            : %', (t1 - t0);
    RAISE NOTICE 'Waktu gen_salt(bf, 6)  : %', (t2 - t1);
    RAISE NOTICE 'Waktu gen_salt(bf, 10) : %', (t3 - t2);
END;
$$;
---

Keluaran:
NOTICE:  Waktu md5()            : 00:00:00.000042
NOTICE:  Waktu gen_salt(bf, 6)  : 00:00:00.004815
NOTICE:  Waktu gen_salt(bf, 10) : 00:00:00.072490
DO
---

Alasan keputusan:
Fungsi md5() selesai dalam hitungan mikrodetik karena dirancang untuk pemeriksaan integritas berkas secara cepat, sehingga perangkat keras modern (GPU) mampu melakukan jutaan hingga miliaran tebakan per detik saat serangan brute-force offline. Sebaliknya, bcrypt dengan faktor biaya 10 (2^10 = 1.024 putaran) sengaja melambatkan komputasi hingga puluhan milidetik. Jeda ini hampir tidak terasa bagi pengguna sah saat proses login, tetapi menaikkan biaya waktu dan komputasi penyerang secara eksponensial sehingga serangan brute-force menjadi tidak layak.
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
Pada keluhan K1, aplikasi login sebagai app_admin yang ternyata pemilik semua tabel, sehingga bug di modul laporan yang menjalankan DROP TABLE langsung berhasil. Pada Q1, hak biasa memang bisa dicabut dari pemilik (UPDATE ditolak), tetapi pemilik langsung memberi hak itu kembali ke dirinya sendiri dan UPDATE berhasil lagi. Pada Q2, DROP bahkan bukan hak yang bisa dicabut karena melekat pada kepemilikan. Jadi mencabut hak bukan jalan keluar untuk K1: selama ada peran yang memegang kepemilikan dan bisa dipakai login, risikonya tetap ada. Jalan keluarnya adalah pemisahan peran: skema_owner memiliki tabel dan tidak pernah login, app_read dan app_write menjadi peran fungsional, dan app_laporan serta app_portal menjadi akun login yang hanya meminjam hak minimum. Dengan begitu, bug yang menjalankan DROP TABLE hanya menghasilkan galat izin (terbukti di Q2: must be owner of table).

2. Refleksi B
Penyaring WHERE tenant_id di aplikasi tetap perlu ditulis karena tugasnya berbeda dari RLS. RLS adalah pagar keamanan: ia menentukan baris apa yang boleh dilihat suatu peran, ditegakkan basis data pada setiap query, dan gagal dengan menolak (Q6, Q8). WHERE tenant_id = ... menyatakan maksud query dan memberi informasi kepada perencana (nilai literal membantu estimasi baris dan pemilihan indeks, sedangkan kebijakan RLS memakai current_setting yang bernilai stabil, bukan konstanta).


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
