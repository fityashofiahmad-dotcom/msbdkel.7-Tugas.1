-- Diminta: membandingkan laporan_kota_rentan dan laporan_kota_aman saat data
--          berbahaya sudah masuk ke tabel lewat INSERT yang aman (second-order).
-- Dipilih: fungsi PL/pgSQL dengan EXECUTE ... USING $1 (atau SQL statis)
--          untuk mengikat nilai dari tabel sebagai parameter, bukan kode.
-- Alternatif: hanya mengamankan query INSERT di pintu masuk; tidak dipilih
--             karena data tersimpan bisa dieksekusi ulang oleh proses hilir.

CREATE OR REPLACE FUNCTION lab11.laporan_kota_rentan(p_id int)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    v_kota text;
    v_jml  bigint;
BEGIN
    SELECT kota INTO v_kota FROM lab11.pelanggan WHERE id = p_id;
    -- RENTAN: nilai kolom dari tabel dirangkai langsung ke EXECUTE dinamis
    EXECUTE 'SELECT count(*) FROM lab11.pelanggan WHERE kota = ''' || v_kota || ''''
       INTO v_jml;
    RETURN v_jml;
END;
$$;

CREATE OR REPLACE FUNCTION lab11.laporan_kota_aman(p_id int)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    v_kota text;
    v_jml  bigint;
BEGIN
    SELECT kota INTO v_kota FROM lab11.pelanggan WHERE id = p_id;
    -- AMAN: nilai kolom dikirim lewat klausa USING sebagai parameter data
    EXECUTE 'SELECT count(*) FROM lab11.pelanggan WHERE kota = $1'
       INTO v_jml
      USING v_kota;
    RETURN v_jml;
END;
$$;

-- Uji dalam transaksi lalu ROLLBACK agar data asli tidak berubah:
BEGIN;
-- Simpan payload berbahaya lewat INSERT berparameter yang sah di pintu masuk:
INSERT INTO lab11.pelanggan (id, tenant_id, nama, nik, surel, lahir, kota, rekening, saldo)
VALUES (
    999999, 1, 'Uji Second Order', '1271000000000001', 'uji@contoh.id',
    '2000-01-01', 'Medan'' OR ''1''=''1', '1234567890', 0
);

SELECT lab11.laporan_kota_rentan(999999) AS hasil_rentan, -- mengembalikan seluruh baris
       lab11.laporan_kota_aman(999999)   AS hasil_aman;   -- mengembalikan 1 baris
ROLLBACK;

-- Penjelasan:
-- Pertahanan di pintu masuk (INSERT berparameter) hanya memastikan payload
-- disimpan secara harfiah ke kolom tabel tanpa mengeksekusinya saat INSERT.
-- Namun, ketika laporan_kota_rentan membaca isi kolom tersebut dan merangkainya
-- ke dalam EXECUTE dinamis tanpa USING, nilai tersimpan itu dieksekusi sebagai
-- kode SQL pada tahap kedua (second-order SQL injection).
