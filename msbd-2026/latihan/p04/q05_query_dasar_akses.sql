-- Diminta: Menjalankan query agregasi jejak akses bulanan per kanal dengan timing aktif dan mencatat waktunya.
-- Dipilih: Menggunakan GROUP BY 1, 2 pada date_trunc('month', waktu) dan kanal langsung pada tabel lab4.jejak_akses.
-- Alternatif: Menggunakan subquery/CTE; tidak dipilih karena query agregasi sederhana sudah cukup representatif untuk mengukur baseline performa.

\timing on

SELECT date_trunc('month', a.waktu) AS bulan,
       a.kanal,
       count(*) AS jumlah_akses,
       count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2;