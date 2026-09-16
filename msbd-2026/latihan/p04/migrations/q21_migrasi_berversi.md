# Q21 · Migrasi Berversi dan Rollback

## Enam pasang migrasi

| # | up | down | Fase | Isi |
|---|----|------|------|-----|
| 0041 | `0041_expand_buat_harga_film.up.sql` | `.down.sql` | Expand | Buat `lab4.harga_film` + `EXCLUDE` gist |
| 0042 | `0042_expand_trigger_tulis_ganda.up.sql` | `.down.sql` | Expand | Trigger tulis ganda `film` → `harga_film` |
| 0043 | `0043_migrate_backfill.up.sql` | `.down.sql` | Migrate | Backfill bertahap 1000 film/batch, commit per batch |
| 0044 | `0044_migrate_verifikasi.up.sql` | `.down.sql` | Migrate | `RAISE EXCEPTION` jika backfill belum nol |
| 0045 | `0045_contract_view_fasad.up.sql` | `.down.sql` | Contract | Rename `film`→`film_dasar` + `CREATE VIEW film` atomik |
| 0046 | `0046_contract_drop_kolom_lama.up.sql` | `.down.sql` | Contract | Drop trigger + drop kolom `rental_rate` lama |

Tautan commit: _(isi setelah push ke cabang `latihan/p04-sql2`)_

## Refleksi E

**Jarak rilis antara 0045 dan 0046.** Diusulkan minimal satu siklus rilis penuh
plus satu periode observasi produksi (contoh: 1–2 minggu), bukan langsung
berurutan dalam deploy yang sama. 0045 sudah membuat pembaca lama berfungsi
normal lewat view fasad, jadi tidak ada tekanan untuk buru-buru menjalankan
0046 — sementara 0046 adalah satu-satunya langkah yang **tidak bisa
sepenuhnya diurungkan** (lihat catatan rollback di soal dan di
`0046_contract_drop_kolom_lama.down.sql`).

**Bukti yang harus dikumpulkan sebelum menjalankan 0046:**

1. Query terhadap log akses/metrik aplikasi membuktikan tidak ada lagi jalur
   kode yang menulis langsung ke kolom `rental_rate` pada `lab4.film_dasar`
   (semua penulisan sudah lewat jalur yang memicu trigger tulis ganda, atau
   sudah dipindah untuk menulis ke `harga_film` langsung).
2. Perbandingan nilai `rental_rate` yang dibaca lewat view fasad (`lab4.film`)
   dengan nilai lama sebelum 0045, untuk sampel/semua film, menunjukkan nol
   selisih — membuktikan `harga_film` benar-benar konsisten dengan sumber
   lama sebelum sumber lama dibuang.
3. Tidak ada laporan galat "relation/column does not exist" dari
   aplikasi/pembaca selama periode observasi setelah 0045 aktif.
4. Query eksplisit `SELECT count(*) FROM lab4.film_dasar WHERE rental_rate IS
   DISTINCT FROM (SELECT harga FROM lab4.harga_film WHERE ...)` menghasilkan
   nol, dijalankan berulang (bukan sekali) menjelang jadwal 0046.

Hanya setelah keempat bukti ini terkumpul dan didokumentasikan di
`laporan.md`, 0046 aman dijalankan.
