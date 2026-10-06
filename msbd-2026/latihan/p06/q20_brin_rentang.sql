-- Q20: Uji Query Rentang Waktu 7 Hari Menggunakan BRIN
SET max_parallel_workers_per_gather = 0;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM lab6.event_log 
WHERE terjadi_pada >= timestamptz '2024-06-01 00:00+07' 
  AND terjadi_pada < timestamptz '2024-06-08 00:00+07';
