SELECT DISTINCT
    i.store_id,
    f.title,
    f.rental_rate
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.rental_rate = (
    SELECT MAX(f_sub.rental_rate)
    FROM inventory i_sub
    JOIN film f_sub ON i_sub.film_id = f_sub.film_id
    WHERE i_sub.store_id = i.store_id
);