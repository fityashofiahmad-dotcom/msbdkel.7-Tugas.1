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