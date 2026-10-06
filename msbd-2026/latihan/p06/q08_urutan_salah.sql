\timing on
SET max_parallel_workers_per_gather = 0;
CREATE INDEX ev_salah_idx ON lab6.event_log (terjadi_pada, customer_id);
ANALYZE lab6.event_log;
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id, jumlah FROM lab6.event_log
WHERE customer_id=4211
  AND terjadi_pada >= timestamptz '2024-06-01 00:00+07'
ORDER BY terjadi_pada DESC LIMIT 20;
