## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |

| Andika Chairul Ilham | 251402047 | Langkah 4, Langkah 6, Reflektif B, Reflektif D, Laporan | Commit |
| Fahri Arizal | 251402102 | Langkah 5, Reflektif C, Laporan | Commit |
| Fitya Shofi Ahmad | 251402132 | Langkah 1, Langkah 2, Langkah 3, Reflektif A, Laporan | Commit |
| Mar'ie Rizqullah | 251402129 | Langkah 7, Langkah 8, Reflektif E, Laporan | Commit |

## Refleksi A - Subquery
1. Hal yang membuat NOT IN berbahaya adalah nilai NULL dimana seandainya nilai NULL terselip di dalam subquery walau hanya 1 maka seluruh query NOT IN bakal langsung gagal total dab gabisa balikin data apapun alias kosong melompong. kenapa bisa gitu? alasannya karna dalam SQL, kalau ada perbandingan yang ketemu sama NULL, hasilnya bakal jadi UNKNOWN atau ga diketahui yang otomatis bakal rusak logika dari NOT IN.
Cara ngeceknya adalah dengan cek aja apakah kolom yang dipakai di subquery itu punya data NULL atau enggak, contohnya bisa pakai query SELECT COUNT(*) FROM nama_tabel WHERE kolom IS NULL;. Nah kalau angkanya lebih dari nol, berarti kolomnya itu rawan banget bikin NOT IN rusak.
2. Secara konseptual, subquery yang berkorelasi itu dievaluasi sekali untuk setiap 1 baris di tabel luar. Sedangkan kenyataannya, postgreSQL ini udah canggih banget karna dia udah punya query optimizer. Jadi, PostgreSQL ga bakal bener-bener jalanin perulangan satu-satu secara haarfiah, melainkan bakal otomatis ubah atau gabungin prosesnya jadi teknik yang jauh lebih cepet supaya eksekusinya efisien tanpa bikin CPU kerja 2x lipat.

## Refleksi B - CTE dan Recursive CTE
...

## Refleksi C - Window Function
1. Mengapa terdapat 34 tanggal yang berbeda dan sifat data apa yang memengaruhinya?
Perbedaan sebanyak 34 baris/tanggal tersebut terjadi karena sifat data pada tabel payment yang memiliki banyak transaksi pada tanggal atau waktu yang identik (nilai duplikat pada kolom pengurutan). Klausa default RANGE memperlakukan baris-baris dengan nilai urut yang sama sebagai peer (kelompok setara) dan menyertakan semuanya sekaligus dalam perhitungan jendela. Sebaliknya, klausa ROWS menghitung secara fisik baris demi baris secara ketat berdasarkan urutan fisik tanpa peduli apakah nilai datanya sama atau tidak.

2. Versi mana yang benar untuk laporan keuangan resmi dan mengapa kesalahan frame sulit ditemukan?
Untuk laporan keuangan resmi, versi yang benar adalah menggunakan frame ROWS yang eksplisit. Kesalahan akibat menggunakan default RANGE sangat sulit ditemukan melalui pengujian fungsional biasa karena query tetap berjalan sukses tanpa menghasilkan error SQL. Namun, secara diam-diam kesalahan ini merusak akurasi karena nilai rata-rata bergerak atau kumulatif akan melompat (jump) ketika menemui tanggal transaksi yang sama.

3. Apa yang terjadi pada total belanja di Q15 jika ORDER BY ditambahkan ke OVER tanpa frame?
Jika klausa ORDER BY ditambahkan ke dalam OVER() tanpa mendefinisikan batas frame secara eksplisit, PostgreSQL secara otomatis menerapkan default frame yaitu RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. Akibatnya, kolom total belanja berubah fungsi menjadi running total (kumulatif belanja berjalan per baris transaksi), sehingga tidak lagi menampilkan total keseluruhan belanja pelanggan secara utuh di setiap barisnya.

## Temuan Q14
- **Jumlah baris/tanggal yang berbeda:** Sebanyak **34 baris**.
- **Penjelasan Teknis:** Perbedaan ini timbul karena perbedaan perlakuan antara frame berbasis baris fisik (`ROWS`) dan frame berbasis rentang nilai (`RANGE`). Pada tabel `payment`, ada banyak transaksi yang terjadi pada hari yang sama. `RANGE` menggabungkan kelompok tanggal yang sama sebagai satu kesatuan nilai (peer), sedangkan `ROWS` memperlakukan setiap baris secara terpisah berdasarkan urutan eksekusinya. Hal ini menyebabkan hasil agregasi seperti rata-rata bergerak 7 hari (`rerata_7hari`) pada tanggal-tanggal tersebut menghasilkan angka yang berbeda.

## Refleksi D - Agregasi dan Operasi Himpunan
...

Refleksi E - JSONB
Dari atribut di dalam payload (nomor transaksi, status, jumlah, dan identitas pelanggan):

Yang sebaiknya dipromosikan menjadi kolom relasional (dengan constraint): Kolom seperti status (dengan CHECK constraint) dan jumlah (tipe data numerik), serta relasi pelanggan_id sebagai Foreign Key. Alasan: Atribut-atribut ini sering menjadi subjek utama operasi relasional berfrekuensi tinggi seperti pemfilteran (WHERE), pengurutan, agregasi matematis (SUM, AVG), serta membutuhkan integritas data yang ketat melalui constraints.

Yang tepat tetap berada di JSON: Atribut semi-terstruktur seperti array kontak (berisi daftar jenis dan nomor kontak yang jumlahnya bisa dinamis atau berbeda tiap transaksi). Alasan: Struktur bersarang (nested array) lebih fleksibel disimpan dalam format JSONB jika skemanya sering berkembang atau tidak seragam, sehingga menghindarkan kebutuhan pembuatan tabel relasional anak (relasi one-to-many) yang berlebihan untuk data pelengkap.

## Temuan Q14
...

## Hasil R1
![Sepuluh baris pertama](r1_10_bars/png)

## Tautan Merge Request
...
