-- Diminta: Membuat ulang view dengan CASCADED CHECK OPTION --

CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99
WITH CASCADED CHECK OPTION;

-- Diminta: Mengulang penyisipan data dengan mencoba memasukkan film melalui view dengan tarif di luar filter (rental_rate = 4.99) --

INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (1002, 'Film Gagal Masuk', 4.99, 'PG');