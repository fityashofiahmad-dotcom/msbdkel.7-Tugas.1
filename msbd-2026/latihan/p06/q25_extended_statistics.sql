-- Q25: Membuat extended statistics untuk dependencies dan ndistinct pada wilayah–kota
-- Cek estimasi sebelum extended statistics
EXPLAIN ANALYZE
SELECT * FROM lab6.event_log WHERE wilayah = 'SUMUT' AND kota = 'SUMUT-1';

-- Buat extended statistics
CREATE STATISTICS IF NOT EXISTS stats_wilayah_kota (dependencies, ndistinct)
ON wilayah, kota FROM lab6.event_log;

ANALYZE lab6.event_log;

-- Cek estimasi setelah ANALYZE
EXPLAIN ANALYZE
SELECT * FROM lab6.event_log WHERE wilayah = 'SUMUT' AND kota = 'SUMUT-1';
