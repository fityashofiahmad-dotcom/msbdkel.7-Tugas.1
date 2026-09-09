-- Diminta: Bentangkan array kontak dari JSONB menjadi satu baris per kontak beserta nomor transaksi, dengan ketentuan data yang array kontaknya kosong tetap harus muncul.
-- Dipilih: Menggunakan jsonb_array_elements disertai LEFT JOIN LATERAL ... ON true agar data dengan array kosong (seperti T-003) tetap tampil sebagai baris dengan nilai NULL.
-- Alternatif: Menggunakan INNER JOIN dengan jsonb_array_elements; tidak dipilih karena akan menghilangkan baris transaksi yang array kontaknya kosong.

SELECT 
    payload->>'trx' AS nomor_transaksi,
    kontak->>'jenis' AS jenis_kontak,
    kontak->>'nomor' AS nomor_kontak
FROM notifikasi
LEFT JOIN LATERAL jsonb_array_elements(payload->'kontak') AS kontak ON true;
