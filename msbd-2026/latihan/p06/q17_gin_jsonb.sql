
-- Q17: GIN Index untuk JSONB (payload)
SET max_parallel_workers_per_gather = 0;

CREATE INDEX IF NOT EXISTS ev_payload_gin_idx 
ON lab6.event_log USING gin (payload jsonb_path_ops);

-- Bandingkan ukuran tabel utama vs GIN index
SELECT 
    pg_size_pretty(pg_relation_size('lab6.event_log')) AS ukuran_heap_tabel,
    pg_size_pretty(pg_relation_size('lab6.ev_payload_gin_idx')) AS ukuran_gin_payload;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM lab6.event_log 
WHERE payload @> '{"promo": true}';
