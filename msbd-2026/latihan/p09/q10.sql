-- Q10: Skenario Lost Update (Read-Modify-Write)
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id = 1;

-- Sesi A & Sesi B sama-sama baca saldo awal (1000000.00)
-- Sesi A menghitung (1000000 - 75000 = 925000) di aplikasi, lalu menulis nilai tetap:
-- Sesi A: BEGIN; UPDATE lab9.rekening SET saldo = 925000 WHERE rekening_id = 1; COMMIT;

-- Sesi B menghitung (1000000 - 75000 = 925000) dari bacaan awal basi, lalu menimpa:
-- Sesi B: BEGIN; UPDATE lab9.rekening SET saldo = 925000 WHERE rekening_id = 1; COMMIT;

-- Cek saldo akhir yang tidak konsisten (harusnya 850000.00)
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil: 925000.00
