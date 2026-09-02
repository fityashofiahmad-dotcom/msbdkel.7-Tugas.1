# Laporan Tugas Praktik - Bagian [Nama Kamu]

## Pertanyaan 5
**Soal:** Seorang anggota kelompok mengubah isi V1__skema_awal.sql setelah migration tersebut sudah diterapkan, kemudian melakukan push ke repositori. Apa yang terjadi ketika anggota lain menjalankan migration? Jelaskan penyebab error dan cara memperbaikinya tanpa menghapus riwayat migration.

**Jawaban:**
Flyway akan menghasilkan *error* `Checksum mismatch` dan menolak menjalankan migrasi apa pun. 
*   **Penyebab:** Flyway menghitung nilai *checksum* (hash) dari setiap file migrasi saat dieksekusi dan menyimpannya di database. Karena file V1 diubah, checksum file lokal tidak lagi cocok dengan checksum di database. Ini adalah mekanisme Flyway untuk mencegah inkonsistensi skema.
*   **Cara memperbaiki:** Anggota yang mengalami error harus menjalankan perintah `flyway repair` (via Docker: `docker compose run --rm flyway repair`). Perintah ini akan menyelaraskan ulang nilai checksum di database agar sama dengan file lokal yang baru, tanpa menghapus riwayat yang sudah ada.

---

## Pertanyaan 6
**Soal:** Catat apa yang terlihat pada pg_stat_activity. Perintah mana yang menunggu? Apa akibatnya jika kondisi tersebut terjadi pada basis data produksi saat banyak pengguna sedang mengakses sistem?

**Jawaban:**
*   **Apa yang terlihat:** Terdapat antrean proses. Transaksi dari Terminal 1 berstatus `idle in transaction` (menahan kunci), sementara query dari Terminal 2 memiliki `wait_event_type` berupa `Lock` dengan `state` berstatus `active` (menunggu).
*   **Perintah yang menunggu:** Perintah DDL `ALTER TABLE peminjaman...` dari Terminal 2.
*   **Akibat pada sistem produksi:** Terjadi efek *Lock Stampede*. Perintah `ALTER TABLE` membutuhkan *Access Exclusive Lock* sehingga harus antre di belakang Terminal 1. Bahayanya, setiap query pengguna lain yang masuk *setelah* `ALTER TABLE` tersebut juga akan ikut dipaksa mengantre. Akibatnya sistem akan macet (*hang*), koneksi menumpuk, dan aplikasi bisa *down* sampai transaksi awal di-commit/rollback.