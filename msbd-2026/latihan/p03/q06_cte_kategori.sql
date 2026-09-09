-- Diminta: menulis ulang Q2 memakai CTE, ditambah CTE kedua yang menghitung rata-rata tarif sewa
--   per kategori. Keluaran akhir: nama kategori, jumlah film, dan rata-rata tarif.
-- Dipilih: dua CTE berurutan — CTE pertama (jumlah_film) menghitung count per kategori dengan
--   HAVING > 60, CTE kedua (rata_tarif) merujuk CTE pertama untuk membatasi hanya kategori yang
--   lolos filter, lalu menghitung AVG(rental_rate) pada kategori tersebut.
-- Alternatif: satu query tunggal dengan derived table bersarang; tidak dipilih karena CTE lebih
--   mudah dibaca urutan langkahnya (hitung jumlah dulu, filter, baru hitung rata-rata) dibanding
--   subquery bersarang dalam satu FROM.

WITH jumlah_film AS (
    SELECT c.category_id, c.name AS kategori, count(*) AS jumlah
    FROM category c
    JOIN film_category fc ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
    HAVING count(*) > 60
),
rata_tarif AS (
    SELECT jf.category_id, jf.kategori, jf.jumlah, avg(f.rental_rate) AS rata_rata_tarif
    FROM jumlah_film jf
    JOIN film_category fc ON fc.category_id = jf.category_id
    JOIN film f ON f.film_id = fc.film_id
    GROUP BY jf.category_id, jf.kategori, jf.jumlah
)
SELECT kategori, jumlah, round(rata_rata_tarif, 2) AS rata_rata_tarif
FROM rata_tarif
ORDER BY jumlah DESC;