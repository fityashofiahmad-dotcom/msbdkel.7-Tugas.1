-- Q19: FOR UPDATE, Sesi B menunggu
-- Sesi A
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- Sesi B
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;          -- menunggu
-- (opsional, tab ketiga)
-- SELECT pid, state, wait_event_type, wait_event, query
-- FROM pg_stat_activity WHERE datname = current_database();
-- Sesi A
COMMIT;
-- Sesi B
COMMIT;
