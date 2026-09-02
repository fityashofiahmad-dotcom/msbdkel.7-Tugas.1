
---

## Pertanyaan 6
**Soal:** Catat apa yang terlihat pada pg_stat_activity. Perintah mana yang menunggu? Apa akibatnya jika kondisi tersebut terjadi pada basis data produksi saat banyak pengguna sedang mengakses sistem?

**Jawaban:**
*   **Apa yang terlihat:** Terdapat antrean proses. Transaksi dari Terminal 1 berstatus `idle in transaction` (menahan kunci), sementara query dari Terminal 2 memiliki `wait_event_type` berupa `Lock` dengan `state` berstatus `active` (menunggu).
*   **Perintah yang menunggu:** Perintah DDL `ALTER TABLE peminjaman...` dari Terminal 2.
*   **Akibat pada sistem produksi:** Terjadi efek *Lock Stampede*. Perintah `ALTER TABLE` membutuhkan *Access Exclusive Lock* sehingga harus antre di belakang Terminal 1. Bahayanya, setiap query pengguna lain yang masuk *setelah* `ALTER TABLE` tersebut juga akan ikut dipaksa mengantre. Akibatnya sistem akan macet (*hang*), koneksi menumpuk, dan aplikasi bisa *down* sampai transaksi awal di-commit/rollback.