-- Diminta: fase expand migrasi rental_rate -> harga_film. Buat struktur baru
--          (lab4.harga_film sudah ada dari Q17) dan pasang trigger tulis ganda
--          agar perubahan rental_rate pada bentuk lama tercermin di bentuk baru.
--          Sesi pembaca (SELECT title, rental_rate FROM lab4.film) harus tetap
--          berjalan tanpa gangguan sepanjang tugas ini.
-- Dipilih: trigger AFTER INSERT OR UPDATE OF rental_rate pada lab4.film yang
--          menutup periode harga lama (upper_inf(berlaku) -> hari ini) lalu
--          membuka periode baru. Urutan tutup-lalu-buka wajib agar tidak
--          melanggar EXCLUDE USING gist (film_id, wilayah, berlaku) dari Q17.
--          Trigger dipasang AFTER (bukan BEFORE) karena tulis ganda adalah efek
--          samping, bukan validasi terhadap baris film itu sendiri.
-- Alternatif: menyalin seluruh rental_rate lewat satu UPDATE massal saat itu
--          juga (tanpa trigger); tidak dipilih karena baris yang ditulis
--          setelah expand dimulai tapi sebelum backfill akan hilang dari
--          harga_film, membuat backfill tidak pernah benar-benar mencapai nol.

SET search_path = lab4, public;

CREATE OR REPLACE FUNCTION lab4.tulis_ganda_harga()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
        VALUES (NEW.film_id, 'ID', NEW.rental_rate, daterange(current_date, NULL));

    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.rental_rate IS DISTINCT FROM OLD.rental_rate THEN
            -- Tutup periode harga lama yang masih terbuka, agar tidak
            -- tumpang tindih (&&) dengan periode baru saat disisipkan.
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

-- Uji cepat: ubah satu harga, buktikan muncul di harga_film
-- UPDATE lab4.film SET rental_rate = rental_rate + 1.00 WHERE film_id = 1;
-- SELECT * FROM lab4.harga_film WHERE film_id = 1 ORDER BY berlaku;
