-- Q28: Tabel Pencatatan Permintaan Penghapusan Subjek Data (Tenggat 72 Jam)
CREATE TABLE lab11.permintaan_hapus (
  id            serial PRIMARY KEY,
  subjek_id     int NOT NULL,
  alasan        text NOT NULL,
  diterima_pada timestamptz NOT NULL DEFAULT now(),
  tenggat       timestamptz NOT NULL DEFAULT now() + interval '72 hours',
  selesai_pada  timestamptz,
  status        text NOT NULL DEFAULT 'DIPROSES'
);

-- Verifikasi struktur kolom dan nilai default
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'lab11' AND table_name = 'permintaan_hapus';
