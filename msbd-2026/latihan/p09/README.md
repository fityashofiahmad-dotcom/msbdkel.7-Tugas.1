# Latihan Kelompok 7 Pertemuan 9: Menguji Transaksi dan Kendali Konkurensi

## Anggota Kelompok
| Nama | NIM | Bagian |
| Andika Chairul Ilham | 251402047 | Langkah 3 (Q14 - Q17) + Langkah 4 (Q14 - Q21) |
| Fahri Arizal | 251402102 | Langkah 2 + Langkah 3 (Q12 - Q13) |
| Fitya Shofi Ahmad | 251402132 | Langkah 1 + Langkah 6 |
| Mar'ie Rizqullah | 251402129 | Langkah 4 (Q22 - Q23) + Langkah 5 |

## Struktur Folder
...

## Cara Menjalankan
1. Jalankan q00_setup.sql untuk membuat skema lab9, tabel rekening, dan data awal.
2. Buka dua SQL Editor sebagai sesi A dan sesi B dengan koneksi terpisah.
3.  Jalankan q1.sql - q32.sql sesuai urutan soal. Setiap bagian diberi komentar sesi dan nomor Q.
4. Setelah tiap eksperimen, ROLLBACK transaksi yang gagal dan pulihkan data awal.

   UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id IN (1, 2);

5. Timeout diuji dengan SET LOCAL di dalam transaksi atau dipulihkan dengan RESET.