-- Q24: Analisis Generalisasi (k-anonymity) & Differencing Attack

-- 1. Kombinasi unik (kota, lahir) sebelum generalisasi
SELECT count(*) AS kombinasi_unik_asli
FROM (
  SELECT kota, lahir
  FROM lab11.pelanggan
  GROUP BY kota, lahir
  HAVING count(*) = 1
) sub;

-- 2. Kombinasi unik (kota, lahir_tahun) setelah generalisasi
SELECT count(*) AS kombinasi_unik_samar
FROM (
  SELECT kota, date_trunc('year', lahir)
  FROM lab11.pelanggan
  GROUP BY 1, 2
  HAVING count(*) = 1
) sub;

-- 3. Sepasang query agregat (differencing attack) yang mengungkap 1 individu
SET ROLE app_analitik;
SELECT count(*) AS jumlah_total, sum(saldo_bulat) AS total_saldo
FROM lab11.v_pelanggan_samar
WHERE kota = 'Medan';

SELECT count(*) AS jumlah_tanpa_id15, sum(saldo_bulat) AS saldo_tanpa_id15
FROM lab11.v_pelanggan_samar
WHERE kota = 'Medan' AND id <> 15;
RESET ROLE;
