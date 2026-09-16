-- Diminta: pasangan .down.sql untuk 0046.
-- Dipilih: hanya menambahkan kembali KOLOM rental_rate (nullable, tanpa
--          isi) dan memasang ulang trigger tulis ganda -- TIDAK mengisi
--          ulang nilai harga lama, karena data itu sudah tidak ada lagi di
--          mana pun setelah up dijalankan.
-- Alternatif: mengisi ulang rental_rate dari harga_film terbaru
--          (UPDATE ... FROM harga_film); tidak dipilih sebagai "rollback
--          sejati" karena migrasi ini didokumentasikan sebagai TIDAK BISA
--          diurungkan sepenuhnya (lihat catatan rollback di soal) --
--          menyamarkannya sebagai pemulihan penuh menyesatkan pembaca
--          migrasi ini di kemudian hari.

SET search_path = lab4, public;

ALTER TABLE lab4.film_dasar ADD COLUMN rental_rate numeric(5,2);

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
            WHERE film_id = OLD.film_id AND wilayah = 'ID' AND upper_inf(berlaku);

            INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
            VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(current_date, NULL));
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER film_tulis_ganda_harga
AFTER INSERT OR UPDATE OF rental_rate ON lab4.film_dasar
FOR EACH ROW
EXECUTE FUNCTION lab4.tulis_ganda_harga();

-- CATATAN: rental_rate di atas berisi NULL untuk semua baris. Tidak ada
-- rollback yang dapat mengembalikan nilai harga lama yang sudah dibuang.
