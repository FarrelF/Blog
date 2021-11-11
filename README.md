# Farrel Franqois Blog
[![GitHub Actions](https://github.com/FarrelF/Blog/actions/workflows/build_and_deploy.yml/badge.svg)](https://github.com/FarrelF/Blog/actions/workflows/build_and_deploy.yml)
[![Netlify Status](https://api.netlify.com/api/v1/badges/edc59a5f-e63a-426c-ae65-cffe9153fa04/deploy-status)](https://app.netlify.com/sites/farrelf/deploys)
[![Lisensi](https://img.shields.io/github/license/FarrelF/Blog?label=Lisensi&style=flat-square)](LICENSE)

_Repository_ ini merupakan kode sumber Blog saya. Blog ini saya buat menggunakan Hugo, yang berbasis Go dan jauh lebih sederhana dan lebih cepat daripada sebelumnya.

Sebelumnya saya menggunakan Pelican yang berbasiskan Python sebagai basis saya untuk nge-blog, untuk Kode Sumber nya bisa Anda lihat [_Repository_ saya sebelumnya](https://github.com/FarrelF/Blog-Old).

## Persyaratan
Sebelum memulai untuk menggunakan Kode Sumber ini, adakalanya untuk memenuhi persyaratannya terlebih dahulu, yakni terinstalnya:

- Git: https://git-scm.com/downloads (Untuk mengetahui Cara Install nya, silahkan baca [artikel ini](https://farrel.franqois.id/cara-install-git))
- Hugo Extended: https://gohugo.io/getting-started/installing/ (Untuk mengetahui Cara Install nya, silahkan baca [artikel ini](https://farrel.franqois.id/cara-install-hugo))

Di dalam Sistem Operasi Anda.

Catatan: Kamu tidak perlu menginstal Go untuk dapat menggunakan Hugo, dan pastikan Hugo yang kamu Install adalah "Hugo Extended", bukan Hugo Standar/Biasa.

## Cara Memperolehnya
Untuk memperolehnya, Anda bisa eksekusi perintah berikut untuk meng-kloningnya:

```bash
$ git clone --recurse-submodules https://github.com/FarrelF/Blog.git FarrelF-Blog
```

Atau, jika Anda menggunakan [GitHub CLI](https://cli.github.com), maka perintah untuk meng-kloningnya sebagai berikut:

```bash
$ gh repo clone FarrelF/Blog FarrelF-Blog -- --recurse-submodules
```

Setelah Anda meng-kloningnya, terutama dengan perintah di atas, kode sumber akan secara otomatis tersimpan di dalam Folder yang bernama `FarrelF-Blog`.

Blog ini memerlukan beberapa modul yang berasal dari luar _Repository_ ini (Seperti: Tema), makanya saya gunakan _Submodules_ di dalam _Repository_ ini.

Jika Anda terlanjur tidak menggunakan opsi `--recurse-submodules` atau `--recursive` saat kloning, maka Anda dapat mengikuti perintah berikut setelah meng-kloningnya:

```bash
$ cd FarrelF-Blog
$ git submodule update --init --recursive
```

## Cara Instal dan Menggunakannya
Agar Kode Sumber ini bisa digunakan, maka Anda perlu menghasilkan HTML untuk Blog ini. Ada dua cara untuk menghasilkan HTML nya, berikut di bawah ini:

### Cara Pertama: Menggunakan Fitur _Web Server_
Hugo telah menyediakan _Web Server_ lokal yang akan sangat berguna untuk pengembangan Web/Blog.

Cara kerjanya adalah Hugo terlebih dahulu membuat berkas-berkas statis yang diperlukan untuk membentuk Web/Blog. Setelah itu, dia akan melayani hasilnya agar bisa langsung diakses melalui Peramban Web, meskipun secara baku dalam lingkungan lokal, tapi ini berguna untuk pengembangan.

Data yang dihasilkan akan tersimpan ke dalam Memori (RAM) daripada Perangkat Diska (_Disk_), sehingga datanya tidak bisa Anda temukan di manapun ketika Anda mencarinya. Perubahan akan secara otomatis diterapkan secara langsung selama fitur tersebut aktif.

Untuk caranya, Anda tinggal navigasikan ke dalam Folder Kode Sumber dengan perintah `cd`, lalu ketik perintah berikut di dalam Terminal:

```bash
$ hugo server -D --gc 
```

Parameter `-D` digunakan untuk membangun artikel/laman yang didraf, silahkan hapus parameter tersebut jika Anda tidak menginginkannya.

Setelah berhasil, silahkan buka Alamat URL `http://localhost:1313` di dalam Peramban Web kamu, dan kamu akan melihat hasilnya :slightly_smiling_face: 

Untuk penggunaan lebih lanjut, silahkan kunjungi laman [dokumentasi nya](https://gohugo.io/commands/hugo_server/) atau ketik perintah `hugo server --help`.

### Cara Kedua: Membangun Blog/Web Statis tanpa _Web Server_
Selain di atas, Hugo telah menyediakan cara untuk membangun Web/Blog Statis tanpa harus menggunakan fitur _Web Server_ nya, hasilnya tidak akan tersimpan ke dalam memori (RAM), melainkan ke Perangkat Diska (_Disk_), ini akan sangat berguna untuk produksi atau sekedar memeriksa Kode dari Berkas Skrip/HTML, sampai Berkas-berkas media (Seperti: Gambar) sebelum disebar ke Lingkungan Produksi.

Untuk caranya, Anda tinggal navigasikan ke dalam Folder Kode Sumber dengan perintah `cd`, lalu eksekusi perintah berikut di dalam Terminal:

```bash
$ hugo
```

Perintah di atas akan menghasilkan Blog Statis yang siap digunakan untuk produksi, dan hasilnya akan tersimpan di dalam folder `public`.

Opsi di atas bukanlah opsi terbaik untuk membangun sebuah Web/Blog Statis dengan Hugo, jadi untuk penggunaan lebih lanjut, silahkan kunjungi laman [dokumentasi nya](https://gohugo.io/commands/hugo/) atau ketik `hugo --help`.

## Cara Kontribusi
Baca berkas [CONTRIBUTING.md](CONTRIBUTING.md)

## Lisensi
Kode Sumber ini dirilis di bawah lisensi GNU Affero General Public License v3 (GNU AGPLv3) yang bisa Anda lihat/baca di dalam berkas [LICENSE](LICENSE).

Sedangkan untuk Artikel dan Laman (terutama di dalam folder [`content`](content)) secara baku saya terbitkan di bawah lisensi [Creative Commons Attribution-ShareAlike Internasional 4.0](https://creativecommons.org/licenses/by-sa/4.0/) (Atau, disingkat: CC BY-SA 4.0), tapi ada beberapa materi tertentu yang bisa saja diterbitkan di bawah lisensi yang berbeda (Contoh: Gambar/Media yang bersumber dari Luar, dll).

Lisensi untuk materi-materi tersebut akan saya sebutkan di masing-masing Artikel dan Laman sebagai Atribusi jika saya diizinkan untuk menggunakan nya.
