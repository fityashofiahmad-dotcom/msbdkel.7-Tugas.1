-- Q9: Pengujian Dirty Read
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id = 1;

-- Sesi A: Ubah saldo tanpa COMMIT
BEGIN;
UPDATE lab9.rekening SET saldo = 500000 WHERE rekening_id = 1;

-- [Di Sesi B]:
-- BEGIN ISOLATION LEVEL READ UNCOMMITTED;
-- SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil: 1000000.00 (Bukan 500000)
-- COMMIT;

-- Sesi A: Batal perubahan
ROLLBACK;
