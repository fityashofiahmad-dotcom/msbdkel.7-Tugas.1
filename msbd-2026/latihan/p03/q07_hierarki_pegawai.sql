-- Diminta: seluruh pegawai beserta level kedalaman dan jalur jabatan dari puncak, misalnya
--   Rina > Bima > Toni.
-- Dipilih: recursive CTE dengan anchor atasan_id IS NULL (level = 1), recursive term meng-JOIN
--   pegawai ke hasil iterasi sebelumnya lewat p.atasan_id = h.pegawai_id, jalur dibentuk dengan
--   penggabungan string bertahap.
-- Alternatif: self-join berulang manual per level tetap (p1 JOIN p2 JOIN p3 ...); tidak dipilih
--   karena kedalaman hierarki tidak diketahui di muka dan tidak fleksibel bila struktur berubah.

WITH RECURSIVE hierarki AS (
    SELECT pegawai_id, nama, atasan_id, 1 AS level, nama::text AS jalur
    FROM pegawai
    WHERE atasan_id IS NULL

    UNION ALL

    SELECT p.pegawai_id, p.nama, p.atasan_id, h.level + 1, h.jalur || ' > ' || p.nama
    FROM pegawai p
    JOIN hierarki h ON p.atasan_id = h.pegawai_id
)
SELECT pegawai_id, nama, level, jalur
FROM hierarki
ORDER BY jalur;