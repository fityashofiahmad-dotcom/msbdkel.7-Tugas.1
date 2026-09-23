# Laporan Latihan Kelompok Pertemuan 5

## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |
|---|---|---|---|

## Q1–Q24
### q01_total_dibayar.sql
1. Perintah: 
CREATE OR REPLACE FUNCTION lab5.total_dibayar(p_rental_id bigint)
RETURNS numeric LANGUAGE sql STABLE AS $$
SELECT coalesce(sum(amount), 0) FROM lab5.payment_tx WHERE rental_id = p_rental_id;
$$;

$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("SELECT lab5.total_dibayar(1::bigint);"); print("Total:", cur.fetchone()[0])'
2. Keluaran: 
Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("SELECT lab5.total_dibayar(1::bigint);"); print("Total:", cur.fetchone()[0])'
Total: 0
(.venv) 
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
Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure berhasil dibuat!")'
Procedure berhasil dibuat!
(.venv) 

Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CALL lab5.process_rental(1, 1, 1, 9.99::numeric);"); conn.commit(); cur.execute("SELECT count(*) FROM lab5.rental_tx;"); r = cur.fetchone()[0]; cur.execute("SELECT count(*) FROM lab5.payment_tx;"); p = cur.fetchone()[0]; print(f"Sukses! Jumlah baris rental_tx: {r}, Jumlah baris payment_tx: {p}")'
Sukses! Jumlah baris rental_tx: 1, Jumlah baris payment_tx: 1
(.venv) 
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
(.venv) 
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
Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
$ python -c 'import psycopg; conn = psycopg.connect("dbnampython -c 'import psycopg; conn = psycopg.connect("dbname=proyek_dev user=postgres host=localhost port=5434 password=postgres"); cur = conn.cursor(); cur.execute("CREATE OR REPLACE PROCEDURE lab5.process_rental_commit(p_customer_id integer, p_inventory_id integer, p_staff_id integer, p_amount numeric) LANGUAGE plpgsql AS '\''DECLARE v_rental_id bigint; BEGIN INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id) VALUES (p_customer_id, p_inventory_id, p_staff_id) RETURNING rental_id INTO v_rental_id; COMMIT; INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (v_rental_id, p_amount); END;'\''"); conn.commit(); print("Procedure dengan COMMIT berhasil dibuat!")'
Procedure dengan COMMIT berhasil dibuat!
(.venv) 

Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
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
(.venv) 
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
Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
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
(.venv) 

Asus Tuf@ASUS-PITSOP MINGW64 /c/MSBD/msbd-2026 (main)
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
(.venv) 
3. Alasan:
Blok EXCEPTION WHEN foreign_key_violation menangkap galat pelanggaran integritas relasi secara spesifik dan meneruskan pesan yang lebih ramah kepada pengguna melalui fungsi RAISE EXCEPTION.

Informasi yang Hilang: Saat galat ditangkap dengan cara ini, informasi teknis mendalam dari mesin database menjadi hilang, seperti nama constraint foreign key yang spesifik, kolom persis yang gagal terhubung (customer_id, inventory_id, atau staff_id), serta detail nilai baris referensi asal.

Kapan Layak Digunakan: Penangkapan galat ini layak digunakan ketika kita ingin menyembunyikan detail teknis basis data yang membingungkan bagi pengguna akhir (end-user), lalu menggantinya dengan pesan antarmuka yang bersih, terstandarisasi, serta mudah dipahami.

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

### q01_total_dibayar.sql
1. Perintah:
2. Keluaran:
3. Alasan:

## Refleksi A–E
...

## Di Mana Aturan Itu Tinggal
| Aturan | Lapisan | Risiko bila dipindahkan | Bukti |
|---|---|---|---|

## Ringkasan N+1
| Q17 | Q18 | Q19 | Penafsiran |
|---:|---:|---:|---|
