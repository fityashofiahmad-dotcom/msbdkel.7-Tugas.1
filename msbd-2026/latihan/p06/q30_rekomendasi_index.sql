-- Q30: Eksekusi konsolidasi rekomendasi akhir (DROP / CREATE)
-- Contoh aksi penghapusan indeks yang redundan atau tidak terpakai
DROP INDEX IF EXISTS lab6.ev_status_idx; -- Dihapus karena idx_scan rendah/efisiensi buruk pada status dominan
