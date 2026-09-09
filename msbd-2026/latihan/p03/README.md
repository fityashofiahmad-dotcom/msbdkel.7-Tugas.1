## Latihan Pertemuan 3 - SQL Lanjutan I

## Prasyarat
- Docker aktif
- PostgreSQL aktif
- Basis data Pagila sudah terisi

## Menjalankan Setup
Get-Content latihan/p03/q00_setup.sql | docker compose exec -T postgres psql -U msbd -d pagila

## Menjalankan Jawaban Q1-Q20 dan R1
1. Get-Content latihan/p03/q01_tarif_di_atas_rata.sql | docker compose exec -T postgres psql -U msbd -d pagila
2. Get-Content latihan/p03/q02_kategori_lebih_60.sql | docker compose exec -T postgres psql -U msbd -d pagila
3. Get-Content latihan/p03/q03_pelanggan_pembayaran_besar.sql | docker compose exec -T postgres psql -U msbd -d pagila
4. Get-Content latihan/p03/q04_film_tidak_pernah_disewa.sql | docker compose exec -T postgres psql -U msbd -d pagila
5. Get-Content latihan/p03/q05_tarif_tertinggi_per_toko.sql | docker compose exec -T postgres psql -U msbd -d pagila
6. Get-Content latihan/p03/q06_cte_kategori.sql | docker compose exec -T postgres psql -U msbd -d pagila
7. Get-Content latihan/p03/q07_hierarki_pegawai.sql | docker compose exec -T postgres psql -U msbd -d pagila
8. Get-Content latihan/p03/q08_bawahan_bima.sql | docker compose exec -T postgres psql -U msbd -d pagila
9. Get-Content latihan/p03/q09_rekursi_tahan_siklus.sql | docker compose exec -T postgres psql -U msbd -d pagila
10. Get-Content latihan/p03/q10_tiga_peringkat_tarif.sql | docker compose exec -T postgres psql -U msbd -d pagila
11. Get-Content latihan/p03/q11_tiga_film_tertinggi.sql | docker compose exec -T postgres psql -U msbd -d pagila
12. Get-Content latihan/p03/q12_perubahan_omzet_harian.sql | docker compose exec -T postgres psql -U msbd -d pagila
13. Get-Content latihan/p03/q13_kumulatif_rerata_7hari.sql | docker compose exec -T postgres psql -U msbd -d pagila
14. Get-Content latihan/p03/q14_rows_vs_range.sql | docker compose exec -T postgres psql -U msbd -d pagila
15. Get-Content latihan/p03/q15_riwayat_pembayaran_pelanggan.sql | docker compose exec -T postgres psql -U msbd -d pagila
16. Get-Content latihan/p03/q16_rollup_kategori_rating.sql | docker compose exec -T postgres psql -U msbd -d pagila
17. Get-Content latihan/p03/q17_filter_per_kategori.sql | docker compose exec -T postgres psql -U msbd -d pagila
18. Get-Content latihan/p03/q18_rekonsiliasi_inventory_rental.sql | docker compose exec -T postgres psql -U msbd -d pagila
19. Get-Content latihan/p03/q19_notifikasi_lunas.sql | docker compose exec -T postgres psql -U msbd -d pagila
20. Get-Content latihan/p03/q20_bentangkan_kontak.sql | docker compose exec -T postgres psql -U msbd -d pagila
21. Get-Content latihan/p03/r1_laporan_bulanan.sql | docker compose exec -T postgres psql -U msbd -d pagila

## Catatan Q9
Q9 mengubah relasi atasan sementara. Pastikan data dipulihkan setelah uji siklus.

## Anggota
- Andika Chairul Ilham - 251402047
- Fahri Arizal - 251402102
- Fitya Shofi Ahmad - 251402132
- Mar'ie Rizqullah - 251402129