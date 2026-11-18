-- Diminta: mengukur waktu eksekusi gen_salt('bf', 6), gen_salt('bf', 10), dan
--          md5(), lalu menjelaskan mengapa fungsi yang lambat justru benar.
-- Dipilih: pengukuran selisih clock_timestamp() (ditambah \timing on di psql)
--          untuk membandingkan biaya kerja tiap algoritma hashing.
-- Alternatif: memakai MD5/SHA-256 mentah demi kecepatan login; tidak dipilih
--             karena memudahkan brute-force GPU hingga miliaran tebakan/detik.

\timing on

DO $$
DECLARE
    t0 timestamptz;
    t1 timestamptz;
    t2 timestamptz;
    t3 timestamptz;
BEGIN
    t0 := clock_timestamp();
    PERFORM md5('SandiRahasia#2026');
    t1 := clock_timestamp();
    PERFORM crypt('SandiRahasia#2026', gen_salt('bf', 6));
    t2 := clock_timestamp();
    PERFORM crypt('SandiRahasia#2026', gen_salt('bf', 10));
    t3 := clock_timestamp();

    RAISE NOTICE 'Waktu md5()             : %', (t1 - t0);
    RAISE NOTICE 'Waktu gen_salt(bf, 6)   : %', (t2 - t1);
    RAISE NOTICE 'Waktu gen_salt(bf, 10)  : %', (t3 - t2);
END;
$$;

-- Penjelasan mengapa yang lambat justru benar untuk kata sandi:
-- MD5 dirancang sangat cepat untuk cek integritas berkas, sehingga perangkat keras
-- modern (GPU) dapat mencoba miliaran kombinasi kata sandi per detik saat
-- melakukan brute-force offline. Algoritma key-stretching adaptif seperti bcrypt
-- dengan cost 10 (2^10 = 1.024 iterasi) sengaja memperlambat setiap perhitungan:
-- jeda puluhan milidetik nyaris tidak terasa oleh pengguna yang login sesekali,
-- tetapi membuat serangan brute-force miliaran tebakan menjadi tidak layak secara
-- waktu dan biaya komputasi.
