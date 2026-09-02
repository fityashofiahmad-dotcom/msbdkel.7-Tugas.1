## 1. a. Domain yang dipilih:
Sistem Manajemen Festival Musik
## 1. b. Alasan pengambilan domain tersebut:
Pemilihan domain ini didasari oleh kebutuhan untuk mengeksplorasi kompleksitas pengelolaan basis data pada industri hiburan skala besar yang menawarkan tantangan logika relasional lebih dinamis dibandingkan sistem konversional. Sistem ini dirancang untuk memahami arsitektur data platform tiket profesional, khususnya dalam menangani validasi aturan bisnis yang kompleks seperti pencegahan konflik jadwal panggung (conflict scheduling), pengelolaan kuota venue, penyesuaian harga tiket dinamis (early-bird), serta transaksi merchandise pre-order yang terikat pada data tiket.

## 2. Ringkasan lingkup sistem.
Sistem Manajemen Festival Musik dirancang untuk mengelola seluruh siklus operasional acara musik secara terpusat. Lingkup utamanya mencakup pencatatan data induk mulai dari venue, artis, hingga event konser itu sendiri. Sistem juga mengakomodasi relasi kompleks seperti Lineup artis dan pemesanan merchandise pre-order yang terikat dengan tiket pembeli. Di sisi fungsional, sistem berfokus pada validasi logika bisnis yang ketat, meliputi pencegahan jadwal panggung yang tumpang tindih (conflict scheduling prevention) secara otomatis, pengendalian kuota kapasitas venue terhadap tiket yang terjual, serta penyesuaian harga tiket dinamis berdasarkan status kuota early-bird. Sebaliknya, sistem ini tidak mencakup hal-hal yang bersifat eksternal atau fisik murni, seperti integrasi langsung dengan payment gateway perbankan, proses logistik pengiriman kurir untuk merchandise, pembuatan kontrak kerja sama artis, maupun pengelolaan internaal panitia acara.

## 3. Ringkasan kebutuhan data yang dibuat.
Sistem ini merumuskan 10 Kebutuhan Data (KD-01 hingga KD-10) yang terbagi menjadi 2 kategori utama. Kelompok inti mencakup pengelolaan data entitas dasar (Venue, Artist, Event, Customer), serta data operasional kruisal seperti Lineup Artis, Stage_Schedule untuk pencegahan jadwal bentrok, Transaksi Tickte, dan Validasi Kapasitas. Sementara itu, kelompok pendukung berfokus pada fitur komersial melalui Manajemen Merchandise dan Pemesanan Merchandise Pre-Order. Seluruh kebutuhan ini dirancang terintegrasi untuk menjaga integritas data dan mengotomatisasi aturan bisnis yang kompleks.

## 4. Penjelasan singkat ERD.

## 5. Keluaran atau ringkasan status migration.

## 6. Bukti database dapat dibangun ulang menggunakan migration.

## 7. Bukti pola 3 langkah penambahan kolom NOT NULL.

## 8. Hasil seed data setelah dijalankan 2 kali.

## 9. Pengamatan dari pg_stat_activity.

## 10. Jawaban pertanyaan 1-7:
1. 
2. Dari 10 Kebutuhan data, kami mengambil KD-05 Jadwal Panggung (Stage_Schedule) dan Aturan jadwal bentrok ini paling cocok pakai Trigger. Alasannya, kalau cuma pakai constraint bawaan SQL kayak CHECK atau UNIQUE, database nggak bakal sanggup ngecek irisan jam tampil yang tumpang tindih antar-baris secara otomatis. Di sisi lain, kalau cuma diatur lewat kode aplikasi, data gampang banget kena race condition atau bobol kalau sewaktu-waktu ada yang akses database langsung di luar aplikasi. Jadi, trigger adalah pilihan paling aman karena sistem bakal otomatis ngecek dan nolak jadwal yang bentrok langsung di dalam database sebelum datanya sempat kesimpan.
3. Satu transaksi peminjaman biasanya berisi lebih dari satu unit alat sekaligus (misalnya meminjam 3 unit dalam satu kali transaksi), dan satu unit alat bisa dipinjam berkali-kali pada peminjaman yang berbeda-beda. Ini adalah relasi many-to-many, yang tidak bisa direpresentasikan langsung antara dua entitas — harus diuraikan menjadi entitas asosiatif. Jika Peminjaman dan Unit Alat dihubungkan langsung (misalnya lewat foreign key tunggal), maka satu baris peminjaman hanya bisa mencatat satu unit alat saja, sehingga informasi "unit apa saja yang dipinjam dalam satu transaksi" akan hilang. Baris_Pinjam menyimpan detail per unit di dalam satu transaksi peminjaman, termasuk kemungkinan atribut tambahan seperti kondisi alat saat dipinjam per unit.
4. 
5. 
6. 
7. 

## 11. Daftar kontribusi atau commit masing2 anggota kelompok.
1. Andika Chairul Ilham - 
2. Fahri Arizal -
3. Fitya Shofi Ahmad - 
4. Mar'ie Rizqullah - 
