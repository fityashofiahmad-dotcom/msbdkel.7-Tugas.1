-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;   -- transfer 1
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

SAVEPOINT sp1;

UPDATE lab9.rekening SET saldo = saldo - 200000 WHERE rekening_id = 1;   -- transfer 2
UPDATE lab9.rekening SET saldo = saldo + 200000 WHERE rekening_id = 2;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

ROLLBACK TO SAVEPOINT sp1;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

COMMIT;
SELECT * FROM lab9.rekening ORDER BY rekening_id;