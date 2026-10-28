# Log Rekam Eksekusi Dua Sesi (Q06 - Q13)

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
