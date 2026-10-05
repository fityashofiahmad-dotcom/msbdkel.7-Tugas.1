-- 1. Buat tabel dengan fillfactor 100 (tidak ada ruang kosong / free space)
CREATE TABLE lab6.hot_penuh (
    id SERIAL PRIMARY KEY,
    status text,
    catatan text
) WITH (fillfactor = 100);

-- 2. Buat tabel dengan fillfactor 80 (menyisakan 20% ruang kosong di setiap halaman)
CREATE TABLE lab6.hot_longgar (
    id SERIAL PRIMARY KEY,
    status text,
    catatan text
) WITH (fillfactor = 80);

-- 3. Masukkan data awal ke kedua tabel (misal 50.000 baris)
INSERT INTO lab6.hot_penuh (status, catatan)
SELECT 'AKTIF', 'catatan awal ' || generate_series(1, 50000);

INSERT INTO lab6.hot_longgar (status, catatan)
SELECT 'AKTIF', 'catatan awal ' || generate_series(1, 50000);

-- 4. Lakukan update pada kolom yang tidak terindeks (kolom catatan)
UPDATE lab6.hot_penuh SET catatan = 'catatan baru update';
UPDATE lab6.hot_longgar SET catatan = 'catatan baru update';

-- 5. Bandingkan statistik n_tup_hot_upd dari kedua tabel
SELECT 
    relname AS nama_tabel,
    n_tup_upd AS total_baris_diupdate,
    n_tup_hot_upd AS baris_hot_update
FROM pg_stat_user_tables 
WHERE schemaname = 'lab6' 
  AND relname IN ('hot_penuh', 'hot_longgar');