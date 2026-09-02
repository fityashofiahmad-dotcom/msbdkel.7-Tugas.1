## 1. Domain yang dipilih:
Sistem Manajemen Festival Musik.

## 2. Nama anggota kelompok
1. Andika Chairul Ilham - 251402047
2. Fahri Arizal - 251402102
3. Fitya Shofi Ahmad - 251402132
4. Mar'ie Rizqullah - 251402129

## 3. Cara menjalankan Docker Compose
Buka terminal atau command prompt pada direktori proyek kelompok yang memiliki file docker-compose.yml, lalu jalankan perintah:

docker compose up -d

untuk menjalankan container di latar belakang dan jalankan perintah:

docker compose ps

untuk memeriksa status container yang sedang berjalan.

## 4. Cara menjalankan migration
Migration basis data bisa dijalankan dengan menggunakan terminal atau command prompt di direktori proyek dengan perintah:

docker compose exec app php artisan migrate

Note: Sesuaikan nama service app dan perintah framework jika tidak menggunakan docker dengan konfigurasi berbeda.

## 5. Cara menjalankan seed data
Untuk menjalankan seed data bisa dengan menjalankan perintah berikut di terminal pada direktori proyek:

docker compose exec app php artisan db:seed