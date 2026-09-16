-- Diminta: Menguji tiga jenis UPDATE dan membuktikan hanya perubahan nilai rental_rate yang menghasilkan audit.
-- Dipilih: Menjalankan 3 UPDATE berbeda dan memeriksa isi tabel audit.
-- Alternatif: Menguji satu persatu secara manual; tidak dipilih agar pengetesan dapat direplikasi.

-- Uji 1: Mengubah harga (Harus tercatat di audit)
UPDATE lab4.film SET rental_rate = 2.99 WHERE film_id = 1;

-- Uji 2: Menulis ulang harga yang sama persis (Tidak tercatat karena ditahan WHEN IS DISTINCT FROM)
UPDATE lab4.film SET rental_rate = 2.99 WHERE film_id = 1;

-- Uji 3: Mengubah title saja (Tidak tercatat karena ditahan AFTER UPDATE OF rental_rate)
UPDATE lab4.film SET title = 'ACADEMY DINOSAUR UPDATED' WHERE film_id = 1;

-- Pembuktian
SELECT * FROM lab4.audit_harga WHERE film_id = 1;
