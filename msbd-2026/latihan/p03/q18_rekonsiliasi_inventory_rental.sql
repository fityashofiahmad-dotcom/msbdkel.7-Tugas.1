-- Diminta: film_id yang ada di inventory tetapi tidak pernah muncul lewat rental, dan arah
--   sebaliknya, dalam satu hasil dengan kolom penanda arah.
-- Dipilih: (A EXCEPT B) UNION ALL (B EXCEPT A) pada dua himpunan film_id (inventory_film dan
--   rental_film), lalu kolom "arah" ditempelkan setelah masing-masing EXCEPT selesai dihitung
--   sebagai literal pada SELECT terluar tiap cabang.
-- Alternatif: dua LEFT JOIN ... WHERE ... IS NULL yang digabung UNION ALL; tidak dipilih karena
--   EXCEPT lebih ringkas menyatakan "ada di himpunan ini, tidak ada di himpunan itu" untuk kasus
--   selisih himpunan murni seperti ini, dan petunjuk soal memang mengarahkan ke EXCEPT.

WITH inventory_film AS (
    SELECT DISTINCT i.film_id FROM inventory i
),
rental_film AS (
    SELECT DISTINCT i.film_id
    FROM rental r
    JOIN inventory i ON i.inventory_id = r.inventory_id
)
SELECT a.film_id, 'inventory_tanpa_rental' AS arah
FROM (
    SELECT film_id FROM inventory_film
    EXCEPT
    SELECT film_id FROM rental_film
) AS a

UNION ALL

SELECT b.film_id, 'rental_tanpa_inventory' AS arah
FROM (
    SELECT film_id FROM rental_film
    EXCEPT
    SELECT film_id FROM inventory_film
) AS b

ORDER BY arah, film_id;