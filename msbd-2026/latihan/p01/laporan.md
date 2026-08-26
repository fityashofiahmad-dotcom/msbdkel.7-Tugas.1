<<<<<<< HEAD
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


## 3. Uji Koneksi PostgreSQL melalui CLI (psql)

![Koneksi PostgreSQL melalui psql](./bukti/02-psql-koneksi.png)

### Langkah-langkah:
1. Membuka Terminal atau PowerShell.
2. Memastikan container PostgreSQL telah berjalan.
3. Menjalankan perintah berikut untuk masuk ke database PostgreSQL:

```bash
docker compose exec postgres psql -U msbd -d latihan
```

## 4. Pemeriksaan Versi PostgreSQL melalui CLI (psql)

![PostgreSQL Version melalui psql](./bukti/03-psql-version.png)

### Langkah-langkah:
1. Membuka Terminal atau PowerShell.
2. Masuk ke PostgreSQL menggunakan perintah:

```bash
docker compose exec postgres psql -U msbd -d latihan
```

## 5. Uji Koneksi PostgreSQL melalui DBeaver

![Koneksi PostgreSQL melalui DBeaver](./bukti/04-dbeaver-koneksi.png)

### Langkah-langkah:
1. Membuka aplikasi **DBeaver Community Edition**.
2. Memilih menu **New Database Connection** untuk membuat koneksi baru.
3. Memilih **PostgreSQL** sebagai jenis database.
4. Mengisi konfigurasi koneksi sebagai berikut:

| Parameter | Nilai |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `latihan` |
| Username | `msbd` |

5. Memasukkan password PostgreSQL sesuai dengan konfigurasi Docker Compose.
6. Memilih **Test Connection** untuk menguji koneksi.
7. Setelah koneksi berhasil, memilih **Finish**.
8. Membuka koneksi database `latihan` pada bagian **Database Navigator**.
9. Membuka bagian **Schemas**.
10. Membuka schema `public` untuk melihat objek database.

### Hasil:
Koneksi PostgreSQL melalui DBeaver berhasil dilakukan. Database `latihan` dapat diakses menggunakan host `localhost` dan port `5432`.

Schema `public` juga berhasil ditampilkan pada DBeaver. Pada tahap ini bagian `Tables` masih kosong karena database `latihan` belum memiliki tabel.

Keberhasilan koneksi ini menunjukkan bahwa DBeaver dapat berkomunikasi dengan PostgreSQL yang berjalan di dalam Docker.

## 6. Menjalankan Query PostgreSQL melalui DBeaver

![SELECT version melalui DBeaver](./bukti/05-dbeaver-query.png)

### Langkah-langkah:
1. Membuka aplikasi **DBeaver Community Edition**.
2. Memilih koneksi database `latihan` yang sebelumnya telah dibuat.
3. Membuka **SQL Editor** pada koneksi PostgreSQL.
4. Menuliskan query berikut:

```sql
SELECT version();
```

## 7. Perbandingan Penggunaan psql dan DBeaver

### 7.1 Aktivitas yang Lebih Cepat Menggunakan psql

Menurut saya, aktivitas yang lebih cepat dilakukan menggunakan `psql` adalah menjalankan perintah atau query SQL secara langsung melalui terminal. Dengan `psql`, saya dapat langsung mengetik perintah tanpa harus membuka atau memilih menu pada antarmuka grafis.

Contohnya adalah ketika melakukan pengecekan database menggunakan perintah:

```text
\l
\dt
\dn
\du
```
=======
\# Laporan Latihan Mandiri Pertemuan 1

\## Menyiapkan Lingkungan Kerja Basis Data



\### V3 — Lima Film dengan Jumlah Penyewaan Terbanyak



Query:



```sql

SELECT f.title, count(\*) AS total\_sewa

FROM rental r

JOIN inventory i

&#x20; ON i.inventory\_id = r.inventory\_id

JOIN film f

&#x20; ON f.film\_id = i.film\_id

GROUP BY f.title

ORDER BY total\_sewa DESC

LIMIT 5;

>>>>>>> 8cbc06bc8a820b09f188f512511908afde83bc95
