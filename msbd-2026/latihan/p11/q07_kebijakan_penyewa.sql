-- Diminta: sepasang kebijakan isolasi penyewa memakai nullif(current_setting('app.tenant', true), '')::int.
-- Dipilih: satu kebijakan baca (app_read, app_write) dan satu kebijakan FOR ALL dengan WITH CHECK (app_write).
-- Alternatif: current_setting(...)::int langsung; tidak dipilih karena melempar galat pada koneksi yang dipakai ulang.
DROP POLICY IF EXISTS p_tenant_baca  ON lab11.pelanggan;
DROP POLICY IF EXISTS p_tenant_tulis ON lab11.pelanggan;

CREATE POLICY p_tenant_baca ON lab11.pelanggan
  FOR SELECT TO app_read, app_write
  USING (tenant_id = nullif(current_setting('app.tenant', true), '')::int);

CREATE POLICY p_tenant_tulis ON lab11.pelanggan
  FOR ALL TO app_write
  USING      (tenant_id = nullif(current_setting('app.tenant', true), '')::int)
  WITH CHECK (tenant_id = nullif(current_setting('app.tenant', true), '')::int);

SELECT policyname, cmd, roles FROM pg_policies
WHERE schemaname = 'lab11' AND tablename = 'pelanggan' ORDER BY 1;