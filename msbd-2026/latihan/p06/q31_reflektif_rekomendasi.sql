-- Q31: Mengambil metric pendukung (ukuran, scan rate, buffer) sebagai dasar keputusan
SELECT 
    i.indexrelname AS nama_indeks,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS ukuran_indeks,
    s.idx_scan AS jumlah_scan,
    s.idx_tup_read AS tuple_terbaca,
    s.idx_tup_fetch AS tuple_diambil
FROM pg_stat_user_indexes s
JOIN pg_index x ON s.indexrelid = x.indexrelid
JOIN pg_statio_user_indexes i ON s.indexrelid = i.indexrelid
WHERE s.schemaname = 'lab6' AND s.relname = 'event_log';
