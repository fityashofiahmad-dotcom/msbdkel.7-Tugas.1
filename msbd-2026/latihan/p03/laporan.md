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
...

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
