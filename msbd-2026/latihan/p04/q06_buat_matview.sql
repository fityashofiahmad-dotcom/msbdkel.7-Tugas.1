-- Diminta: Membuat Materialized View lab4.ringkasan_akses dengan klausa WITH NO DATA, menguji pembacaan awal, dan me-refresh data.
-- Dipilih: CREATE MATERIALIZED VIEW ... WITH NO DATA untuk menunda pengisian data awal hingga REFRESH pertama dijalankan.
-- Alternatif: Membuat langsung dengan data; tidak dipilih karena soal secara spesifik meminta pengujian perilaku pembacaan saat data belum terisi.

CREATE MATERIALIZED VIEW lab4.ringkasan_akses AS
SELECT date_trunc('month', a.waktu) AS bulan,
       a.kanal,
       count(*) AS jumlah_akses,
       count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2
WITH NO DATA;

-- Percobaan membaca sebelum refresh (akan menghasilkan error):
-- SELECT * FROM lab4.ringkasan_akses;
-- Pesan Galat: ERROR: materialized view "ringkasan_akses" has not been populated

-- Melakukan REFRESH biasa
\timing on
REFRESH MATERIALIZED VIEW lab4.ringkasan_akses;