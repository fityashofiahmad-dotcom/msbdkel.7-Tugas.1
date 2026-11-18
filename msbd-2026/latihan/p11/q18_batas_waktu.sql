-- Diminta: memasang batas waktu eksekusi query pada app_portal dan menjelaskan
--          efeknya terhadap percobaan penundaan (pg_sleep) serta SQLSTATE-nya.
-- Dipilih: ALTER ROLE app_portal SET statement_timeout = '5s'.
-- Alternatif: membiarkan timeout default (0 / tak terbatas); tidak dipilih
--             karena serangan time-based blind berjalan senyap tanpa error log.

ALTER ROLE app_portal SET statement_timeout = '5s';

-- Verifikasi konfigurasi pada peran:
SELECT rolname, rolconfig
FROM pg_roles
WHERE rolname = 'app_portal';

-- Uji terkendali di kontainer lab11 sendiri (akan berhenti di detik ke-5):
-- SET statement_timeout = '5s';
-- SELECT pg_sleep(6);
--
-- Galat & SQLSTATE yang muncul:
-- ERROR:  canceling statement due to statement timeout
-- SQLSTATE: 57014 (query_canceled)
--
-- Penjelasan:
-- Tanpa statement_timeout, payload pg_sleep selesai normal tanpa galat di log
-- server sehingga serangan time-based blind berjalan senyap. Dengan batas 5 detik,
-- setiap upaya penundaan paksa dihentikan dan dicatat sebagai ERROR (SQLSTATE 57014)
-- beserta teks query-nya di log PostgreSQL, sehingga lonjakan percobaan langsung
-- terdeteksi oleh pemantauan log.
