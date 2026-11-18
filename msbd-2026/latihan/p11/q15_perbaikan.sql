-- Diminta: memperbaiki fungsi pencarian dengan query berparameter (cari_aman),
--          mengulang payload yang sama, dan menjelaskan keunggulan parameterisasi.
-- Dipilih: PREPARE / placeholder parameter ($1 atau %s) agar masukan pengguna
--          selalu diperlakukan sebagai nilai literal string.
-- Alternatif: blacklist karakter kutip/komentar; tidak dipilih karena daftar
--             hitam selalu bisa dilewati dan merusak masukan sah (mis. O'Connor).

-- Jalankan di kontainer lab11-web:
-- python rentan.py aman "zz' OR '1'='1' --"
-- Keluaran: Jumlah baris: 0 (tidak ada galat sintaks maupun kebocoran baris)

BEGIN;
SET LOCAL ROLE app_laporan;
SET LOCAL app.tenant = '1';

PREPARE cari_aman_stmt (text) AS
SELECT id, nama, kota
FROM lab11.pelanggan
WHERE nama ILIKE $1
LIMIT 100;

EXECUTE cari_aman_stmt('%zz'' OR ''1''=''1'' --%');
DEALLOCATE cari_aman_stmt;
COMMIT;

-- Mengapa penyaringan karakter tidak akan mencapai hasil yang sama:
-- Penyaringan karakter tetap membiarkan masukan pengguna menyatu ke dalam string
-- perintah SQL, sehingga rentan terlewat oleh variasi sintaks/encoding atau
-- memblokir data asli yang sah. Query berparameter memisahkan pohon sintaks SQL
-- dari nilai data pada level protokol, sehingga nilai tidak pernah dieksekusi
-- sebagai kode SQL.
