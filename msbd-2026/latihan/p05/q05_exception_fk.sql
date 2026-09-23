-- Diminta: Menambahkan penanganan eksepsi FOREIGN KEY (foreign_key_violation) dengan pesan yang lebih ramah pada procedure.
-- Dipilih: Menggunakan blok EXCEPTION ... WHEN foreign_key_violation di dalam prosedur PL/pgSQL.
-- Alternatif: Menyerahkan penanganan galat mentah ke aplikasi luar; tidak dipilih agar prosedur dapat memberikan respons pesan yang terstandarisasi langsung dari database.

-- 1. Definisi Procedure dengan Exception Handling Foreign Key
CREATE OR REPLACE PROCEDURE lab5.process_rental_safe(
    p_customer_id integer,
    p_inventory_id integer,
    p_staff_id integer,
    p_amount numeric
)
LANGUAGE plpgsql
AS $$ DECLARE     v_rental_id bigint; BEGIN     

-- Proses insert rental     INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)     VALUES (p_customer_id, p_inventory_id, p_staff_id)     RETURNING rental_id INTO v_rental_id;      -- Proses insert payment     INSERT INTO lab5.payment_tx (rental_id, amount)     VALUES (v_rental_id, p_amount);  -- Menangkap pelanggaran Foreign Key dan memberikan pesan ramah EXCEPTION     WHEN foreign_key_violation THEN         RAISE EXCEPTION 'Data relasi tidak ditemukan. Mohon periksa kembali input Anda.'; END; $$;

-- 2. Uji Pemanggilan dengan ID Inventaris Fiktif (yang memicu pelanggaran FK)
CALL lab5.process_rental_safe(1, 99999, 1, 9.99);