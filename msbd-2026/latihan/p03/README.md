## Latihan Pertemuan 3 - SQL Lanjutan I

## Prasyarat
- Docker aktif
- PostgreSQL aktif
- Basis data Pagila sudah terisi

## Menjalankan Setup
docker compose exec -T db psql -U postgres -d pagila \
  -f /dev/stdin < latihan/p03/q00_setup.sql

## Menjalankan Jawaban Q1-Q20 dan R1
1. docker compose exec -T db psql -U postgres -d pagila \
  -f /dev/stdin < latihan/p03/q01_tarif_di_atas_rata.sql

## Catatan Q9
Q9 mengubah relasi atasan sementara. Pastikan data dipulihkan setelah uji siklus.

## Anggota
- Andika Chairul Ilham - 251402047
- Fahri Arizal - 251402102
- Fitya Shofi Ahmad - 251402132
- Mar'ie Rizqullah - 251402129