-- subquery versi HAVING --
SELECT c.name AS category_name, COUNT(fc.film_id) AS total_films
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
HAVING COUNT(fc.film_id) > 60;

-- subquery versi Derived Table di FROM --
SELECT category_name, total_films
FROM (
    SELECT c.name AS category_name, COUNT(fc.film_id) AS total_films
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    GROUP BY c.name
) AS derived_table
WHERE total_films > 60;