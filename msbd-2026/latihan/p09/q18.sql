-- Q18: Perbandingan row lock (demo)
-- Sesi A
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR NO KEY UPDATE;
-- Sesi B
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR KEY SHARE;       -- langsung berhasil
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR SHARE;           -- MENUNGGU
-- Sesi A
ROLLBACK;
-- Sesi B (setelah FOR SHARE lanjut)
ROLLBACK;
