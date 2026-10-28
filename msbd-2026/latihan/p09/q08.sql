-- Q8: Pengujian Phantom Read
-- Reset & siapkan data dasar
DELETE FROM lab9.rekening WHERE rekening_id > 2;

-- 1. Pengujian pada READ COMMITTED (Sesi A)
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) FROM lab9.rekening WHERE saldo >= 500000; -- Hasil 1: 2 baris

-- [Di Sesi B]: INSERT INTO lab9.rekening VALUES (3, 'Charlie', 750000); COMMIT;

SELECT COUNT(*) FROM lab9.rekening WHERE saldo >= 500000; -- Hasil 2: 3 baris (Phantom Read)
COMMIT;

-- 2. Pengujian pada REPEATABLE READ (Sesi A)
DELETE FROM lab9.rekening WHERE rekening_id = 3;

BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM lab9.rekening WHERE saldo >= 500000; -- Hasil 1: 2 baris

-- [Di Sesi B]: INSERT INTO lab9.rekening VALUES (3, 'Charlie', 750000); COMMIT;

SELECT COUNT(*) FROM lab9.rekening WHERE saldo >= 500000; -- Hasil 2: 2 baris (Phantom Read Dicegah)
COMMIT;
