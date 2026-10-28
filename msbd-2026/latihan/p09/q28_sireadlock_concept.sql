/*
1. FUNGSI SIReadLock:
   SIReadLock (Snapshot Isolation Read Lock) adalah lock in-memory (virtual) yang 
   digunakan PostgreSQL untuk mencatat read dependency. Kunci ini TIDAK MEMBLOKIR 
   transaksi lain yang ingin melakukan pembacaan atau penulisan data.

2. MEKANISME KERJA:
   Saat transaksi SERIALIZABLE membaca baris/tabel, PostgreSQL menempatkan SIReadLock. 
   Mesin mengamati grafik ketergantungan (rw-antidependencies). Jika terjadi siklus 
   ketergantungan yang memicu instruksi tak terurut (non-serializable execution), 
   PostgreSQL menghentikan salah satu transaksi dengan SQLSTATE 40001.

3. PERBEDAAN DENGAN SELECT ... FOR UPDATE:
   - SELECT ... FOR UPDATE : Menggunakan heavyweight lock yang memblokir (block) sesi lain.
   - SIReadLock             : Hanya berupa penanda deklaratif (non-blocking) untuk melacak 
                             konflik pembacaan/penulisan secara efisien.
*/
