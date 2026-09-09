-- Diminta: Menampilkan judul, kategori, tarif sewa, dan tiga jenis peringkat tarif di dalam kategorinya secara berdampingan.
-- Dipilih: Menggunakan klausa WINDOW w AS (...) di akhir query agar definisi partisi dan urutan (OVER w) tidak perlu ditulis berulang kali pada setiap fungsi.
-- Alternatif: Menulis partisi OVER(PARTITION BY...) secara eksplisit di masing-masing fungsi; tidak dipilih karena membuat query terlalu panjang dan rawan salah ketik.

SELECT
    f.title,
    c.name AS category_name,
    f.rental_rate,
    ROW_NUMBER() OVER w AS peringkat_row,
    RANK() OVER w AS peringkat_rank,
    DENSE_RANK() OVER w AS peringkat_dense
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WINDOW w AS (PARTITION BY c.name ORDER BY f.rental_rate DESC);