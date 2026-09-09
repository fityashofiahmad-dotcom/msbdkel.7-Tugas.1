-- Diminta: Tampilkan seluruh notifikasi berstatus lunas beserta nomor transaksi, kota pelanggan, dan jumlah sebagai angka, serta buat indeks GIN.
-- Dipilih: Menggunakan operator ->> untuk ekstraksi teks/angka dan operator @> untuk pencarian JSONB, serta membuat indeks GIN pada kolom payload.
-- Alternatif: Menggunakan fungsi jsonb_path_ops tanpa operator @>; tidak dipilih karena kurang fleksibel untuk pencarian key-value sederhana yang cepat.

-- Pembuatan Indeks GIN pada kolom payload
CREATE INDEX IF NOT EXISTS idx_notifikasi_payload ON notifikasi USING gin (payload);

-- Query utama
SELECT 
    notifikasi_id,
    payload->>'trx' AS nomor_transaksi,
    payload->'pelanggan'->>'kota' AS kota_pelanggan,
    (payload->>'jumlah')::numeric AS jumlah
FROM notifikasi
WHERE payload @> '{"status": "lunas"}';
