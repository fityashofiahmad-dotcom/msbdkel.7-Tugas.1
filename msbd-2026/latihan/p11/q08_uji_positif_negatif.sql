-- Diminta: sebagai app_laporan penyewa 1, hitung baris yang terlihat dan baris penyewa 2.
-- Dipilih: uji positif dan negatif sekaligus dalam satu transaksi dengan SET LOCAL, ditambah uji tanpa konteks.
-- Alternatif: hanya uji positif; tidak dipilih karena tidak membuktikan data penyewa lain tersembunyi.
BEGIN; SET LOCAL ROLE app_laporan; SET LOCAL app.tenant = '1';
  SELECT count(*) AS terlihat_tenant1 FROM lab11.pelanggan;                   -- harapkan 10000
  SELECT count(*) AS harus_nol FROM lab11.pelanggan WHERE tenant_id = 2;      -- harapkan 0
COMMIT;

BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS tanpa_konteks FROM lab11.pelanggan;                      -- harapkan 0, bukan galat
COMMIT;