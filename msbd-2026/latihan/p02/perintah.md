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