-- Diminta: Mengukur waktu eksekusi UPDATE massal saat trigger aktif vs nonaktif.
-- Dipilih: UPDATE massal seluruh tabel lab4.film dan mencatat timing.
-- Alternatif: Mengubah sebagian baris; tidak dipilih karena beban per baris lebih terlihat pada dataset utuh.

-- Kembalikan trigger ke kondisi aman (IS DISTINCT FROM)
CREATE OR REPLACE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_perubahan_harga();

\timing on

-- Trigger aktif
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;

-- Nonaktifkan trigger
ALTER TABLE lab4.film DISABLE TRIGGER film_audit_harga;

-- Trigger nonaktif
UPDATE lab4.film SET rental_rate = rental_rate + 0.01;

-- Aktifkan kembali trigger
ALTER TABLE lab4.film ENABLE TRIGGER film_audit_harga;
