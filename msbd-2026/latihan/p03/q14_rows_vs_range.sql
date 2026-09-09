-- Diminta: Menjalankan ulang Q13 tanpa klausa frame (sehingga menggunakan RANGE default) dan membandingkan perbedaannya dengan hasil Q13.
-- Dipilih: Menggunakan operator EXCEPT untuk mencari baris dari hasil Q14 yang tidak ada di hasil Q13, guna menemukan secara tepat tanggal mana saja yang nilainya berubah.
-- Alternatif: Menggunakan FULL JOIN dengan kondisi WHERE untuk mengecek ketidakcocokan nilai; EXCEPT dipilih karena sintaksnya jauh lebih singkat dan otomatis membandingkan seluruh kolom.

WITH Harian AS (
    SELECT DATE(payment_date) AS payment_day, SUM(amount) AS omzet
    FROM payment
    GROUP BY DATE(payment_date)
),
Q13_Rows AS (
    SELECT
        payment_day,
        omzet,
        SUM(omzet) OVER (ORDER BY payment_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS kumulatif,
        ROUND(AVG(omzet) OVER (ORDER BY payment_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rerata_7hari
    FROM Harian
),
Q14_Range AS (
    SELECT
        payment_day,
        omzet,
        SUM(omzet) OVER (ORDER BY payment_day) AS kumulatif,
        ROUND(AVG(omzet) OVER (ORDER BY payment_day), 2) AS rerata_7hari
    FROM Harian
)
SELECT * FROM Q14_Range
EXCEPT
SELECT * FROM Q13_Rows
ORDER BY payment_day;