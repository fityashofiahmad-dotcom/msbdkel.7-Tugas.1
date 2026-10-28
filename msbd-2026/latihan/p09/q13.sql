-- Q13: Mencegah Lost Update dengan SELECT ... FOR UPDATE
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id = 1;

-- Sesi A mengunci baris:
BEGIN;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;

-- [Sesi B mencoba SELECT FOR UPDATE pada baris 1 -> Tertahan / Waiting]

-- Sesi A memutakhirkan saldo & commit:
UPDATE lab9.rekening SET saldo = saldo - 75000 WHERE rekening_id = 1;
COMMIT;

-- Sesi B terlepas dari antrean, membaca nilai baru (925000), lalu mengutak-atik & commit.
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1; -- Hasil akhir: 850000.00
