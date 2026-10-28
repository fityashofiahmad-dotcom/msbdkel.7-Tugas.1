-- Setup Tabel Dokter Jaga
CREATE TABLE IF NOT EXISTS lab9.dokter_jaga (
    id INT PRIMARY KEY,
    nama TEXT NOT NULL,
    aktif BOOLEAN NOT NULL
);

INSERT INTO lab9.dokter_jaga VALUES
(1, 'dr. Andi', TRUE),
(2, 'dr. Budi', TRUE)
ON CONFLICT (id) DO UPDATE SET aktif = TRUE;

-- URUTAN EKSEKUSI:

-- [1. Sesi A]
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE; -- Hasil: 2

-- [2. Sesi B]
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE; -- Hasil: 2

-- [3. Sesi A]
UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 1;
COMMIT;

-- [4. Sesi B]
UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 2;
COMMIT;

-- EVALUASI HASIL AKHIR:
SELECT * FROM lab9.dokter_jaga;
-- Hasil: Kedua dokter menjadi FALSE (tidak aktif).
-- Kesimpulan: Aturan bisnis "Minimal 1 dokter harus aktif" terlanggar (Write Skew terjadi).
