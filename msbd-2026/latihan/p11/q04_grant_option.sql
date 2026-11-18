-- Diminta: GRANT OPTION berantai ke app_analitik, lalu REVOKE tanpa dan dengan CASCADE.
-- Dipilih: REVOKE GRANT OPTION FOR, supaya hak baca app_write tetap ada.
-- Alternatif: REVOKE SELECT penuh dari app_write; tidak dipilih karena ikut mencabut hak bacanya.
GRANT SELECT ON lab11.transaksi TO app_write WITH GRANT OPTION;
SET ROLE app_write;
GRANT SELECT ON lab11.transaksi TO app_analitik;
RESET ROLE;
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write;            -- amati galatnya
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write CASCADE;    -- lalu bandingkan
SELECT has_table_privilege('app_analitik','lab11.transaksi','SELECT') AS analitik,
       has_table_privilege('app_write','lab11.transaksi','SELECT')    AS app_write;