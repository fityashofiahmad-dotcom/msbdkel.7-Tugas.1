-- Q6: Non-repeatable Read pada READ COMMITTED
-- Reset saldo awal
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id = 1;

-- Sesi A: Mulai transaksi dan baca saldo pertama kali
BEGIN;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil 1: 1000000.00

-- [Di Sesi B terpisah]: BEGIN; UPDATE lab9.rekening SET saldo = 950000 WHERE rekening_id = 1; COMMIT;

-- Sesi A: Baca saldo kedua kali dalam transaksi yang sama
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil 2: 950000.00 (Berubah!)
COMMIT;
