-- Q13: Expression Index pada lower(email)
SET max_parallel_workers_per_gather = 0;

CREATE INDEX IF NOT EXISTS ev_email_lower_idx 
ON lab6.event_log (lower(email));

-- Test 1: Menggunakan fungsi lower(email) - Memakai Expression Index
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM lab6.event_log 
WHERE lower(email) = 'user100@contoh.ac.id';

-- Test 2: Kolom email biasa - Tidak memakai Expression Index (Seq Scan)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM lab6.event_log 
WHERE email = 'user100@contoh.ac.id';
