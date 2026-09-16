-- Diminta: Membuat tabel lab4.ulasan dengan FK ke film dan menguji 3 aksi referensial (NO ACTION, CASCADE, SET NULL).
-- Dipilih: Menguji perilaku DELETE induk terhadap baris anak pada 3 skenario FK berbeda.
-- Alternatif: Menulis trigger manual untuk penanganan FK; tidak dipilih karena fitur bawaan RDBMS lebih deklaratif dan aman.

CREATE TABLE IF NOT EXISTS lab4.ulasan (
    ulasan_id bigserial PRIMARY KEY,
    film_id integer REFERENCES lab4.film(film_id) ON DELETE NO ACTION,
    isi text NOT NULL
);

INSERT INTO lab4.ulasan (film_id, isi) VALUES (1, 'Film bagus!');

-- Ringkasan Perilaku dalam Komentar SQL:
-- 1. NO ACTION (Default): Menolak pembatalan/penghapusan induk jika masih ada baris anak yang merujuknya.
-- 2. CASCADE: Otomatis menghapus seluruh baris anak yang merujuk saat baris induk dihapus.
-- 3. SET NULL: Mengubah kolom Foreign Key pada baris anak menjadi NULL saat baris induk dihapus.
