Diminta: Menyimpan JSONB berisi channel dan device, lalu mengambil nilai channel.

Dipilih: Memakai operator ->> agar PostgreSQL langsung mengembalikan nilainya sebagai teks murni.

Alternatif: Memakai operator ->; tidak dipilih karena kembaliannya masih berupa objek JSONB (masih mengikutkan tanda kutip).

UPDATE lab5.rental_tx SET metadata = '{"channel":"web","device":"andr oid"}'::jsonb WHERE rental_id = 1; SELECT rental_id, metadata ->> 'channel' AS kanal FROM lab5.rental_tx WHERE rental_id = 1;
