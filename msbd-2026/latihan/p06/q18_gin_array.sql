-- Q18: GIN Index untuk Array (tags)
SET max_parallel_workers_per_gather = 0;

CREATE INDEX IF NOT EXISTS ev_tags_gin_idx 
ON lab6.event_log USING gin (tags);

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM lab6.event_log 
WHERE tags @> ARRAY['kanal:1'];
