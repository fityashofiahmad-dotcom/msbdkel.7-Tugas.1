-- Q15: Membandingkan Covering Index (INCLUDE) dengan Composite Index 3 Kolom Biasa
SET max_parallel_workers_per_gather = 0;

CREATE INDEX IF NOT EXISTS ev_composite_tiga_idx 
ON lab6.event_log (customer_id, terjadi_pada, jumlah);

-- Bandingkan ukuran kedua index
SELECT 
    pg_size_pretty(pg_relation_size('lab6.ev_cover_idx')) AS ukuran_cover_include,
    pg_size_pretty(pg_relation_size('lab6.ev_composite_tiga_idx')) AS ukuran_composite_tiga;

EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah 
FROM lab6.event_log 
WHERE customer_id = 4211;
