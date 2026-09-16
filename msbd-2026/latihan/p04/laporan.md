# Laporan Latihan Kelompok 7 Pert.4

## Identitas Kelompok
| Nama | NIM | Kontribusi | Commit |

| Andika Chairul Ilham | 251402047 | L | Commit |
| Fahri Arizal | 251402102 |  | Commit |
| Fitya Shofi Ahmad | 251402132 | Langkah 1, Langkah 2, Reflektif A, Laporan | Commit |
| Mar'ie Rizqullah | 251402129 |  | Commit |

## Q1_Q21
### Q1 (q01_view_film_murah.sql)
1. Perintah:
CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99;
2. Keluaran:
Pesan status eksekusi berhasil (Query returned successfully in 0.008s / Update rows: 0), dan view lab4.film_murah berhasil terbentuk di dalam database.
3. Alasan:
Perintah ini digunakan untuk membuat virtual table (view) bernama film_murah di dalam skema lab4 yang menyaring data film dengan ketentuan harga sewa (rental_rate) maksimal 0.99 secara spesifik tanpa klausul tambahan check option.

### Q2 (q02_baris_menghilang.sql)
1. Perintah: 
-- Mencoba menyisipkan data di luar kriteria filter view --
INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (1001, 'Film Mahal Banget', 4.99, 'PG');

-- Mengecek keberadaan data di view vs tabel dasar --
SELECT * FROM lab4.film_murah WHERE film_id = 1001;
SELECT * FROM lab4.film WHERE film_id = 1001;
2. Keluaran: 
a. Saat insert: INSERT 0 1 (berhasil masuk ke tabel dasar).
b. Saat dicek di lab4.film_murah: Baris tidak ditemukan (kosong).
c. Saat dicek di lab4.film: Baris data (1001, 'Film Mahal Banget', 4.99, 'PG') benar-benar tersimpan
3. Alasan: Karena view dibuat tanpa WITH CHECK OPTION, PostgreSQL mengizinkan data baru masuk ke tabel fisik di baliknya (lab4.film). Namun, data tersebut langsung "menghilang" atau tidak tampak saat diakses melalui view karena melanggar batasan filter klausa WHERE rental_rate <= 0.99.

### Q3 (q03_check_option.sql)
1. Perintah:
-- Membuat ulang view dengan CASCADED CHECK OPTION --
CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99
WITH CASCADED CHECK OPTION;

-- Mencoba menyisipkan data dengan harga di luar batas filter --
INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (1002, 'Film Gagal Masuk', 4.99, 'PG');
2. Keluaran: ERROR: new row violates check option for view "film_murah"
DETAIL: Failing row contains (1002, Film Gagal Masuk, null, null, null, null, null, null, null, 4.99, null, PG, null).
3. Alasan: Penggunaan klausul WITH CASCADED CHECK OPTION memaksa PostgreSQL untuk memvalidasi setiap data yang akan dimasukkan melalui view. Karena nilai rental_rate (4.99) melanggar syarat filter view (<= 0.99), maka operasi insert ditolak secara mutlak oleh sistem.

### Q4 (q04_view_pendapatan_kategori.sql)
1. Perintah: 
CREATE OR REPLACE VIEW lab4.pendapatan_kategori AS
SELECT c.name AS category_name, SUM(p.amount) AS total_revenue
FROM public.category c
JOIN public.film_category fc ON c.category_id = fc.category_id
JOIN public.inventory i ON fc.film_id = i.film_id
JOIN public.rental r ON i.inventory_id = r.inventory_id
JOIN public.payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

-- Uji coba insert ke view agregasi --
INSERT INTO lab4.pendapatan_kategori VALUES ('Action', 50000);
2. Keluaran: ERROR: cannot insert into view "pendapatan_kategori"
  Detail: Views containing GROUP BY are not automatically updatable.
  Hint: To enable inserting into the view, provide an INSTEAD OF INSERT trigger or an unconditional ON INSERT DO INSTEAD rule.
3. Alasan: View yang melibatkan fungsi agregasi (SUM) dan pengelompokan (GROUP BY) bersama join banyak tabel dikategorikan sebagai read-only oleh PostgreSQL. Sistem tidak bisa secara otomatis memetakan atau memecah balik data sisipan ke tabel-tabel dasarnya, sehingga operasi insert langsung ditolak.

### Q5 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q6 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q7 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q8 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q9 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q10 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q11 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q12 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q13 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q14 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q15 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q16 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q17 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q18 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q19 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q20 ()
1. Perintah:
2. Keluaran:
3. Alasan:

### Q21 ()
1. Perintah:
2. Keluaran:
3. Alasan:

## Refleksi A-E
### Refleksi A
1. Dua Keuntungan peletakan seluruh akses lewat view:
a. Keamanan dan Kontrol Data Lebih Terjaga: Kita bisa ngebatasi aplikasi cuma buat akses data atau kolom tertentu aja (kayak nyembunyiin data sensitif), jadi aplikasi nggak nyentuh tabel aslinya secara langsung.
b. Struktur Lebih Rapi: Query yang ribet dan panjang (kayak join antar banyak tabel) bisa diringkas jadi bentuk view yang bersih, jadi kode di aplikasi keliatan jauh lebih rapi.
2. Dua kerugiannya:
a. Operasi Data Jadi Terbatas: Nggak semua view bisa di-update atau di-insert dengan bebas. Contohnya kayak view yang pakai GROUP BY di Q4 yang otomatis jadi read-only, jadi malah bikin repot kalau mau nulis data.
b. Susah Ditebak Saat Debugging: Kasus "baris menghilang" kayak di Q2 bisa bikin bingung. Data masuk ke tabel dasar, tapi nggak keliatan di view karena kehalang klausa WHERE, yang bikin tim butuh waktu ekstra buat ngecek logikanya.
3. Satu Keadaan Konkret yang Mempersulit Tim:
Pendekatan ini bakal paling kerasa nyusahin waktu tim lagi bikin fitur input data massal (bulk insert) atau migrasi data, terus di view-nya dipasang aturan ketat kayak WITH CHECK OPTION (kayak di Q3). Kalau ada data yang sedikit aja melenceng dari kondisi filter view, sistem bakal langsung nolak dan nimbulin error tanpa pengembang sadar kalau ternyata masalahnya ada di batasan view yang ketat itu.

### Refleksi B - Materialized View1. Trade-Off Materialized View
Materialized View menukar kesegaran data (freshness) dengan kecepatan baca (read performance). Data yang dibaca dari Materialized View bersifat stale (basi) sesuai waktu refresh terakhir, namun waktu kuerinya turun drastis dari orde detik menjadi milidetik karena hasilnya telah ditulis ke disk dalam bentuk tabel berindeks.  2. Kompromi Konkret untuk Laporan KeuanganBatas Kebasian (Staleness SLA): Menetapkan toleransi batas kebasian data laporan, misalnya 15–30 menit. Keuangan umumnya tidak membutuhkan agregasi transaksi bulanan/harian dalam skala detik secara real-time.Jadwal Refresh: Menjalankan REFRESH MATERIALIZED VIEW CONCURRENTLY menggunakan penjadwal otomatis (cron job / pg_cron) setiap 30 menit di luar jam sibuk atau pada interval waktu transaksi sepi.  Penanganan Saat Refresh Gagal:Mitigasi Pembaca: Menggunakan CONCURRENTLY memastikan bahwa apabila proses refresh gagal di tengah jalan, versi data lama tetap aman dibaca oleh aplikasi tanpa merusak atau menghapus data.  Alerting & Retry: Mengirim notifikasi otomatis (alerting) ke tim Data Ops/Engineering dan mengaktifkan prosedur retry otomatis dengan batas maksimal 3 kali percobaan.

### Refleksi C
...

### Refleksi D
...

### Refleksi E
...

## Ringkasan Waktu
| Tugas | Waktu | Penafsiran |

| Q5 | | |
| Q6 | | |
| Q7 | | |
| Q12 | | |
| Q13 | | |

## Tangkapan Layar struktur migrations/
![struktur migrations/](....png/)

## tautan merge
...







