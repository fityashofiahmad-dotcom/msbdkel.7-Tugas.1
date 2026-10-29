# Log Rekam Eksekusi Dua Sesi (Q06 - Q13)
*Konfigurasi:* transaction_isolation = read committed. Data awal: Ani 1000000.00, Budi 1000000.00 (total 2000000.00).

## Q01: Data Awal
- T1 (Sesi A): `SELECT * FROM lab9.rekening ORDER BY rekening_id;` -> `Ani 1000000.00, Budi 1000000.00`
- T2 (Sesi A): `SELECT SUM(saldo) AS total_saldo FROM lab9.rekening;`
*Hasil*: Total saldo `2000000.00` menjadi patokan konsistensi untuk soal berikutnya. Tidak ada transaksi eksplisit.

## Q02: Dirty Read pada Transaksi belum COMMIT
- T1 (Sesi a): `BEGIN;`
- T2 (Sesi A): `UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;`
- T3 (Sesi A): `UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;`
- T4 (Sesi A): `SELECT * FROM lab9.rekening ORDER BY rekening_id;` -> `Ani 900000.00, Budi 1100000.00`
- T5 (Sesi B): `SELECT * FROM lab9.rekening ORDER BY rekening_id;` -> `Ani 1000000.00, Budi 1000000.00`
- T6 (Sesi A): `ROLLBACK` -> data kembali `1000000.00/1000000.00`
*Hasil*: Sesi B tidak melihat perubahan yang belum di-COMMIT (tidak ada dirty read, berkat MVCC).

## Q03: COMMIT vs ROLLBACK
*Percobaan 1 (COMMIT)*
- T1 (Sesi A): `BEGIN; UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1; UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2; COMMIT;`
- t2 (sESI b): `SELECT * FROM lab9.rekening ORDER BY rekening_id;` -> `Ani 900000.00, Budi 1100000.00, total 2000000.00`
*Percobaan 2 (ROLLBACK)*
- T3 (Sesi A): `BEGIN; UPDATE lab9.rekening SET saldo = saldo - 200000 WHERE rekening_id = 1; UPDATE lab9.rekening SET saldo = saldo + 200000 WHERE rekening_id = 2; ROLLBACK;`
- T4 (Sesi B): `SELECT * FROM lab9.rekening ORDER BY rekening_id;` -> `Ani 900000.00, Budi 1100000.00, total 2000000.00`
*Hasil*: Transfer 100000 yang di-COMMIT bertahan dan langsung terlihat Sesi B. Transfer 2000000 yang di-ROLLBACK dibatalkan seluruhnya.

## Q04: SAVEPOINT
- T1 (Sesi A): `Begin;`
- T2 (Sesi A): transfer 100000 (Ani->Budi), lalu `SELECT` -> `Ani 900000.00, Budi 1100000.00`
- T3 (Sesi A): `SAVEPOINT sp1;`
- T4 (Sesi A): transfer 200000 (Ani->Budi), lalu `SELECT` -> `Ani 700000.00, Budi 1300000.00`
- T5 (Sesi A): `ROLLBACK TO SAVEPOINT sp1;` lalu `SELECT` -> `Ani 900000.00, Budi 1100000.00`
- T6 (Sesi A): `COMMIT;` lalu `SELECT` -> `Ani 900000.00, Budi 1100000.00`
*Hasil*: Hanya transfer kedua yang dibatalkan. Transfer pertama tetap tersimpan. Transaksi tetap terbuka setelah `ROLLBACK TO SAVEPOINT` sampai `COMMIT`

## Q05: Atomicity dan Consistency (CHECK)
- T1 (Sesi A): `BEGIN;`
- T2 (Sesi A): `UPDATE lab9.rekening SET saldo = saldo + 500000 WHERE rekening_id = 2;` -> berhasil
- T3 (Sesi A): `UPDATE lab9.rekening SET ssaldo = saldo - 5000000 WHERE rekening_id = 1;` -> `SQL Error [23514]: ERROR: new row for relation "rekening" violates check constraint "rekening_saldo_check" Detail: Failing row contains (1, Ani, -4000000.00).`
- T4 (Sesi A): `SELECT * FROM lab9.rekening;` -> `SQL Error [25P02]: ERROR: current transaction is aborted, commands ignored until end of transaction block`
- T5 (Sesi A): `ROLLBACK` lalu `SELECT` -> `Ani 1000000.00, Budi 1000000.00`(total `2000000.00`)
*Hasil*: SQLSTATE `23514` (pelanggaran CHECK), `25P02` (transaksi aborted). Penambahan saldo Budi ikut dibatalkan (atomicity).

## Q06: Non-repeatable Read (READ COMMITTED)
- T1 (Sesi A): `BEGIN;`
- T2 (Sesi A): `SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;` -> `1000000.00`
- T3 (Sesi B): `BEGIN; UPDATE lab9.rekening SET saldo = 950000 WHERE rekening_id = 1; COMMIT;`
- T4 (Sesi A): `SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;` -> `950000.00`
- T5 (Sesi A): `COMMIT;`
*Hasil*: Terjadi Non-repeatable Read karena query kedua membaca data yang di-commit Sesi B.

## Q07: Perbandingan dengan REPEATABLE READ
- T1 (Sesi A): `BEGIN ISOLATION LEVEL REPEATABLE READ;`
- T2 (Sesi A): `SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;` -> `1000000.00`
- T3 (Sesi B): `BEGIN; UPDATE lab9.rekening SET saldo = 900000 WHERE rekening_id = 1; COMMIT;`
- T4 (Sesi A): `SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;` -> `1000000.00`
- T5 (Sesi A): `COMMIT;`
*Hasil*: Non-repeatable read dicegah. Sesi A mempertahankan snapshot transaksi awal.

## Q08: Phantom Read
- **READ COMMITTED**: `COUNT(*)` berubah dari `2` menjadi `3` setelah Sesi B melakukan `INSERT` dan `COMMIT`.
- **REPEATABLE READ**: `COUNT(*)` tetap `2` pada Sesi A (Phantom Read dicegah secara native oleh MVCC PostgreSQL).

## Q09: Dirty Read
- T1 (Sesi A): `BEGIN; UPDATE lab9.rekening SET saldo = 500000 WHERE rekening_id = 1;` (Belum COMMIT)
- T2 (Sesi B): `BEGIN ISOLATION LEVEL READ UNCOMMITTED; SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;` -> `1000000.00`
*Hasil*: Dirty Read tidak terjadi. PostgreSQL memperlakukan READ UNCOMMITTED sebagai READ COMMITTED.

## Q10 - Q13: Lost Update & Solusi
- **Q10**: Lost Update terjadi. Penarikan Sesi A tertimpa oleh Sesi B karena penulisan nilai statis terhitung dari aplikasi. Saldo akhir `925000.00` (salah).
- **Q12**: Pembaruan atomik `saldo = saldo - 75000` berhasil menjaga konsistensi saldo akhir `850000.00`.
- **Q13**: `SELECT ... FOR UPDATE` memaksa Sesi B menunggu hingga Sesi A `COMMIT`, menghasilkan saldo akhir `850000.00`.


