-- Q14: Optimistic locking dengan version_no
-- Setup (satu sesi). Tabel terpisah agar lab9.rekening tidak berubah.
DROP TABLE IF EXISTS lab9.rekening_v;
CREATE TABLE lab9.rekening_v (
    rekening_id INT PRIMARY KEY,
    pemilik TEXT NOT NULL,
    saldo NUMERIC(12,2) NOT NULL CHECK (saldo >= 0),
    version_no INT NOT NULL DEFAULT 1
);
INSERT INTO lab9.rekening_v (rekening_id, pemilik, saldo)
VALUES (1, 'Ani', 1000000), (2, 'Budi', 1000000);

-- Sesi A
SELECT saldo, version_no FROM lab9.rekening_v WHERE rekening_id = 1;   -- 1000000.00, v1
-- Sesi B
SELECT saldo, version_no FROM lab9.rekening_v WHERE rekening_id = 1;   -- 1000000.00, v1
-- Sesi A (menulis lebih dulu)
UPDATE lab9.rekening_v
SET saldo = 900000, version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 1;                              -- UPDATE 1
-- Sesi B (versi sudah basi)
UPDATE lab9.rekening_v
SET saldo = 950000, version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 1;                              -- UPDATE 0
-- Sesi B
SELECT * FROM lab9.rekening_v ORDER BY rekening_id;                    -- 900000.00, v2
-- Sesi B (coba ulang setelah baca ulang dan hitung ulang)
UPDATE lab9.rekening_v
SET saldo = 900000 - 50000, version_no = version_no + 1
WHERE rekening_id = 1 AND version_no = 2;                              -- UPDATE 1
