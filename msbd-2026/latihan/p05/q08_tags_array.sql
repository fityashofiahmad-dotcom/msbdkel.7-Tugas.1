Diminta: Mengisi tags dengan

tiga nilai dan mencari baris menggunakan operator array. -- Dipilih: Menggunakan operator

ANY(tags) untuk mencocokkan nilai persis di dalam elemen array. -- Alternatif: Menggunakan operator @> (contains); tidak dipilih agar tetap selaras dengan bentuk query pada modul instruksi.

UPDATE lab5.rental_tx SET tags

= ARRAY['promo', 'akhir-pekan', 'anggota'] WHERE rental_id = 1; SELECT rental_id, tags FROM lab5.rental_tx WHERE 'promo' = ANY(tags);
