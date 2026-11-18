-- Q23: Penyamaran Data (Data Masking) via View tanpa security_invoker
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

-- Pengujian akses sebagai app_analitik
SET ROLE app_analitik;
-- Query berikut harus ditolak (permission denied):
-- SELECT * FROM lab11.pelanggan LIMIT 1;
-- Query berikut berhasil dengan data tersamar:
SELECT * FROM lab11.v_pelanggan_samar LIMIT 5;
RESET ROLE;
