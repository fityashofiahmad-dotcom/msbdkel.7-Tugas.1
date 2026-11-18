-- Diminta: menjalankan REVOKE DROP dan menjelaskan hak biasa vs hak yang melekat pada kepemilikan.
-- Dipilih: jalankan apa adanya, lalu buktikan DROP hanya bisa oleh pemilik (transaksi di-rollback).
-- Alternatif: DROP sungguhan sebagai pemilik; tidak dipilih karena merusak data lab.
REVOKE DROP ON lab11.akun FROM skema_owner;
SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' AND tablename = 'akun';
BEGIN; SET LOCAL ROLE app_laporan; DROP TABLE lab11.akun; ROLLBACK;