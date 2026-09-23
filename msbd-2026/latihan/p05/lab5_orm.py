# Diminta: Mengatasi masalah N+1 pada ORM dan membandingkan query analitik dengan SQL mentah.
# Dipilih: Gaya deklaratif SQLAlchemy 2.0 dengan selectinload untuk koleksi one-to-many.
# Alternatif: Lazy loading bawaan (tidak dipilih karena memicu N+1) dan imperative mapping (tidak dipilih karena usang di 2.0).

import time
from sqlalchemy import create_engine, ForeignKey, text, select, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, Session, selectinload, joinedload

# Memakai port 5434 tempat data Customer (dari P04) berada
URL = "postgresql+psycopg://postgres:postgres@localhost:5434/proyek_dev"
engine = create_engine(URL, echo=True) # echo=True wajib agar statement SQL tercetak di log

class Base(DeclarativeBase):
    pass

# Q16 · Model deklaratif
class Customer(Base):
    __tablename__ = "customer"
    __table_args__ = {'schema': 'public'}
    
    customer_id: Mapped[int] = mapped_column(primary_key=True)
    # Relasi 1-to-Many: 1 Customer memiliki banyak Rental
    rentals: Mapped[list["Rental"]] = relationship(back_populates="customer")

class Rental(Base):
    __tablename__ = "rental_tx"
    __table_args__ = {'schema': 'lab5'}
    
    rental_id: Mapped[int] = mapped_column(primary_key=True)
    customer_id: Mapped[int] = mapped_column(ForeignKey("public.customer.customer_id"))
    inventory_id: Mapped[int] = mapped_column()
    
    # Relasi Many-to-1: Banyak Rental dimiliki 1 Customer
    customer: Mapped["Customer"] = relationship(back_populates="rentals")


def q17_bukti_n1():
    print("\n--- Q17: BUKTI N+1 (Target Log: 11 SELECT) ---")
    with Session(engine) as session:
        customers = session.scalars(select(Customer).limit(10)).all()
        # Perulangan ini akan memaksa ORM menembak 1 query per customer (N) ditambah 1 query induk (+1)
        hasil = [(c.customer_id, len(c.rentals)) for c in customers]
        print(f"Hasil Q17: {hasil}")

def q18_selectinload():
    print("\n--- Q18: SELECTINLOAD (Target Log: 2 SELECT) ---")
    with Session(engine) as session:
        # Memuat relasi menggunakan 1 query tambahan dengan IN (...)
        rows = session.scalars(select(Customer).options(selectinload(Customer.rentals)).limit(10)).all()
        hasil = [(c.customer_id, len(c.rentals)) for c in rows]
        print(f"Hasil Q18: {hasil}")

def q19_joinedload():
    print("\n--- Q19: JOINEDLOAD (Target Log: 1 SELECT via JOIN) ---")
    with Session(engine) as session:
        # unique() wajib dipanggil saat menggunakan joinedload pada relasi koleksi (one-to-many)
        rows = session.scalars(select(Customer).options(joinedload(Customer.rentals)).limit(10)).unique().all()
        hasil = [(c.customer_id, len(c.rentals)) for c in rows]
        print(f"Hasil Q19: {hasil}")

def q20_komparasi_analitik():
    print("\n--- Q20: ORM vs SQL MENTAH (Query Analitik: 5 Film Tersewa Terbanyak) ---")
    
    # 1. Versi ORM
    start_orm = time.time()
    with Session(engine) as session:
        orm_result = session.execute(
            select(Rental.inventory_id, func.count(Rental.rental_id).label('total'))
            .group_by(Rental.inventory_id)
            .order_by(func.count(Rental.rental_id).desc())
            .limit(5)
        ).all()
    waktu_orm = time.time() - start_orm
    
    # 2. Versi SQL Mentah
    start_sql = time.time()
    with engine.connect() as conn:
        sql_result = conn.execute(text("""
            SELECT inventory_id, count(rental_id) as total 
            FROM lab5.rental_tx 
            GROUP BY inventory_id 
            ORDER BY total DESC 
            LIMIT 5
        """)).fetchall()
    waktu_sql = time.time() - start_sql
    
    print(f"Hasil eksekusi ORM: {orm_result} | Waktu: {waktu_orm:.6f} detik")
    print(f"Hasil eksekusi SQL: {sql_result} | Waktu: {waktu_sql:.6f} detik")

if __name__ == "__main__":
    q17_bukti_n1()
    q18_selectinload()
    q19_joinedload()
    q20_komparasi_analitik()