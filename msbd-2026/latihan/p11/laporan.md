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
---

Keluaran:
---

Alasan keputusan:
---

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
