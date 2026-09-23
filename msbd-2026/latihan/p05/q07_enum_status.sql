Diminta: Mengubah status menjadi EXPIRED, mencatat galat, menambahkan nilai enum, dan mengulangi percobaan.

-- Dipilih: ALTER TYPE ... ADD VALUE untuk menambahkan opsi baru pada ENUM.

Alternatif: Menghapus tipe dan membuat ulang; tidak dipilih karena berisiko tinggi dan memakan biaya perawatan besar pada data produksi.

-- 1. Jalankan ini dulu, ia akan ditolak basis data. Salin pesan galatnya ke laporan.

-- UPDATE lab5.rental_tx SET status = 'EXPIRED' WHERE rental_id = 1;

-- 2. Tambahkan nilai enum (wajib di-commit terlebih dahulu sebelum dipakai jika dalam transaksi)

ALTER TYPE lab5.rental_status ADD VALUE 'EXPIRED'; COMMIT;

-- 3. Ulangi query, kali ini akan berhasil.

UPDATE lab5.rental_tx SET status =

'EXPIRED' WHERE rental_id = 1;
