-- 1. KONSEP DAN DEFINISI:
-- - Antrean Lock Panjang (Lock Wait/Blocking):
--   Keterlambatan temporal di mana Sesi B terhalang (blocked) menunggu Sesi A melepaskan
--   kunci (lock) pada suatu sumber daya. Sesi B akan memproses query-nya secara otomatis
--   begitu Sesi A menjalankan COMMIT atau ROLLBACK.
--
-- - Deadlock:
--   Kondisi circular dependency (saling tunggu yang melingkar). Sesi A menunggu kunci
--   yang dipegang Sesi B, sementara Sesi B menunggu kunci yang dipegang Sesi A.
--   PostgreSQL akan membatalkan salah satu transaksi dengan SQLSTATE 40P01.

-- 2. REPRODUKSI SKENARIO ANTREAN LOCK PANJANG:

-- [Sesi A]
BEGIN;
UPDATE lab9.rekening SET saldo = saldo + 50000 WHERE rekening_id = 1;
-- Transaksi dibiarkan menggantung (idle in transaction)...

-- [Sesi B]
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 20000 WHERE rekening_id = 1;
-- KETERANGAN: Sesi B mengalami blocking (lock wait) menunggu Sesi A selesai.

-- [Sesi A]
COMMIT; -- Sesi B baru akan mengeksekusi UPDATE-nya tepat setelah COMMIT ini.

-- [Sesi B]
COMMIT;
