-- Diminta: pasangan .down.sql untuk 0045.
-- Dipilih: DROP VIEW lalu RENAME tabel dasar kembali ke nama semula, atomik
--          dalam satu transaksi, simetris dengan file up-nya.
-- Alternatif: RENAME dulu baru DROP VIEW; tidak dipilih karena RENAME
--          film_dasar -> film akan gagal selama view lab4.film masih ada
--          (nama bentrok), jadi urutan DROP VIEW dulu adalah satu-satunya
--          yang valid.

SET search_path = lab4, public;

DROP VIEW IF EXISTS lab4.film;
ALTER TABLE lab4.film_dasar RENAME TO film;
