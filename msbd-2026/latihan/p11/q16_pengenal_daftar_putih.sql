-- Diminta: menunjukkan bagian query yang tidak bisa diparameterkan (kolom dan
--          arah pengurutan) dan mengamankannya dengan daftar putih tertutup.
-- Dipilih: validasi ketat terhadap kamus tetap (allowlist) di aplikasi sebelum
--          menyusun klausa ORDER BY.
-- Alternatif: menyisipkan parameter %s di ORDER BY; tidak dipilih karena
--             placeholder SQL hanya untuk nilai literal, bukan identifier/keyword.

-- Jalankan di kontainer lab11-web:
-- 1) Valid:   python rentan.py urut kota turun  -> mengembalikan 10 baris terurut
-- 2) Ditolak: python rentan.py urut "nama; DROP TABLE lab11.pelanggan--" naik
--    Keluaran: ValueError: parameter pengurutan tidak dikenal

BEGIN;
SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

-- Contoh bentuk query yang hanya terbentuk setelah lulus daftar putih tertutup:
SELECT id, nama, kota
FROM lab11.pelanggan
ORDER BY kota DESC
LIMIT 10;
COMMIT;
