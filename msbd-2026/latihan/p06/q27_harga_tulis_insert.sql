-- Q27: Mengukur performa INSERT pada tabel tanpa indeks vs dengan 5 indeks

-- 1. Buat tabel sementara TANPA indeks
CREATE TABLE lab6.event_log_no_idx (LIKE lab6.event_log INCLUDING DEFAULTS);

-- Ukur waktu INSERT 200.000 baris (Tabel Polos)
\timing on
INSERT INTO lab6.event_log_no_idx (customer_id, terjadi_pada, status, wilayah, kota, email, idempotency_key, jumlah, tags, payload)
SELECT customer_id, terjadi_pada, status, wilayah, kota, email, idempotency_key, jumlah, tags, payload
FROM lab6.event_log LIMIT 200000;

-- 2. Buat tabel sementara DENGAN 5 indeks
CREATE TABLE lab6.event_log_with_idx (LIKE lab6.event_log INCLUDING DEFAULTS);
CREATE INDEX ON lab6.event_log_with_idx (customer_id);
CREATE INDEX ON lab6.event_log_with_idx (terjadi_pada);
CREATE INDEX ON lab6.event_log_with_idx (status);
CREATE INDEX ON lab6.event_log_with_idx (email);
CREATE INDEX ON lab6.event_log_with_idx USING gin (tags);

-- Ukur waktu INSERT 200.000 baris (Tabel Berindeks)
INSERT INTO lab6.event_log_with_idx (customer_id, terjadi_pada, status, wilayah, kota, email, idempotency_key, jumlah, tags, payload)
SELECT customer_id, terjadi_pada, status, wilayah, kota, email, idempotency_key, jumlah, tags, payload
FROM lab6.event_log LIMIT 200000;
\timing off
