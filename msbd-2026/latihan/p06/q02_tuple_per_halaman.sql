SELECT 
    COUNT(*) AS total_baris,
    MAX(split_part(btrim(ctid::text, '()'), ',', 1)::bigint) + 1 AS total_halaman,
    ROUND(COUNT(*)::numeric / (MAX(split_part(btrim(ctid::text, '()'), ',', 1)::bigint) + 1), 2) AS rata_rata_tuple_per_halaman
FROM lab6.event_log;