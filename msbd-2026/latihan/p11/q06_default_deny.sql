-- Diminta: nyalakan RLS pada pelanggan, lalu hitung baris yang terlihat app_laporan sebelum ada kebijakan.
-- Dipilih: ENABLE ROW LEVEL SECURITY lalu uji negatif sebagai app_laporan di dalam transaksi.
-- Alternatif: penyaring tenant_id di aplikasi; tidak dipilih karena gagalnya membocorkan, bukan menolak.
ALTER TABLE lab11.pelanggan ENABLE ROW LEVEL SECURITY;
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS sebelum_ada_kebijakan FROM lab11.pelanggan;   -- harapkan 0
COMMIT;