-- Diminta: melakukan hashing kata sandi dengan bcrypt (pgcrypto), membuktikan
--          dua hash untuk sandi identik berbeda, dan menjelaskan serangan yang dicegah.
-- Dipilih: crypt(kata_sandi, gen_salt('bf', 8)) menggunakan ekstensi pgcrypto.
-- Alternatif: enkripsi simetris atau MD5 tanpa salt; tidak dipilih karena sandi
--             tidak perlu didekripsi dan hash tanpa salt rentan rainbow table.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Buktikan dua hasil hashing untuk kata sandi yang sama menghasilkan nilai berbeda:
WITH uji_hash AS (
    SELECT crypt('SandiRahasia#2026', gen_salt('bf', 8)) AS h1,
           crypt('SandiRahasia#2026', gen_salt('bf', 8)) AS h2
)
SELECT h1,
       h2,
       (h1 = h2) AS string_hash_sama,
       (crypt('SandiRahasia#2026', h1) = h1) AS verifikasi_h1_valid,
       (crypt('SandiRahasia#2026', h2) = h2) AS verifikasi_h2_valid
FROM uji_hash;

-- Contoh hashing pada kolom kata sandi lab11.akun (diuji via transaksi/ROLLBACK
-- atau sesuaikan jika memang diminta memperbarui kolom hash di lab11.akun):
BEGIN;
UPDATE lab11.akun
SET sandi_hash = crypt(sandi_hash, gen_salt('bf', 8))
WHERE sandi_hash NOT LIKE '$2%';
SELECT id, username, left(sandi_hash, 20) || '...' AS contoh_hash FROM lab11.akun;
ROLLBACK;

-- Serangan yang dicegah:
-- 1. Serangan Rainbow Table / tabel hash pra-komputasi: gen_salt('bf', 8)
--    menyisipkan salt acak unik pada setiap hash sehingga tabel hash universal
--    yang sudah dihitung sebelumnya tidak berguna.
-- 2. Deteksi kata sandi kembar lintas akun: dua pengguna dengan kata sandi sama
--    memiliki nilai hash berbeda sehingga kebocoran satu akun tidak membongkar
--    akun lain yang memakai kata sandi identik.
