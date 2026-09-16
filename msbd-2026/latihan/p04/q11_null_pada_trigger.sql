-- Diminta: Mengubah kondisi IS DISTINCT FROM menjadi <> lalu menguji perubahan dari/ke NULL.
-- Dipilih: Mengganti klausa WHEN memakai operator <> untuk mengamati kelemahan penanganan NULL.
-- Alternatif: Membiarkan IS DISTINCT FROM; tidak dipilih karena bertujuan mendemonstrasikan perilaku logis NULL pada SQL.

CREATE OR REPLACE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate <> NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_perubahan_harga();

-- Uji perubahan nilai biasa ke NULL
UPDATE lab4.film SET rental_rate = NULL WHERE film_id = 2;
-- Uji perubahan NULL ke nilai biasa
UPDATE lab4.film SET rental_rate = 1.99 WHERE film_id = 2;

-- Penjelasan: Dalam logika 3-nilai SQL (three-valued logic), perbandingan (NULL <> 1.99) bernilai UNKNOWN/NULL, bukan TRUE.
-- Akibatnya kondisi WHEN tidak terpenuhi sehingga perubahan dari/ke NULL gagal dicatat oleh trigger.
