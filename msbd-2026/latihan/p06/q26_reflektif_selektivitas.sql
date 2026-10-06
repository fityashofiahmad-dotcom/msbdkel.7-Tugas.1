-- Q26 (Reflektif): Analisis alasan teknis perbedaan pemilihan metode scan
SELECT 
    tablename, 
    attname, 
    null_frac, 
    avg_width, 
    n_distinct, 
    most_common_vals, 
    most_common_freqs 
FROM pg_stats 
WHERE schemaname = 'lab6' AND tablename = 'event_log' AND attname = 'status';
