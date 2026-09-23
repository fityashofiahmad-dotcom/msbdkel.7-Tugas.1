-- Diminta: Membuktikan perilaku rollback saat terjadi pelanggaran kendala data (domain positive_amount).
-- Dipilih: Menjalankan procedure dengan amount negatif (-4.99) untuk memicu check constraint.
-- Alternatif: Menguji dengan data foreign key yang salah; tidak dipilih karena fokus soal menguji validasi nilai amount negatif.

-- 1. Panggil procedure dengan p_amount negatif
CALL lab5.process_rental(
    1, 1, 1, -4.99
);

-- 2. Hitung jumlah baris rental_tx sesudahnya
SELECT count(*) FROM lab5.rental_tx;