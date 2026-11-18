-- Q27: Tiga Query Sinyal Anomali pada Jejak Audit

-- Sinyal 1: Lonjakan baris per peran dalam rentang 1 menit (deteksi bulk scraping/mass update)
SELECT date_trunc('minute', waktu) AS menit,
       pelaku,
       aksi,
       count(*) AS jumlah_baris
FROM lab11.jejak_audit
GROUP BY 1, 2, 3
HAVING count(*) > 50
ORDER BY jumlah_baris DESC;

-- Sinyal 2: Akses atau modifikasi di luar jam kerja (08:00 - 18:00 Asia/Jakarta)
SELECT id,
       waktu AT TIME ZONE 'Asia/Jakarta' AS waktu_wib,
       pelaku,
       aksi,
       tabel,
       kunci
FROM lab11.jejak_audit
WHERE EXTRACT(HOUR FROM (waktu AT TIME ZONE 'Asia/Jakarta')) < 8
   OR EXTRACT(HOUR FROM (waktu AT TIME ZONE 'Asia/Jakarta')) >= 18;

-- Sinyal 3: Ringkasan total aksi per peran dan tabel
SELECT pelaku,
       tabel,
       aksi,
       count(*) AS total_aksi
FROM lab11.jejak_audit
GROUP BY 1, 2, 3
ORDER BY pelaku, total_aksi DESC;
