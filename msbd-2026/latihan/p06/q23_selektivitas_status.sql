-- Q23: Menghitung fraksi tiap status dan mengidentifikasi titik peralihan scan
SELECT 
    status, 
    COUNT(*) AS jumlah_baris,
    ROUND((COUNT(*)::numeric / SUM(COUNT(*)) OVER ()) * 100, 2) AS persentase
FROM lab6.event_log
GROUP BY status;

-- Catatan Uji Titik Transisi:
-- PostgreSQL akan menggunakan Seq Scan pada 'SUKSES' (~84%) dan 'TERTUNDA' (~14%),
-- tetapi menggunakan Index Scan pada 'GAGAL' (~2%).
