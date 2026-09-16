-- Diminta: tahap contract terakhir - hentikan tulis ganda dan drop kolom
--          rental_rate asli dari tabel dasar. Sama seperti Langkah B pada
--          q20. Dijalankan sebagai migrasi TERPISAH dan HANYA setelah bukti
--          view fasad (0045) stabil terkumpul -- lihat Refleksi E.
-- Dipilih: DROP TRIGGER lalu DROP FUNCTION lalu ALTER TABLE ... DROP COLUMN,
--          urutan ini wajib karena trigger AFTER UPDATE OF rental_rate akan
--          gagal referensi kolom begitu kolomnya hilang.
-- Alternatif: DROP COLUMN ... CASCADE agar trigger ikut terhapus otomatis;
--          tidak dipilih karena CASCADE pada DROP COLUMN di Postgres hanya
--          menghapus objek yang BERGANTUNG pada kolom tsb (mis. index),
--          bukan trigger level tabel -- trigger tetap harus di-drop manual.

SET search_path = lab4, public;

DROP TRIGGER IF EXISTS film_tulis_ganda_harga ON lab4.film_dasar;
DROP FUNCTION IF EXISTS lab4.tulis_ganda_harga();

ALTER TABLE lab4.film_dasar DROP COLUMN rental_rate;
