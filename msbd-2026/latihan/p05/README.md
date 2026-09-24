# Latihan Lab 5: Dari Procedure hingga Endpoint

Repositori ini berisi rangkaian latihan praktikum Basis Data Lanjutan yang mencakup implementasi prosedur PL/pgSQL, pengelolaan transaksi, tipe data lanjutan PostgreSQL (`DOMAIN`, `ENUM`, `ARRAY`, `JSONB`), koneksi aman dengan `psycopg` (termasuk connection pooling), optimasi ORM SQLAlchemy untuk mengatasi masalah N+1, serta pembuatan API menggunakan FastAPI dengan translasi galat yang aman.

---

## 1. Prasyarat Sistem
Pastikan perangkat lunak berikut sudah terpasang di komputer/lingkungan kerja Anda:
* **Docker & Docker Compose** (untuk menjalankan container PostgreSQL)
* **Python 3.10+** (bersama `pip` dan modul `venv`)
* **Git**

---

## 2. Variabel DSN (Data Source Name)
Aplikasi Python pada lab ini menggunakan koneksi basis data standar dengan format DSN berikut (sesuaikan port jika menggunakan port selain `5434`, misalnya `5432`):
```text
postgresql://postgres:postgres@localhost:5434/proyek_dev 


# Cara Setup lab5
1. Jalankan layanan PostgresSQL melalui Docker:
docker compose up -d
docker compose ps
2. Buat dan aktifkan virtual environment Python:
python3 -m venv .venv
source .venv/bin/activate  
# Untuk Windows (Git Bash): source .venv/Scripts/activate
3. Install dependensi paket Python:
pip install "psycopg[binary,pool]==3.2.*" "sqlalchemy==2.0.*" "fastapi==0.115.*" "uvicorn==0.32.*" "pydantic==2.*"
4. Eksekusi skrip setup untuk membuat skema dan tabel lab5:
psql "postgresql://postgres:postgres@localhost:5434/proyek_dev" -f latihan/p05/q00_setup.sql
