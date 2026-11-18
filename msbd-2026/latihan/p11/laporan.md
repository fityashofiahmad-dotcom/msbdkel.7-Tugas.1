## Laporan Latihan Kelompok 7 Pertemuan 11.

## Anggota dan Kontribusi
Nama               |    NIM    |                       Kontribusi                       | Commit
Fahri Arizal       | 251402102 | Q12-Q20, Refleksi C, laporan.md                        | -
Fitya Shofi Ahmad  | 251402132 | Q00-Q11, Refleksi A. Refleksi B, laporan.md, README.md | -
Mar'ie rizqullah   | 251402129 | Q21-Q30, Refleksi D, Refleksi E, laporan.md            | -

## Q1-Q30
1. Q01
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

2. Q02
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

3. Q03
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

4. Q04
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

5. Q05
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

6. Q06
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

7. Q07
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

8. Q08
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

9. Q09
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

10. Q10
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

11. Q11
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

12. Q12
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

13. Q13
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

14. Q14
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

15. Q15
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

16. Q16
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

17. Q17
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

18. Q18
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

19. Q19
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

20. Q20
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

21. Q21

Perintah:

SQL
SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';
ALTER TABLE lab11.pelanggan ADD COLUMN rekening_enc bytea;

UPDATE lab11.pelanggan
  SET rekening_enc = pgp_sym_encrypt(rekening, current_setting('app.kunci_kolom'))
WHERE id <= 1000;

-- Verifikasi dekripsi 1 baris
SELECT id, rekening, 
       pgp_sym_decrypt(rekening_enc, current_setting('app.kunci_kolom')) AS rekening_dekrip
FROM lab11.pelanggan WHERE id = 1;

-- Buktikan sifat non-deterministik (IV/Salt acak)
SELECT pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') AS sama;

Keluaran:

Plaintext
SET
ALTER TABLE
UPDATE 1000
 id |   rekening   | rekening_dekrip 
----+--------------+-----------------
  1 | 100000000001 | 100000000001
(1 row)

 sama 
------
 f
(1 row)

Alasan keputusan: Menggunakan pgp_sym_encrypt (OpenPGP symmetric encryption) dengan menyuntikkan kunci melalui parameter sesi (app.kunci_kolom) agar kunci tidak disimpan permanen (hardcoded) di dalam skema atau tabel database. Pengujian pgp_sym_encrypt('x','k') = pgp_sym_encrypt('x','k') menghasilkan false (f) karena OpenPGP secara otomatis menyertakan random salt dan Initialization Vector (IV) pada setiap proses enkripsi. Hal ini mencegah serangan analisis frekuensi atau pencocokan pola (pattern matching) antarbaris yang memiliki nilai rekening sama.

22. Q22

Perintah:

SQL
-- Dijalankan dari session kedua selagi UPDATE enkripsi berlangsung di session pertama:
SELECT pid, usename, state, query
FROM pg_stat_activity
WHERE state != 'idle' AND pid <> pg_backend_pid();

Keluaran:

Plaintext
 pid | usename  | state  |                                       query                                        
-----+----------+--------+------------------------------------------------------------------------------------
 142 | postgres | active | UPDATE lab11.pelanggan SET rekening_enc = pgp_sym_encrypt(rekening, current_setting('app.kunci_kolom')) WHERE id <= 1000;
(Catatan: Jika SET app.kunci_kolom = '...' sedang dieksekusi tepat saat dipantau, nilai kuncinya akan terlihat utuh di kolom query)

Alasan keputusan: Ya, kunci rahasia dapat terlihat dalam bentuk teks terang (plaintext) di pg_stat_activity tepat pada saat perintah SET app.kunci_kolom = '...' dieksekusi oleh klien. Selain pg_stat_activity, dua tempat lain yang wajib diperiksa untuk kebocoran kunci serupa adalah:

Log Server PostgreSQL (postgresql.log): Jika konfigurasi log_statement = 'all' atau log_min_duration_statement aktif, pernyataan SET beserta kunci teks terangnya akan tercatat permanen ke dalam file log.

Riwayat Klien / Command History (~/.psql_history): Jika administrator atau skrip menjalankan perintah secara interaktif lewat psql, kunci akan tersimpan dalam file riwayat perintah di sistem operasi.

23. Q23

Perintah:

SQL
REVOKE pg_read_all_data FROM app_analitik;

CREATE VIEW lab11.v_pelanggan_samar WITH (security_barrier = true) AS
SELECT id, tenant_id,
       left(nama,1) || repeat('*', greatest(length(nama)-1, 1)) AS nama,
       'xxxxxxxxxxxx' || right(nik, 4)                           AS nik,
       regexp_replace(surel, '^[^@]+', '****')                  AS surel,
       date_trunc('year', lahir)::date                          AS lahir_tahun,
       kota, round(saldo, -5)                                   AS saldo_bulat
FROM lab11.pelanggan;

REVOKE ALL   ON lab11.pelanggan         FROM app_analitik;
GRANT SELECT ON lab11.v_pelanggan_samar TO   app_analitik;

-- Pengujian akses sebagai app_analitik:
SET ROLE app_analitik;
SELECT * FROM lab11.pelanggan LIMIT 1;        -- Harus ditolak
SELECT * FROM lab11.v_pelanggan_samar LIMIT 3; -- Berhasil dengan data tersamar
RESET ROLE;

Keluaran:

Plaintext
REVOKE ROLE
CREATE VIEW
REVOKE
GRANT
SET
ERROR:  permission denied for table pelanggan
 id | tenant_id |    nama     |       nik        |      surel      | lahir_tahun |   kota    | saldo_bulat 
----+-----------+-------------+------------------+-----------------+-------------+-----------+-------------
  1 |         1 | P********** | xxxxxxxxxxxx0001 | ****@contoh.id  | 1990-01-01  | Jakarta   |     1500000
  2 |         1 | P********** | xxxxxxxxxxxx0002 | ****@contoh.id  | 1985-01-01  | Bandung   |     2300000
  3 |         1 | P********** | xxxxxxxxxxxx0003 | ****@contoh.id  | 1992-01-01  | Surabaya  |      800000
(3 rows)
RESET

Alasan keputusan: VIEW dibuat tanpa opsi security_invoker = true sehingga dijalankan dengan hak akses pemilik tampilan (definer rights), memungkinkan app_analitik membaca hasil penyamaran tanpa perlu diberikan hak akses langsung ke tabel asli lab11.pelanggan. Opsi WITH (security_barrier = true) ditambahkan untuk mencegah serangan side-channel melalui fungsi buatan pengguna (user-defined functions) yang berbiaya murah yang dapat membocorkan baris sebelum difilter oleh tampilan.

24. Q24
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

25. Q25
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

26. Q26
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

27. Q27
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

28. Q28
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

29. Q29
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

30. Q30
Perintah:
---

Keluaran:
---

Alasan keputusan:
---

## Jawaban refleksi A-E
1. Refleksi A

2. Refleksi B

3. Refleksi C

4. Refleksi D

5. Refleksi E

## Peta Tiket #1134 ke UU PDP
Keluhan | Pasal relevan | Kontrol teknis pencegah | Bukti
  ....  |      ....     |           ....          | ....

  ## Pernyataan Etika
  Seluruh percobaan serangan hanya dijalankan pada kontainer lab11 milik sendiri di jaringan tertutup. (tanda tangan tiap anggota)
