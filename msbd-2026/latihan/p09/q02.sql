-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

-- Sesi B (saat Sesi A belum COMMIT)
SELECT * FROM lab9.rekening ORDER BY rekening_id;

-- Sesi A
ROLLBACK;