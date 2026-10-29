# Log Rekam Eksekusi Dua Sesi (Q26 - Q29): Write Skew, SERIALIZABLE, dan Retry
Tabel lab9.dokter_jaga: dr. Andi (aktif), dr. Budi (aktif). Aturan bisnis: minimal 1 dokter harus aktif.

## Q26: Write Skew (REPEATABLE READ)
- T1 (Sesi A): `BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ; SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE;` -> `2`
- T2 (Sesi B): `BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ; SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE;` -> `2`
- T3 (Sesi A): `UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 1; COMMIT;` -> berhasil
- T4 (Sesi B): `UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 2; COMMIT;` -> berhasil
- T5 (Sesi A): `SELECT * FROM lab9.dokter_jaga;` -> kedua dokter `aktif = FALSE`
*Hasil*: Write Skew terjadi (0 dokter aktif). Kedua transaksi menulis baris berbeda sehingga tidak ada konflik tulis. SQLSTATE -.

## Q27: SERIALIZABLE Mencegah Write Skew
- T0: data dipulihkan ke 2 dokter aktif.
- T1 (Sesi A): `BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE; SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE;` -> `2`
- T2 (Sesi B): `BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE; SELECT COUNT(*) FROM lab9.dokter_jaga WHERE aktif = TRUE;` -> `2`
- T3 (Sesi A): `UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 1; COMMIT;` -> berhasil
- T4 (Sesi B): `UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 2;` (atau saat `COMMIT`) -> error:

SQL Error [40001]: ERROR: could not serialize access due to read/write dependencies among transactions
  <ISI: salin Detail dan Hint dari output asli>

- T5 (Sesi B): `ROLLBACK;`
*Hasil*: SQLSTATE `40001` (serialization_failure). SSI mendeteksi potensi write skew dan membatalkan Sesi B.

## Q28: SIReadLock Tidak Memblokir
- T1 (Sesi A): `BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE; SELECT * FROM lab9.dokter_jaga WHERE aktif = TRUE;`
- T2 (Sesi B): `BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE; SELECT * FROM lab9.dokter_jaga WHERE aktif = TRUE; UPDATE lab9.dokter_jaga SET aktif = FALSE WHERE id = 2; COMMIT;` -> berhasil tanpa menunggu
- T3 (Sesi A): `ROLLBACK;` 
*Hasil*: SELECT di SERIALIZABLE hanya mencatat SIReadLock (penanda dependensi in-memory), bukan lock pemblokir seperti `FOR UPDATE`. SQLSTATE -.

## Q29: Strategi Retry Transaksi
- Pseudocode: `BEGIN SERIALIZABLE` -> jalankan transaksi -> `COMMIT` -> baru kirim efek samping eksternal (email/API).
- Jika error SQLSTATE `40001` atau `40P01: ROLLBACK`, tunggu dengan exponential backoff + jitter `(100ms * 2^(percobaan-1) + random(0..50ms))`, ulangi dari `BEGIN`, maksimum 5 percobaan. Selain itu, lempar error. Hasil: Error 40001/40P01 adalah error sementara yang normal. Operasi eksternal wajib setelah COMMIT agar tidak terkirim ganda saat retry.