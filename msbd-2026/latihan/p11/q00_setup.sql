-- Diminta: memuat skema lab11 pada klaster tertutup dan memverifikasi jumlah baris.
-- Dipilih: skrip setup modul dijalankan apa adanya, lalu diverifikasi dengan count per tabel.
-- Alternatif: mengetik ulang skema sendiri; tidak dipilih karena berisiko berbeda dari modul.
SELECT (SELECT count(*) FROM lab11.tenant)    AS tenant,
       (SELECT count(*) FROM lab11.pelanggan) AS pelanggan,
       (SELECT count(*) FROM lab11.akun)      AS akun,
       (SELECT count(*) FROM lab11.transaksi) AS transaksi;   -- harapkan 3 | 30000 | 4 | 120000
SELECT tenant_id, count(*) FROM lab11.pelanggan GROUP BY 1 ORDER BY 1;   -- harapkan tiap penyewa 10000
SELECT version();