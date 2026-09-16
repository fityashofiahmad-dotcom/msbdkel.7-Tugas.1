-- Diminta: tahap expand pertama - buat struktur baru (tabel harga per wilayah)
--          tanpa menyentuh data/kolom lama.
-- Dipilih: CREATE EXTENSION btree_gist + tabel dengan EXCLUDE USING gist agar
--          periode harga per (film_id, wilayah) tidak pernah tumpang tindih,
--          dijamin benar oleh index, bukan oleh disiplin trigger/aplikasi.
-- Alternatif: UNIQUE(film_id, wilayah, berlaku) biasa; tidak dipilih karena
--          unique constraint hanya menolak baris IDENTIK, bukan baris yang
--          rentang tanggalnya beririsan.

SET search_path = lab4, public;

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE IF NOT EXISTS lab4.harga_film (
    harga_film_id bigserial PRIMARY KEY,
    film_id      integer NOT NULL REFERENCES lab4.film (film_id),
    wilayah      text NOT NULL,
    harga        numeric(5,2) NOT NULL CHECK (harga >= 0),
    berlaku      daterange NOT NULL,
    EXCLUDE USING gist (film_id WITH =, wilayah WITH =, berlaku WITH &&)
);
