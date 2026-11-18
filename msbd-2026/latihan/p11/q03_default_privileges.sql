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