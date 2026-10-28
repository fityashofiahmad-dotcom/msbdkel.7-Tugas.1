-- 1. lock_timeout
-- Mengatur durasi maksimum suatu pernyataan/transaksi menunggu untuk mendapatkan lock.
-- Jika terlampaui: dibatalkan dengan SQLSTATE 55P03 (lock_not_available).
SET LOCAL lock_timeout = '5s';

-- 2. statement_timeout
-- Mengatur batas waktu maksimum eksekusi untuk satu perintah SQL tunggal.
-- Mencegah long-running query menghabiskan sumber daya server.
SET LOCAL statement_timeout = '10s';

-- 3. idle_in_transaction_session_timeout
-- Mengatur batas waktu maksimum sesi dibiarkan menganggur dalam kondisi transaksi terbuka (BEGIN).
-- Memutus koneksi gantung sehingga lock yang dipegang otomatis dilepaskan.
SET LOCAL idle_in_transaction_session_timeout = '1min';

-- 4. deadlock_timeout
-- Mengatur durasi tunggu sebelum PostgreSQL mengaktifkan pemeriksaan siklus deadlock.
-- Mengatur responsivitas pendeteksian deadlock vs overhead CPU.
SET LOCAL deadlock_timeout = '1s';

-- Memeriksa nilai parameter saat ini:
SHOW lock_timeout;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;
SHOW deadlock_timeout;
