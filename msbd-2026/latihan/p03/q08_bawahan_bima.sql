-- Diminta: seluruh bawahan langsung maupun tidak langsung dari pegawai bernama Bima, beserta
--   jaraknya dari Bima.
-- Dipilih: recursive CTE dengan anchor disaring pada nama = 'Bima' (jarak 0), recursive term
--   menambah 1 pada jarak untuk setiap level bawahan berikutnya.
-- Alternatif: menjalankan Q7 lalu memfilter jalur yang mengandung teks 'Bima'; tidak dipilih
--   karena pencocokan substring pada kolom jalur rawan salah tangkap (mis. nama lain yang
--   kebetulan memuat potongan teks yang sama).

WITH RECURSIVE bawahan_bima AS (
    SELECT pegawai_id, nama, atasan_id, 0 AS jarak
    FROM pegawai
    WHERE nama = 'Bima'

    UNION ALL

    SELECT p.pegawai_id, p.nama, p.atasan_id, b.jarak + 1
    FROM pegawai p
    JOIN bawahan_bima b ON p.atasan_id = b.pegawai_id
)
SELECT pegawai_id, nama, jarak
FROM bawahan_bima
WHERE jarak > 0
ORDER BY jarak, nama;