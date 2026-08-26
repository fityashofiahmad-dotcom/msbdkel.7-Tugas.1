# Laporan Praktikum P01

## 1. Verifikasi Docker & Docker Compose
* **Keluaran docker --version:**
![Docker Version](./bukti/docker-version.png)

* **Keluaran docker compose version:**
![Docker Compose Version](./bukti/docker-compose-version.png)


## 2. Verifikasi Database

## 3. Pertanyaan Pemahaman (Image, Container, dan Volume)
1. **Docker Image:** Template atau blueprint yang berisi instruksi lengkap tapi masih bersifat read-only.
2. **Container:** Wujud nyata atau aplikasi yang lagi berjalan (runtime) dari sebuah Docker Image.
3. **Volume:** Media penyimpanan data khusus yang dibuat supaya data tetap aman dan persisten (menetap) walaupun containernya dihapus atau dimatikan.


## 4. Uji Koneksi PostgreSQL melalui CLI (psql)

![Koneksi PostgreSQL melalui psql](./bukti/02-psql-koneksi.png)

### Langkah-langkah:
1. Membuka Terminal atau PowerShell.
2. Memastikan container PostgreSQL telah berjalan.
3. Menjalankan perintah berikut untuk masuk ke database PostgreSQL:

```bash
docker compose exec postgres psql -U msbd -d latihan

