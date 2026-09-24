import psycopg
from psycopg import sql
from psycopg_pool import ConnectionPool

# Menggunakan port 5434 dan database proyek_dev
DSN = "postgresql://postgres:postgres@localhost:5434/proyek_dev"

# Q10 · SELECT berparameter
# Diminta: Menyambung ke PostgreSQL dan menjalankan SELECT memakai %s.
# Dipilih: Menggunakan tuple (1,) sebagai argumen kedua conn.execute.
# Alternatif: Memasukkan nilai langsung ke string (f-string); tidak dipilih karena rawan injeksi.
def q10_select_parameter(conn):
    print("\n--- Q10: SELECT Berparameter ---")
    rows = conn.execute(
        "SELECT rental_id, status FROM lab5.rental_tx WHERE customer_id = %s", 
        (1,)
    ).fetchall()
    print(f"Hasil: {rows}")

# Q11 · q11_uji_injeksi.py
# Diminta: Cetak SQL hasil f-string dengan payload berbahaya, lalu jalankan versi aman.
# Dipilih: Mencetak f-string saja ke terminal untuk bukti, lalu execute versi %s.
# Alternatif: Menjalankan eksekusi f-string; tidak dipilih karena berpotensi merusak keamanan.
def q11_uji_injeksi(conn):
    print("\n--- Q11: Uji Injeksi ---")
    payload = "SMITH' OR '1'='1"
    print(f"Bentuk f-string bahaya: SELECT customer_id FROM public.customer WHERE last_name = '{payload}'")
    
    rows = conn.execute(
        "SELECT customer_id FROM public.customer WHERE last_name = %s", 
        (payload,)
    ).fetchall()
    print(f"Hasil eksekusi parameter (Aman/Kosong): {rows}")

# Q12 · Identifier dan allow-list
# Diminta: Kirim nama kolom ORDER BY sebagai parameter nilai, gagal, lalu perbaiki.
# Dipilih: Memakai sql.Identifier dan allow-list tertutup di sisi Python.
# Alternatif: Menggabungkan string biasa; tidak dipilih karena bisa disusupi injeksi nama kolom.
def q12_identifier_allowlist(conn):
    print("\n--- Q12: Identifier ---")
    try:
        conn.execute("SELECT customer_id FROM public.customer ORDER BY %s LIMIT 1", ("first_name",))
    except psycopg.errors.SyntaxError as e:
        print(f"Galat disengaja: {e}")
        conn.rollback() 

    ALLOWED = {"first_name", "last_name", "create_date"}
    order_by = "first_name"
    
    if order_by in ALLOWED:
        stmt = sql.SQL("SELECT customer_id, first_name FROM public.customer ORDER BY {} LIMIT 2").format(sql.Identifier(order_by))
        rows = conn.execute(stmt).fetchall()
        print(f"Hasil Perbaikan: {rows}")

# Q13 · Rollback dari aplikasi
# Diminta: Panggil process_rental dalam blok with, lempar exception di tengah jalan.
# Dipilih: Menggunakan with psycopg.connect untuk memulai transaksi, lalu raise RuntimeError.
# Alternatif: Menangkap galat di dalam procedure PL/pgSQL; tidak dipilih karena batas transaksi milik aplikasi.
def q13_rollback_aplikasi():
    print("\n--- Q13: Rollback Aplikasi ---")
    with psycopg.connect(DSN) as temp_conn:
        awal = temp_conn.execute("SELECT count(*) FROM lab5.rental_tx").fetchone()[0]
        print(f"Jumlah baris sebelum: {awal}")
        
    try:
        with psycopg.connect(DSN) as conn2:
            conn2.execute("CALL lab5.process_rental(%s::integer, %s::integer, %s::integer, %s::numeric, %s::jsonb, NULL)", (1, 1, 1, 4.99, '{}'))
            raise RuntimeError("gagal di tengah alur")
    except RuntimeError as e:
        print(f"Terjadi galat: {e} -> Transaksi di-rollback otomatis")
        
    with psycopg.connect(DSN) as temp_conn:
        akhir = temp_conn.execute("SELECT count(*) FROM lab5.rental_tx").fetchone()[0]
        print(f"Jumlah baris sesudah (tetap sama): {akhir}")

# Q14 · ConnectionPool
# Diminta: Ganti koneksi tunggal dengan ConnectionPool ukuran 2, jalankan 5 permintaan, catat stats.
# Dipilih: psycopg_pool.ConnectionPool dengan batas maksimal 2 koneksi.
# Alternatif: Membuka dan menutup koneksi secara berulang; tidak dipilih karena biaya overhead pembukaan koneksi terlalu mahal.
def q14_connection_pool():
    print("\n--- Q14: Connection Pool ---")
    with ConnectionPool(DSN, min_size=1, max_size=2) as pool:
        for _ in range(5):
            with pool.connection() as conn:
                conn.execute("SELECT 1")
        print(f"Stats Pool: {pool.get_stats()}")

if __name__ == "__main__":
    with psycopg.connect(DSN) as main_conn:
        q10_select_parameter(main_conn)
        q11_uji_injeksi(main_conn)
        q12_identifier_allowlist(main_conn)
    q13_rollback_aplikasi()
    q14_connection_pool()