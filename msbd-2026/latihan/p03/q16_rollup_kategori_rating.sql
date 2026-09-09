-- Diminta: satu query menghasilkan jumlah film dan rata-rata tarif untuk setiap pasangan
--   kategori-rating, subtotal per kategori, dan grand total dalam satu hasil, dengan label SEMUA
--   pada baris subtotal.
-- Dipilih: GROUP BY ROLLUP (kategori, rating) dan GROUPING() untuk mendeteksi baris
--   subtotal/grand-total, lalu CASE mengganti NULL bawaan ROLLUP dengan label 'SEMUA'.
-- Alternatif: GROUP BY CUBE(kategori, rating); tidak dipilih karena CUBE juga menghasilkan
--   subtotal per rating saja (lintas semua kategori) yang tidak diminta soal — ROLLUP sudah
--   cukup dan menghasilkan lebih sedikit baris berlebih.

SELECT
    CASE WHEN GROUPING(c.name) = 1 THEN 'SEMUA' ELSE c.name END AS kategori,
    CASE WHEN GROUPING(f.rating) = 1 THEN 'SEMUA' ELSE f.rating::text END AS rating,
    count(*) AS jumlah_film,
    round(avg(f.rental_rate), 2) AS rata_rata_tarif,
    GROUPING(c.name) AS grp_kategori,
    GROUPING(f.rating) AS grp_rating
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY ROLLUP (c.name, f.rating)
ORDER BY c.name NULLS LAST, f.rating NULLS LAST;