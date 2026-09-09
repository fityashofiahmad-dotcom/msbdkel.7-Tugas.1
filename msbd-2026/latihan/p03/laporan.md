## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |

| Andika Chairul Ilham | 251402047 | Langkah 4, Langkah 6, Reflektif B, Reflektif D, Laporan | Commit |
| Fahri Arizal | 251402102 | Langkah 5, Reflektif C, Laporan | Commit |
| Fitya Shofi Ahmad | 251402132 | Langkah 1, Langkah 2, Langkah 3, Reflektif A, Laporan | Commit |
| Mar'ie Rizqullah | 251402129 | Langkah 7, Langkah 8, Reflektif E, Laporan | Commit |

## Refleksi A - Subquery
1. Hal yang membuat NOT IN berbahaya adalah nilai NULL dimana seandainya nilai NULL terselip di dalam subquery walau hanya 1 maka seluruh query NOT IN bakal langsung gagal total dab gabisa balikin data apapun alias kosong melompong. kenapa bisa gitu? alasannya karna dalam SQL, kalau ada perbandingan yang ketemu sama NULL, hasilnya bakal jadi UNKNOWN atau ga diketahui yang otomatis bakal rusak logika dari NOT IN.
Cara ngeceknya adalah dengan cek aja apakah kolom yang dipakai di subquery itu punya data NULL atau enggak, contohnya bisa pakai query SELECT COUNT(*) FROM nama_tabel WHERE kolom IS NULL;. Nah kalau angkanya lebih dari nol, berarti kolomnya itu rawan banget bikin NOT IN rusak.
2. Secara konseptual, subquery yang berkorelasi itu dievaluasi sekali untuk setiap 1 baris di tabel luar. Sedangkan kenyataannya, postgreSQL ini udah canggih banget karna dia udah punya query optimizer. Jadi, PostgreSQL ga bakal bener-bener jalanin perulangan satu-satu secara haarfiah, melainkan bakal otomatis ubah atau gabungin prosesnya jadi teknik yang jauh lebih cepet supaya eksekusinya efisien tanpa bikin CPU kerja 2x lipat.

## Refleksi B - CTE dan Recursive CTE
**Mengapa recursive term hanya melihat baris yang baru dihasilkan pada iterasi sebelumnya, dan
apa akibatnya jika ia melihat seluruh hasil?**
 
Recursive CTE di PostgreSQL dieksekusi sebagai proses berulang: setiap iterasi hanya
menggabungkan (JOIN) recursive term terhadap *working table* yang berisi baris-baris yang baru
saja dihasilkan pada iterasi sebelumnya — bukan seluruh hasil yang sudah terkumpul sejak awal.
Ini sesuai definisi standar SQL untuk recursive query: setiap langkah maju hanya "melangkah satu
level" dari titik terakhir. Jika recursive term dipaksa melihat seluruh hasil yang sudah
terkumpul (bukan hanya baris baru), setiap iterasi akan memproses ulang baris-baris yang
sebelumnya sudah pernah diproses. Akibatnya jumlah baris yang dihasilkan bisa membengkak secara
eksponensial (baris yang sama dipasangkan ulang berkali-kali pada level berikutnya), query jadi
jauh lebih lambat, dan pada struktur yang cukup dalam bisa terasa seperti tidak pernah selesai
walau datanya sendiri tidak bersiklus.
 
**Kapan mengganti UNION ALL dengan UNION dapat menghentikan siklus, dan mengapa itu tetap bukan
solusi yang baik?**
 
UNION (tanpa ALL) membuang baris duplikat, sehingga rekursi berhenti ketika suatu iterasi tidak
lagi menghasilkan baris baru yang berbeda dari baris yang sudah ada — jika siklus data membuat
baris yang identik di SEMUA kolom terus terulang, UNION akan mendeteksinya sebagai duplikat dan
tidak menambahkannya lagi, sehingga rekursi akhirnya berhenti. Meski begitu, ini bukan solusi
yang baik karena tiga alasan: pertama, ia hanya bekerja jika baris yang berulang benar-benar
identik di semua kolom — begitu ada kolom seperti "jalur" yang terus bertambah panjang tiap
iterasi (seperti pada Q7/Q9), setiap baris menjadi unik walau pegawai_id-nya berputar, sehingga
UNION tidak pernah mendeteksi duplikat dan siklus tetap tidak berhenti. Kedua, walau berhasil
menghentikan rekursi, ia menyembunyikan masalah data yang sesungguhnya (adanya siklus/loop pada
struktur atasan-bawahan) alih-alih mendeteksi dan melaporkannya secara eksplisit seperti pada
pendekatan jalur array atau klausa CYCLE. Ketiga, pemeriksaan duplikat UNION membandingkan
seluruh kolom pada setiap iterasi, yang lebih mahal dibanding pengecekan keanggotaan sederhana
pada array jalur.
 
## Refleksi C - Window Function
1. Mengapa terdapat 34 tanggal yang berbeda dan sifat data apa yang memengaruhinya?
Perbedaan sebanyak 34 baris/tanggal tersebut terjadi karena sifat data pada tabel payment yang memiliki banyak transaksi pada tanggal atau waktu yang identik (nilai duplikat pada kolom pengurutan). Klausa default RANGE memperlakukan baris-baris dengan nilai urut yang sama sebagai peer (kelompok setara) dan menyertakan semuanya sekaligus dalam perhitungan jendela. Sebaliknya, klausa ROWS menghitung secara fisik baris demi baris secara ketat berdasarkan urutan fisik tanpa peduli apakah nilai datanya sama atau tidak.

2. Versi mana yang benar untuk laporan keuangan resmi dan mengapa kesalahan frame sulit ditemukan?
Untuk laporan keuangan resmi, versi yang benar adalah menggunakan frame ROWS yang eksplisit. Kesalahan akibat menggunakan default RANGE sangat sulit ditemukan melalui pengujian fungsional biasa karena query tetap berjalan sukses tanpa menghasilkan error SQL. Namun, secara diam-diam kesalahan ini merusak akurasi karena nilai rata-rata bergerak atau kumulatif akan melompat (jump) ketika menemui tanggal transaksi yang sama.

3. Apa yang terjadi pada total belanja di Q15 jika ORDER BY ditambahkan ke OVER tanpa frame?
Jika klausa ORDER BY ditambahkan ke dalam OVER() tanpa mendefinisikan batas frame secara eksplisit, PostgreSQL secara otomatis menerapkan default frame yaitu RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. Akibatnya, kolom total belanja berubah fungsi menjadi running total (kumulatif belanja berjalan per baris transaksi), sehingga tidak lagi menampilkan total keseluruhan belanja pelanggan secara utuh di setiap barisnya.

## Temuan Q14
- **Jumlah baris/tanggal yang berbeda:** Sebanyak **34 baris**.
- **Penjelasan Teknis:** Perbedaan ini timbul karena perbedaan perlakuan antara frame berbasis baris fisik (`ROWS`) dan frame berbasis rentang nilai (`RANGE`). Pada tabel `payment`, ada banyak transaksi yang terjadi pada hari yang sama. `RANGE` menggabungkan kelompok tanggal yang sama sebagai satu kesatuan nilai (peer), sedangkan `ROWS` memperlakukan setiap baris secara terpisah berdasarkan urutan eksekusinya. Hal ini menyebabkan hasil agregasi seperti rata-rata bergerak 7 hari (`rerata_7hari`) pada tanggal-tanggal tersebut menghasilkan angka yang berbeda.

## Refleksi D - Agregasi dan Operasi Himpunan
**Pada Q16, tanpa GROUPING(), bagaimana pembaca membedakan subtotal dari baris data yang
kolomnya memang kosong?**
 
Tanpa GROUPING(), nilai NULL yang dihasilkan ROLLUP untuk baris subtotal/grand-total tidak bisa
dibedakan dari NULL yang memang ada secara alami pada data sumber — misalnya pada Pagila memang
ada film dengan rating bernilai NULL (belum diberi rating MPAA). Kedua kasus itu sama-sama
tampil sebagai NULL pada kolom rating, sehingga pembaca laporan tidak bisa tahu apakah baris itu
"subtotal seluruh rating untuk satu kategori" atau "baris data asli untuk film-film yang memang
tidak memiliki rating". GROUPING(kolom) menyelesaikan ini karena ia mengembalikan 1 khusus untuk
baris super-agregat (di mana nilai kolom itu memang sengaja "diciutkan" oleh ROLLUP) dan 0 untuk
baris nilai asli — termasuk ketika nilai asli itu sendiri kebetulan NULL — sehingga ambiguitasnya
hilang sepenuhnya.
 
**Pada Q17, mengapa versi FILTER dan CASE WHEN dapat memberi rata-rata berbeda walaupun jumlah
baris sama?**
 
Selama versi CASE WHEN ditulis tanpa klausa ELSE (`CASE WHEN kondisi THEN nilai END`), hasilnya
identik dengan FILTER: baris yang tidak memenuhi syarat menghasilkan NULL, dan AVG secara bawaan
mengabaikan NULL saat menghitung rata-rata — sama seperti FILTER yang mengecualikan baris
tersebut dari agregat sama sekali. Perbedaan rata-rata baru muncul jika CASE WHEN ditulis DENGAN
ELSE yang memetakan baris tak memenuhi syarat ke suatu nilai nyata, misalnya
`avg(CASE WHEN f.length > 90 THEN f.length ELSE 0 END)`. Pada kasus itu, jumlah baris yang
"dihitung" oleh AVG tetap sama, tetapi baris yang seharusnya dikecualikan justru ikut menyumbang
nilai 0 ke dalam rata-rata, sehingga hasilnya turun dibanding versi FILTER. Jadi perbedaan
sesungguhnya bukan dari pilihan FILTER vs CASE WHEN itu sendiri, melainkan dari ada-tidaknya
ELSE pada versi CASE WHEN — sebuah jebakan yang mudah luput saat menulis agregat kondisional.
 

## Refleksi E - JSONB
Dari atribut di dalam payload (nomor transaksi, status, jumlah, dan identitas pelanggan):

Yang sebaiknya dipromosikan menjadi kolom relasional (dengan constraint): Kolom seperti status (dengan CHECK constraint) dan jumlah (tipe data numerik), serta relasi pelanggan_id sebagai Foreign Key. Alasan: Atribut-atribut ini sering menjadi subjek utama operasi relasional berfrekuensi tinggi seperti pemfilteran (WHERE), pengurutan, agregasi matematis (SUM, AVG), serta membutuhkan integritas data yang ketat melalui constraints.

Yang tepat tetap berada di JSON: Atribut semi-terstruktur seperti array kontak (berisi daftar jenis dan nomor kontak yang jumlahnya bisa dinamis atau berbeda tiap transaksi). Alasan: Struktur bersarang (nested array) lebih fleksibel disimpan dalam format JSONB jika skemanya sering berkembang atau tidak seragam, sehingga menghindarkan kebutuhan pembuatan tabel relasional anak (relasi one-to-many) yang berlebihan untuk data pelengkap.

## Hasil R1
![Sepuluh baris pertama](r1_10_bars/png)

## Tautan Merge Request
...
