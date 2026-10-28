-- Percobaan 1: COMMIT (Sesi A)
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;
COMMIT;
-- Sesi B
SELECT * FROM lab9.rekening ORDER BY rekening_id;

-- Percobaan 2: ROLLBACK (Sesi A)
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 200000 WHERE rekening_id = 1;
UPDATE lab9.rekening SET saldo = saldo + 200000 WHERE rekening_id = 2;
ROLLBACK;
-- Sesi B
SELECT * FROM lab9.rekening ORDER BY rekening_id;