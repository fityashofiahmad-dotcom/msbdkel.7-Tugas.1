# LAPORAN LATIHAN KELOMPOK PERTEMUAN 5

## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |
| Andika Chairul Ilham | 251402047 | Langkah 6, Refleksi E, Laporan |---|
| Fahri Arizal | 2514020102 | Langkah 5, Refleksi D, Laporan |---|
| Fitya Shofi Ahmad | 251402132 | Langkah 1,Langkah 2, Refleksi A, Laporan |---|
| Mar-ie Rizqullah | 251402129 | Langkah 3, Langkah 4, Refleksi B, Refleksi C, Laporan |---|

## Q1–Q24
### q01_total_dibayar.sql
1. Perintah: 
CREATE OR REPLACE FUNCTION lab5.total_dibayar(p_rental_id bigint)
RETURNS numeric LANGUAGE sql STABLE AS $$
SELECT coalesce(sum(amount), 0) FROM lab5.payment_tx WHERE rental_id = p_rental_id;
$$;

$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("SELECT lab5.total_dibayar(1::bigint);"); print("Total:", cur.fetchone()[0])'
2. Keluaran: 
`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("SELECT lab5.total_dibayar(1::bigint);"); print("Total:", cur.fetchone()[0])'
Total: 0
`.venv` 
3. Alasan: 
Fungsi lab5.total_dibayar berhasil didefinisikan menggunakan bahasa SQL dengan sifat STABLE. Ketika dipanggil untuk rental_id = 1 yang belum memiliki riwayat pembayaran, fungsi menghitung agregasi pembayaran menggunakan sum(amount) yang digabung dengan coalesce(..., 0), sehingga mengembalikan nilai 0 alih-alih nilai kosong (NULL).

### q02_process_rental.sql
1. Perintah:
CREATE SCHEMA IF NOT EXISTS lab5;
CREATE TYPE lab5.rental_status AS ENUM ('ACTIVE','RETURNED','CANCELLED');
CREATE DOMAIN lab5.positive_amount AS numeric(10,2) CHECK (VALUE > 0);

CREATE TABLE lab5.rental_tx (
  rental_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  integer NOT NULL,
  inventory_id integer NOT NULL,
  staff_id     integer NOT NULL,
  status       lab5.rental_status NOT NULL DEFAULT 'ACTIVE',
  tags         text[] NOT NULL DEFAULT '{}',
  metadata     jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE lab5.payment_tx (
  payment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  rental_id  bigint NOT NULL REFERENCES lab5.rental_tx (rental_id),
  amount     lab5.positive_amount NOT NULL,
  paid_at    timestamptz NOT NULL DEFAULT now()
);

python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure berhasil dibuat!")'

python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CALL lab5.process_rental(1, 1, 1, 9.99::numeric);"); conn.commit(); cur.execute("SELECT count(*) FROM lab5.rental_tx;"); r = cur.fetchone()[0]; cur.execute("SELECT count(*) FROM lab5.payment_tx;"); p = cur.fetchone()[0]; print(f"Sukses! Jumlah baris rental_tx: {r}, Jumlah baris payment_tx: {p}")'
2. Keluaran:
`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure berhasil dibuat!")'
Procedure berhasil dibuat!
`.venv` 

`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CALL lab5.process_rental(1, 1, 1, 9.99::numeric);"); conn.commit(); cur.execute("SELECT count(*) FROM lab5.rental_tx;"); r = cur.fetchone()[0]; cur.execute("SELECT count(*) FROM lab5.payment_tx;"); p = cur.fetchone()[0]; print(f"Sukses! Jumlah baris rental_tx: {r}, Jumlah baris payment_tx: {p}")'
Sukses! Jumlah baris rental_tx: 1, Jumlah baris payment_tx: 1
`.venv` 
3. Alasan:
Prosedur lab5.process_rental berhasil dijalankan secara atomik (atomic transaction). Ketika dipanggil dengan nilai parameter yang sah, perintah INSERT pertama berhasil menyisipkan data penyewaan baru ke dalam tabel lab5.rental_tx dan mengembalikan (RETURNING) kunci ID baru (v_rental_id), yang kemudian langsung digunakan oleh perintah INSERT kedua untuk mencatat data pembayaran ke dalam tabel lab5.payment_tx.

### q03_buktikan_rollback.sql
1. Perintah:
CALL lab5.process_rental(
    1, 1, 1, -4.99
);

SELECT count(*) FROM lab5.rental_tx;

python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor()
try:
    cur.execute("CALL lab5.process_rental(1, 1, 1, -4.99::numeric);")
    conn.commit()
except Exception as e:
    conn.rollback()
    print("--- SALINAN GALAT ---")
    print(e)

cur.execute("SELECT count(*) FROM lab5.rental_tx;")
print("Jumlah baris rental_tx sesudahnya:", cur.fetchone()[0])
'
2. Keluaran:
"Jumlah baris rental_tx sesudahnya:", cur.fetchone
--- SALINAN GALAT ---
value for domain lab5.positive_amount violates check constraint "positive_amount_check"
CONTEXT:  SQL statement "INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount)"
PL/pgSQL function lab5.process_rental(integer,integer,integer,numeric) line 1 at SQL statement
Jumlah baris rental_tx sesudahnya: 1
`.venv` 
3. Alasan:
Prosedur dijalankan dalam satu blok transaksi yang bersifat atomik (atomic transaction). Ketika proses INSERT kedua ke tabel payment_tx gagal karena nilai -4.99 melanggar aturan domain positive_amount (yang mengharuskan nilai > 0), PostgreSQL secara otomatis melakukan rollback penuh pada seluruh transaksi yang sedang berjalan. Akibatnya, operasi INSERT pertama yang sebelumnya sempat sukses pada tabel rental_tx ikut dibatalkan oleh sistem, sehingga jumlah baris pada rental_tx tidak mengalami penambahan sama sekali.

### q04_commit_dalam_procedure.sql
1. Perintah:
-- Diminta: Membuat salinan procedure yang menjalankan COMMIT di tengah prosedur setelah INSERT pertama, lalu memanggilnya.
-- Dipilih: Menguji perilaku procedure dengan COMMIT internal terhadap manajemen transaksi dari aplikasi luar (Python).
-- Alternatif: Menggunakan fungsi tanpa COMMIT; tidak dipilih karena tujuan soal adalah menganalisis dampak COMMIT di dalam prosedur.

-- 1. Definisi Procedure dengan COMMIT di tengah
CREATE OR REPLACE PROCEDURE lab5.process_rental_commit(
    p_customer_id integer,
    p_inventory_id integer,
    p_staff_id integer,
    p_amount numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rental_id bigint;
BEGIN
    -- INSERT pertama ke rental_tx
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
    VALUES (p_customer_id, p_inventory_id, p_staff_id)
    RETURNING rental_id INTO v_rental_id;

    -- Menjalankan COMMIT di tengah blok prosedur
    COMMIT;

    -- INSERT kedua ke payment_tx
    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
END;
$$;

-- 2. Pemanggilan Procedure (dapat memicu galat jika dipanggil di dalam blok transaksi aktif luar)
CALL lab5.process_rental_commit(1, 1, 1, 9.99);

python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental_commit(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; COMMIT; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure dengan COMMIT berhasil dibuat!")'

python -c 'import psycopg
try:
    with psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL lab5.process_rental_commit(1, 1, 1, 9.99::numeric);")
except Exception as e:
    print("--- SALINAN GALAT ---")
    print(e)
'

python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental_commit(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; COMMIT; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure dengan COMMIT berhasil dibuat!")'

python -c 'import psycopg
try:
    with psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL lab5.process_rental_commit(1, 1, 1, 9.99::numeric);")
except Exception as e:
    print("--- SALINAN GALAT ---")
    print(e)
'
2. Keluaran:
`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbnampython -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental_commit(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; COMMIT; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure dengan COMMIT berhasil dibuat!")'
Procedure dengan COMMIT berhasil dibuat!
`.venv` 

`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg
try:
    with psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL lab5.process_rental_commit(1, 1, 1, 9.99::numeric);")
except Exception as e:
    print("--- SALINAN GALAT ---")
    print(e)
'
--- SALINAN GALAT ---
invalid transaction termination
CONTEXT:  PL/pgSQL function lab5.process_rental_commit(integer,integer,integer,numeric) line 1 at COMMIT
`.venv` 
3. Alasan:
Driver Python (psycopg) beserta konteks blok with psycopg.connect(...) mengelola awal dan akhir transaksi secara otomatis dari sisi klien (koneksi luar). Ketika procedure mencoba mengeksekusi perintah pengendali transaksi secara mandiri di tengah-tengah blok (seperti perintah COMMIT di dalam fungsi/prosedur PL/pgSQL), PostgreSQL mendeteksi pelanggaran batas siklus transaksi aktif yang sedang dikendalikan, sehingga memicu galat terminasi transaksi yang tidak valid (invalid transaction termination).

### q05_exception_fk.sql
1. Perintah:
CREATE OR REPLACE PROCEDURE lab5.process_rental_safe(
    p_customer_id integer,
    p_inventory_id integer,
    p_staff_id integer,
    p_amount numeric
)
LANGUAGE plpgsql
AS $$ DECLARE     v_rental_id bigint; BEGIN     

CALL lab5.process_rental_safe(1, 99999, 1, 9.99);

python -c 'import psycopg
conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres")
cur = conn.cursor()
cur.execute("""
    CREATE OR REPLACE PROCEDURE lab5.process_rental_safe(
        p_customer_id integer,
        p_inventory_id integer,
        p_staff_id integer,
        p_amount numeric
    )
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_rental_id bigint;
    BEGIN
        INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
        VALUES (p_customer_id, p_inventory_id, p_staff_id)
        RETURNING rental_id INTO v_rental_id;

        INSERT INTO lab5.payment_tx (rental_id, amount)
        VALUES (v_rental_id, p_amount);
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE EXCEPTION '\''Data relasi tidak ditemukan. Mohon periksa kembali input Anda.'\'';
    END;
    $$;
""")
conn.commit()
print("Procedure safe berhasil dibuat!")
'

python -c 'import psycopg
conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres")
cur = conn.cursor()
try:
    cur.execute("CALL lab5.process_rental_safe(1, 99999, 1, 9.99::numeric);")
    conn.commit()
    print("Berhasil!")
except Exception as e:
    conn.rollback()
    print("--- GALAT RAMAH TERTANGKAP ---")
    print(e)
'
2. Keluaran:
`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg
conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres")
cur = conn.cursor()
cur.execute("""
    CREATE OR REPLACE PROCEDURE lab5.process_rental_safe(
        p_customer_id integer,
        p_inventory_id integer,
        p_staff_id integer,
        p_amount numeric
    )
'rint("Procedure safe berhasil dibuat!")''; tidak ditemu
Procedure safe berhasil dibuat!
`.venv` 

`Asus Tuf@ASUS-PITSOP MINGW64` /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg
conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres")
cur = conn.cursor()
try:
    cur.execute("CALL lab5.process_rental_safe(1, 99999, 1, 9.99::numeric);")
    conn.commit()
    print("Berhasil!")
except Exception as e:
    conn.rollback()
    print("--- GALAT RAMAH TERTANGKAP ---")
'   print(e)
--- GALAT RAMAH TERTANGKAP ---
Data relasi tidak ditemukan. Mohon periksa kembali input Anda.
CONTEXT:  PL/pgSQL function lab5.process_rental_safe(integer,integer,integer,numeric) line 13 at RAISE
`.venv` 
3. Alasan:
Blok EXCEPTION WHEN foreign_key_violation menangkap galat pelanggaran integritas relasi secara spesifik dan meneruskan pesan yang lebih ramah kepada pengguna melalui fungsi RAISE EXCEPTION.

Informasi yang Hilang: Saat galat ditangkap dengan cara ini, informasi teknis mendalam dari mesin database menjadi hilang, seperti nama constraint foreign key yang spesifik, kolom persis yang gagal terhubung (customer_id, inventory_id, atau staff_id), serta detail nilai baris referensi asal.

Kapan Layak Digunakan: Penangkapan galat ini layak digunakan ketika kita ingin menyembunyikan detail teknis basis data yang membingungkan bagi pengguna akhir (end-user), lalu menggantinya dengan pesan antarmuka yang bersih, terstandarisasi, serta mudah dipahami.

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

## Q16 Model Deklaratif
1. **Perintah:** 
Memetakan `Customer` dan `Rental` beserta relasinya menggunakan gaya deklaratif SQLAlchemy 2.0.
2. **Keluaran:**
```python
class Customer(Base):
    __tablename__ = "customer"
    __table_args__ = {'schema': 'public'}
    customer_id: Mapped[int] = mapped_column(primary_key=True)
    rentals: Mapped[list["Rental"]] = relationship(back_populates="customer")

class Rental(Base):
    __tablename__ = "rental_tx"
    __table_args__ = {'schema': 'lab5'}
    rental_id: Mapped[int] = mapped_column(primary_key=True)
    customer_id: Mapped[int] = mapped_column(ForeignKey("public.customer.customer_id"))
    customer: Mapped["Customer"] = relationship(back_populates="rentals")

## Refleksi A–E
1. Refleksi A
Setelah kita menguji Q3 dan Q4, berikut adalah analisis siapa yang memegang kendali transaksi beserta cara membuktikannya:
* **Siapa yang memulai transaksi?**
Yang memulai transaksi adalah klien luar (aplikasi Python/driver psycopg), bukan prosedur yang ada di dalam database. Setiap kali kita menjalankan perintah CALL atau mengeksekusi fungsi dari Python, driver secara otomatis membuka sebuah blok transaksi baru.
* **Siapa yang mengakhirinya?**
Yang mengakhirinya tetap klien luar (Python) melalui perintah conn.commit() atau conn.rollback().
* **Bagaimana membuktikannya dari data?**
A. Bukti di Q3 (Rollback otomatis): Kita membuktikannya dengan sengaja memasukkan data yang salah (nilai -4.99 yang melanggar aturan domain). Meskipun perintah INSERT pertama ke tabel rental_tx sempat sukses di dalam prosedur, ketika perintah kedua gagal, Python menangkap error tersebut dan melakukan conn.rollback(). Hasil pengecekan data di tabel rental_tx menunjukkan jumlah barisnya tetap 0 (tidak bertambah sama sekali). Ini membuktikan bahwa kendali rollback ada di tangan luar.
B. Bukti di Q4 (Error Invalid Transaction Termination): Kita membuktikannya dengan sengaja menyelipkan perintah COMMIT di tengah-tengah prosedur. Ketika prosedur itu dipanggil dari Python, PostgreSQL langsung memunculkan galat invalid transaction termination. Ini adalah bukti nyata bahwa prosedur tidak boleh (dilarang keras) mengatur akhir transaksi sendiri karena kendali siklus transaksi sudah dipegang penuh oleh koneksi luar dari Python.

2. Refleksi B
Keputusan: Tipe tags (Array) sebaiknya tetap dipertahankan di dalam tabel rental_tx selama ia hanya dibaca utuh sebagai atribut pelengkap. Pertanyaan Bisnis (Alasan Pindah): "Tag mana yang paling sering digunakan pengguna bulan ini dan bagaimana korelasi tag tersebut dengan total pembayaran?". Jika bisnis mulai menanyakan hal ini, maka tag akan sering difilter di klausa WHERE, butuh di-join, dan butuh dihitung terpisah. Begitu hal ini terjadi, struktur array memakan biaya perawatan yang tinggi dan tags wajib dipisah menjadi tabel anak dengan relasi Foreign Key.

3. Refleksi C
Persamaan: Keduanya (baik rollback dari basis data maupun Python) mengamankan integritas data secara atomik. Jika ada satu langkah yang gagal, maka seluruh statement perubahan data sebelumnya dalam transaksi tersebut akan ikut dibatalkan, sehingga tidak ada data "setengah jadi". Yang Hanya Bisa Dilakukan Aplikasi: Aplikasi dapat melakukan orkestrasi dengan memanggil layanan dari luar (dunia luar) sebelum memutuskan rollback. Misalnya: aplikasi bisa mencatat error ke monitoring log, membatalkan pengiriman email ke customer, atau memanggil API payment gateway eksternal untuk refund uang, di mana hal-hal ini tidak bisa/tidak boleh dilakukan dari dalam transaksi basis data.

4. Refleksi D

Versi mana yang dipilih jika dibaca 6 bulan lagi?
Jika digunakan untuk alur CRUD/Operasional Bisnis, versi ORM lebih dipilih karena relasi dan tipe datanya terlihat jelas sebagai objek Python, meskipun ada pengorbanan waktu eksekusi yang sedikit lebih lambat (ORM [masukkan angka detikmu di sini] vs SQL [masukkan angka detikmu di sini]). Namun, jika untuk membuat laporan analitik kompleks yang melibatkan ratusan ribu baris, versi SQL Mentah mutlak dipilih untuk menghemat memori.   Kapan joinedload lebih tepat dari selectinload?
joinedload lebih tepat dipakai saat kita memuat relasi Many-to-One (misal: 1 Rental punya 1 Customer). Jika digunakan untuk One-to-Many dengan data anak yang sangat besar, joinedload berisiko memperbanyak baris duplikat di memori, sehingga selectinload (yang memakai 2 statement terpisah dengan IN) menjadi pilihan yang jauh lebih aman.

5. Refleksi E

Bagian refleksi E belum memuat jawaban pada bahan laporan yang tersedia.


## Di Mana Aturan Itu Tinggal

| Aturan | Lapisan | Risiko bila dipindahkan | Bukti |
|---|---|---|---|
| *Belum diisi pada bahan laporan yang tersedia.* | — | — | — |

## Q17 – Bukti N+1
### Perintah
Mengambil 10 customer, kemudian mengakses atribut `c.rentals` untuk masing-masing baris.

### Keluaran
Terdapat 11 query `SELECT` pada log terminal.
Hasil Q17: [(1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0), (8, 0), (9, 0), (10, 0)]

### Alasan
Pola akses bawaan (*lazy loading*) menembakkan 1 query untuk mengambil 10 induk (Customer), lalu karena ada iterasi len(c.rentals), ORM secara reaktif menembakkan 10 query tambahan untuk masing-masing anak.

### Ringkasan N+1

| Strategi | Jumlah Statement | Penafsiran |
|---|---:|---|
| Q17 (*Lazy*) | 11 | 1 query mengambil 10 data induk, lalu ORM mengeksekusi 10 query tambahan untuk mengambil data anak pada setiap perulangan. |
| Q18 (*selectinload*) | 2 | 1 query mengambil data induk, kemudian 1 query susulan mengambil seluruh data anak secara serentak menggunakan `IN (...)`. |
| Q19 (*joinedload*) | 1 | 1 query besar mengambil data induk dan anak sekaligus melalui `LEFT OUTER JOIN`. |

## Kesimpulan

Latihan Pertemuan 5 menunjukkan penerapan function, procedure, transaksi, rollback, exception handling, serta pemetaan relasi menggunakan SQLAlchemy. Hasil pengujian juga memperlihatkan pentingnya menjaga integritas transaksi dan memilih strategi pemuatan relasi ORM yang sesuai untuk menghindari masalah N+1 query.
