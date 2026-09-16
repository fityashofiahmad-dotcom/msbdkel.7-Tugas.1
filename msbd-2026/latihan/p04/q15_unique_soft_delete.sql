-- Diminta: Menguji UNIQUE constraint biasa pada soft delete, lalu menggantinya dengan unique index parsial.
-- Dipilih: UNIQUE INDEX ... WHERE deleted_at IS NULL.
-- Alternatif: UNIQUE constraint standar; tidak dipilih karena mencegah pendaftaran ulang judul yang sudah dihapus secara soft-delete.

ALTER TABLE lab4.film ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- Solusi Unique Index Parsial
ALTER TABLE lab4.film DROP CONSTRAINT IF EXISTS film_judul_unik;
DROP INDEX IF EXISTS lab4.ux_film_judul_aktif;

CREATE UNIQUE INDEX ux_film_judul_aktif ON lab4.film (title) WHERE deleted_at IS NULL;
