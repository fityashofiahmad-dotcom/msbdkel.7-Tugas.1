-- Q12: Partial Index vs Index Polos
SET max_parallel_workers_per_gather = 0;

-- Buat Partial Index (hanya untuk status GAGAL)
CREATE INDEX IF NOT EXISTS ev_gagal_idx 
ON lab6.event_log (terjadi_pada DESC) 
WHERE status = 'GAGAL';

-- Buat Index B-Tree Polos sebagai pembanding
CREATE INDEX IF NOT EXISTS ev_waktu_polos_idx 
ON lab6.event_log (terjadi_pada DESC);

-- Bandingkan ukuran dan hitung persentase penghematan
SELECT 
    pg_size_pretty(pg_relation_size('lab6.ev_gagal_idx')) AS ukuran_partial_idx,
    pg_size_pretty(pg_relation_size('lab6.ev_waktu_polos_idx')) AS ukuran_polos_idx,
    round(
        (1.0 - (pg_relation_size('lab6.ev_gagal_idx')::numeric / pg_relation_size('lab6.ev_waktu_polos_idx')::numeric)) * 100, 2
    ) AS persentase_penghematan;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM lab6.event_log 
WHERE status = 'GAGAL';
