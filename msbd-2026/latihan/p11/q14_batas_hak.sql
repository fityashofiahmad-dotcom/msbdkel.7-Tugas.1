-- Diminta: mengulang payload SQL injection lewat peran app_laporan yang hanya
--          anggota app_read dan tunduk RLS, lalu menganalisis dampaknya.
-- Dipilih: menjalankan query terinjeksi di bawah SET LOCAL ROLE app_laporan
--          dengan konteks tenant 1 untuk mengamati pembatasan radius bocor.
-- Alternatif: mengandalkan pembatasan hak saja tanpa memperbaiki kode; tidak
--             dipilih karena kebocoran data dalam satu penyewa tetap terjadi.

BEGIN;
SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

-- Payload tetap berhasil memanipulasi WHERE dalam batas penyewa 1:
SELECT count(*) AS bocor_tenant_1
FROM lab11.pelanggan
WHERE nama ILIKE '%zz' OR '1'='1' --%';

-- Kebijakan RLS tetap menahan akses ke penyewa lain (harus 0):
SELECT count(*) AS bocor_tenant_lain
FROM lab11.pelanggan
WHERE (nama ILIKE '%zz' OR '1'='1' --%') AND tenant_id <> 1;

COMMIT;

-- Analisis (kaitkan dengan prinsip hak minimum per tabel):
-- 1. Yang berubah: jumlah baris terbatasi hanya pada 10.000 baris milik penyewa 1
--    (tidak menyentuh 20.000 baris penyewa 2 & 3 berkat RLS), serta peran
--    app_laporan tidak bisa membaca tabel sensitif lain (seperti lab11.akun)
--    atau melakukan UPDATE/DELETE/DROP.
-- 2. Yang tetap: celah SQL injection tetap aktif dan membocorkan seluruh baris
--    pelanggan pada penyewa 1. Hak minimum per tabel memperkecil radius ledakan
--    kebocoran, tetapi tidak menghilangkan kerentanan injeksi di aplikasi.
