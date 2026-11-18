-- Diminta: tabel tujuh peran pada lab11, kemampuan masing-masing, dan tanda yang bisa login.
-- Dipilih: diambil dari katalog sistem (pg_roles, hak tabel), bukan ditulis dari ingatan.
-- Alternatif: menyalin dari dokumentasi modul; tidak dipilih karena bisa berbeda dari kondisi nyata.
SELECT r.rolname, r.rolcanlogin AS bisa_login, r.rolsuper, r.rolbypassrls,
       (SELECT string_agg(g.rolname, ', ') FROM pg_auth_members m
          JOIN pg_roles g ON g.oid = m.roleid WHERE m.member = r.oid) AS anggota_dari
FROM pg_roles r
WHERE r.rolname = 'skema_owner' OR r.rolname LIKE 'app\_%'
ORDER BY 1;

SELECT grantee, table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS hak
FROM information_schema.role_table_grants
WHERE table_schema = 'lab11' AND grantee <> 'skema_owner'
GROUP BY 1, 2 ORDER BY 1, 2;

SELECT tablename, tableowner FROM pg_tables WHERE schemaname = 'lab11' ORDER BY 1;