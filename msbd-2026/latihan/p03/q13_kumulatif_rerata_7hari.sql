-- Diminta: Menampilkan omzet harian, total kumulatif sejak hari pertama, dan rata-rata bergerak 7 hari.
-- Dipilih: Menggunakan window function dengan frame ROWS eksplisit (6 PRECEDING AND CURRENT ROW) untuk membatasi rentang rata-rata bergerak tepat pada 7 baris terakhir.
-- Alternatif: Menggunakan subquery berkorelasi dengan filter tanggal; tidak dipilih karena performanya jauh lebih lambat dibandingkan window function.

WITH Harian AS (
    SELECT DATE(payment_date) AS payment_day, SUM(amount) AS omzet
    FROM payment
    GROUP BY DATE(payment_date)
)
SELECT
    payment_day,
    omzet,
    SUM(omzet) OVER (ORDER BY payment_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS kumulatif,
    ROUND(AVG(omzet) OVER (ORDER BY payment_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rerata_7hari
FROM Harian;