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