-- Diminta: Membuat view dengan GROUP BY --

CREATE OR REPLACE VIEW lab4.pendapatan_kategori AS
SELECT c.name AS category_name, SUM(p.amount) AS total_revenue
FROM public.category c
JOIN public.film_category fc ON c.category_id = fc.category_id
JOIN public.inventory i ON fc.film_id = i.film_id
JOIN public.rental r ON i.inventory_id = r.inventory_id
JOIN public.payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

-- Diminta: Menyisipkan baris melalui view --

-- ERROR: cannot insert into view "pendapatan_kategori" Detail: Views containing GROUP BY are not automatically updatable. Hint: To enable inserting into the view, provide an INSTEAD OF INSERT trigger or an unconditional ON INSERT DO INSTEAD rule.  --