# Diminta: mendemonstrasikan celah SQL injection dan menutupnya dengan
#          query berparameter serta daftar putih tertutup untuk pengenal.
# Dipilih: placeholder %s (psycopg) untuk nilai data dan kamus allowlist
#          tertutup untuk nama kolom serta arah pengurutan ORDER BY.
# Alternatif: penyaringan/escaping karakter manual; tidak dipilih karena
#             mudah ditembus variasi sintaks dan merusak data sah.

import sys
import psycopg

DB_DSN = "host=lab11-db dbname=msbd user=app_portal password=portal_pass"

KOLOM = {"nama": "nama", "kota": "kota", "terbaru": "dibuat_pada"}
ARAH = {"naik": "ASC", "turun": "DESC"}


def cari_rentan(cur, kata: str):
    # RENTAN: masukan pengguna langsung dirangkai ke teks perintah SQL
    sql = f"SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE '%{kata}%'"
    print("SQL tercetak:", sql)
    cur.execute(sql)
    return cur.fetchall()


def cari_aman(cur, kata: str):
    # AMAN: nilai dikirim lewat saluran parameter terpisah
    sql = "SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE %s LIMIT 100"
    cur.execute(sql, (f"%{kata}%",))
    return cur.fetchall()


def urut_aman(cur, kolom: str, arah: str):
    # AMAN: pengenal kolom & arah urut divalidasi lewat daftar putih tertutup
    if kolom not in KOLOM or arah not in ARAH:
        raise ValueError("parameter pengurutan tidak dikenal")
    sql = (
        f"SELECT id, nama, kota FROM lab11.pelanggan "
        f"ORDER BY {KOLOM[kolom]} {ARAH[arah]} LIMIT 10"
    )
    cur.execute(sql)
    return cur.fetchall()


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 2 else "rentan"
    arg1 = sys.argv[2] if len(sys.argv) > 2 else (sys.argv[1] if len(sys.argv) > 1 else "Pelanggan 12")
    arg2 = sys.argv[3] if len(sys.argv) > 3 else "naik"

    with psycopg.connect(DB_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("SET LOCAL app.tenant = '1'")
            if mode == "aman":
                hasil = cari_aman(cur, arg1)
            elif mode == "urut":
                hasil = urut_aman(cur, arg1, arg2)
            else:
                hasil = cari_rentan(cur, arg1)
            print(f"Jumlah baris: {len(hasil)}")
