-- Q20: Deadlock
-- Sesi A
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- Sesi B
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;
-- Sesi A
SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;          -- menunggu B
-- Sesi B
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;          -- deadlock: SQLSTATE 40P01
-- Sesi korban: ROLLBACK;   Sesi lain: COMMIT;
