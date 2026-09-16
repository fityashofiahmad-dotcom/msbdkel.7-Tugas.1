-- Diminta: tahap expand kedua - pasang tulis ganda dari film ke harga_film.
-- Dipilih: fungsi + trigger AFTER INSERT OR UPDATE OF rental_rate, menutup
--          periode lama (upper_inf) sebelum membuka periode baru agar tidak
--          melanggar EXCLUDE dari 0041. Sama seperti q18.
-- Alternatif: trigger BEFORE yang memodifikasi NEW; tidak dipilih karena
--          tulis ganda menyasar tabel LAIN (harga_film), bukan baris film
--          itu sendiri, sehingga secara semantik ini efek samping (AFTER),
--          bukan validasi/transformasi baris (BEFORE).

SET search_path = lab4, public;

CREATE OR REPLACE FUNCTION lab4.tulis_ganda_harga()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
        VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(current_date, NULL));

    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.rental_rate IS DISTINCT FROM OLD.rental_rate THEN
            UPDATE lab4.harga_film
            SET berlaku = daterange(lower(berlaku), current_date)
            WHERE film_id = OLD.film_id
              AND wilayah = 'ID'
              AND upper_inf(berlaku);

            INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
            VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(current_date, NULL));
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS film_tulis_ganda_harga ON lab4.film;

CREATE TRIGGER film_tulis_ganda_harga
AFTER INSERT OR UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
EXECUTE FUNCTION lab4.tulis_ganda_harga();
