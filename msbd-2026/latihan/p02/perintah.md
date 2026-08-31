# Perintah untuk Tugas 02

## 1. Menyiapkan basis data
* **Menjalankan Docker Compose dari repositori kelompok**
docker compose up -d

docker compose ps
* **Membuat 2 database baru untuk latihan:**
docker compose exec postgres psql -U postgres -c \
"CREATE DATABASE proyek_dev;"

docker compose exec postgres psql -U postgres -c \
"CREATE DATABASE proyek_test;"
* **Memverifikasi:**
docker compose exec postgres psql -U postgres -l | grep proyek
* **Pertanyaan 1**
Mengapa lingkungan pengujian memerlukan basis data sendiri, dan bukan sekadar schema terpisah di dalam basis data yang sama? Jawab dalam sekitar dua kalimat.