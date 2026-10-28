-- [Sesi A]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;

-- [Sesi B]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE NOWAIT;

-- HASIL EVALUASI SESI B:
-- Status     : Transaksi Gagal Seketika (Fail Fast)
-- SQLSTATE   : 55P03
-- Pesan Error: ERROR: could not obtain lock on row in relation "rekening"

-- [Sesi A & B]
ROLLBACK;
