-- Q22: Membuat indeks pada kolom status dan menguji query untuk 'SUKSES' dan 'GAGAL'
CREATE INDEX IF NOT EXISTS ev_status_idx ON lab6.event_log (status);

-- Eksekusi EXPLAIN ANALYZE untuk status SUKSES
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM lab6.event_log WHERE status = 'SUKSES';

-- Eksekusi EXPLAIN ANALYZE untuk status GAGAL
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM lab6.event_log WHERE status = 'GAGAL';
