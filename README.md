# Farrel Franqois Blog
[![Netlify Status](https://api.netlify.com/api/v1/badges/edc59a5f-e63a-426c-ae65-cffe9153fa04/deploy-status)](https://app.netlify.com/sites/farrelf/deploys)
[![Lisensi](https://img.shields.io/github/license/FarrelF/Blog?label=Lisensi&style=flat-square)](LICENSE.md)

_Repository_ ini merupakan kode sumber Blog saya. Blog ini saya buat menggunakan Hugo, yang berbasis Go dan jauh lebih sederhana dan lebih cepat daripada sebelumnya. 

Sebelumnya saya menggunakan Pelican yang berbasiskan Python sebagai basis saya untuk nge-blog, untuk Kode Sumber nya bisa Anda lihat [_Repository_ saya sebelumnya](https://github.com/FarrelF/Blog-Old).

## Persyaratan
Sebelum memulai untuk menggunakan Kode Sumber nya, adakala nya untuk memenuhi Persyaratan nya terlebih dahulu, yakni ter-installnya:

### Persyaratan Wajib
- Git: https://git-scm.com/downloads (Untuk mengetahui Cara Install nya, silahkan baca artikel [ini](https://farrel.franqois.id/cara-install-git))
- Hugo Extended: https://gohugo.io/getting-started/installing/

Di dalam Sistem Operasi Anda.

Catatan: Kamu tidak perlu meng-install Go untuk dapat menggunakan Hugo, dan pastikan Hugo yang kamu Install adalah "Hugo Extended", bukan Hugo Standar/Biasa.

## Cara Memperoleh nya (dan Meng-installnya)
Untuk memperoleh nya, Anda bisa eksekusi perintah berikut untuk meng-kloning nya:

```bash
$ git clone --recurse-submodules https://github.com/FarrelF/Blog.git FarrelF-Blog
```

Setelah Anda meng-kloning nya, terutama dengan perintah di atas, kode sumber akan secara otomatis tersimpan di dalam Folder yang bernama `FarrelF-Blog`.

Blog ini memerlukan beberapa modul yang berasal dari luar _Repository_ ini (Seperti: Tema), makanya saya gunakan _Submodules_ di dalam _Repository_ ini. 

Jika Anda terlanjur tidak menggunakan opsi `--recurse-submodules` atau `--recursive` pas kloning, setelah Anda meng-kloningnya, maka Anda perlu mengikuti perintah berikut:

```bash
$ cd FarrelF-Blog
$ git submodule update --init --recursive
```

## Cara Install dan Menggunakan nya
Agar Kode Sumber ini bisa di gunakan, maka Anda perlu menghasilkan HTML untuk Blog ini. Ada dua cara untuk menghasilkan HTML nya, berikut di bawah ini:

### Cara Pertama: Menggunakan Fitur _Web Server_
Hugo telah menyediakan _Web Server_ lokal yang akan sangat berguna untuk pengembangan Web/Blog. Cara kerja nya adalah Hugo terlebih dahulu membuat berkas-berkas statis yang diperlukan untuk membentuk Web/Blog. Setelah itu dia akan melayani hasil nya agar bisa langsung di akses melalui Peramban Web, meskipun dalam bentuk lokal secara bawaan, tapi ini berguna untuk pengembangan.

Data yang dihasilkan akan tersimpan ke dalam Memori (RAM) daripada Perangkat Diska (_Disk_), sehingga datanya tidak akan Anda temukan dimanapun ketika Anda mencarinya. Perubahan akan secara otomatis di terapkan secara langsung selama fitur tersebut aktif.

Untuk caranya, Anda tinggal navigasikan ke dalam Folder Kode Sumber dengan perintah `cd`, lalu ikuti langkah-langkah berikut dengan Terminal:

**Catatan**: Di dalam Sistem Operasi GNU/Linux, macOS dan Sistem Operasi berbasis Unix/Unix-like lain nya kamu bisa gunakan Terminal Bawaan, sedangkan di Windows kamu bisa gunakan "Git Bash" atau "PowerShell Core" juga boleh.

```bash
$ hugo server -D --gc 
```

Jika Anda ingin agar web/blog nya tidak ter-_cache_ oleh Peramban Web dan memberikan pengalaman terbaik untuk membuat _Web Server_ nya, maka Anda perlu ikuti perintah berikut:

```bash
$ hugo server -D --gc --noHTTPCache --disableFastRender --cacheDir \$PWD/cache
```

Parameter `-D` digunakan untuk membangun artikel/laman yang di draf, silahkan hapus parameter tersebut jika Anda tidak menginginkan nya.

**Catatan**: Perintah di atas dapat di eksekusi melalui "PowerShell Core" dan Perangkat Lunak tersebut dapat mengenali variabel `$PWD` dengan baik.

Setelah berhasil, bisa kamu coba buka Alamat URL `http://localhost:1313` di dalam Peramban Web kamu, dan kamu akan melihat hasilnya :slightly_smiling_face: 

Opsi di atas mungkin bukanlah opsi terbaik untuk mengembangkan sebuah Web/Blog Statis dengan Hugo, jadi untuk penggunaan lebih lanjut, silahkan kunjungi laman [dokumentasi nya](https://gohugo.io/commands/hugo_server/) atau ketik perintah `hugo server --help`.

### Cara Kedua: Membangun Blog/Web Statis tanpa _Web Server_
Selain di atas, Hugo telah menyediakan cara untuk membangun Web/Blog Statis tanpa harus menggunakan fitur _Web Server_ nya, hasilnya tidak akan ter simpan ke dalam memori (RAM), melainkan ke Perangkat Diska (_Disk_), ini akan sangat berguna untuk produksi atau sekedar memeriksa Kode dari Berkas Skrip/HTML, sampai Berkas-berkas media (Seperti: Gambar) sebelum di unggah ke Lingkungan Produksi.

Untuk caranya, Anda tinggal navigasikan ke dalam Folder Kode Sumber dengan perintah `cd`, lalu ikuti langkah-langkah berikut dengan Terminal:

```bash
$ hugo
```

Perintah di atas akan menghasilkan Blog Statis yang siap di gunakan untuk produksi, dan hasil nya akan tersimpan di dalam folder `public`.

Opsi di atas bukanlah opsi terbaik untuk membangun sebuah Web/Blog Statis dengan Hugo, jadi untuk penggunaan lebih lanjut, silahkan kunjungi laman [dokumentasi nya](https://gohugo.io/commands/hugo/) atau ketik `hugo --help`.

## Cara Kontribusi
Mohon maaf, saya belum bisa memberikan cara kontribusi dalam bentuk perubahan pada kode sumber untuk saat ini. Maka lebih baik Anda tidak memberikan kontribusi berupa perubahan pada kode sumber untuk saat ini, kecuali jika itu bisa di terima oleh saya.

Namun, saat ini Anda bisa berkontribusi dengan memberikan sejumlah uang/donasi kepada saya, bisa melalui [PayPal](https://paypal.me/FarrelF) atau Akun [Trakteer](https://trakteer.id/farrelf) saya. 

Rencana nya saya akan membuat artikel yang hanya bisa kalian baca/lihat setelah membayar nya disana (Trakteer), jadi kalau Anda suka atau merasa Informasi nya berguna, maka Anda bisa berlangganan dengan saya disana.

## Lisensi
Kode Sumber ini di rilis di bawah lisensi GNU Affero General Public License v3 (GNU AGPLv3) yang bisa Anda lihat/baca di dalam berkas [LICENSE.md](LICENSE.md). 

Sedangkan untuk Artikel dan Laman (terutama di dalam folder [`content`](content)) saya terbitkan di bawah lisensi [Creative Commons Attribution-ShareAlike Internasional 4.0](https://creativecommons.org/licenses/by-sa/4.0/) (Atau, disingkat: CC BY-SA 4.0), kecuali untuk materi-materi tertentu yang bisa saja di terbitkan di bawah lisensi yang berbeda (Contoh: Gambar/Media yang bersumber dari Luar, dll).

Lisensi untuk materi-materi tersebut akan saya sebutkan di masing-masing Artikel dan Laman sebagai Atribusi jika saya di izinkan untuk menggunakan nya.
