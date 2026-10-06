-- Q24: Mengubah random_page_cost dan mengamati pergeseran titik transisi
SET random_page_cost = 1.1;

-- Uji ulang query status TERTUNDA atau status dengan selektivitas sedang
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM lab6.event_log WHERE status = 'TERTUNDA';

-- Kembalikan konfigurasi ke default
RESET random_page_cost;
