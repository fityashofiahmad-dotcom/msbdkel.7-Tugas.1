-- Diminta: Membuat fungsi untuk menghitung total pembayaran suatu penyewaan.
-- Dipilih: Menggunakan COALESCE(sum(amount), 0) agar nilai NULL berubah jadi 0.
-- Alternatif: Mengembalikan NULL jika belum ada pembayaran; tidak dipilih karena menyulitkan perhitungan di aplikasi.

CREATE OR REPLACE FUNCTION lab5.total_dibayar(p_rental_id bigint)
RETURNS numeric LANGUAGE sql STABLE AS $$
SELECT coalesce(sum(amount), 0) FROM lab5.payment_tx WHERE rental_id = p_rental_id;
$$;