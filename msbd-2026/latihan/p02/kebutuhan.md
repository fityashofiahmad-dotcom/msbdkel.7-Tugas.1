## Nama Domain: 
Sistem Manajemen Festival Musik

## Alasan pngambilan domain tersebut:


## Lingkup.

| Termasuk | Tidak termasuk |
| Pengelolaan data venue dan kapasitas panggung | Pengadaan fisik atau logistik venue |
| Manajemen data artis dan penjadwalan manggung | Manajemen kontrak atau rider artis |
| Penjualan tiket festival dan kuota | Gerbang pembayaran (payment gateway) eksternal |
| Validasi pencegahan jadwal bentrok artis | Pengiriman fisik merchandise ke kurir |
| Pemesanan merchandise pre-order terkait tiket | Pengelolaan gaji kru atau panitia event |

## Kebutuhan Data.

1. KD-01 Manajemen Venue
* **Deskripsi: Pencatatan data lokasi, nama panggung, dan batas maksimal kapasitas penonton.
* **Data: id_venue, nama_venue, nama_panggung, kapasitas_maksimal, lokasi.
* **Aturan: Kapasitas maksimal venue harus bernilai positif dan menjadi acuan validasi kuota tiket event.
* **Volume: ±10 data venue.
* **Sumber: Hasil analisis sistem tiket konser.
* **Prioritas: Wajib.

2. KD-02 Manajemen Artist
* **Deskripsi: Pendataan profil musisi atau pengisi acara yang akan tampil dalam festival.
* **Data: id_artist, nama_artist, genre_musik, asal_negara, rider_info
* **Aturan: Setiap artis wajib memiliki identifikasi unik untuk keperluan relasi lineup event.
* **Volume: ±50 data artist.
* **Sumber: Hasil analisis sistem tiket konser.
* **Prioritas: Wajib.

3. KD-03 Manajemen Event
* **Deskripsi: pencatatan informasi utama konser atau festival musik yang diselenggarakan.
* **Data: id_event, nama_event, tanggal_mulai, tanggal_selesai, deskripsi_event.
* **Aturan: tanggal selesai event tidak boleh lebih awal dari tanggal mulai event.
* **Volume: ±5 event per tahun.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: wajib.

4. KD-04 Lineup Artist dan Event (Many-to-Many)
* **Deskripsi: penghubung relasi antara artis yang tampil pada suatu event konser tertentu.
* **Data: id_lineup, id_event, id_artist, status_tampil.
* **Aturan: satu event dapat menampilkan banyak artis, dan satu artis bisa tampil di event berbeda.
* **Volume: ±100 relasi lineup/event.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: wajib.

5. KD-05 Jadwal Panggung (Stage_Schedule)
* **Deskripsi: pengaturan jadwal spesifik jam tampil artis pada venue tertentu dengan validasi bentrok.
* **Data: id_schedule, id_event, id_artist, id_venue, jam_mulai, jam_selesai.
* **Aturan: seorang artist tidak boleh dijadwalkan tampil di venue dan jam yang tumpang tindih meskipun di event berbeda; sistem wajib memvalidasi bentrok waktu secara otomatis.
* **Volume: ±80 jadwal per event.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: wajib.

6. KD-06 Manajemen Customer
* **Deskripsi: pencatatan data diri pembeli tiket konser atau festival.
* **Data: id_customer, nama_lengkap, email, nomor_telepon, alamat.
* **Aturan: alamat email customer harus unik dan valid untuk pengiriman e-ticket.
* **Volume: ±5.000 data customer.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: wajib.

7. KD-07 Transaksi Ticket
* **Deskripsi: pencatatan pembelian tiket oleh customer dengan aturan kuota dan harga dinamis.
* **Data: id_ticket, id_customer, id_event, jenis_tiket, harga_beli, status_kuota, tanggal_pesan.
* **Aturan: jumlah tiket terjual pada suatu venue di event tertentu tidak boleh melebihi kapasitas maksimal venue; harga tiket otomatis berubah jika kuota early-bird habis.
* **Volume: ±3.000 transaksi tiket/event.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: wajib.

8. KD-08 Manajemen Merchandise
* **Deskripsi: pendataan atribut band atau festival yang dijual kepada penonton.
* **Data: id_merchandise, nama_item, jenis_item, harga_satuan, stok_tersedia.
* **Aturan: stok merchandise harus diperbarui secara otomatis setiap kali ada transaksi pre-order terikat tiket.
* **Volume: ±20 jenis merchandise.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: pendukung.

9. KD-09 Pemesanan Merchandise Pre-Order (Many-to-Many)
* **Deskripsi: pencatatan pesanan merchandise yang dikaitkan langsung dengan data tiket pembeli.
* **Data: id_pesanan_merch, id_ticket, id_merchandise, jumlah_pesanan, total_harga.
* **Aturan: satu tiket bisa dipakai untuk memesan berbagai jenis merchandise, dan satu jenis merchandise bisa dipesan oleh banyak tiket dalam transaksi pre-order.
* **Volume: ±1.500 transaksi pre-order.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: pendukung.

10. KD-10 Validasi Kapasitas dan Kuota Venue
* **Deskripsi: proses pengecekan otomatis antara jumlah total tiket terjual terhadap kapasitas maksimal venue.
* **Data: d_event, id_venue, total_tiket_terjual, kapasitas_maksimal_venue, status_penuh.
* **Aturan: jika total tiket terjual mencapai kapasitas maksimal venue, sistem wajib menutup transaksi pembelian tiket baru untuk venue tersebut.
* **Volume: 1 kali per transaksi tiket masuk.
* **Sumber: hasil analisis sistem tiket konser.
* **Prioritas: wajib.