-- Diminta: tahap migrate pertama - backfill harga_film dari data film lama
--          dalam potongan, bukan satu UPDATE besar. Sama seperti q19.
-- Dipilih: PROCEDURE dengan loop 1000 baris per batch + COMMIT tiap batch,
--          dipanggil lewat CALL agar transaksi pendek per batch dan progres
--          tidak hilang jika terhenti di tengah jalan.
-- Alternatif: banyak file migrasi kecil (satu per rentang film_id) yang
--          dijalankan tool migrasi satu per satu; tidak dipilih karena
--          jumlah film di produksi tidak diketahui saat menulis migrasi,
--          sedangkan procedure ini otomatis menyesuaikan dari max(film_id).

SET search_path = lab4, public;

CREATE OR REPLACE PROCEDURE lab4.backfill_harga_film(ukuran_batch int DEFAULT 1000)
LANGUAGE plpgsql AS $$
DECLARE
    batch_awal int;
    batch_akhir int;
    id_maks int;
BEGIN
    SELECT max(film_id) INTO id_maks FROM lab4.film;
    batch_awal := 1;

    WHILE batch_awal <= id_maks LOOP
        batch_akhir := batch_awal + ukuran_batch - 1;

        INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
        SELECT f.film_id, 'ID', f.rental_rate, daterange('2026-01-01', NULL)
        FROM lab4.film f
        WHERE f.film_id BETWEEN batch_awal AND batch_akhir
          AND NOT EXISTS (
              SELECT 1 FROM lab4.harga_film h
              WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
          );

        COMMIT;
        batch_awal := batch_akhir + 1;
    END LOOP;
END;
$$;

CALL lab4.backfill_harga_film(1000);
