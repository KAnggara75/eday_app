# Perencanaan Fitur: Guideline Kamera (Onion Skinning) dari GitHub

## Deskripsi Tugas
Tugas ini bertujuan untuk menambahkan fitur panduan bayangan (guideline/onion skinning) secara live saat pengguna membuka kamera.
Panduan yang ditampilkan menggunakan berkas gambar terakhir yang selalu ku-pull dari GitHub (berasal dari tautan mentah Github).
Karena linknya statis tapi gambar selalu diperbarui (*update* rutin di server), kita harus memastikan sisi aplikasi selalu mengunduh versi yang terbaru dan menghindari mekanisme *cache* bawaan.

**URL Sumber Gambar:**
[https://raw.githubusercontent.com/KAnggara75/everyday/main/timelapse/last.jpg](https://raw.githubusercontent.com/KAnggara75/everyday/main/timelapse/last.jpg)

## Ruang Lingkup Pengerjaan (To-Do List)

- [ ] **1. Fetch Image tanpa Cache**
  - Minta gambar `last.jpg` dari URL raw GitHub di atas.
  - Tambahkan parameter unik seperti timestamp (Contoh: `?v=<timestamp>`) di ujung string URL agar framework tidak menggunakan berkas *cache* yang lama.

- [ ] **2. Tampilkan sebagai Overlay di Kamera**
  - Buka file `lib/camera_screen.dart` dan posisikan di dalam `Stack` yang merender widget `CameraPreview`.
  - Letakkan fungsi `Image.network()` tersebut persis di DEPAN layer `CameraPreview()`.
  - Pastikan dimensi bayangan (*image overlay*) menggunakan `AspectRatio(aspectRatio: 3 / 2)` dan `BoxFit.cover` agar ukurannya nge-pas sempurna (sinkron 1:1) dengan area pratinjau yang akan dijepret.

- [ ] **3. Atur Transparansi (Opacity)**
  - Bungkus `Image.network` dengan `Opacity`.
  - Set level opasitas sekitar `0.4` hingga `0.5`. Hasil akhirnya pengguna akan melihat muka/postur mereka langsung dan dibayangi transparan oleh wujud gambar hari kemarin.
  - Bungkus juga dengan properti pengananganan *error* `errorBuilder` (misalnya kembali mengembalikan `SizedBox.shrink()` jika file di repositori sewaktu-waktu tak bisa dijangkau).

- [ ] **4. Uji Coba UI (Testing)**
  - Pastikan pratinjau (*preview*) kamera tidak terhalang atau tak dapat dipencet alias error overlay.
  - (*Opsional/Bonus*) Pertimbangkan menambahkan tombol toggle transparan (ikon mata) agar panduan bisa dimatikan atau dinyalakan sesuai kebutuhan!

## Berkas yang Diubah
* `lib/camera_screen.dart` -> Menambahkan widget overlay & network image.
