-- Diminta: Menulis trigger level pernyataan menggunakan transition table (OLD TABLE / NEW TABLE) untuk audit massal.
-- Dipilih: FOR EACH STATEMENT dengan REFERENCING OLD TABLE AS lama NEW TABLE AS baru.
-- Alternatif: Trigger FOR EACH ROW; tidak dipilih karena memicu fungsi berulang kali (N kali eksekusi) dibanding 1 kali query massal.

CREATE OR REPLACE FUNCTION lab4.catat_audit_massal()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO lab4.audit_harga (film_id, harga_lama, harga_baru)
    SELECT b.film_id, l.rental_rate, b.rental_rate
    FROM baru b
    JOIN lama l ON l.film_id = b.film_id
    WHERE l.rental_rate IS DISTINCT FROM b.rental_rate;
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS film_audit_harga ON lab4.film;
DROP TRIGGER IF EXISTS film_audit_harga_massal ON lab4.film;

CREATE TRIGGER film_audit_harga_massal
AFTER UPDATE ON lab4.film
REFERENCING OLD TABLE AS lama NEW TABLE AS baru
FOR EACH STATEMENT
EXECUTE FUNCTION lab4.catat_audit_massal();

\timing on
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;
