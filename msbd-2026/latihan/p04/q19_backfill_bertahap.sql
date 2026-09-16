-- Diminta: fase migrate. Backfill harga_film dari film dalam potongan 1000
--          film (bukan satu UPDATE/INSERT besar), ulangi untuk seluruh
--          rentang film_id, lalu jalankan verifikasi yang harus bernilai nol.
-- Dipilih: PROCEDURE plpgsql dengan loop per 1000 film dan COMMIT di setiap
--          iterasi. COMMIT hanya tersedia dalam PROCEDURE yang dipanggil lewat
--          CALL (bukan DO block), sehingga tiap batch jadi transaksi pendek
--          sendiri: kunci baris dilepas cepat, progres tersimpan permanen
--          walau backfill terhenti di tengah jalan, dan sesi pembaca tidak
--          pernah menunggu lock dalam waktu lama.
-- Alternatif: satu INSERT ... SELECT tanpa batas WHERE film_id BETWEEN ...;
--          tidak dipilih karena pada tabel besar itu memegang kunci lebih
--          lama, memperbesar risiko konflik dengan trigger tulis ganda Q18,
--          dan jika gagal di tengah harus diulang dari awal (bukan dari titik
--          terakhir).

SET search_path = lab4, public;

CREATE OR REPLACE PROCEDURE lab4.backfill_harga_film(ukuran_batch int DEFAULT 1000)
LANGUAGE plpgsql AS $$
DECLARE
    batch_awal int;
    batch_akhir int;
    id_maks int;
    baris_disisipkan int;
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

        GET DIAGNOSTICS baris_disisipkan = ROW_COUNT;
        RAISE NOTICE 'Batch % - %: % baris disisipkan', batch_awal, batch_akhir, baris_disisipkan;

        COMMIT;
        batch_awal := batch_akhir + 1;
    END LOOP;
END;
$$;

CALL lab4.backfill_harga_film(1000);

-- Verifikasi: harus menghasilkan nol sebelum lanjut ke fase contract (Q20)
SELECT count(*) AS film_belum_terbackfill
FROM lab4.film f
WHERE NOT EXISTS (
    SELECT 1 FROM lab4.harga_film h
    WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
);
