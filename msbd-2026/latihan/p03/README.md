## Latihan Pertemuan 3 - SQL Lanjutan I

## Prasyarat
- Docker aktif
- PostgreSQL aktif
- Basis data Pagila sudah terisi

## Menjalankan Setup
Get-Content latihan/p03/q00_setup.sql | docker compose exec -T postgres psql -U msbd -d pagila

## Menjalankan Jawaban Q1-Q20 dan R1
1. Get-Content latihan/p03/q01_tarif_di_atas_rata.sql | docker compose exec -T postgres psql -U msbd -d pagila
2. Get-Content latihan/p03/q02_kategori_lebih_60.sql | docker compose exec -T postgres psql -U msbd -d pagila
3. Get-Content latihan/p03/q03_pelanggan_pembayaran_besar.sql | docker compose exec -T postgres psql -U msbd -d pagila
4. Get-Content latihan/p03/q04_film_tidak_pernah_disewa.sql | docker compose exec -T postgres psql -U msbd -d pagila
5. Get-Content latihan/p03/q05_tarif_tertinggi_per_toko.sql | docker compose exec -T postgres psql -U msbd -d pagila
6. 
7. 
8. 
9. 
10. 
11. 
12. 
13. 
14. 
15. 
16. 
17. 
18. 
19. 
20. 

## Catatan Q9
Q9 mengubah relasi atasan sementara. Pastikan data dipulihkan setelah uji siklus.

## Anggota
- Andika Chairul Ilham - 251402047
- Fahri Arizal - 251402102
- Fitya Shofi Ahmad - 251402132
- Mar'ie Rizqullah - 251402129