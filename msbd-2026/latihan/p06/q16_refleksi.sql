===============================================================================
JAWABAN REFLEKTIF Q16:
===============================================================================
PostgreSQL tidak menyimpan informasi visibilitas transaksi (MVCC like xmin/xmax)
di dalam struktur B-Tree Index. 

1. Sebelum VACUUM:
   PostgreSQL belum memperbarui Visibility Map (VM) untuk halaman-halaman baru.
   Meskipun query menemukan semua kolom di dalam Covering Index (INCLUDE),
   DBMS terpaksa melakukan 'Heap Fetches' (membaca halaman tabel utama/heap)
   untuk memverifikasi apakah baris tersebut aktif dan terlihat oleh transaksi saat ini.

2. Sesudah VACUUM (ANALYZE):
   Proses VACUUM memeriksa halaman heap dan menandai halaman yang sudah 'all-visible'
   di dalam Visibility Map. Saat query dijalankan kembali, Index-Only Scan memeriksa
   Visibility Map terlebih dahulu. Karena halaman bertanda 'all-visible', DBMS dapat
   langsung mengembalikan data dari index tanpa perlu mengunjungi Heap sama sekali
   (Heap Fetches menjadi 0).
===============================================================================
