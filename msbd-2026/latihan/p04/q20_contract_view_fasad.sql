-- Diminta: fase contract. Buat view fasad yang mempertahankan bentuk lama
--          (lab4.film dengan kolom rental_rate) bagi pembaca lama, hentikan
--          tulis ganda, lalu drop kolom rental_rate asli. Sesi pembaca yang
--          menjalankan SELECT title, rental_rate FROM lab4.film LIMIT 5;
--          tidak boleh pernah gagal karena "relation does not exist".
-- Dipilih: RENAME tabel lab4.film -> lab4.film_dasar dan CREATE VIEW lab4.film
--          digabung dalam SATU transaksi (langkah A). Karena DDL di Postgres
--          transaksional dan RENAME mengambil ACCESS EXCLUSIVE lock, sesi lain
--          yang sedang SELECT dari lab4.film akan menunggu sebentar lalu
--          otomatis melihat objek baru (view) begitu transaksi commit -- nama
--          "lab4.film" tidak pernah kosong. FK harga_film->film tetap valid
--          karena constraint terikat ke OID relasi, bukan ke nama. Trigger
--          tulis ganda baru dihentikan dan kolom lama baru di-drop pada
--          transaksi TERPISAH (langkah B), setelah view fasad terbukti stabil,
--          karena men-drop trigger + kolom tidak bisa dibatalkan semudah
--          membuat view.
-- Alternatif: RENAME lebih dulu lalu CREATE VIEW belakangan sebagai dua
--          statement/transaksi terpisah tanpa BEGIN...COMMIT pembungkus.
--          Tidak dipilih -- inilah "urutan yang salah": ada jendela waktu
--          nyata setelah RENAME commit tapi sebelum CREATE VIEW commit di
--          mana nama lab4.film tidak menunjuk ke objek apa pun, sehingga
--          sesi pembaca yang kebetulan query pada jendela itu gagal dengan
--          galat "relation lab4.film does not exist".

SET search_path = lab4, public;

-- =====================================================================
-- LANGKAH A: rename + view fasad, ATOMIK dalam satu transaksi
-- =====================================================================
BEGIN;

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

COMMIT;

-- Uji dari sesi pembaca pada titik ini: query lama tetap jalan tanpa ubahan.
-- SELECT title, rental_rate FROM lab4.film LIMIT 5;

-- =====================================================================
-- LANGKAH B: hentikan tulis ganda, drop kolom lama (transaksi terpisah,
-- dijalankan setelah bukti view fasad stabil dikumpulkan -- lihat Q21/E)
-- =====================================================================
BEGIN;

DROP TRIGGER IF EXISTS film_tulis_ganda_harga ON lab4.film_dasar;
DROP FUNCTION IF EXISTS lab4.tulis_ganda_harga();

ALTER TABLE lab4.film_dasar DROP COLUMN rental_rate;

COMMIT;

-- Setelah Langkah B, lab4.film (view) tetap menyajikan rental_rate, sekarang
-- murni dari lab4.harga_film -- pembaca lama tidak melihat perbedaan apa pun.
