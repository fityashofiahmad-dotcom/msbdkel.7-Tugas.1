# Laporan Latihan Kelompok 7 Pertemuan 9

## Anggota dan Kontribusi
Nama                 |    NIM    | Kontribusi                                   | Commit 
---------------------+-----------+----------------------------------------------+-------------------
Andika Chairul Ilham | 251402047 | Langkah 3 (Q14 - Q17), Langkah 4 (Q18 - Q21) | Commit 
Fahri Arizal         | 251402102 | Langkah 2 (Q6 - Q11), Langkah 3 (Q12 - Q13)  | Commit 
Fitya Shofi Ahmad    | 251402132 | Langkah 1, Langkah 6                         | Commit 
Mar'ie Rizqullah     | 251402129 | Langkah 4 (Q22 - Q23), Langkah 5             | Commit 

## Konfigurasi relevan (hasil perintah SHOW)
Parameter                           | Nilai 
------------------------------------+-----------------
transaction_isolation               | read committed
deadlock_timeout                    | 1s
lock_timeout                        | 0
statement_timeout                   | 0
idle_in_transaction_session_timeout | 0

## Data Awal
1. Hasil dari SELECT * FROM lab9.rekening ORDER BY rekening_id;

rekening_id | pemilik | saldo 
------------+---------+------------
          1 | Ani     | 1000000.00     
          2 | Budi    | 1000000.00     

2. Total saldo awal: 2000000.00

## Jawaban Q1-Q32
1. Q1
-- Sesi A
SELECT * FROM lab9.rekening ORDER BY rekening_id;
SELECT SUM(saldo) AS total_saldo FROM lab9.rekening;

Hasil sebelum:
Tabel baru dibuat dan diisi oleh q00_setup.sql

Hasil sesudah:
rekening_id | pemilik | saldo
------------+---------+------------
          1 | Ani     | 1000000.00
          2 | Budi    | 1000000.00

total_saldo = 2000000.00

Status akhir: Tidak ada transaksi eksplisit
SQLSTATE (jika ada eror): -
Penjelasan penyebab:
Data awal terbukti dua rekening dengan saldo masing-masing 1.000.000, sehingga total saldo 2.000.000. Total ini dipakai sebagai patokan setiap transfer yang benar tidak boleh mengubah total sehingga bisa dipakai untuk memeriksa konsistensi di soal-soal berikutnya.

Bukti:
![Q1: hasil SELECT data awal](bukti/q01-SesiA-1.png)
![Q1: hasil SELECT total saldo](bukti/q01-SesiA-2.png)

2. Q2
-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;
SELECT * FROM lab9.rekening ORDER BY rekening_id;   -- belum COMMIT

-- Sesi B (saat sesi A belum COMMIT)
SELECT * FROM lab9.rekening ORDER BY rekening_id;

-- Sesi A
ROLLBACK;

Hasil sebelum:
Ani 1.000.000
Budi 1.000.000

Hasil sesudah:
Sesi                                   |     Ani    | Budi
---------------------------------------+------------+--------------
A (di dalam transaksi, sebelum COMMIT) | 900000.00  | 1100000.00
B (sesi lain)                          | 1000000.00 | 1000000.00

Status akhir: ROLLBACK (data kembali 1.000.000 / 1.000.000)
SQLSTATE (jika ada eror): -
Penjelasan penyebab:
Sesi A melihat perubahannya sendiri, sedangkan Sesi B tetap melihat saldo lama. PostgreSQL memakai MVCC dan hanya menampilkan data yang sudah di-COMMIT kepada sesi lain, sehingga perubahan yang belum di-COMMIT tidak bocor (tidak ada dirty read). Perubahan baru terligat oleh Sesi B jika Sesi A melakukan COMMIT.

Bukti:
![Q2: Hasil SELECT Sesi A tanpa COMMIT](bukti/q02-SesiA.png)
![Q2: Hasil SELECT Sesi B saat Sesi A belum COMMIT](bukti/q02-SesiB.png)

3. Q3
* **Percobaan 1: COMMIT*
-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;
COMMIT;

-- Sesi B
SELECT * FROM lab9.rekening ORDER BY rekening_id;

* **Percobaan 2: ROLLBACK*
--Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 200000 WHERE rekening_id = 1;
UPDATE lab9.rekening SET saldo = saldo + 200000 WHERE rekening_id = 2;
ROLLBACK;

--Sesi B
SELECT * FROM lab9.rekening ORDER BY rekening_id;

Hasil sebelum:
Ani 1.000.000
Budi 1.000.000

Hasil sesudah:
Percobaan                             |    Ani    |     Budi   | Total
--------------------------------------+-----------+------------+---------------
Setelah COMMIT (transfer 100000.00)   | 900000.00 | 1100000.00 | 2000000.00 
Setelah ROLLBACK (transfer 200000.00) | 900000.00 | 1100000.00 | 2000000.00

Status akhir: Percobaan 1 COMMIT, percobaan 2 ROLLBACK
SQLSTATE (jika ada eror): -
Penjelasan penyebab:
Perubahan yang bertahan hanya transfer 100000.00 yang di-COMMIT, dan langsung terlihat oleh Sesi B. Transfer 200000.00 yang di-ROLLBACK dibatalkan seluruhnya sehingga saldo tidak berubah dari hasil percobaan 1. COMMIT membuat perubahan permanen dan terlihat oleh sesi lain, sedangkan ROLLBACK membatalkan semua perubahan sejak BEGIN.

Bukti: 
![Q3: Percobaan 1 COMMIT Sesi A](bukti/q03-SesiA-COMMIT.png)
![Q3: Percobaan 1 COMMIT Sesi B](bukti/Q03-SesiB-COMMIT.png)
![Q3: Percobaan 2 ROLLBACK Sesi A](bukti/q03-SesiA-ROLLBACK.png)
![Q3: Percobaan 2 ROLLBACK Sesi B](bukti/q03-SesiB-ROLLBACK.png)

4. Q4
-- Sesi A
-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 100000 WHERE rekening_id = 1;   -- transfer 1
UPDATE lab9.rekening SET saldo = saldo + 100000 WHERE rekening_id = 2;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

SAVEPOINT sp1;

UPDATE lab9.rekening SET saldo = saldo - 200000 WHERE rekening_id = 1;   -- transfer 2
UPDATE lab9.rekening SET saldo = saldo + 200000 WHERE rekening_id = 2;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

ROLLBACK TO SAVEPOINT sp1;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

COMMIT;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

-- Sesi B
....

Hasil sebelum:
Ani 1000000.00
Budi 1000000.00

Hasil sesudah:
Tahap                         |    Ani    | Budi
------------------------------+-----------+--------------
Setelah transfer 1            | 900000.00 | 1100000.00
Setelah transfer 2            | 700000.00 | 1300000.00
Setelah ROLLBACK TO SAVEPOINT | 900000.00 | 1100000.00
Setelah COMMIT                | 900000.00 | 1100000.00

Status akhir: ROLLBACK TO SAVEPOINT lalu COMMIT
SQLSTATE (jika ada eror): -
Penjelasan penyebab:
Yang dibatalkan hanya perubahan setelah SAVEPOINT sp1, yaitu transfer kedua (200000.00). Transfer pertama tetap ada dan ikut tersimpan saat COMMIT. ROLLBACK TO SAVEPOINT tidak mengakhiri transaksi, jadi transakssi tetap terbuka sampai COMMIT atau ROLLBACK. SAVEPOINT berguna untuk membatalkan sebagian langkah tanpa mengulang seluruh transaksi.

Bukti:
![Q4: Hasil transfer 1](bukti/q04-setelahTransfer1.png)
![Q4: hasil transfer 2](bukti/q04-setelahTransfer2.png)
![Q4: Hasil ROLLBACK TO SAVEPOINT sp1](bukti/q04-setelahROLLBACK-TO-SAVEPOINT.png)
![Q4: Hasil COMMIT](bukti/q04-setelahCOMMIT.png)

5. Q5
-- Sesi A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo + 500000 WHERE rekening_id = 2;    -- berhasil
UPDATE lab9.rekening SET saldo = saldo - 5000000 WHERE rekening_id = 1;   -- melanggar CHECK
SELECT * FROM lab9.rekening;                                              -- ditolak (transaksi aborted)
ROLLBACK;
SELECT * FROM lab9.rekening ORDER BY rekening_id;

-- Sesi B
....

Hasil sebelum:
Ani 1000000.00
Budi 1000000.00

Hasil sesudah:
Langkah 2: Error occurred during SQL query execution
SQL Error [23514]: ERROR: new row for relation "rekening" violates check constraint "rekening_saldo_check"
  Detail: Failing row contains (1, Ani, -4000000.00).

Langkah 3: Error occurred during SQL query execution
SQL Error [25P02]: ERROR: current transaction is aborted, commands ignored until end of transaction block

Setelah ROLLBACK: Ani 1000000.00, Budi 1000000.00 (Total 2000000.00)

Status akhir: ROLLBACK 
SQLSTATE (jika ada eror): 23514(pelanggaran CHECK), 25P02(transaksi aborted)
Penjelasan penyebab:
* **Atomicity:* Penambahan saldo Budi sudah berhasil, tapi karena langkah berikutnya gagal ROLLBACK membatalkan keduanya. Transaksi berlaku semua atau tidak sama sekali.

* **Consistency:* CHECK (saldo >= 0) menolak data tidak valid (SQLSTATE 23514) sehingga database hanya berpindah dari satu keadaan vslid ke keadaan valid lain.

* Setelah error, transaksi berstatus aborted (25P02) dan hanya bisa diakhiri dengan ROLLBACK.

Bukti:
![Q5: Pesan error padan langkah 2](bukti/q05-eror1.png)
![Q5: Pesan error pada langkah 3](bukti/q05-eror2.png)
![Q5: Hasil akhir setelah ROLLBACK](bukti/q05-hasilAkhir.png)

6. Q6
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

7. Q7
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

8. Q8
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

9. Q9
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

10. Q10
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

11. Q11
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

12. Q12
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

13. Q13
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

14. Q14
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

15. Q15
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

16. Q16
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

17. Q17
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

18. Q18
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

19. Q19
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

20. Q20
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

21. Q21
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

22. Q22
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

23. Q23
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

24. Q24
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

25. Q25
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

26. Q26
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

27. Q27
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

28. Q28
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

29. Q29
-- Sesi A
....
-- Sesi B
....

Hasil sebelum:
....

Hasil sesudah:
....

Status akhir: COMMIT/ROLLBACK (pilih salah satu)
SQLSTATE (jika ada eror): ...
Penjelasan penyebab:
....

Bukti: (screenshot .bukti/...)

## Tabel Ringkasan Anomali (Q11 dan Q30)
Anomali | Cara reproduksi | Isolation Level | Hasil yang diamati | Penyebab | Dampak | Mitigasi 
--------+-----------------+-----------------+--------------------+----------+--------+-------------
Dirty read                | A mengubah saldo tanpa COMMIT,B Menjalankan SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED lalu SELECT | READ UNCOMMITTED | Tidak terjadi. B melihat saldo lama. | PostgreSQL memperlakukan READ UNCOMMITTED sama dengan READ COMMITTED. MVCC hanya menampilkan versi baris yang sudah di-COMMIT | Tidak ada karena sudah dicegah | Tidak perlu tindakan khusus 
Non-repeatable read       | A: BEGIN, SELECT saldo. B: UPDATE + COMMIT. A: SELECT lagi | READ COMMITTED (terjadi), REPEATABLE READ (tidak terjadi) | Pada READ COMMITTED, SELECT kedua A menampilkan nilai baru. Pada REPEATABLE READ nilainya tetap  | Pada READ COMMITTED setiap pernyataan memakai snapshot baru | Hasil dalam satu transaksi bisa berubah sehingga perhitungan tidak konsisten | Pakai REPEATABLE READ atau lebih tinggi 
Phantom read              | A menghitung baris dengan saldo di atas nilai tertentu. B INSERT baris yang cocok + COMMIT. A menghitung lagi. | READ COMMITTED (terjadi), REPEATABLE READ (tidak terjadi di PostgreSQL) | Jumlah baris bertambah pada READ COMMITTED tapi tetap pada REPEATABLE READ. | Snapshot baru per pernyataan pada READ COMMITTED. | Laporan hitung atau agregat di tengah transaksi tidak stabil. | Pakai REPEATABLE READ atau SERIALIZABLE 
Lost update               | A dan B membaca saldo yang sama, menghitung di aplikasi, lalu menulis nilai tetap. | READ COMMITTED (terjadi) | Tulisan kedua menimpa hasil sesi pertama. Pada REPEATABLE READ sesi kedua mendapat eror 40001 | Nilai baru dihitung dari data lama yang dibaca, bukan dari nilai baru di database | Perubahan satu sesi hilang, saldo salah | SET saldo = saldo - x, SELECT .... FOR UPDATE, atau kolom version_no 
Write skew                | Dua transaksi membaca jumlah dokter aktif lalu menonaktifkan dokter berbeda. | REPEATABLE READ (terjadi), SERIALIZABLE (dicegah) | Pada REPEATABLE READ keduanya COMMIT dan aturan "minimal 1 dokter aktif" dilanggar. Pada SERIALIZABLE salah satu dibatalkan (SQLSTATE 40001) | Kedua transaksi membaca snapshot yang sama tapi menulis baris berbeda, sehingga tidak ada konflik tulis. | Aturan bisnis lintas baris dilanggar | SERIALIZABLE + retry, atau FOR UPDATE pada baris terkait. 
Pembacaan tidak konsisten | A membaca saldo Ani (1000000.00), B transfer Ani ->  Budi 100000 + COMMIT, A membaca saldo Budi (1100000.00). | READ COMMITTED (terjadi), REPEATABLE READ (tidak terjadi) | A melihat total 2100000.00, padahal seharusnya 2000000.00 | Dua SELECT memakai snapshot yang berbeda | Laporan/penjumalahan menghasilkan angka yang tidak pernah benar-benar ada | REPEATABLE READ, atau hitung dalam satu pernyataan. 

## Rekomendaasi Isolation Level (Q31)
Kebutuhan | Isolation Level | Alasan dan Kompromi
----------+-----------------+----------------------------
Pembacaan sederhana yang menerima perubahan antarpernyataan | READ COMMITTED (default) | Paling ringan dan jarang menimbulkan error serialisasi. Risikonya non-repeatable read dan phantom, yang tidak masalah untuk satu query berdiri sendiri 
Laporan yang membutuhkan snapshot konsisten | REPEATABLE READ (idealnya READ ONLY) | Semua query dalam transaksi melihat snapshot yang sama sehingga total laporan konsisten. Komprominya jika transaksi menulis dan ada update konkuren pada baris yang sama, dapat terjadi error 40001
Transaksi dengan aturan bisnis lintas beberapa baris | SERIALIZABLE (atau REPEATABLE READ + FOR UPDATE) | Mencegah write skew. Komprominya dengan transaksi dapat dibatalkan dengan SQLSTATE 40001 dan ada overhead pelacakan (SIReadLock)

* **Risiko serialization failure dan cara menanganinya:*
Pada isolation level tinggi, PostgreSQL dapat membatalkan transaksi yang berisiko menimbulkan hasil yang tidak setara dengan eksekusi berurutan (SQLSTATE 40001). Ini bukan bug melainkan cara menjaga kebenaran data. Penanganannya dengan aplikasi harus mengulang seluruh transaksi dari BEGIN, membatasi jumlah percobaan, memakai jeda yang bertambah dengan jitter, dan menjalankan operasi eksternal hanya setelah COMMIT berhasil.

## Kesimpulan berbasis Hasil Eksperimen (Q32)
1. Pelajaran 1: MVCC membuat sesi lain tidak melihat perubahan yang belum di-COMMIT sehingga tiak aada dirty read di PostgreSQL.
--Bukti: Pada Q2, Sesi B tetap melihat Ani 1000000.00 dan Budi 1000000.00 saat Sesi A sudah mengubahnya menjadi 900000.00/1100000.00 tetapi belum COMMIT. pADA q9, READ UNCOMMITTED juga tidak menampilkan perubahan yang belum di-COMMIT.

2. Pelajaran 2: Menghitung nilai di sisi aplikasi menyebabkan lost update, sedangkan pembaruan automik dan penguncian baris mencegaahnya.
--Bukti: pada Q10, hasil satu sesi tertimpa karena kedua sesi menulis nilai tetap dari data lama. Pada Q12 (saldo = saldo - 10000) dan Q13 (FOR UPDATE, sesi kedua menunggu sampai sesi pertama selesai), saldo akhir benar.

3. Pelajaran 3: Deadlock dan serialization failure adalah error yang wajar, sehingga aplikasi harus siap mengulang transaksi.
--Bukti: Q20 menghasilkan error deadlock SQLSTATE 40P01 pada salah satu sesi, dan Q21 menunjukkan urutan penguncian yang konsisten menghindarinya. Q26 menunjukkan write skew lolos di REPEATABLE READ, sedangkan Q27 menghasilkan SQLSTATE 40001 pada SERIALIZABLE.