-- Q12: Mencegah Lost Update dengan Pembaruan Atomik
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id = 1;

-- Sesi A & Sesi B menjalankan query atomik yang sama:
UPDATE lab9.rekening
SET saldo = saldo - 75000
WHERE rekening_id = 1 AND saldo >= 75000;

-- Verifikasi hasil akhir (Berhasil menjadi 850000.00)
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
