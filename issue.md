# Perencanaan Fitur: Sinkronisasi Galeri ke Repositori GitHub

## Deskripsi Tugas
Tugas ini bertujuan untuk menambahkan fungsionalitas **Sync (Sinkronisasi)** ke dalam aplikasi.
Pengguna dapat menekan sebuah tombol "Sync" yang akan menarik pembaruan (pull) dan mengunggah (push) foto-foto dari galeri lokal gawai (perangkat) ke repositori GitHub terpisah milik pengguna.

**Repositori Target:**
`https://github.com/KAnggara75/everyday`

**Struktur Folder Target Eksekusi:**
- Foto harus dikelompokkan ke dalam folder berdasarkan **Tahun** pengambilannya.
- Contoh: Foto yang diambil pada tahun 2026 akan diunggah ke path `2026/{nama_file}.jpg`.
- Aplikasi juga dianjurkan memperbarui file `timelapse/last.jpg` di repositori tersebut dengan foto paling baru agar fitur *overlay* / *guideline* selalu akurat.

## Solusi / Pendekatan Teknis (Tanpa Server Git Lokal)
Karena aplikasi ini berjalan di perangkat seluler (Flutter) dan tidak ideal menjalankan perintah *Command Line Git* secara bawaan, fungsionalitas "Pull dan Push" dapat diakali dan diimplementasikan secara mudah menggunakan **GitHub REST API**.

**Dokumentasi API:**
- [GitHub API: Create or update file contents](https://docs.github.com/en/rest/repos/contents#create-or-update-file-contents)
- Dibutuhkan *Personal Access Token (PAT)* dari GitHub.

## Langkah-Langkah Pengerjaan

- [ ] **1. Persiapan Kredensial Akses Github API**
  - Buat mekanisme penyisipan GitHub *Personal Access Token (PAT)*. Bisa dititipkan lewat variabel enviroment (`.env` file menggunakan `flutter_dotenv`) atau halaman Settings kecil. Token ini mutlak diperlukan untuk melakukan *Push* (PUT Request) via API.

- [ ] **2. Menambahkan Tombol Sync di UI**
  - Tambahkan sebuah tombol aksi baru "Sync" (contoh ikon: `Icons.sync` atau `Icons.cloud_upload`).
  - Penempatan terbaik adalah di `GalleryScreen` di bagian AppBar, atau di panel kontrol samping layar kamera agar sejajar dengan tombol Jepret dan Galeri.

- [ ] **3. Implementasi Logika Tarik Data (Pull / Check)**
  - Karena kita menggunakan API, fungsi "Pull" berarti:
    - Memanggil *endpoint* Github `GET /repos/KAnggara75/everyday/contents/{Tahun}` untuk mendapatkan daftar file apa saja yang sudah ada di repositori server.
    - Ini berguna agar aplikasi bisa menyeleksi file mana yang sudah di-push sebelumnya (menghindari unggah ulang seluruh foto setiap kali tombol *Sync* ditekan).

- [ ] **4. Implementasi Logika Unggah (Push)**
  - Untuk file yang belum ada di GitHub, persiapkan perulangannya (*looping*):
    - Dapatkan tanggal dari nama berkas (Format saat ini: `yymmddHHmmss.jpg`) -> Ketahui tahun 4-digitnya (Misal `yy=26` menjadi `2026`).
    - Ubah format berkas `.jpg` menjadi konversi string **Base64**.
    - Lakukan HTTP PUT ke `https://api.github.com/repos/KAnggara75/everyday/contents/2026/{nama_file}` beserta data Base64 dan Token Autorisasinya.
    - Tampilkan indikator proses (misal: "Syncing 1 of 5..." lewat *SnackBar* atau *ProgressDialog*).

- [ ] **5. Pembaruan File Guideline (`timelapse/last.jpg`)**
  - Saat menekan tombol *Sync*, cari file foto lokal yang tanggal pembuatannya atau namanya paling baru.
  - Setelah diunggah ke folder tahunan, lakukan satu kali unggahan tambahan (di-overwrite) ke `https://api.github.com/repos/KAnggara75/everyday/contents/timelapse/last.jpg` agar tautan guideline terus terbarui. Ingat untuk menyertakan nilai parameter `sha` khusus saat menimpa/overwrite file yang sudah ada di Github API.

## Referensi File yang Harus Diedit / Dibuat
* `pubspec.yaml` (Mungkin butuh package `http` dan `flutter_dotenv` jika belum ada).
* `lib/github_sync_service.dart` (Bagusnya logika API dipisah ke file *service* tersendiri agar kode tidak terlalu panjang).
* `lib/gallery_screen.dart` / `lib/camera_screen.dart` (Untuk UI tombol *Sync*).
* `.env` file (disimpan tersembunyi dari repo untuk PAT token).

**Instruksi Tambahan Untuk Junior Dev / AI Model:**
Perhatikan bahwa Github REST API punya limitasi pengiriman data sekian Megabyte per detik. Beri jeda/delay singkat setiap iterasi unggahan foto di dalam fungsi loop agar request tidak diblokir Github dengan pesan *Rate Limit Exceeded* atau *Abuse Mechanism*. Gunakan struktur `try ... catch` dengan *print* error saat mendesain pemanggilan API tersebut.
