-- Q17: Dead tuple dan VACUUM
-- Sesi A (auto-commit; VACUUM tidak boleh di dalam transaksi)
SELECT relname, n_live_tup, n_dead_tup
FROM pg_stat_user_tables WHERE schemaname = 'lab9' AND relname = 'rekening';
-- Jalankan 10 kali:
UPDATE lab9.rekening SET saldo = saldo WHERE rekening_id = 1;
-- Tunggu beberapa detik (statistik diperbarui asinkron)
SELECT relname, n_live_tup, n_dead_tup
FROM pg_stat_user_tables WHERE schemaname = 'lab9' AND relname = 'rekening';
VACUUM (VERBOSE) lab9.rekening;
SELECT relname, n_live_tup, n_dead_tup
FROM pg_stat_user_tables WHERE schemaname = 'lab9' AND relname = 'rekening';
