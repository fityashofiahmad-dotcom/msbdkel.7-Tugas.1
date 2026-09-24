# Diminta: endpoint HTTP yang memanggil procedure lab5.process_rental
#          dan menerjemahkan galat basis data menjadi respons HTTP yang aman.
# Dipilih: FastAPI + dependency get_conn bergaya "with yield" yang meminjam
#          koneksi dari ConnectionPool (Q14), validasi input di Pydantic
#          (amount > 0) supaya nilai tidak sah ditolak sebelum menyentuh DB,
#          lalu exception handler menerjemahkan SQLSTATE ke status HTTP.
# Alternatif: memvalidasi hanya di database dan meneruskan pesan error
#          psycopg mentah ke klien; tidak dipilih karena membocorkan detail
#          SQL/skema ke luar dan mengembalikan 500 untuk kesalahan input
#          yang sebenarnya adalah kesalahan klien (harusnya 422).

import os
from contextlib import contextmanager
from decimal import Decimal

import psycopg
from psycopg_pool import ConnectionPool
from fastapi import FastAPI, Depends, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, Field

DSN = os.environ.get(
    "DSN", "postgresql://postgres:postgres@localhost:5434/proyek_dev"
)

app = FastAPI(title="Lab5 Rental API")

# --- Q14: pool dipakai ulang di sini, bukan koneksi tunggal per request ---
pool = ConnectionPool(DSN, min_size=1, max_size=2, open=True)


@app.on_event("shutdown")
def _close_pool():
    pool.close()


# ---------------------------------------------------------------------
# Q21 · Dependency koneksi (gaya "with yield", meminjam dari pool)
# ---------------------------------------------------------------------
def get_conn():
    with pool.connection() as conn:
        yield conn


# ---------------------------------------------------------------------
# Skema Pydantic — validasi amount > 0 di sini menghasilkan 422 otomatis
# tanpa perlu ke database sama sekali.
# ---------------------------------------------------------------------
class RentalIn(BaseModel):
    customer_id: int
    inventory_id: int
    staff_id: int
    amount: Decimal = Field(gt=0)


class RentalOut(BaseModel):
    rental_id: int


# ---------------------------------------------------------------------
# Q22–Q24 · POST /rentals
# ---------------------------------------------------------------------
@app.post("/rentals", response_model=RentalOut, status_code=201)
def create_rental(payload: RentalIn, conn: psycopg.Connection = Depends(get_conn)):
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                CALL lab5.process_rental(%s, %s, %s, %s)
                """,
                (
                    payload.customer_id,
                    payload.inventory_id,
                    payload.staff_id,
                    payload.amount,
                ),
            )
            # Sesuaikan dengan bentuk procedure kelompok: jika process_rental
            # tidak mengembalikan rental_id langsung, ambil id baru dengan
            # currval/lastval atau ubah procedure agar RETURN/OUT rental_id.
            cur.execute(
                """
                SELECT rental_id FROM lab5.rental_tx
                ORDER BY rental_id DESC LIMIT 1
                """
            )
            row = cur.fetchone()
        conn.commit()
        return RentalOut(rental_id=row[0])

    except psycopg.errors.ForeignKeyViolation:
        conn.rollback()
        # Q24: inventory_id (atau customer/staff) tidak ada -> 409 Conflict
        raise HTTPException(
            status_code=409,
            detail="Salah satu referensi (customer/inventory/staff) tidak ditemukan.",
        )

    except psycopg.errors.CheckViolation:
        conn.rollback()
        # Jaring pengaman kedua: kalaupun ada jalur yang lolos validasi
        # Pydantic (mis. dipanggil bukan lewat endpoint ini), domain
        # positive_amount di database tetap menolak nilai <= 0.
        raise HTTPException(
            status_code=422,
            detail="Nilai amount tidak memenuhi aturan (harus lebih besar dari 0).",
        )

    except psycopg.Error:
        conn.rollback()
        # Galat basis data lain: jangan pernah meneruskan pesan psycopg
        # mentah (bisa memuat SQL/nama tabel) ke klien.
        raise HTTPException(status_code=500, detail="Terjadi kesalahan pada server.")


# ---------------------------------------------------------------------
# Pastikan galat validasi Pydantic (Q23) tetap 422 tanpa membocorkan
# detail internal — FastAPI sudah default 422, handler ini hanya
# merapikan bentuk responsnya.
# ---------------------------------------------------------------------
@app.exception_handler(RequestValidationError)
async def validation_handler(request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={"detail": "Data yang dikirim tidak valid.", "errors": exc.errors()},
    )
