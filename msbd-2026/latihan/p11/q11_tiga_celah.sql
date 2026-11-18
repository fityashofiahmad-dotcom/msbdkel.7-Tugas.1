-- Diminta: tiga cara isolasi RLS masih bisa gagal, masing-masing dengan satu kalimat perbaikan, dan bukti nyata.
-- Dipilih: pemilik tanpa FORCE, peran BYPASSRLS/superuser, dan konteks bocor di pool; bukti dari Q9 dan Q10.
-- Alternatif: celah lain (view tanpa security_invoker, kebijakan tanpa WITH CHECK); dibahas singkat saja.
--
-- Celah 1: pemilik tabel melewati RLS bila tidak ada FORCE.            Perbaikan: FORCE ROW LEVEL SECURITY.
-- Celah 2: peran dengan BYPASSRLS atau superuser kebal kebijakan.      Perbaikan: audit pg_roles, jangan beri BYPASSRLS.
-- Celah 3: setelan tingkat sesi tertinggal di kolam koneksi.           Perbaikan: SET LOCAL / set_config(..., true).

-- Bukti kondisi saat ini (celah 1 dan 2 bisa dideteksi dari katalog)
SELECT rolname, rolsuper, rolbypassrls FROM pg_roles WHERE rolsuper OR rolbypassrls ORDER BY 1;
SELECT relname, relrowsecurity, relforcerowsecurity
FROM pg_class WHERE relnamespace = 'lab11'::regnamespace AND relkind = 'r' ORDER BY 1;