# Farrel Franqois Blog

[![GitHub Actions](https://github.com/FarrelF/Blog/actions/workflows/build_and_deploy.yml/badge.svg)](https://github.com/FarrelF/Blog/actions/workflows/build_and_deploy.yml)
[![Netlify Status](https://api.netlify.com/api/v1/badges/edc59a5f-e63a-426c-ae65-cffe9153fa04/deploy-status)](https://app.netlify.com/sites/farrelf/deploys)
[![Lisensi](https://img.shields.io/github/license/FarrelF/Blog?label=Lisensi&style=flat-square)](LICENSE)
[![Ditenagai oleh Hugo](https://img.shields.io/badge/Hugo-ff4088?logo=hugo&style=flat-square&label=Ditenagai%20oleh)](https://gohugo.io)

Repositori ini merupakan kode sumber blog saya. Blog ini saya buat menggunakan Hugo, yang berbasis Go dan jauh lebih sederhana dan lebih cepat daripada sebelumnya.

Sebelumnya saya menggunakan Pelican yang berbasiskan Python sebagai basis saya untuk nge-blog, untuk kode sumbernya bisa Anda lihat [repositori saya sebelumnya](https://github.com/FarrelF/Blog-Old).

## Persyaratan

Agar dapat menggunakan kode sumber ini, adakalanya untuk memenuhi persyaratannya terlebih dahulu, yakni terinstalnya:

- Git (disarankan versi terbaru): [https://git-scm.com/downloads](https://git-scm.com/downloads) (Untuk mengetahui cara instalnya, silakan baca [artikel ini](https://farrel.franqois.id/cara-install-git))
- Hugo Extended (versi minimal: 0.91.0, disarankan terbaru): [https://gohugo.io/getting-started/installing/](https://gohugo.io/getting-started/installing/) (Untuk mengetahui Cara Instalnya, silakan baca [artikel ini](https://farrel.franqois.id/cara-install-hugo))
- Go (versi minimal: 1.12, disarankan: 1.17 atau terbaru): [https://golang.org/](https://golang.org/)

Di dalam sistem operasi Anda. Jika Anda ingin memakai fitur "Codespaces", maka Anda tidak perlu memenuhi persyaratan tersebut di perangkat Anda.

## Cara Memperolehnya

Untuk memperolehnya, Anda bisa eksekusi perintah berikut untuk mengkloningnya:

```bash
git clone https://github.com/FarrelF/Blog.git FarrelF/Blog
```

Atau, jika Anda ingin menggunakan SSH, maka Anda bisa gunakan perintah berikut untuk mengkloningnya:

```bash
git clone git@github.com:FarrelF/Blog.git FarrelF/Blog
```

Atau, jika Anda menggunakan [GitHub CLI](https://cli.github.com), maka perintah untuk mengkloningnya sebagai berikut:

```bash
gh repo clone FarrelF/Blog FarrelF/Blog
```

Kode Sumber akan disimpan di dalam sebuah subfolder yang bernama `Blog` yang terletak di dalam folder `FarrelF`, jadi untuk mengaksesnya bisa pakai perintah `cd FarrelF/Blog`.

## Sebelum Instal

Sebelum Instal, pastikan Anda telah memenuhi semua persyaratannya terlebih dahulu di atas.

Atau, Anda dapat menggunakan fitur ["Codespaces"](https://github.com/features/codespaces) di GitHub yang dapat membantu Anda untuk menggunakan kode sumber blog ini, dimulai dari sekadar mencoba sampai turut ikut berkontribusi. Untuk caranya, silakan baca [halaman dokumentasinya](https://docs.github.com/en/codespaces/getting-started/quickstart), di situ sudah dijelaskan secara sederhana dan lengkap dengan gambar.

Saya sudah persiapkan semua yang dibutuhkan untuk ini yang konfigurasinya dapat Anda lihat di dalam folder [`.devcontainer`](.devcontainer) dan tinggal Anda pakai jadi saja, konfigurasinya belum sempurna sih, jadi masukkan dari Anda mengenai konfigurasi tersebut akan saya apresiasi.

Codespaces ini gratis 60 jam setiap bulannya untuk penggunaan mesin virtual dari GitHub dengan prosesor berinti dua (_dual-core_) + Memori RAM sebesar 4 GB, untuk biaya kelebihannya silakan Anda tanggung sendiri dan ini bisa saja berubah sewaktu-waktu.

Jika sudah, Anda dapat lanjut ke langkah berikutnya.

## Cara Instal dan Menggunakannya

Agar Kode Sumber ini dapat digunakan, maka Anda perlu menghasilkan HTML untuk Blog ini. Ada dua cara untuk menghasilkan HTML-nya, salah satunya berikut di bawah ini:

### Cara Pertama: Menggunakan Fitur _Web Server_

Hugo telah menyediakan _Web Server_ lokal yang akan sangat berguna untuk pengembangan Web/Blog.

Cara kerjanya adalah Hugo terlebih dahulu membuat berkas-berkas statis yang diperlukan untuk membentuk Web/Blog. Setelah itu, dia akan melayani hasilnya agar bisa langsung diakses melalui Peramban Web, meskipun secara baku dalam lingkungan lokal, tetapi ini berguna untuk pengembangan.

Untuk caranya, Anda bisa eksekusi perintah berikut di dalam Terminal setelah mengakses kode sumbernya:

```bash
hugo server -D --gc
```

Argumen `-D` digunakan untuk membangun artikel/halaman yang didraf dan `--gc` digunakan agar konten dapat diperbarui dengan menghapus _cache_ yang tidak diperlukan, silakan hapus parameter tersebut jika Anda tidak menginginkannya.

Tambahkan argumen `--liveReloadPort 443` jika Anda memakai Codespaces agar fitur "LiveReload" dari Hugo dapat bekerja dengan baik, kecuali jika Anda tidak memerlukannya.

Secara baku, data-data yang dihasilkan akan disimpan di dalam Memori RAM, bukan pada perangkat diska, jika ini dirasa berat, Anda dapat menambahkan argumen `--renderToDisk` agar tersimpan semua di dalam folder `public` atau `--renderStaticToDisk` agar cuma data statis saja yang boleh disimpan di dalam perangkat diska.

Setelah berhasil, silakan buka Alamat URL `http://localhost:1313` (atau alamat yang disediakan di Visual Studio Code jika Anda menggunakan fitur "Codespaces") di dalam Peramban Web kamu dan kamu akan melihat hasilnya 🙂

Untuk penggunaan lebih lanjut, silakan kunjungi halaman [dokumentasinya](https://gohugo.io/commands/hugo_server/) atau ketik perintah `hugo server --help`.

### Cara Kedua: Membangun Blog/Web Statis tanpa _Web Server_

Selain di atas, Hugo telah menyediakan cara untuk membangun Web/Blog Statis tanpa harus menggunakan fitur _Web Server_-nya, data-data yang dihasilkan akan tersimpan di dalam perangkat diska (_Disk_), ini akan sangat berguna untuk produksi atau sekadar memeriksa Kode dari berkas skrip atau HTML, sampai berkas-berkas media (Seperti: Gambar) sebelum disebar ke lingkungan produksi.

Untuk caranya, Anda bisa eksekusi perintah berikut di dalam Terminal setelah mengakses kode sumbernya:

```bash
hugo --gc
```

Perintah di atas akan menghasilkan Blog Statis yang siap digunakan untuk produksi, dan hasilnya akan tersimpan di dalam folder `public`.

Opsi di atas bukanlah opsi terbaik untuk membangun sebuah Web/Blog Statis dengan Hugo, jadi untuk penggunaan lebih lanjut, silakan kunjungi halaman [dokumentasinya](https://gohugo.io/commands/hugo/) atau ketik `hugo --help`.

## Cara Kontribusi

Silakan baca berkas [CONTRIBUTING.md](CONTRIBUTING.md)

## Lisensi

Kode Sumber ini dirilis di bawah lisensi GNU Affero General Public License v3 (GNU AGPLv3) yang bisa Anda lihat/baca di dalam berkas [LICENSE](LICENSE).

Sedangkan untuk Artikel dan Halaman (terutama di dalam folder [`content`](content)) secara baku saya terbitkan di bawah lisensi [Creative Commons Attribution-ShareAlike Internasional 4.0](https://creativecommons.org/licenses/by-sa/4.0/) (Atau, disingkat: CC BY-SA 4.0), tetapi ada beberapa materi tertentu yang bisa saja diterbitkan di bawah lisensi yang berbeda (Contoh: Gambar/Media yang bersumber dari luar, dll).

Lisensi untuk materi-materi tersebut akan saya sebutkan di masing-masing artikel dan halaman sebagai atribusi jika saya diizinkan untuk menggunakannya.
