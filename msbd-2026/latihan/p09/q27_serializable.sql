-- Reset Data Dokter Jaga
UPDATE lab9.dokter_jaga SET aktif = TRUE;

-- URUTAN EKSEKUSI:

-- [1. Sesi A]
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE;

-- [2. Sesi B]
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE;

-- [3. Sesi A]
UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 1;
COMMIT; -- Berhasil COMMIT

-- [4. Sesi B]
UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 2;
-- Mengalami kegagalan transaksi!

-- EVALUASI HASIL SESI B:
-- Status     : Transaksi Dibatalkan (ROLLBACK)
-- SQLSTATE   : 40001
-- Pesan Error: ERROR: could not serialize access due to read/write dependencies among transactions
