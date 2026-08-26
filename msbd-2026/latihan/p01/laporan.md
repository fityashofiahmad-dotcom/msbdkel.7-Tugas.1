# Laporan Praktikum P01

## 1. Verifikasi Docker & Docker Compose
* **Keluaran docker --version:**
![Docker Version](./bukti/docker-version.png)

* **Keluaran docker compose version:**
![Docker Compose Version](./bukti/docker-compose-version.png)

## 2. Pertanyaan Pemahaman (Image, Container, dan Volume)
1. **Docker Image:** Template atau blueprint yang berisi instruksi lengkap tapi masih bersifat read-only.
2. **Container:** Wujud nyata atau aplikasi yang lagi berjalan (runtime) dari sebuah Docker Image.
3. **Volume:** Media penyimpanan data khusus yang dibuat supaya data tetap aman dan persisten (menetap) walaupun containernya dihapus atau dimatikan.

---

## 3. Pertanyaan Langkah 2 (Menyusun dan Menjalankan Docker Compose)
1. **Apa yang terjadi jika bagian `volumes:` pada layanan PostgreSQL dihapus, kemudian container dihentikan menggunakan `docker compose down -v`?**
   * Volume digunakan agar data PostgreSQL tetap tersimpan meskipun container dihentikan. Jika bagian `volumes` dihapus dan dihentikan dengan `down -v`, maka seluruh data di dalam database akan hilang dan kita harus memulai dari awal (database kosong).
2. **Mengapa pemetaan port ditulis "5432:5432" dan bukan cukup satu angka? Apa yang harus diubah apabila komputer Anda sudah memiliki PostgreSQL lain yang menggunakan port 5432?**
   * Penulisan "5432:5432" berarti port host 5432 (kiri) diarahkan ke port PostgreSQL 5432 di dalam container (kanan). Apabila port 5432 di komputer (host) sudah digunakan, kita harus mengubah angka di sebelah kiri menjadi port yang kosong, misalnya `"5433:5432"`.
3. **Apa fungsi blok healthcheck? Mengapa healthcheck penting ketika terdapat layanan lain yang bergantung pada basis data?**
   * Fungsi `healthcheck` adalah untuk memastikan PostgreSQL benar-benar sudah siap menerima koneksi. Hal ini penting agar layanan atau aplikasi lain yang bergantung pada database tidak *crash* atau *error* saat mencoba terhubung sebelum database selesai melakukan proses *startup*.
4. **Menyimpan password langsung di dalam `docker-compose.yml` merupakan praktik yang kurang baik. Sebutkan satu cara yang lebih aman dan jelaskan mengapa hal tersebut penting ketika berkas masuk ke repositori Git.**
   * Cara yang lebih aman adalah menggunakan berkas `.env` untuk menyimpan kredensial, kemudian memanggilnya sebagai variabel di dalam `docker-compose.yml`. Hal ini penting karena berkas `.env` dimasukkan ke `.gitignore` sehingga *password* tidak akan ikut ter-upload dan terbaca oleh publik saat masuk ke repositori Git.

---

## 4. Uji Koneksi PostgreSQL melalui CLI (psql)
![Koneksi PostgreSQL melalui psql](./bukti/02-psql-koneksi.png)

### Langkah-langkah:
1. Membuka Terminal atau PowerShell.
2. Memastikan container PostgreSQL telah berjalan.
3. Menjalankan perintah berikut untuk masuk ke database PostgreSQL:
```bash
docker compose exec postgres psql -U msbd -d latihan