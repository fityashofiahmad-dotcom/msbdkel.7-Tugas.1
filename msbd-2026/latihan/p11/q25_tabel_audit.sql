-- Q25: Tabel Jejak Audit & Trigger SECURITY DEFINER
CREATE TABLE lab11.jejak_audit (
  id          bigserial PRIMARY KEY,
  waktu       timestamptz NOT NULL DEFAULT now(),
  pelaku      text NOT NULL DEFAULT session_user,
  peran_aktif text NOT NULL DEFAULT current_user,
  aksi        text NOT NULL,
  tabel       text NOT NULL,
  kunci       text,
  nilai_lama  jsonb,
  nilai_baru  jsonb
);

CREATE OR REPLACE FUNCTION lab11.rekam_audit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = lab11, pg_temp
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO lab11.jejak_audit(aksi, tabel, kunci, nilai_baru)
    VALUES (TG_OP, TG_TABLE_NAME, NEW.id::text, to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO lab11.jejak_audit(aksi, tabel, kunci, nilai_lama, nilai_baru)
    VALUES (TG_OP, TG_TABLE_NAME, NEW.id::text, to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO lab11.jejak_audit(aksi, tabel, kunci, nilai_lama)
    VALUES (TG_OP, TG_TABLE_NAME, OLD.id::text, to_jsonb(OLD));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_audit_pelanggan
AFTER INSERT OR UPDATE OR DELETE ON lab11.pelanggan
FOR EACH ROW EXECUTE FUNCTION lab11.rekam_audit();

-- Cabut semua hak langsung dari peran aplikasi agar log tidak bisa dipalsukan/dibaca
REVOKE ALL ON lab11.jejak_audit FROM PUBLIC, app_read, app_write, app_portal, app_laporan, app_analitik;
