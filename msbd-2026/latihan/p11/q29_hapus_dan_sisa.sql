-- Q29: Eksekusi Permintaan Penghapusan & Pelacakan Sisa Data Subjek

-- 1. Catat permintaan penghapusan subjek ID 12 dan 13
INSERT INTO lab11.permintaan_hapus (subjek_id, alasan)
VALUES (12, 'Permintaan penghapusan akun oleh subjek data'),
       (13, 'Permintaan penghapusan akun oleh subjek data');

-- 2. Hapus transaksi terkait lalu hapus data pelanggan
DELETE FROM lab11.transaksi WHERE pelanggan_id IN (12, 13);
DELETE FROM lab11.pelanggan WHERE id IN (12, 13);

-- 3. Perbarui status permintaan penghapusan
UPDATE lab11.permintaan_hapus
SET status = 'SELESAI', selesai_pada = now()
WHERE subjek_id IN (12, 13);

-- 4. Periksa di mana saja data subjek masih hidup
SELECT count(*) AS sisa_tabel_utama FROM lab11.pelanggan WHERE id IN (12,13);
SELECT count(*) AS sisa_transaksi   FROM lab11.transaksi WHERE pelanggan_id IN (12,13);
SELECT count(*) AS sisa_jejak_audit FROM lab11.jejak_audit
WHERE kunci IN ('12','13') AND nilai_lama ? 'nik';
