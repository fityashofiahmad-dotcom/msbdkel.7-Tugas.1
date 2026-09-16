-- Diminta: Membuktikan bahwa REFRESH MATERIALIZED VIEW CONCURRENTLY tidak memblokir query SELECT pembaca dibanding REFRESH biasa.
-- Dipilih: Menggunakan pengujian dua sesi simultan (penulis/refresher di Sesi 1 dan pembaca di Sesi 2).
-- Alternatif: Menguji secara sekuensial; tidak dipilih karena pembuktian non-blocking wajib diamati secara bersamaan pada dua koneksi terpisah.

-- === SESI 1 (Penulis/Refresher) ===
INSERT INTO lab4.jejak_akses (film_id, waktu, kanal)
SELECT (random() * 999)::int + 1, now(), 'web'
FROM generate_series(1, 200000);

-- Uji A: Refresh CONCURRENTLY (Tidak memblokir Sesi 2)
REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;

-- Uji B: Refresh Biasa (Memblokir Sesi 2 hingga proses refresh selesai)
-- REFRESH MATERIALIZED VIEW lab4.ringkasan_akses;

-- === SESI 2 (Pembaca - Dijalankan saat Sesi 1 sedang me-refresh) ===
-- SELECT count(*) FROM lab4.ringkasan_akses;

-- Catatan Perilaku:
-- 1. Pada REFRESH CONCURRENTLY: Sesi 2 langsung mengembalikan data lama (snapshot sebelumnya) tanpa menunggu Sesi 1 selesai.
-- 2. Pada REFRESH biasa: Sesi 2 tertahan (hanging/waiting) karena REFRESH biasa mengambil lock eksklusif (AccessExclusiveLock) yang menolak pembacaan.