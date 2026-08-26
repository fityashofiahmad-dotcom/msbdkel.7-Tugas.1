\# Laporan Latihan Mandiri Pertemuan 1

\## Menyiapkan Lingkungan Kerja Basis Data



\### V3 — Lima Film dengan Jumlah Penyewaan Terbanyak



Query:



```sql

SELECT f.title, count(\*) AS total\_sewa

FROM rental r

JOIN inventory i

&#x20; ON i.inventory\_id = r.inventory\_id

JOIN film f

&#x20; ON f.film\_id = i.film\_id

GROUP BY f.title

ORDER BY total\_sewa DESC

LIMIT 5;

