-- Q29: Memeriksa statistik penggunaan indeks (idx_scan) dan ukurannya
SELECT 
    schemaname || '.' || relname AS nama_tabel,
    indexrelname AS nama_indeks,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS ukuran_indeks
FROM pg_stat_user_indexes
WHERE schemaname = 'lab6' AND relname = 'event_log'
ORDER BY idx_scan ASC;
