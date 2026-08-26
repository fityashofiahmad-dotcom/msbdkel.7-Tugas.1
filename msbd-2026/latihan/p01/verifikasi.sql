-- ============================================================
-- LATIHAN P01 - VERIFIKASI
-- MSBD 2026
-- ============================================================

-- V1 — Jumlah tabel pada skema public
SELECT count(*)
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';


-- V2 — Sepuluh tabel terbesar beserta ukurannya
SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS ukuran
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;


-- V3 — Lima film dengan jumlah penyewaan terbanyak
SELECT f.title,
       count(*) AS total_sewa
FROM rental r
JOIN inventory i
  ON i.inventory_id = r.inventory_id
JOIN film f
  ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY total_sewa DESC
LIMIT 5;


-- V4 — Melihat rencana eksekusi query
EXPLAIN ANALYZE
SELECT f.title,
       count(*)
FROM rental r
JOIN inventory i
  ON i.inventory_id = r.inventory_id
JOIN film f
  ON f.film_id = i.film_id
GROUP BY f.title;


-- ============================================================
-- TANTANGAN TAMBAHAN
-- ============================================================

-- Membuat tabel dengan 2 juta baris
CREATE TABLE besar AS
SELECT g AS id,
       md5(g::text) AS nilai
FROM generate_series(1, 2000000) g;


-- Pencarian sebelum index
EXPLAIN ANALYZE
SELECT *
FROM besar
WHERE nilai = md5('1000000');


-- Membuat index
CREATE INDEX idx_besar_nilai ON besar(nilai);


-- Pencarian sesudah index
EXPLAIN ANALYZE
SELECT *
FROM besar
WHERE nilai = md5('1000000');