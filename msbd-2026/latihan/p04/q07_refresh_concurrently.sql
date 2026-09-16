-- Diminta: Menguji REFRESH CONCURRENTLY pada materialized view tanpa dan dengan index unik, serta mengukur catatan waktunya.
-- Dipilih: Membuat UNIQUE INDEX pada kombinasi kolom (bulan, kanal) agar REFRESH CONCURRENTLY dapat membandingkan delta data.
-- Alternatif: Membuat index biasa (non-unique); tidak dipilih karena PostgreSQL mewajibkan setidaknya satu index unik tanpa klausa WHERE untuk REFRESH CONCURRENTLY.

-- Percobaan REFRESH CONCURRENTLY tanpa index unik (akan gagal):
-- REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;
-- Pesan Galat: ERROR: cannot refresh materialized view "lab4.ringkasan_akses" concurrently
-- HINT: Create a unique index with no WHERE clause on one or more columns of the materialized view.

-- Buat index unik yang mencakup seluruh baris matview
CREATE UNIQUE INDEX ux_ringkasan_akses ON lab4.ringkasan_akses (bulan, kanal);

-- Ulangi refresh concurrently
\timing on
REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;

-- Penjelasan Perbedaan Waktu:
-- REFRESH CONCURRENTLY membutuhkan waktu lebih lama dibanding REFRESH biasa karena PostgreSQL membuat tabel sementara, membandingkan beda data (diff/delta), lalu melakukan operasi INSERT/UPDATE/DELETE berindeks secara atomic untuk mencegah penguncian pembaca (lock-free read).