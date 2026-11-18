-- Diminta: tunjukkan bagaimana konteks penyewa tertinggal di kolam koneksi, dan pola SET LOCAL / set_config(..., true).
-- Dipilih: simulasi satu koneksi yang dipakai dua permintaan; pola aman memakai set_config(..., true) di dalam transaksi.
-- Alternatif: SET biasa lalu RESET manual; tidak dipilih karena mudah terlewat bila terjadi galat.

-- Permintaan 1 (penyewa 1) menyetel di tingkat SESI, lalu koneksi kembali ke pool
SET app.tenant = '1';
-- Permintaan 2 memakai koneksi yang sama dan lupa menyetel konteks
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS bocor_ke_permintaan_berikutnya FROM lab11.pelanggan;   -- 10000 = data penyewa 1 bocor
COMMIT;
RESET app.tenant;

-- Pola aman: konteks hanya hidup di dalam transaksi
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT set_config('app.tenant', '2', true);
  SELECT count(*) AS penyewa2_dalam_transaksi FROM lab11.pelanggan;         -- 10000
COMMIT;
SHOW app.tenant;                                                            -- kosong: konteks ikut hilang
BEGIN; SET LOCAL ROLE app_laporan;
  SELECT count(*) AS permintaan_berikutnya FROM lab11.pelanggan;            -- 0
COMMIT;