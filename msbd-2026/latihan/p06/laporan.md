# Laporan Latihan Kelompok Pertemuan 6

## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |
| Andika Chairul Ilham | 251402047 | Langkah 3, Laporan |---|
| Fahri Arizal | 2514020102 | Langkah 4, Langkah 5, Laporan |---|
| Fitya Shofi Ahmad | 251402132 | Langkah 1,Langkah 2, Laporan |---|
| Mar-ie Rizqullah | 251402129 | Langkah 6, Langkah 7, Laporan |---|

## Kondisi Uji
PostgreSQL, spesifikasi mesin, setelan paralel, jumlah pengulangan.

## Q1–Q31
1. Q1.
-- a. Cek ukuran total tabel, data, dan indeks
SELECT 
    pg_size_pretty(pg_total_relation_size('lab6.event_log')) AS total_size,
    pg_size_pretty(pg_relation_size('lab6.event_log')) AS table_size,
    pg_size_pretty(pg_indexes_size('lab6.event_log')) AS index_size;

-- b. Menghitung rata-rata byte per baris
SELECT 
    pg_relation_size('lab6.event_log') AS total_bytes_tabel,
    2000000 AS total_baris,
    ROUND(pg_relation_size('lab6.event_log')::numeric / 2000000, 2) AS rata2_byte_per_baris;

Total ukuran tabel dan indeks:
a. Data tabel (table_size): 479.821.824 bytes (~457,6 MB).
b. Total baris data: 2.000.000 baris
c. Rata-rata ukuran per baris: 239.91 bytes.

Perbandingan dengan definisi kolom:
Secara teoretis, penjumlahan tipe data mentah (seperti bigint, integer, timestamptz, uuid) hanya memakan sekitar 40–50 byte per baris. Namun, ukuran aktual di disk mencapai ~240 byte per baris karena adanya overhead sistem PostgreSQL, seperti row header (metadata transaksi MVCC), penyimpanan dinamis untuk tipe data kompleks (text, jsonb, dan text[]), serta alignment memori.

2. Q2.
Perbandingan dan penjelasan selisihnya:
a. Perbandingan angka:
    1. Batas teoritis: 291 tuple per halaman.
    2. Kondisi aktual: 34.15 tuple per halaman.
    3. Selisih yang terlihat sangat jauh di mana jumlah aktual jauh lebih sedikit dibanding batas teoritisnya.
b. Penjelasan selisih:
    1. Ukuran baris yang lebih besar dari asumsi teori. Batas teoretis 291 tuple biasanya dihitung berasumsi ukuran baris yang sangat kecil dan pas. Padahal, tabel lab6.event_log berisi tipe data kompleks seperti jsonb (payload), array (tags), serta beberapa kolom text yang ukurannya dinamis dan cukup memakan tempat.
    2. Overhead Struktur Halaman (Page & Line Pointers). Setiap halaman database PostgreSQL berukuran 8 KB harus membagikan ruangnya untuk Page Header (metadata halaman), Line Pointer array (penunjuk posisi tuple), serta HeapTupleHeaderData (header transaksi MVCC di setiap baris).
    3. Padding & Fragmentasi Ruang Kosong. Karena ukuran baris bervariasi (dinamis), sisa ruang kosong di akhir halaman (free space) sering kali tidak cukup lagi untuk menampung baris berikutnya, sehingga tercipta celah kosong (padding) yang membuat jumlah baris per halaman menjadi lebih sedikit (hanya sekitar 34 baris saja).

3. Q3.
a. Kolom yang bernilai x atau e:
    1. status (x) (text)
    2. wilayah (x) (text)
    3. kota (x) (text)
    4. email (x) (text)
    5. tags (x) (text[])
    6. payload (x) (jsonb)

b. Akibat pada SELECT * :
    1. Potensi akses TOAST tambahan (TOAST Fetching). Kolom dengan strategi x diizinkan untuk dikompresi dan dipindahkan penyimpanannya ke tabel terpisah (TOAST table) jika ukuran barisnya melebihi ambang batas tertentu. Saat melakukan SELECT *, PostgreSQL tidak hanya membaca tabel utama, tetapi juga harus mengambil (fetch) data dari tabel TOAST jika kolom-kolom tersebut disimpan secara out-of-line.
    2. Penurunan performa (I/O Oevrhead). Karena SELECT * memaksa database untuk memuat seluruh kolom—termasuk data besar seperti payload (jsonb) atau teks yang panjang—proses pembacaan data di disk akan menjadi lebih berat dan lambat dibandingkan jika hanya memanggil kolom tertentu yang diperlukan saja (SELECT customer_id, jumlah).

4. Q4.
Analisis Output:
a. hot_penuh (Fillfactor 100):
    1. Total baris di-update: 0.
    2. Baris HOT update: 0.

b. hot_longgar (Fillfactor 80):
    1. Total baris di-update: 100.000.
    2. Baris HOT update: 35.536.

Kesimpulannya:
    1. Efektivitas Fillfactor: Tabel hot_longgar yang di-set dengan fillfactor 80% terbukti berhasil memanfaatkan mekanisme HOT (Heap-Only Tuple) Update sebanyak 35.536 baris.   
    2. Penjelasannya: Karena fillfactor 80 menyisakan 20% ruang kosong (free space) di setiap halaman fisik disk. Ketika kolom yang tidak berindeks (catatan) di-update, baris baru tersebut masih muat dan disimpan di halaman fisik yang sama tanpa perlu membuat entri indeks baru atau memindahkannya ke halaman lain.

5. Q5.
a. Perbandingan ukuran tabel setelah UPDATE:
    1. hot_longgar (Fillfactor 80):
        Total ukuran: 9008 kB (Tabel: 6768 kB, Indeks: 2200 kB)
    2. hot_penuh (Fillfactor 100):
        Total ukuran: 4096 kB (Tabel: 2944 kB, Indeks: 1112kB)

b. Penjelasannya:
    1. Penyebab perbedaan ukurannya: Meskipun jumlah baris data di kedua tabel awalnya sama, tabel hot_longgar memakan ruang penyimpanan yang jauh lebih besar (hampir dua kali lipat) dibanding hot_penuh. Hal ini terjadi karena pengaturan fillfactor = 80 memaksa PostgreSQL untuk menyisakan 20% ruang kosong (free space) di setiap halaman (page) fisik disk.
    2. "Harga" yang harus dibayar (Space Overhead): Harus merelakan kapasitas penyimpanan disk yang lebih boros dan jumlah halaman yang lebih banyak (table bloat yang disengaja) demi menyediakan tempat cadangan tersebut.
    3. Keuntungannya: Ruang ekstra yang dikorbankan tersebut adalah "harga" atau investasi yang dibayar agar baris baru hasil pembaruan (update) dapat langsung ditampung di halaman fisik yang sama tanpa harus mencari halaman baru. Dengan begitu, mekanisme HOT (Heap-Only Tuple) Update dapat berjalan dengan sukses sehingga performa operasi UPDATE menjadi jauh lebih cepat, efisien, dan meminimalkan pembengkakan indeks.

6. Q6.
a. Perbandingan UPDATE kolom terindeks vs tidak terindeks.
    1. UPDATE pada kolom terindeks:
        Saat kolom yang terdaftar dalam suatu indeks (misalnya kolom kunci utama atau kolom yang diberi indeks tambahan) diubah nilainya, PostgreSQL wajib memperbarui entri pada struktur indeks tersebut agar tetap sinkron dan menunjuk ke lokasi fisik baris yang benar.
    2. UPDATE pada kolom tidak terindeks:
        Saat kolom yang tidak memiliki indeks (seperti kolom catatan pada latihan Q4) diubah nilainya, struktur indeks di dalam database sama sekali tidak terpengaruh karena kolom tersebut tidak dicatat di dalam indeks.

b. Alasan satu skenario menghasilkan HOT update sedangkan yang lain tidak.
    1. Kolom tidak terindeks (menghasilkan HOT update):
        Karena nilai kolom indeks tidak berubah, PostgreSQL tidak perlu menyentuh atau memperbarui entri indeks sama sekali. Jika halaman fisik disk memiliki ruang kosong yang cukup (berkat pengaturan fillfactor seperti di hot_longgar), baris baru hasil update dapat langsung diletakkan di halaman fisik yang sama. PostgreSQL cukup membuat tautan (heap-only tuple link) dari baris lama ke baris baru. Inilah yang disebut HOT Update.
    2. Kolom terindeks (tidak menghasilkan HOT update):
        jika kolom yang di-update adalah kolom terindeks, perubahan nilai tersebut memaksa PostgreSQL untuk membuat entri indeks baru atau memodifikasi pointer indeks. Hal ini melanggar syarat mutlak mekanisme HOT update. Akibatnya, PostgreSQL terpaksa melakukan pembaruan standar (non-HOT), yaitu menaruh tuple baru di halaman disk (bisa di halaman berbeda) dan meregistrasikan ulang posisinya pada indeks secara penuh.

7. Q7.
...

8. Q8
...

9. Q9
...

10. Q10
...

11. q11
...

12. Q12
...

13. Q13
...

14. Q14
...

15. Q15
...

16. Q16
...

17. Q17
...

18. Q18
...

19. Q19
...

20. Q20
...

21. Q21
...

22. Q22.
Pemilihan Plan Berdasarkan Status
- **Status 'SUKSES':** Optimizer memilih **Sequential Scan**. Karena status 'SUKSES' mencakup ~84% total data, mengakses halaman tabel secara berurutan jauh lebih cepat daripada menggunakan indeks (mencegah *random I/O*).
- **Status 'GAGAL':** Optimizer memilih **Bitmap Index Scan / Index Scan**. Status 'GAGAL' hanya mencakup ~2% dari total baris, sehingga pencarian lewat indeks jauh lebih efisien.

23. Q23.
Fraksi Status dan Titik Transisi
- **Distribusinya:**
  - `SUKSES`: 84.0%
  - `TERTUNDA`: 14.0%
  - `GAGAL`: 2.0%
- **Titik Transisi:** Optimizer berpindah dari *Index Scan* ke *Seq Scan* ketika estimasi baris yang dikembalikan melebihi kisaran **5%–10%** dari total populasi tabel.

24. Q24.
Pengaruh `random_page_cost`
- Saat `random_page_cost` diturunkan dari `4.0` (default HDD) menjadi `1.1` (mendekati SSD), biaya I/O acak dianggap hampir sebanding dengan I/O sekuensial.
- **Dampak:** Titik transisi bergeser. Optimizer lebih agresif memilih *Index Scan* bahkan untuk nilai selektivitas yang lebih tinggi (seperti status `TERTUNDA` dengan fraksi 14%).

25. Q25.
Extended Statistics (`dependencies` & `ndistinct`)
- **Sebelum Extended Statistics:** Optimizer mengasumsikan kolom `wilayah` dan `kota` saling independen. Estimasi baris menjadi sangat rendah (*underestimation*) karena menghitung `P(wilayah) * P(kota)`.
- **Sesudah Extended Statistics:** Setelah membuat `CREATE STATISTICS` dan mengeksekusi `ANALYZE`, PostgreSQL memahami ketergantungan fungsional (`kota` ditentukan oleh `wilayah`). Estimasi baris yang dihasilkan pas dan sesuai dengan jumlah baris riil.

26. Q26.
Reflektif: Mengapa Titik Peralihan Bukan Angka Tetap?
Titik peralihan (*crossover point*) antara *Seq Scan* dan *Index Scan* bersifat dinamis karena dipengaruhi oleh:
1. **Faktor Hardware / Konfigurasi:** Nilai `random_page_cost` dan `seq_page_cost`.
2. **Ukuran Halaman & Density:** Berapa banyak tuple yang muat dalam satu blok disk.
3. **Kondisi Cache (RAM):** Nilai `effective_cache_size` yang memengaruhi ketersediaan memori buffer.

27. Q27.
Biaya Penulisan (INSERT Overhead)
- **Tabel Tanpa Indeks:** Operasi `INSERT 200.000` baris selesai dalam waktu ~**0.8 detik**.
- **Tabel Dengan 5 Indeks:** Operasi `INSERT 200.000` baris selesai dalam waktu ~**4.2 detik**.
- **Selisih Waktu:** Penambahan 5 indeks memberikan overhead penulisan sekitar **+425%** lebih lambat karena PostgreSQL harus memperbarui struktur pohon B-Tree dan GIN secara synchronous untuk setiap baris baru.

28. Q28.
Perbandingan Ukuran Total
| Kondisi | Ukuran Heap (Tabel) | Ukuran Indeks | Total Ukuran |
| :--- | :--- | :--- | :--- |
| **Tanpa Indeks** | 32 MB | 0 bytes | 32 MB |
| **Dengan 5 Indeks** | 32 MB | 68 MB | 100 MB |

*Penambahan indeks memakan ruang disk 2,1x lipat lebih besar dibandingkan data tabel itu sendiri.*

29. Q29
Analisis Penggunaan Indeks (`idx_scan`)
Berdasarkan pemantauan dari `pg_stat_user_indexes`:
- `ev_cover_idx`: `idx_scan` tinggi → **Dipertahankan**
- `ev_status_idx`: `idx_scan = 0` (atau sangat rendah) → **Direkomendasikan Hapus**
- *Pengecualian:* Indeks dengan `idx_scan = 0` seperti `UNIQUE constraint` atau `Foreign Key index` tetap harus dipertahankan untuk menjamin integritas data dan mempercepat proses *DELETE/UPDATE cascading*.
  
30. Q30
...

31. q31
...

## Tabel Perbandingan
| Query/index | Tercepat | Median | Buffers | Ukuran | Keputusan |

| ... | ... | ... | ... | ... | .. |
| ... | ... | ... | ... | ... | .. |
| ... | ... | ... | ... | ... | .. |

## Rekomendasi Akhir
...
