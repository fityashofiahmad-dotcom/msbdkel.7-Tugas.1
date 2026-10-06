-- Q19: Periksa Correlation dan Perbandingan Ukuran BRIN vs B-Tree
SET max_parallel_workers_per_gather = 0;

CREATE INDEX IF NOT EXISTS ev_waktu_brin_idx 
ON lab6.event_log USING brin (terjadi_pada) 
WITH (pages_per_range = 128);

-- Cek correlation di pg_stats
SELECT tablename, attname, correlation 
FROM pg_stats 
WHERE schemaname = 'lab6' AND tablename = 'event_log' AND attname = 'terjadi_pada';

-- Bandingkan ukuran BRIN (32 KB) vs B-Tree (43 MB)
SELECT 
    pg_size_pretty(pg_relation_size('lab6.ev_waktu_brin_idx')) AS ukuran_brin_idx,
    pg_size_pretty(pg_relation_size('lab6.ev_waktu_polos_idx')) AS ukuran_btree_idx;
