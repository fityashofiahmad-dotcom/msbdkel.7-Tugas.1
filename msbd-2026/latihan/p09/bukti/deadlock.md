# Log Rekam Eksekusi Dua Sesi (Q18 - Q25): Locking dan Deadlock
*Konfigurasi:* deadlock_timeout = 1s, lock_timeout = 0, statement_timeout = 0, idle_in_transaction_session_timeout = 0.

## Q18: Mode Row Lock
- T1 (Sesi A): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR NO KEY UPDATE;`
- T2 (Sesi B): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR KEY SHARE;` -> langsung berhasil
- T3 (Sesi B): `SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR SHARE;` -> menunggu sekitar `<ISI>` detik
- T4 (Sesi A): `ROLLBACK;` -> Sesi B berhasil mendapat lock
- T5 (Sesi B): `ROLLBACK;`
*Hasil*: `FOR KEY SHARE` tidak konflik dengan `FOR NO KEY UPDATE`, sedangkan `FOR SHARE` konflik.

## Q19: FOR UPDATE Menunggu
- T1 (Sesi A): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;` -> `Ani 1000000.00`
- T2 (Sesi B): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;` -> menunggu sekitar `<ISI>` detik
- T3 (Sesi A): `COMMIT;`
- T4 (Sesi B): langsung mendapat baris rekening 1, lalu `COMMIT;`
*Hasil*: Sesi B antre tanpa error (SQLSTATE -) sampai Sesi A melepas lock.

## Q20: Deadlock
- T1 (Sesi A): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;`
- T2 (Sesi B): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;`
- T3 (Sesi A): `SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;` -> menunggu B
- T4 (Sesi B): `SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;` -> menunggu A (siklus tunggu)
- T5: setelah sekitar `<ISI>` detik, Sesi `<A/B> `menjadi korban:
SQL Error [40P01]: ERROR: deadlock detected
  Detail: Process <pid1> waits for ShareLock on transaction <xid>; blocked by process <pid2>.
  Process <pid2> waits for ShareLock on transaction <xid>; blocked by process <pid1>.
- T6 (korban): `ROLLBACK;`. Sesi lain mendapat lock lalu `COMMIT;`
*Hasil*: SQLSTATE `40P01` (deadlock_detected). Aplikasi harus mengulang transaksi korban.

## Q21: Menghindari Deadlock dengan Urutan Lock Konsisten
- T1 (Sesi A): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;` -> berhasil
- T2 (Sesi B): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;` -> menunggu
- T3 (Sesi A): `SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE; COMMIT;` -> berhasil
- T4 (Sesi B): mendapat rekening 1, lalu `SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE; COMMIT;` -> berhasil 
*Hasil*: Tidak ada error dan tidak ada deadlock (SQLSTATE -), karena semua sesi mengunci dari ID terkecil ke terbesar.

## Q22: Lock Wait Panjang (Bukan Deadlock)
- T1 (Sesi A): `BEGIN; UPDATE lab9.rekening SET saldo = saldo - 50000 WHERE rekening_id = 1;` (dibiarkan idle in transaction)
- T2 (Sesi B): `BEGIN; UPDATE lab9.rekening SET saldo = saldo + 50000 WHERE rekening_id = 1;` -> menunggu (blocking)
- T3 (Sesi A): `COMMIT;`
- T4 (Sesi B): UPDATE selesai, lalu `COMMIT;` 
*Hasil*: Ketergantungan satu arah (A memblokir B) dan selesai otomatis saat A COMMIT. Beda dengan deadlock yang melingkar (SQLSTATE `40P01`).

## Q23: Parameter Timeout
- T1 (Sesi A): `BEGIN;`
- T2 (Sesi A): `SET LOCAL lock_timeout = '3s'; SET LOCAL statement_timeout = '5s'; SET LOCAL idle_in_transaction_session_timeout = '10s';`
- T3 (Sesi A): `SHOW lock_timeout;` -> `3s` | `SHOW statement_timeout;` -> `5s` | `SHOW idle_in_transaction_session_timeout;` -> `10s` | `SHOW deadlock_timeout;` -> `1s`
- T4 (Sesi A): `COMMIT;`
*Hasil*: Nilai hanya berlaku lokal dalam transaksi, lalu kembali ke default (0) setelah COMMIT. `lock_timeout` yang terlampaui menghasilkan SQLSTATE `55P03`.

## Q24: SKIP LOCKED (Antrean Pekerjaan)
- T0: setup `lab9.antrean_pekerjaan` berisi 3 baris `PENDING` (id 1, 2, 3).
- T1 (Sesi A / Worker 1): `BEGIN; SELECT * FROM lab9.antrean_pekerjaan WHERE status = 'PENDING' ORDER BY id LIMIT 1 FOR UPDATE;` -> id `1 (Kirim Email Welcome)`
- T2 (Sesi B / Worker 2): `BEGIN; SELECT * FROM lab9.antrean_pekerjaan WHERE status = 'PENDING' ORDER BY id LIMIT 1 FOR UPDATE SKIP LOCKED;` -> id `2 (Generate Report PDF)`, tanpa menunggu
- T3 (Sesi A dan B): `COMMIT;`
*Hasil*: `SKIP LOCKED` melewati baris yang terkunci sehingga banyak worker bisa mengambil pekerjaan paralel tanpa blocking. SQLSTATE -.

## Q25: NOWAIT
- T1 (Sesi A): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;` -> berhasil
- T2 (Sesi B): `BEGIN; SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE NOWAIT;` -> gagal seketika
- T3 (Sesi A dan B): `ROLLBACK;`
*Hasil*: SQLSTATE `55P03` (lock_not_available). `NOWAIT` memilih gagal cepat (fail-fast) daripada mengantre.