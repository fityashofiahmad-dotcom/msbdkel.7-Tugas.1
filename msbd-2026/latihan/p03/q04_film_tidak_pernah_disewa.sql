-- versi NOT IN --
SELECT title
FROM film
WHERE film_id NOT IN (
    SELECT DISTINCT i.film_id
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
);

-- versi NOT EXISTS --
SELECT f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE i.film_id = f.film_id
);