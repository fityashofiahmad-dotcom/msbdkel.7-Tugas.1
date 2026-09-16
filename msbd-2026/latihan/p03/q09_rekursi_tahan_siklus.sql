-- Diminta: membuat siklus, mengamati Q7, menghentikan bila perlu, memperbaiki query agar tahan
--   siklus, lalu mengembalikan data ke keadaan semula.
-- Dipilih: menambahkan kolom jalur bertipe array pegawai_id (jalur_id) dan syarat
--   NOT (p.pegawai_id = ANY(h.jalur_id)) pada recursive term, sehingga rekursi berhenti begitu
--   sebuah pegawai_id akan muncul dua kali pada jalur yang sama.
-- Alternatif: klausa CYCLE bawaan PostgreSQL 16+ (WITH ... CYCLE kolom SET flag USING jalur);
--   dicantumkan sebagai perbandingan, tetapi versi array manual dipilih sebagai jawaban utama
--   karena lebih eksplisit menunjukkan mekanisme deteksi siklusnya.

SET search_path = public;

-- 1) Buat siklus (SENGAJA, untuk pengamatan): 1 -> 2 -> 4 -> 6 -> 1
UPDATE pegawai SET atasan_id = 6 WHERE pegawai_id = 1;

-- 2) Versi TIDAK AMAN dari Q7 (JANGAN dijalankan tanpa Ctrl-C siap; disertakan hanya sebagai
--    pembanding tertulis, jangan dieksekusi begitu saja):
-- WITH RECURSIVE hierarki AS (
--     SELECT pegawai_id, nama, atasan_id, 1 AS level, nama::text AS jalur
--     FROM pegawai WHERE atasan_id IS NULL
--     UNION ALL
--     SELECT p.pegawai_id, p.nama, p.atasan_id, h.level + 1, h.jalur || ' > ' || p.nama
--     FROM pegawai p JOIN hierarki h ON p.atasan_id = h.pegawai_id
-- )
-- SELECT * FROM hierarki;
-- Query di atas tidak akan pernah berhenti karena siklus 1 -> 2 -> 4 -> 6 -> 1 tidak pernah
-- mencapai baris ber-atasan_id IS NULL lagi. Tekan Ctrl-C jika terlanjur menjalankannya, atau
-- "docker compose restart db" bila sesi menjadi tidak responsif.

-- 3) Versi TAHAN SIKLUS memakai jalur array
WITH RECURSIVE hierarki AS (
    SELECT pegawai_id, nama, atasan_id, 1 AS level,
           nama::text AS jalur,
           ARRAY[pegawai_id] AS jalur_id
    FROM pegawai
    WHERE atasan_id IS NULL

    UNION ALL

    SELECT p.pegawai_id, p.nama, p.atasan_id, h.level + 1,
           h.jalur || ' > ' || p.nama,
           h.jalur_id || p.pegawai_id
    FROM pegawai p
    JOIN hierarki h ON p.atasan_id = h.pegawai_id
    WHERE NOT (p.pegawai_id = ANY (h.jalur_id))
)
SELECT pegawai_id, nama, level, jalur
FROM hierarki
ORDER BY jalur;

-- 3b) Alternatif setara memakai klausa CYCLE bawaan (PostgreSQL 16+), sebagai referensi:
-- WITH RECURSIVE hierarki AS (
--     SELECT pegawai_id, nama, atasan_id, 1 AS level, nama::text AS jalur
--     FROM pegawai WHERE atasan_id IS NULL
--     UNION ALL
--     SELECT p.pegawai_id, p.nama, p.atasan_id, h.level + 1, h.jalur || ' > ' || p.nama
--     FROM pegawai p JOIN hierarki h ON p.atasan_id = h.pegawai_id
-- ) CYCLE pegawai_id SET tersiklus USING jalur_terlacak
-- SELECT * FROM hierarki;

-- 4) WAJIB: pulihkan data ke keadaan semula setelah pengujian
UPDATE pegawai SET atasan_id = NULL WHERE pegawai_id = 1;

-- 5) Verifikasi pemulihan (atasan_id pegawai_id=1 harus kembali NULL)
SELECT pegawai_id, nama, atasan_id FROM pegawai ORDER BY pegawai_id;