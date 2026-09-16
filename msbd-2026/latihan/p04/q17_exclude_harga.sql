-- Diminta: Membuat tabel harga film dengan constraint EXCLUDE agar periode harga film dan wilayah tidak tumpang tindih.
-- Dipilih: EXCLUDE USING gist (film_id WITH =, wilayah WITH =, berlaku WITH &&) memakai ekstensi btree_gist.
-- Alternatif: Menggunakan trigger pengecekan manual; tidak dipilih karena rawan race condition pada transaksi konkuren.

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE IF NOT EXISTS lab4.harga_film (
    harga_film_id bigserial PRIMARY KEY,
    film_id integer NOT NULL REFERENCES lab4.film (film_id),
    wilayah text NOT NULL,
    harga numeric(5,2) NOT NULL CHECK (harga >= 0),
    berlaku daterange NOT NULL,
    EXCLUDE USING gist (film_id WITH =, wilayah WITH =, berlaku WITH &&)
);

-- INSERT 1 (Diterima)
INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
VALUES (1, 'ID', 2.99, daterange('2026-01-01', '2026-06-30'));

-- INSERT 2 (Ditolak karena tumpang tindih tanggal)
-- INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
-- VALUES (1, 'ID', 3.99, daterange('2026-05-01', '2026-12-31'));
