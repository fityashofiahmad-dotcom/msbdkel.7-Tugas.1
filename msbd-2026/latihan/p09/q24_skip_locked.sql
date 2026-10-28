-- Setup Tabel Antrean
CREATE TABLE IF NOT EXISTS lab9.antrean_pekerjaan (
    id INT PRIMARY KEY,
    deskripsi TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING'
);

INSERT INTO lab9.antrean_pekerjaan VALUES
(1, 'Kirim Email Welcome', 'PENDING'),
(2, 'Generate Report PDF', 'PENDING'),
(3, 'Sync Data Customer', 'PENDING')
ON CONFLICT (id) DO NOTHING;

-- SKENARIO EKSEKUSI:

-- [Sesi A - Worker 1]
BEGIN;
SELECT * FROM lab9.antrean_pekerjaan 
WHERE status = 'PENDING' 
ORDER BY id 
LIMIT 1 
FOR UPDATE;
-- Hasil: Mengunci baris id = 1

-- [Sesi B - Worker 2]
BEGIN;
SELECT * FROM lab9.antrean_pekerjaan 
WHERE status = 'PENDING' 
ORDER BY id 
LIMIT 1 
FOR UPDATE SKIP LOCKED;
-- Hasil: Langsung mengembalikan baris id = 2 tanpa terhalang (id = 1 dilewati)

-- Cleanup/Commit
-- [Sesi A] COMMIT;
-- [Sesi B] COMMIT;

-- KEGUNAAN:
-- Mengizinkan pemrosesan antrean secara paralel oleh banyak worker tanpa risiko 
-- lock contention atau blocking.
