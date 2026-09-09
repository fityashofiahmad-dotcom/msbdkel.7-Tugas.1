-- Diminta: Menampilkan omzet harian, omzet hari sebelumnya, selisih omzet, dan persentase perubahannya.
-- Dipilih: Menggunakan fungsi LAG() dengan nilai pengganti default 0 untuk menangani perhitungan pada hari pertama transaksi tanpa menghasilkan nilai NULL yang mengacaukan operasi matematika.
-- Alternatif: Menggunakan Self-Join berdasarkan selisih tanggal (payment_date - 1); tidak dipilih karena fungsi LAG() jauh lebih efisien membaca baris sebelumnya dalam satu kali pemindaian urutan.

WITH DailyRevenue AS (
    SELECT
        DATE(payment_date) AS payment_day,
        SUM(amount) AS daily_omzet
    FROM payment
    GROUP BY DATE(payment_date)
)
SELECT
    payment_day,
    daily_omzet,
    LAG(daily_omzet, 1, 0) OVER (ORDER BY payment_day) AS omzet_kemarin,
    (daily_omzet - LAG(daily_omzet, 1, 0) OVER (ORDER BY payment_day)) AS selisih,
    CASE
        WHEN LAG(daily_omzet, 1, 0) OVER (ORDER BY payment_day) = 0 THEN NULL
        ELSE ROUND(((daily_omzet - LAG(daily_omzet, 1, 0) OVER (ORDER BY payment_day)) / LAG(daily_omzet, 1, 0) OVER (ORDER BY payment_day)) * 100, 2)
    END AS persentase_perubahan
FROM DailyRevenue;