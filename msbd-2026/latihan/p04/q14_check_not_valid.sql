-- Diminta: Menambahkan CHECK constraint dua tahap (NOT VALID lalu VALIDATE) dan menguji penyisipan data negatif.
-- Dipilih: ALTER TABLE ... ADD CONSTRAINT ... CHECK (...) NOT VALID dilanjutkan VALIDATE CONSTRAINT.
-- Alternatif: ADD CONSTRAINT langsung tanpa NOT VALID; tidak dipilih karena memblokir tabel besar saat memindai seluruh data lama.

-- Tambahkan constraint dengan NOT VALID (berhasil tanpa memvalidasi data lama)
ALTER TABLE lab4.film ADD CONSTRAINT chk_rental_rate_positif CHECK (rental_rate >= 0) NOT VALID;

-- Coba VALIDATE CONSTRAINT (akan gagal jika ada data kotor)
-- ALTER TABLE lab4.film VALIDATE CONSTRAINT chk_rental_rate_positif;

-- Perbaiki data kotor jika ada
UPDATE lab4.film SET rental_rate = 0.99 WHERE rental_rate < 0;

-- Jalankan ulang VALIDATE CONSTRAINT (berhasil)
ALTER TABLE lab4.film VALIDATE CONSTRAINT chk_rental_rate_positif;
