-- Q16: xmin dan xmax
-- Sesi A
SELECT xmin, xmax, ctid, rekening_id, saldo FROM lab9.rekening WHERE rekening_id = 1;
BEGIN;
SELECT pg_current_xact_id();
UPDATE lab9.rekening SET saldo = saldo - 1000 WHERE rekening_id = 1;
SELECT xmin, xmax, ctid, rekening_id, saldo FROM lab9.rekening WHERE rekening_id = 1;
-- Sesi B (A belum COMMIT)
SELECT xmin, xmax, ctid, rekening_id, saldo FROM lab9.rekening WHERE rekening_id = 1;
-- Sesi A
ROLLBACK;
-- Sesi B
SELECT xmin, xmax, ctid, rekening_id, saldo FROM lab9.rekening WHERE rekening_id = 1;
