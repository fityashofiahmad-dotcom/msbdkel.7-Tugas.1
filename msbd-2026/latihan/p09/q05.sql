-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo + 500000 WHERE rekening_id = 2;    -- berhasil
UPDATE lab9.rekening SET saldo = saldo - 5000000 WHERE rekening_id = 1;   -- melanggar CHECK
SELECT * FROM lab9.rekening;                                              -- ditolak (transaksi aborted)
ROLLBACK;
SELECT * FROM lab9.rekening ORDER BY rekening_id;