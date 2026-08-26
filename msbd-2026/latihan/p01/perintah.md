# Perintah Untuk Tugas 01

## 1. Memasang dan Memverifikasi Docker
* **Menjalankan tiga perintah berikut secara berurutan di Terminal, Powershell, atau command line:**
1. docker --version
2. docker compose version
3. docker run --rm hello-world
* **Salin keluaran perintah atau buat screenshot untuk dimasukkan ke laporan.**
* **Pertanyaan Pemahaman**
1. Apa yang dimaksud dengan Docker Image?
2. Apa yang dimaksud dengan Container?
3. Apa fungsi Volume?

## 2. Menyusun dan Menjalankan Docker Compose
* **Buat irektori kerja:**
msbd-2026/
* **Isi dengan berkas docker-compose.yml.**
* **Isi dengan:**
services:
  postgres:
    image: postgres:17
    container_name: msbd-pg
    environment:
      POSTGRES_USER: msbd
      POSTGRES_PASSWORD: msbd2026
      POSTGRES_DB: latihan
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./dump:/dump
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U msbd"]
      interval: 10s
      retries: 5

  mongo:
    image: mongo:8
    container_name: msbd-mongo
    environment:
      MONGO_INITDB_ROOT_USERNAME: msbd
      MONGO_INITDB_ROOT_PASSWORD: msbd2026
    ports:
      - "27017:27017"
    volumes:
      - mongodata:/data/db

  redis:
    image: redis:7-alpine
    container_name: msbd-redis
    ports:
      - "6379:6379"

volumes:
  pgdata:
  mongodata:
* **Jalankan environment:**
mkdir -p dump
docker compose up -d
docker compose ps
docker compose logs postgres | tail -20
* **Note: Pastikan ketiga layanan berhasil berjalan dan PostgreSQL menunjukkan kondisi running/healthy.**
* **Pertanyaan Wajib**
1. Apa yang terjadi jika bagian volumes: pada layanan PostgreSQL dihapus, kemudian container dihentikan menggunakan docker compose down -v?
2. Mengapa pemetaan port ditulis "5432:5432" dan bukan cukup satu angka? Apa yang harus diubah apabila komputer Anda sudah memiliki PostgreSQL lain yang menggunakan port 5432?
3. Apa fungsi blok healthcheck? Mengapa healthcheck penting ketika terdapat layanan lain yang bergantung pada basis data?
4. Menyimpan password langsung di dalam docker-compose.yml merupakan praktik yang kurang baik. Sebutkan satu cara yang lebih aman dan jelaskan mengapa hal tersebut penting ketika berkas masuk ke repositori Git.

## 3. Mengakses PostgreSQL melalui psql dan DBeaver.
1. **Menggunakan psql**
* **Masuk ke PosgreSQL:**
docker compose exec postgres psql -U msbd -d latihan
* **Jalankan perintah berikut:**
SELECT version();

\l
\dt
\dn
\du

SHOW data_directory;
SHOW shared_buffers;

\timing on
\q
2. **Menggunakan DBeaver**
* **Buat koneksi PostgreSQL baru di DBeaver.**
* **Hubungkan ke database latihan.**
* **Telusuri skema public.**
* **Buka bagian ER Diagram.**
* **Pertanyaan Wajib**
1. Satu aktivitas yang menurut Anda lebih cepat dilakukan menggunakan psql.
2. Satu aktivitas yang menurut Anda lebih cepat dilakukan menggunakan DBeaver.

## 4. Restore Basis Data Pagila dan Verifikasi
* **Letakkan pagila.dump di dalam direktori ./dump.**
1. Buat database kosong
docker compose exec postgres createdb -U msbd pagila
2. Restore Pagila
docker compose exec postgres pg_restore -U msbd -d pagila --no-owner /dump/pagila.dump
3. Verifikasi tabel
docker compose exec postgres psql -U msbd -d pagila -c "\dt"
* **Query Verifikasi**
1. V1-Jumlah tabel pada skema public
SELECT count(*)
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';
* **Nilai rujukan: 21 tabel.**
2. V2 — Sepuluh tabel terbesar beserta ukurannya
SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS ukuran
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
3. V3 — Lima film dengan jumlah penyewaan terbanyak
SELECT f.title, count(*) AS total_sewa
FROM rental r
JOIN inventory i
  ON i.inventory_id = r.inventory_id
JOIN film f
  ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY total_sewa DESC
LIMIT 5;
4. V4 — Melihat rencana eksekusi query
EXPLAIN ANALYZE
SELECT f.title, count(*)
FROM rental r
JOIN inventory i
  ON i.inventory_id = r.inventory_id
JOIN film f
  ON f.film_id = i.film_id
GROUP BY f.title;
* **Salin hasilnya ke laporan, kemudian lengkapi kalimat berikut:**
“Yang paling membingungkan dari keluaran ini adalah __________.”

## 5. Menyiapkan Repositori Git Tim
* **Gunakan repositori tim yang akan dipakai untuk menyimpan hasil latihan dan artefak pembelajaran selama semester.**
Gunakan struktur berikut:
msbd-2026/
├── docker-compose.yml
├── .gitignore
├── README.md
├── dump/
├── latihan/
│   └── p01/
│       ├── perintah.md
│       ├── verifikasi.sql
│       ├── laporan.md
│       └── bukti/
└── proyek/
    └── docs/
* **Inisialisasi Git**
git init

printf 'dump/\n*.dump\n.env\n.DS_Store\n' > .gitignore

git add .

git commit -m "chore: menyiapkan lingkungan MSBD"

git branch -M main

git remote add origin <URL repositori tim>

git push -u origin main
 * **Aturan Repositori**
 1. Berkas dump, kredensial, dan .env tidak boleh dimasukkan ke repositori.
 2. Setiap anggota tim melakukan commit menggunakan akun masing-masing.
 3. Gunakan pesan commit yang menjelaskan perubahan, misalnya feat:, fix:, docs:, atau chore:.
 