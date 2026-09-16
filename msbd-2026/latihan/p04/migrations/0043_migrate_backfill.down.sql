-- Diminta: pasangan .down.sql untuk 0043.
-- Dipilih: hapus baris hasil backfill (wilayah 'ID') dan procedure-nya.
--          Ini AMAN diurungkan karena 0043 hanya menyalin data yang sumber
--          aslinya (rental_rate di lab4.film) masih utuh pada tahap ini.
-- Alternatif: tidak menyediakan down sama sekali karena "backfill idealnya
--          tidak pernah diurungkan"; tidak dipilih karena pada tahap 0043
--          kolom lama belum di-drop (baru terjadi di 0046), jadi rollback
--          di titik ini masih murni dan tanpa risiko kehilangan data.

SET search_path = lab4, public;

DELETE FROM lab4.harga_film WHERE wilayah = 'ID';
DROP PROCEDURE IF EXISTS lab4.backfill_harga_film(int);
