-- Q21: Enkripsi Kolom dengan pgp_sym_encrypt & Kunci Per Session
SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';

ALTER TABLE lab11.pelanggan ADD COLUMN rekening_enc bytea;

UPDATE lab11.pelanggan
  SET rekening_enc = pgp_sym_encrypt(rekening, current_setting('app.kunci_kolom'))
WHERE id <= 1000;

-- Verifikasi dekripsi satu baris
SELECT id,
       rekening,
       pgp_sym_decrypt(rekening_enc, current_setting('app.kunci_kolom')) AS rekening_dekrip
FROM lab11.pelanggan
WHERE id = 1;

-- Buktikan dua enkripsi dari nilai dan kunci yang sama menghasilkan ciphertext berbeda
SELECT pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') AS sama;
