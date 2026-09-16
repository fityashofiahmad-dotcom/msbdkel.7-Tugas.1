-- Diminta: tahap migrate kedua - verifikasi bahwa backfill 0043 lengkap
--          (hasil harus nol) sebelum fase contract diizinkan berjalan.
-- Dipilih: fungsi pemeriksa yang RAISE EXCEPTION jika masih ada film tanpa
--          harga, dipanggil lewat DO block. Migrasi jadi gagal (dan tool
--          migrasi berhenti) alih-alih diam-diam lanjut ke 0045 dengan data
--          tidak lengkap.
-- Alternatif: hanya SELECT count(*) tanpa penegakan (seperti pada q19);
--          tidak dipilih untuk file migrasi karena hasil SELECT biasa tidak
--          menghentikan pipeline migrasi otomatis bila count(*) > 0.

SET search_path = lab4, public;

DO $$
DECLARE
    sisa int;
BEGIN
    SELECT count(*) INTO sisa
    FROM lab4.film f
    WHERE NOT EXISTS (
        SELECT 1 FROM lab4.harga_film h
        WHERE h.film_id = f.film_id AND h.wilayah = 'ID'
    );

    IF sisa > 0 THEN
        RAISE EXCEPTION 'Verifikasi backfill gagal: % film belum punya harga_film', sisa;
    END IF;
END;
$$;
