-- Diminta: mencatat teks SQL yang tercetak pada perilaku normal rentan.py
--          dan menandai bagian yang berasal dari masukan pengguna.
-- Dipilih: menjalankan query pencarian pola ILIKE dengan masukan normal
--          "Pelanggan 12" pada konteks penyewa 1.
-- Alternatif: menguji langsung dengan payload serangan; tidak dipilih di
--             langkah ini karena butuh baseline perilaku normal lebih dulu.

-- Jalankan di kontainer lab11-web:
-- python rentan.py rentan "Pelanggan 12"

-- Teks SQL yang tercetak:
-- SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%Pelanggan 12%'
--
-- Bagian dari masukan pengguna:
-- Substring `Pelanggan 12` di dalam literal pola `'%Pelanggan 12%'` berasal
-- langsung dari argumen masukan pengguna yang disisipkan ke string SQL.
-- Keluaran: 365 baris pada penyewa 1.

BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';
SELECT count(*) AS baris_normal
FROM lab11.pelanggan
WHERE nama ILIKE '%Pelanggan 12%';
COMMIT;
