-- Diminta: tahap contract pertama - rename tabel lama + buat view fasad
--          bernama sama, atomik, agar pembaca lama tidak pernah melihat nama
--          lab4.film menghilang. Sama seperti Langkah A pada q20.
-- Dipilih: satu transaksi (implisit -- file migrasi dijalankan sebagai satu
--          transaksi oleh tool migrasi) berisi RENAME lalu CREATE VIEW.
-- Alternatif: lihat q20 -- RENAME dan CREATE VIEW sebagai dua migrasi/
--          transaksi terpisah; tidak dipilih karena membuka jendela waktu
--          nyata di mana lab4.film tidak ada, dan sesi pembaca yang query
--          pada jendela itu gagal dengan "relation does not exist".

SET search_path = lab4, public;

ALTER TABLE lab4.film RENAME TO film_dasar;

CREATE VIEW lab4.film AS
SELECT
    fd.film_id,
    fd.title,
    fd.description,
    fd.release_year,
    fd.language_id,
    fd.rental_duration,
    hf.harga                AS rental_rate,
    fd.length,
    fd.replacement_cost,
    fd.rating,
    fd.last_update,
    fd.special_features,
    fd.fulltext
FROM lab4.film_dasar fd
LEFT JOIN lab4.harga_film hf
       ON hf.film_id = fd.film_id
      AND hf.wilayah  = 'ID'
      AND hf.berlaku @> current_date;
