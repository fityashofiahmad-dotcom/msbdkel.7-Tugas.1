-- Diminta: per kategori — jumlah film total, jumlah film rating G, jumlah film rating PG-13, dan
--   rata-rata durasi film berdurasi lebih dari 90 menit, dalam satu baris per kategori. Tulis
--   versi agregat FILTER dan versi CASE WHEN, lalu jelaskan perbedaan hasil rata-ratanya.
-- Dipilih: versi utama memakai agregat FILTER karena sintaksnya menyatakan langsung "hitung X
--   HANYA untuk baris yang memenuhi syarat Y" tanpa perlu mengubah nilai menjadi 0/NULL manual.
-- Alternatif: CASE WHEN di dalam count()/avg(); tetap ditulis di bawah sebagai pembanding karena
--   soal secara eksplisit meminta kedua versi dibandingkan hasil rata-ratanya.

SET search_path = public;

-- Versi 1: agregat FILTER
SELECT
    c.name AS kategori,
    count(*) AS total_film,
    count(*) FILTER (WHERE f.rating = 'G') AS jumlah_g,
    count(*) FILTER (WHERE f.rating = 'PG-13') AS jumlah_pg13,
    round(avg(f.length) FILTER (WHERE f.length > 90), 2) AS rata_durasi_lebih_90
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY c.name;

-- Versi 2: CASE WHEN
SELECT
    c.name AS kategori,
    count(*) AS total_film,
    count(CASE WHEN f.rating = 'G' THEN 1 END) AS jumlah_g,
    count(CASE WHEN f.rating = 'PG-13' THEN 1 END) AS jumlah_pg13,
    round(avg(CASE WHEN f.length > 90 THEN f.length END), 2) AS rata_durasi_lebih_90
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY c.name;

/*
Penjelasan perbedaan rata-rata:
Kedua versi di atas (FILTER, dan CASE WHEN ... END TANPA ELSE) menghasilkan angka rata-rata durasi
yang SAMA persis. Alasannya: "avg(f.length) FILTER (WHERE f.length > 90)" dan
"avg(CASE WHEN f.length > 90 THEN f.length END)" sama-sama mengecualikan baris yang tidak
memenuhi syarat dari agregat AVG — CASE WHEN tanpa ELSE menghasilkan NULL untuk baris yang tidak
cocok, dan AVG mengabaikan NULL, sehingga efeknya identik dengan FILTER.

Perbedaan BARU akan muncul jika versi CASE WHEN ditulis DENGAN ELSE, misalnya:
  avg(CASE WHEN f.length > 90 THEN f.length ELSE 0 END)
Versi ini akan menurunkan rata-rata karena baris yang tidak memenuhi syarat ikut masuk hitungan
AVG sebagai nilai 0, bukan dikecualikan seluruhnya seperti pada FILTER. Jadi bukan "FILTER vs
CASE WHEN" itu sendiri yang membuat hasil berbeda, melainkan ada/tidaknya klausa ELSE pada
versi CASE WHEN -- ini jebakan umum yang perlu dihindari saat menulis agregat kondisional.
*/