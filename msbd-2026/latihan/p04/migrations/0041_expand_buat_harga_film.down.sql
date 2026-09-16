-- Diminta: pasangan .down.sql untuk 0041.
-- Dipilih: DROP TABLE tabel baru saja; tidak menyentuh lab4.film karena
--          migrasi ini belum mengubah bentuk lama sama sekali.
-- Alternatif: DROP EXTENSION btree_gist sekaligus; tidak dipilih karena
--          ekstensi itu bisa dipakai fitur lain di skema yang sama,
--          drop-nya berisiko efek samping di luar migrasi ini.

SET search_path = lab4, public;

DROP TABLE IF EXISTS lab4.harga_film;
