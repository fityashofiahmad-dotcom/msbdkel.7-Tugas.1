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