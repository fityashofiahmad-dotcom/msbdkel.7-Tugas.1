SELECT indexrelid::regclass AS index,
       pg_relation_size(indexrelid) AS byte,
       pg_size_pretty(pg_relation_size(indexrelid)) AS ukuran
FROM pg_index
WHERE indexrelid::regclass::text IN ('lab6.ev_salah_idx','lab6.ev_benar_idx');
