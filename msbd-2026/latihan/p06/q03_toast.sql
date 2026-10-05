SELECT 
    attname AS nama_kolom, 
    format_type(atttypid, atttypmod) AS tipe_data, 
    attstorage AS strategi_storage
FROM pg_attribute 
WHERE attrelid = 'lab6.event_log'::regclass 
  AND attnum > 0 
  AND NOT attisdropped;