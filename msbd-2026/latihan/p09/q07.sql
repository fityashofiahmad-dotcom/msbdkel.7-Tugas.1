-- Q7: Mencegah Non-repeatable Read dengan REPEATABLE READ
-- Reset saldo awal
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id = 1;

-- Sesi A: Mulai transaksi dengan tingkat isolasi REPEATABLE READ
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil 1: 1000000.00

-- [Di Sesi B terpisah]: BEGIN; UPDATE lab9.rekening SET saldo = 900000 WHERE rekening_id = 1; COMMIT;

-- Sesi A: Baca saldo kedua kali
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil 2: 1000000.00 (Tetap/Konsisten)
COMMIT;
