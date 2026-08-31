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

### B. Menuliskan lingkup.
* **Buat:**
latihan/p02/kebutuhan.md
* **Menuliskan bagian TERMASUK dan TIDAK TERMASUK, masing-masing minimal 4 poin.**

### C. Menuliskan minimal 8 kebutuhan data.
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