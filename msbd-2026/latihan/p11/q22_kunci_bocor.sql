-- Q22: Deteksi Kebocoran Kunci & Teks Terang via pg_stat_activity
-- Jalankan query ini dari session kedua selagi proses SET / UPDATE enkripsi berjalan
SELECT pid, usename, state, query
FROM pg_stat_activity
WHERE state != 'idle'
  AND pid <> pg_backend_pid();

-- Dua tempat lain yang wajib diperiksa:
-- 1. Log server PostgreSQL (postgresql.log jika log_statement = 'all' aktif)
-- 2. Riwayat perintah klien (~/.psql_history)
