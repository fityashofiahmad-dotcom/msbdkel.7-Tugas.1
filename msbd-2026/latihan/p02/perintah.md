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

## 2. Menentukan lingkup dan kebutuhan data

### A. Menentukan Domain
* **Memilih 1 domain yang akan digunakan oleh kelompok pada latihan ini.**

syarat Domain:
1. Minimal 6 entitas.
2. Minimal 1 relasi many to many.
3. Minimal 1 aturan bisnis yang tidak sederhana.

Note: Hindari domain yang terlalu luas.

### B. Menuliskan Lingkup.
* **Buat:**
latihan/p02/kebutuhan.md
* **Menuliskan bagian TERMASUK dan TIDAK TERMASUK, masing-masing minimal 4 poin.**

### C. Menuliskan Minimal 8 Kebutuhan Data.
* **Gunakan format KD-01, KD-02, KD-03,...**
* **Setiap kebutuhan wajib memuat:**
1. Deskripsi
2. Data
3. Aturan
4. Volume
5. Sumber
6. Prioritas
* **Pertanyaan 2**
Pilih satu kebutuhan yang memiliki aturan paling rumit. Menurut kelompok kalian, apakah aturan tersebut lebih tepat ditegakkan menggunakan constraint, trigger, atau kode aplikasi? Berikan satu alasan.

## 3. Membuat ERD konseptual.

* **Membuat ERD berdasarkan kebutuhan data kelompok.**

syarat ERD:
1. Minimal 6 entitas beserta atribut kunci alaminya.
2. Kardinalitas pada setiap relasi.
3. Relasi M:N yang sudah diuraikan menjadi entitas asosiatif.
4. Notasi yang konsisten.
5. Tidak memasukkan detail implementasi fisik.

Note: Jangan masukkan detail fisik seperti bigint, varchar(120), created_at, atau nama index.

* **Ekspor hasil akhir menjadi:**
latihan/p02/erd.png
* **Pertanyaan 3**
Mengapa Peminjaman dan Unit Alat pada contoh tidak dihubungkan langsung, tetapi melalui Baris Pinjam? Apa yang hilang jika hubungan dibuat langsung?
* **Pertanyaan 4**
Apa perbedaan antara entitas Alat dan Unit Alat? Sebutkan satu pertanyaan bisnis yang hanya dapat dijawab jika keduanya dipisahkan.

## 4. Membuat migrasi skema berversi

* **Gunakan Flyway melalui Docker untuk mengelola migration.
### A. Menyiapkan Struktur Folder
latihan/
└── p02/
    ├── kebutuhan.md
    ├── erd.png
    ├── migrations/
    │   └── V1__skema_awal.sql
    ├── seeds/
    ├── bukti/
    ├── laporan.md
    └── README.md

### B. Menambahkan Flyway
* **Tambahkan service Flyway pada docker-compose.yml
flyway:
  image: flyway/flyway:11
  depends_on:
    - postgres
  volumes:
    - ./latihan/p02/migrations:/flyway/sql
  command: >
    -url=jdbc:postgresql://postgres:5432/proyek_dev
    -user=postgres
    -password=postgres
    -connectRetries=10
    migrate

### C. Membuat Migration Pertama
* **Terjemahkan sebagian ERD menjadi DDL. Gunakan sekitar 3–4 tabel inti pada migration pertama.**
* **Buat file:**
latihan/p02/migrations/V1__skema_awal.sql

### D. Menjalankan Migration
docker compose run --rm flyway migrate
docker compose run --rm flyway info
* **Periksa riwayat migration:**
docker compose exec postgres psql -U postgres -d proyek_dev -c \
"SELECT installed_rank, version, description, success
FROM flyway_schema_history
ORDER BY installed_rank;"
* **Simpan screenshot hasil flyway info dan riwayat migration ke folder latihan/p02/bukti/.**

### E. Membuktikan Database Dapat Dibangun Ulang
docker compose exec postgres psql -U postgres -c \
"DROP DATABASE proyek_dev; CREATE DATABASE proyek_dev;"
docker compose run --rm flyway migrate
docker compose run --rm flyway info
* **Simpan bukti hasil rebuild ke folder bukti/ .**
* **Pertanyaan 5**
Seorang anggota kelompok mengubah isi V1__skema_awal.sql setelah migration tersebut sudah diterapkan, kemudian melakukan push ke repositori. Apa yang terjadi ketika anggota lain menjalankan migration? Jelaskan penyebab error dan cara memperbaikinya tanpa menghapus riwayat migration.