-- Q14: Covering Index (INCLUDE) dan Dampak VACUUM pada Index-Only Scan
SET max_parallel_workers_per_gather = 0;

CREATE INDEX IF NOT EXISTS ev_cover_idx 
ON lab6.event_log (customer_id) 
INCLUDE (terjadi_pada, jumlah);

-- Pengujian 1: SEBELUM VACUUM (Amati angka Heap Fetches)
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah 
FROM lab6.event_log 
WHERE customer_id = 4211;

-- Jalankan VACUUM untuk memperbarui Visibility Map
VACUUM (ANALYZE) lab6.event_log;

-- Pengujian 2: SESUDAH VACUUM (Heap Fetches menjadi 0)
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, terjadi_pada, jumlah 
FROM lab6.event_log 
WHERE customer_id = 4211;
