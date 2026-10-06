-- Q28: Membandingkan total ukuran tabel dan indeks pada kedua kondisi
SELECT 
    'Tanpa Indeks' AS kondisi,
    pg_size_pretty(pg_relation_size('lab6.event_log_no_idx')) AS ukuran_tabel,
    pg_size_pretty(pg_indexes_size('lab6.event_log_no_idx')) AS ukuran_indeks,
    pg_size_pretty(pg_total_relation_size('lab6.event_log_no_idx')) AS total_ukuran
UNION ALL
SELECT 
    'Dengan 5 Indeks' AS kondisi,
    pg_size_pretty(pg_relation_size('lab6.event_log_with_idx')) AS ukuran_tabel,
    pg_size_pretty(pg_indexes_size('lab6.event_log_with_idx')) AS ukuran_indeks,
    pg_size_pretty(pg_total_relation_size('lab6.event_log_with_idx')) AS total_ukuran;
