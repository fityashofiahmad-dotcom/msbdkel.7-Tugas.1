# Latihan Kelompok Pertemuan 11: Menutup Pintu yang Terbuka
* Pertahanan berlapis padaa skema lab11 (PostgreSQL 17): peran berlapis, Row-Level Security, query berparameter, enskripsi dan hashing, penyamaran, audit, dan pemetaan UU PDP.
* *Peringatan etika: Semua percobaan hanya boleh dijalankan di kontainer lab11 milik sendiri, pada jaringan yang tidak tersambung ke internet. Menjalankan hal yang sama pada sistem lain (sistem kampus, situs mana pun, basis data teman) adalah tindak pidana. Payload hanya berupa pembacaan (SELECT)*

## Isi Folder
msbd-2026/<proyek>/
└── latihan/
    └── p11/
        ├── README.md
        ├── laporan.md
        ├── q00_setup.sql
        ├── q01_hak_pemilik.sql ... q29_hapus_dan_sisa.sql
        ├── q30_peta_uu_pdp.md
        └── rentan.py

## Prasyarat
* Docker dan Docker Compose (docker --version, docker compose version).
* Git dan akun Git masing-masing anggota.
* Python 3 (untuk rentan.py, dijalankan di kontainer lab11-web).
* Berkas docker-compose.yml/docker-compose.lab11.yml dan lab11_setup.sql dari modul praktikum.

## Menyalakan Dua Kontainer

mkdir -p ~/msbd-2026/lab11/sql ~/msbd-2026/lab11/app
cd ~/msbd-2026/lab11
# docker-compose.lab11.yml memakai jaringan internal: true (lihat modul)
docker compose -f docker-compose.lab11.yml up -d

* *pastikan jaringan benar-benar tertutup (harapan true):*

docker network inspect lab11_labnet --format '{{.Internal}}'

## Memuat Skema lab11

docker cp sql/lab11_setup.sql lab11-db:/sql/lab11_setup.sql
docker exec -i lab11-db psql -U postgres -d msbd -f /sql/lab11_setup.sql
docker exec -it lab11-db psql -U postgres -d msbd -c "SELECT version();"

* *Verifikasi (hrapan 3 | 30000 | 4 | 1200000, dan tiap penyewa 10000 pelanggan):*

SELECT (SELECT count(*) FROM lab11.tenant)    AS tenant,
       (SELECT count(*) FROM lab11.pelanggan) AS pelanggan,
       (SELECT count(*) FROM lab11.akun)      AS akun,
       (SELECT count(*) FROM lab11.transaksi) AS transaksi;
SELECT tenant_id, count(*) FROM lab11.pelanggan GROUP BY 1 ORDER BY 1;

* *Untuk mengulang dari awal, hapus kontainer dan volume lalu jalankan ulang langkah di atas (docker compose -f docker-compose.lab11.yml down -v).*

## Aturan Berkas Jawaban
Tiap qNN_nama_singkat.sql diawaali tiga komentar:

-- Diminta: <permintaan soal>
-- Dipilih: <keputusan dan alasan>
-- Alternatif: <alternatif yang tidak dipakai dan alasannya>

## Pembagian Tugas.
* *Karena pembagian per rentang nomor, sebelum mengerjakan rentangmu jalankan dulu semua berkas .sql sebelumnya secara berurutan (git pull, lalu q00 sampai nomor sebelum rentang masing-masing) di kontainer masing-masing, supaya keadaan basis datanya sama dengan yang diharapkan soal.*

Anggota              | Tanggung jawab
Fahri Arizal         | Q12-Q20, refleksi C, laporan.md
Fitya Shofi Ahmad    | Q00-Q11, refleksi A, refleksi B, laporan.md, README.md
Mar'ie Rizqullah     | Q21-Q30, refleksi D, refleksi E
* *Setiap anggota membuat commit dengan akun Git masing-masing.
