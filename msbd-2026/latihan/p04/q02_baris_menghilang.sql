-- Diminta: Penyisipan Data dengan mencoba memasukkan film melalui view dengan tarif di luar filter (rental_rate = 4.99) --

INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (1001, 'Film Mahal Banget', 4.99, 'PG');

-- Keluaran PostgreSQL: PostgreSQL akan melaporkan penyisipan berhasil (INSERT 0 1), tetapi baris tersebut tidak akan tampak jika melakukan SELECT * FROM lab4.film_murah;. --

-- Jumlah baris di view (lab4.film_murah): Baris baru bernilai 0 (tidak bertambah) karena kondisi rental_rate <= 0.99 dilanggar oleh data yang baru dimasukkan, sehingga baris tersebut tersembunyi dari view. --

-- Jumlah baris di tabel dasar (lab4.film): Bertambah 1 baris. --

-- Selisihnya: Terjadi karena view tanpa check option mengizinkan data dimasukkan ke tabel fisik di baliknya, namun data tersebut langsung difilter keluar dari pandangan view karena tidak memenuhi klausa WHERE. --