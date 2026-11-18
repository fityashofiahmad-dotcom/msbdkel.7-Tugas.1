-- Q26: Pengujian Pencatatan Audit & Isolasi Integritas Log

-- 1. Jalankan UPDATE dan DELETE sebagai app_portal pada tenant 1
BEGIN;
SET LOCAL ROLE app_portal;
SET LOCAL app.tenant = '1';

UPDATE lab11.pelanggan SET kota = 'Medan' WHERE id = 3;

INSERT INTO lab11.pelanggan (id, tenant_id, nama, nik, surel, lahir, kota, saldo)
VALUES (99999, 1, 'Uji Audit', '1271000000000099', 'uji@test.id', '2000-01-01', 'Medan', 0);

DELETE FROM lab11.pelanggan WHERE id = 99999;
COMMIT;

-- 2. Verifikasi isi jejak_audit sebagai superuser
SELECT id, waktu, pelaku, peran_aktif, aksi, tabel, kunci,
       nilai_lama->>'kota' AS kota_lama,
       nilai_baru->>'kota' AS kota_baru
FROM lab11.jejak_audit
ORDER BY id;

-- 3. Buktikan app_portal tidak bisa membaca maupun menghapus/memalsukan audit
SET ROLE app_portal;
-- SELECT * FROM lab11.jejak_audit; -- Akan gagal: permission denied
-- DELETE FROM lab11.jejak_audit;   -- Akan gagal: permission denied
RESET ROLE;
