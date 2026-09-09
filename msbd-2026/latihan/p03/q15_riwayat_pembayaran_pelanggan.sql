-- Diminta: Menampilkan urutan pembayaran pelanggan, jarak hari sejak pembayaran sebelumnya, dan total belanja pelanggan.
-- Dipilih: Menghilangkan klausa ORDER BY di dalam OVER() pada perhitungan total belanja agar default frame-nya mencakup seluruh baris di dalam partisi (seluruh transaksi milik pelanggan tersebut).
-- Alternatif: Menggunakan GROUP BY pada subquery terpisah lalu di-JOIN; tidak dipilih karena window function bisa menyelesaikannya secara elegan dalam satu iterasi.

SELECT
    customer_id,
    payment_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS urutan_pembayaran,
    EXTRACT(DAY FROM (payment_date - LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date))) AS jarak_hari,
    SUM(amount) OVER (PARTITION BY customer_id) AS total_belanja
FROM payment
ORDER BY customer_id, urutan_pembayaran;