-- Diminta: Tiga film dengan tarif sewa tertinggi di setiap kategori.
-- Dipilih: Menghitung fungsi DENSE_RANK() di dalam CTE terlebih dahulu, lalu menyaring hasilnya di query utama (WHERE rnk <= 3) karena fungsi window dievaluasi setelah klausa WHERE di lapisan yang sama.
-- Alternatif: Menggunakan subquery/derived table di FROM; CTE dipilih karena alur logikanya lebih mudah dibaca dari atas ke bawah.

WITH RankedFilms AS (
    SELECT
        f.title,
        c.name AS category_name,
        f.rental_rate,
        DENSE_RANK() OVER (PARTITION BY c.name ORDER BY f.rental_rate DESC) AS rnk
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
)
SELECT title, category_name, rental_rate
FROM RankedFilms
WHERE rnk <= 3;