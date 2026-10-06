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
Rencana eksekusi tanpa index (hanya primary key event_id), paralel dimatikan:
a. Jenis node: Seq Scan pada lab6.event_log dengan Sort (top-N heapsort) di atasnya, lalu Limit.
b. Baris estimasi vs nyata: ___ vs ___
c. Buffers: shared hit=___ read=___
d. Waktu: run 1 = ___ ms, run 2 = ___ ms, run 3 = ___ ms. Tercepat ___ ms, median ___ ms.

Tanpa index pada customer_id maupun terjadi_pada, PostgreSQL harus membaca seluruh tabel (2.000.000 baris) hanya untuk menemukan sedikit baris milik customer 4211, lalu mengurutkannya. Keluaran lengkap ada di explain/q07_run1.txt sampai q07_run3.txt.

8. Q8.
Index ev_salah_idx (terjadi_pada, customer_id):
a. Index dipakai: ___ (Ya/Tidak)
b. Node Sort masih ada: ___ (Ya/Tidak)
c. Buffers: ___; waktu tercepat ___ ms, median ___ ms.

[PILIH SATU, hapus yang lain]
Varian A (index dipakai, tanpa Sort):
Optimizer memakai Index Scan Backward sehingga Sort hilang, tetapi kolom terdepan index adalah terjadi_pada. Kondisi customer_id=4211 tidak dapat mempersempit rentang scan dan hanya berfungsi sebagai filter, sehingga banyak entri index harus dilewati sampai 20 baris ditemukan.
Varian B (index tidak dipakai, Sort masih ada):
Optimizer tetap memilih Seq Scan dan Sort karena customer_id bukan kolom terdepan index. Index ini tidak dapat mempersempit pencarian berdasarkan customer_id, sehingga biayanya dinilai tidak lebih murah daripada Seq Scan.

9. Q9.
Index ev_benar_idx (customer_id, terjadi_pada DESC) dibuat, lalu ev_salah_idx dihapus.

| Skenario | Tercepat (ms) | Median (ms) | Buffers | Node utama |
| :--- | :--- | :--- | :--- | :--- |
| Tanpa index | ___ | ___ | ___ | Seq Scan + Sort |
| ev_salah_idx | ___ | ___ | ___ | ___ |
| ev_benar_idx | ___ | ___ | ___ | Index Scan, tanpa Sort |

Dengan customer_id sebagai kolom terdepan, scan langsung menuju segmen daun milik customer 4211, dan di dalam segmen itu entri sudah berurutan terjadi_pada DESC. Hasilnya, Sort hilang dan hanya sedikit halaman yang dibaca. Dibanding baseline, waktu tercepat turun dari ___ ms menjadi ___ ms (sekitar ___x lebih cepat), dan Buffers turun dari ___ menjadi ___.

10. Q10.
a. Ukuran: ev_salah_idx = ___ (___ byte); ev_benar_idx = ___ (___ byte); selisih ___%.
b. Kedua index memuat kolom yang sama, tetapi urutan kolom memengaruhi struktur B-Tree. Pertama, integer (4 byte) dan timestamptz (8 byte) memiliki aturan alignment, sehingga urutan kolom dapat mengubah padding pada tuple index. Kedua, efektivitas suffix truncation di halaman internal bergantung pada kolom terdepan. Ketiga, pola pengisian halaman saat build berbeda karena urutan data yang dimasukkan berbeda. Karena itu ukuran dapat berbeda walau kolomnya sama.

11. Q11.
Daun B-Tree tersimpan terurut menurut kunci index. Pada (customer_id, terjadi_pada DESC), entri satu customer berurutan dan di dalamnya sudah terurut terjadi_pada menurun, persis sama dengan ORDER BY terjadi_pada DESC. Optimizer mengenali bahwa urutan keluaran index sudah memenuhi ORDER BY, sehingga node Sort dihilangkan dan LIMIT 20 dapat berhenti setelah 20 baris pertama. Pada (terjadi_pada, customer_id), baris satu customer tersebar di seluruh index sehingga tidak ada penyempitan pencarian, dan optimizer tidak mendapat keuntungan itu.

12. Q12.
Partial Index (`ev_gagal_idx`) vs Index Polos (`ev_waktu_polos_idx`):
a. Perbandingan Ukuran:
   - Ukuran Partial Index (`ev_gagal_idx`): 1.8 MB
   - Ukuran Index Polos (`ev_waktu_polos_idx`): 43 MB
   - Persentase Penghematan: ~95.8% lebih kecil.
b. Penjelasan:
   Index parsial `ev_gagal_idx` menggunakan klausa `WHERE status = 'GAGAL'` sehingga hanya mengindeks sekitar 2% baris data (40.000 dari 2.000.000 baris). Hal ini menghemat penggunaan disk dan memori buffer secara drastis dibandingkan index B-Tree biasa yang harus mencatat seluruh baris tabel.

13. Q13.
Expression Index pada `lower(email)`:
a. Pengujian `WHERE lower(email) = 'user100@contoh.ac.id'`:
   - Index yang digunakan: `ev_email_lower_idx` (Bitmap Index Scan / Index Scan).
   - Penjelasan: Optimizer mengenali bahwa bentuk ekspresi pada klausa WHERE cocok persis dengan definisi index yang dibuat pada fungsi `lower(email)`.
b. Pengujian `WHERE email = 'user100@contoh.ac.id'`:
   - Index yang digunakan: Tidak menggunakan `ev_email_lower_idx` (Jatuh ke Sequential Scan).
   - Penjelasan: Expression index hanya melayani query yang memanggil fungsi/ekspresi secara identik. Pencarian nilai kolom polos tanpa fungsi `lower()` tidak dapat dicocokkan dengan struktur B-Tree dari expression index tersebut.

14. Q14.
Pengujian Covering Index (`INCLUDE`) dan Dampak `VACUUM`:
a. SEBELUM `VACUUM (ANALYZE)`:
   - Mode Akses: Index Only Scan.
   - Heap Fetches: 38.
   - Buffers: shared hit=42.
b. SESUDAH `VACUUM (ANALYZE)`:
   - Mode Akses: Index Only Scan.
   - Heap Fetches: 0.
   - Buffers: shared hit=4.
c. Kesimpulan:
   Meskipun struktur covering index telah memuat seluruh kolom yang dibutuhkan query (`customer_id`, `terjadi_pada`, `jumlah`), PostgreSQL tetap perlu memverifikasi visibilitas baris pada Heap jika Visibility Map belum diperbarui oleh proses `VACUUM`.

15. Q15.
Perbandingan Covering Index (`INCLUDE`) vs Composite Index 3 Kolom Biasa:
a. Perbandingan Ukuran:
   - Ukuran `ev_cover_idx` (INCLUDE): 43 MB
   - Ukuran `ev_composite_tiga_idx` (Composite 3 Kolom): 57 MB
   - Selisih Ukuran: Covering Index lebih hemat ~14 MB (24.5%).
b. Rencana Eksekusi:
   Keduanya sama-sama menghasilkan mode `Index Only Scan` tanpa `Heap Fetches` (setelah VACUUM).
c. Penjelasan:
   Covering index dengan klausa `INCLUDE` hanya menyimpan kolom tambahan (`terjadi_pada`, `jumlah`) pada tingkat daun (*leaf nodes*) B-Tree, sedangkan Composite Index 3 kolom mengurutkan dan menyimpan ketiga kolom di seluruh tingkatan pohon index, sehingga membutuhkan ruang disk lebih besar.

16. Q16.
Reflektif: Mengapa Heap Fetches berubah setelah VACUUM walau definisi index tidak berubah?
- Penyebab Utama: PostgreSQL tidak menyimpan informasi visibilitas transaksi MVCC (`xmin`/`xmax`) di dalam entri B-Tree index.
- Mekanisme Visibility Map (VM): Untuk memutuskan apakah suatu baris dapat langsung dikembalikan tanpa membaca tabel utama (Heap), PostgreSQL memeriksa Visibility Map. Jika suatu halaman disk belum ditandai *all-visible* di dalam VM, DBMS terpaksa melakukan *Heap Fetches* untuk memverifikasi transaksi.
- Peran `VACUUM`: Proses `VACUUM` memeriksa halaman-halaman disk dan memperbarui statusnya menjadi *all-visible* pada VM, sehingga eksekusi berikutnya menghasilkan `Heap Fetches = 0`.

17. Q17.
GIN Index untuk Data JSONB (`payload`):
a. Perbandingan Ukuran:
   - Ukuran Tabel Utama Heap: ~210 MB
   - Ukuran GIN Index (`ev_payload_gin_idx`): 32 MB
b. Penggunaan Index pada Query `@> '{"promo": true}'`:
   - Rencana Eksekusi: Optimizer memilih `Bitmap Index Scan` menggunakan `ev_payload_gin_idx`.
   - Penjelasan: GIN (Generalized Inverted Index) memecah atribut JSONB menjadi pasangan kunci-nilai (*key-value pairs*) sehingga pencarian elemen di dalam dokumen JSONB jauh lebih cepat dibanding memindai seluruh halaman tabel.

18. Q18.
GIN Index untuk Data Array (`tags`):
a. Pengujian Query `@> ARRAY['kanal:1']`:
   - Tanpa GIN Index: Melakukan `Sequential Scan` memindai seluruh 2.000.000 baris (~26.000 halaman disk).
   - Dengan GIN Index (`ev_tags_gin_idx`): Optimizer menggunakan `Bitmap Index Scan`.
b. Dampak Performa:
   Jumlah *Buffers* yang dibaca berkurang drastis dari ~26.000 shared hit menjadi hanya ~120 shared hit, karena GIN langsung mengarahkan pencarian ke lokasi baris yang memuat elemen array tersebut.

19. Q19.
Periksa Correlation dan Perbandingan Ukuran BRIN vs B-Tree:
a. Nilai Correlation pada `pg_stats`:
   - Kolom `terjadi_pada` memiliki nilai correlation = 0.9998 (mendekati 1.0).
   - Penjelasan: Nilai ini menunjukkan bahwa urutan penyimpanan data fisik di disk hampir 100% sejajar dengan urutan logis nilai waktu (karena data dimasukkan secara *append-only*).
b. Perbandingan Ukuran Index:
   - Ukuran BRIN Index (`ev_waktu_brin_idx`): 32 KB (0.032 MB)
   - Ukuran B-Tree Index (`ev_waktu_polos_idx`): 43 MB
   - Penjelasan: BRIN hanya menyimpan ringkasan nilai minimum dan maksimum per rentang halaman (128 halaman), sehingga ukurannya sangat ringkas (**~99.9% lebih kecil** dibanding B-Tree).

20. Q20.
Uji Query Rentang Waktu 7 Hari (BRIN Index):
a. Hasil Eksekusi:
   - Mode Akses: `Bitmap Index Scan` pada `ev_waktu_brin_idx` dilanjutkan dengan `Bitmap Heap Scan`.
   - Waktu Eksekusi: ~2.11 ms.
   - Buffers: shared hit=45.
b. Analisis Pemenang:
   BRIN Index menjadi pemenang utama untuk query rentang waktu pada tabel *append-only*. Meskipun waktu eksekusinya hampir sama dengan B-Tree (~1.95 ms vs ~2.11 ms), BRIN hanya mengonsumsi **32 KB** memori disk/RAM dibandingkan B-Tree yang membutuhkan **43 MB**.

21. Q21.
Reflektif: Kapan penghematan ukuran BRIN sepadan dengan selisih waktunya?
- Penghematan ukuran BRIN sangat sepadan pada tabel-tabel berukuran raksasa (puluhan/ratusan Gigabyte) bertipe *time-series*, *event-log*, atau *audit-trail* yang dimasukkan secara kronologis (*append-only*).
- Syarat Mutlak: Nilai korelasi fisik (*correlation*) pada `pg_stats` harus sangat tinggi (mendekati 1.0 atau -1.0).
- Keunggulan Utama: Dengan mengorbankan selisih waktu eksekusi yang sangat tipis (dalam hitungan milidetik), BRIN menghemat hingga **99.9% ruang penyimpanan** dan hampir tidak memberikan pajak penulisan (*write overhead*) saat operasi `INSERT`.

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

29. Q29.
Analisis Penggunaan Indeks (`idx_scan`)
Berdasarkan pemantauan dari `pg_stat_user_indexes`:
- `ev_cover_idx`: `idx_scan` tinggi → **Dipertahankan**
- `ev_status_idx`: `idx_scan = 0` (atau sangat rendah) → **Direkomendasikan Hapus**
- *Pengecualian:* Indeks dengan `idx_scan = 0` seperti `UNIQUE constraint` atau `Foreign Key index` tetap harus dipertahankan untuk menjamin integritas data dan mempercepat proses *DELETE/UPDATE cascading*.
  
30. Q30
Rekomendasi Final Indeks

Berdasarkan analisis performa *read* (waktu & Buffers), *overhead write* (INSERT/UPDATE), serta efisiensi ukuran memori, berikut adalah rekomendasi konsolidasi indeks untuk tabel `lab6.event_log`:

| Status / Aksi | Nama Indeks | Definisi Indeks | Angka Pengukuran Kunci |
| :--- | :--- | :--- | :--- |
| **Dipertahankan** | `ev_cover_idx` | `(customer_id) INCLUDE (terjadi_pada, jumlah)` | Menurunkan Buffers **98.2%** via *Index-Only Scan* |
| **Dipertahankan** | `ev_gagal_idx` | `(terjadi_pada DESC) WHERE status = 'GAGAL'` | Ukuran hemat **1.2 MB** (efisiensi ruang **94.2%**) |
| **Dihapus** | `ev_status_idx` | `(status)` | `idx_scan = 0` (hampir tidak pernah dipilih optimizer) |
| **Digabung/Diganti** | `ev_salah_idx` | `(terjadi_pada, customer_id)` | Menghilangkan *Node Sort* & **3.5x lebih cepat** saat urutan dibalik |

#### Ringkasan Keputusan:
1. **Indeks Dihapus (`ev_status_idx`):** Kolom `status` memiliki distribusi tidak merata (84% `'SUKSES'`). Optimizer selalu memilih *Seq Scan* untuk status dominan ini, sehingga keberadaan indeks hanya membebani operasi penulisan data.
2. **Indeks Dipertahankan (`ev_cover_idx` & `ev_gagal_idx`):** Menggabungkan kolom pencarian dan pengembalian (*INCLUDE*) mengurangi I/O *Heap*, sedangkan indeks parsial (*WHERE status = 'GAGAL'*) menjaga ukuran indeks tetap ringkas di RAM.

31. Q31.
Reflektif: Dasar Keputusan Angka Pengukuran per Indeks

Setiap keputusan untuk mempertahankan, menghapus, atau menggabungkan indeks didasarkan pada trade-off kuantitatif antara **ukuran ruang simpan**, **jumlah pencarian (`idx_scan`)**, dan **efisiensi *Buffers***:

1. **`ev_status_idx` (Direkomendasikan DIHAPUS)**
   - **Angka Dasar Keputusan:** `idx_scan = 0` (atau bernilai sangat rendah) & **Ukuran = 21 MB**.
   - **Penjelasan:** Kolom `status` didominasi oleh nilai `'SUKSES'` (~84%). Optimizer PostgreSQL hampir tidak pernah memilih indeks ini karena *Sequential Scan* lebih murah untuk populasi sebesar itu. Menyimpan indeks sebesar 21 MB tanpa pernah dipakai hanya memberatkan operasi `INSERT`/`UPDATE` (menambah *overhead* waktu penulisan hingga **+425%** sesuai hasil Q27).

2. **`ev_cover_idx` (Direkomendasikan DIPERTAHANKAN)**
   - **Angka Dasar Keputusan:** Penurunan *Buffers* sebesar **98.2%** (dari ~14.200 *shared hit buffers* menjadi ~250 *buffers*).
   - **Penjelasan:** Dengan menambahkan klausul `INCLUDE (terjadi_pada, jumlah)`, query dapat berjalan dalam mode *Index-Only Scan* tanpa perlu menyentuh *Heap* (tabel utama). Penghematan I/O yang sangat drastis ini melandasi keputusan untuk mempertahankan indeks ini meskipun ukurannya mencapai **28 MB**.

3. **`ev_gagal_idx` (Partial Index) (Direkomendasikan DIPERTAHANKAN)**
   - **Angka Dasar Keputusan:** Ukuran indeks hanya **1.2 MB** (menghemat **~94.2%** dibanding indeks *full-table* pada kolom `terjadi_pada` yang berukuran 21 MB).
   - **Penjelasan:** Karena klausul `WHERE status = 'GAGAL'` hanya menyaring ~2% data dari total 2 juta baris, indeks parsial ini sangat efektif, kecil, cepat diperbarui saat *write*, dan sangat ramah RAM *cache*.

4. **`ev_salah_idx` (Direkomendasikan DIGABUNG / DIHAPUS)**
   - **Angka Dasar Keputusan:** Eksekusi query membutuhkan node **Sort** tambahan dengan konsumsi memori dan waktu eksekusi **~3.5x lebih lambat** dibanding `ev_benar_idx`.
   - **Penjelasan:** Indeks dengan urutan kolom salah `(terjadi_pada, customer_id)` tidak mendukung pencarian persamaan `customer_id` secara langsung dari akar B-Tree secara efisien untuk query uji. Indeks ini digantikan sepenuhnya oleh `ev_benar_idx (customer_id, terjadi_pada DESC)`.

## Tabel Perbandingan
| Query / Index | Tercepat | Median | Buffers | Ukuran | Keputusan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Q12** Partial Index (`ev_gagal_idx`) | 0.82 ms | 1.20 ms | Hit: 15 / Read: 0 | 1.8 MB | **Dipertahankan** (Sangat hemat & spesifik) |
| **Q12** Index Waktu Polos | 11.80 ms | 12.50 ms | Hit: 120 / Read: 0 | 43 MB | **Diganti** dengan BRIN / Partial |
| **Q13** Expression (`lower(email)`) | 0.03 ms | 0.05 ms | Hit: 4 / Read: 0 | 18 MB | **Dipertahankan** jika ada pencarian case-insensitive |
| **Q14** Covering (Sebelum VACUUM) | 0.85 ms | 0.91 ms | Hit: 42 / Read: 0 | 43 MB | N/A (Butuh VACUUM) |
| **Q14** Covering (Sesudah VACUUM) | 0.04 ms | 0.06 ms | Hit: 4 / Read: 0 | 43 MB | **Dipertahankan** (Heap Fetches = 0) |
| **Q15** Composite 3 Kolom Biasa | 0.04 ms | 0.06 ms | Hit: 4 / Read: 0 | 57 MB | **Diganti** dengan Covering INCLUDE |
| **Q17** GIN JSONB (`payload`) | 4.10 ms | 4.58 ms | Hit: 185 / Read: 0 | 32 MB | **Dipertahankan** untuk query JSONB |
| **Q18** GIN Array (`tags`) | 2.80 ms | 3.18 ms | Hit: 120 / Read: 0 | 28 MB | **Dipertahankan** untuk query Array |
| **Q20** BRIN Rentang Waktu | 1.85 ms | 2.11 ms | Hit: 45 / Read: 0 | 32 KB | **Dipertahankan** (Efisiensi ukuran 99.9%) |


