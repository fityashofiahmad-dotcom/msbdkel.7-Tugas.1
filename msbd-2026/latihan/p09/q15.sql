-- Q15: MVCC, pembaca tidak menunggu penulis
-- Sesi A
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;                 -- SELECT #1
-- Sesi B
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 50000 WHERE rekening_id = 1;
-- Sesi A (B belum COMMIT)
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;                 -- SELECT #2: tidak menunggu
-- Sesi B
COMMIT;
-- Sesi A
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;                 -- SELECT #3: tetap nilai lama
COMMIT;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;                 -- nilai baru terlihat
-- Pemulihan
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id IN (1, 2);
