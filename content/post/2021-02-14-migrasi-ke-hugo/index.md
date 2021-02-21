---
Title: Migrasi Blog ke Hugo, Alasan dan Rencana Kedepan nya
Slug: migrasi-ke-hugo-dan-rencana-kedepannya
Author: Farrel Franqois
Category: Info Blog
Date: 2021-02-14 21:42:00+07:00
Draft: true
Tags: 
    - Migrasi
    - Hugo
    - Static-site Generator
    - SSG
enableSummary: true
Description: 
Summary:
    <p>
    Sudah lama sekali saya tidak membuat postingan di blog ini, sudah hampir 2 tahun rasanya.
    </p>
    <p>
    Sebelumnya saya lagi tidak membuat artikel karena saya habiskan waktu nya untuk memahami SSG yang saya gunakan sebelumnya, yakni Pelican. Oleh karena itu, daripada saya gabut seperti itu, saya memutuskan untuk mencari SSG yang jauh lebih baik daripada SSG yang saya pakai sebelumnya, dan pada akhirnya, saya memutuskan untuk menggunakan Hugo + Mengganti Tema.
    </p>
    <p>
    Kenapa saya gunakan Hugo daripada Pelican? Dan, apa rencana kedepan nya? Kalo penasaran silahkan baca artikel ini, kalau tidak, yah tidak apa-apa 🙂
    </p>
---

## Daftar Isi
{{< toc >}}

## Alasan Migrasi dari Pelican ke Hugo
Pelican (bukan [Burung 'Pelican'](https://www.google.com/search?q=burung+pelikan&tbm=isch)) adalah salah satu _Static-site Generator_ (atau saya singkat "SSG") berbasis Python yang saya gunakan sebelum nya.

Awalnya saya sendiri juga menggunakan nya daripada SSG lain seperti Hugo karena saat itu saya sedang belajar Bahasa Pemrograman Python.

Setelah beberapa waktu saya menggunakan nya, saya malah jadi gak posting-posting selama hampir 2 tahun karena saya menghabiskan waktu nya untuk memahami SSG tersebut agar Blog saya berjalan dengan fitur yang sesuai dengan kebutuhan saya, setelah lama mencari, akhirnya saya malah pindah hati ke Hugo + Mengganti Tema nya. 

Kenapa saya lakukan itu? Alasan nya bisa Anda lihat di bawah ini.

### Saat Instalasi
Saat Instalasi, Pelican memerlukan untuk meng-install beberapa modul Python terlebih dahulu agar bisa di eksekusi.

Mau tidak mau, saya harus menggunakan fitur "Virtual Environment" (Lingkungan Virtual) yang ada pada Python agar tidak terjadi konflik antar modul yang terinstall, serta supaya hanya modul yang diperlukan saya yang di Install. 

Tapi tentu saja ini akan sulit untuk mengatur modul-modul nya, begitupula dengan urusan _Caching_ nya, sehingga ini kurang bisa untuk mengatasi masalah "Ini bekerja di mesin saya, kok".

Akhirnya saya manfaatkan ["Poetry"](https://python-poetry.org) sebagai Pengelola Modul agar bisa mengelola modul-modulnya dengan lebih mudah, dan bahkan bisa dengan mudah meng-install modul Python yang diperlukan di Komputer lain.

Semua hal di atas tentu saja sangat merepotkan buat saya, sudah banyak langkah (Belum lagi Install Python dan "Poetry" nya sendiri), makan waktu dan tenaga pula.

Sedangkan Hugo? Semua hal di atas tidak pernah terjadi dan saya gak ada kendala ataupun keluhan sama sekali. Artinya, saya gak perlu Install Modul/Ketergantungan apapun hanya untuk menggunakan nya, bahkan termasuk Bahasa Pemrograman Go sekalipun.

Kenapa? Karena Hugo sendiri telah menyediakan Berkas Biner yang telah di bangun (atau di-_compile_) sebelumnya. 

Lalu apa artinya itu? Artinya yang Anda perlu lakukan cuma dua saja, yakni punya 1 Berkas Biner Hugo, lalu copas ke dalam folder yang termasuk _Environment_ `PATH` agar bisa di eksekusi dimanapun. Tanpa perlu Install Modul/Ketergantungan apapun terlebih dahulu.

### Kecepatan
Komputer yang saya gunakan masih menggunakan _Harddisk_ sebagai Penyimpanan Utama (belum menggunakan SSD, kecuali Laptop, karena belum sanggup beli).

Maka kecepatan dalam membuat Blog Statis adalah hal yang paling terasa perbedaan nya. Di Pelican, dalam membuat Blog Statis, maka di perlukan beberapa detik untuk menyelesaikan nya, kadang 2-5 detik, bahkan sampai puluhan detik paling lambat nya.

Sedangkan di Hugo? Paling Lambat sekitar 1-2 detik an saja, dan itupun dalam posisi di nonaktifkan "Fast Render" nya.

Itu bisa saja banyak faktor dan relatif juga, mungkin banyaknya modul atau/dan konfigurasi itu yang membuat nya lama, tapi modul-modul tersebut saya perlukan juga agar blog nya berjalan sesuai kebutuhan saya.

Pada akhirnya ini masalah ke selera aja, sih, hehe 😀

### Modifikasi Tema
Di Pelican, jika saya ingin memodifikasi tema nya, maka saya sampai harus membuat Repo Git khusus yang berisikan Tema yang saya gunakan sekarang, lalu saya modifikasi sesuka saya.

Memang ini hal yang mudah, tapi hal ini sangat merepotkan saya, terlebih kalo tema tersebut ada pembaruan penting buat blog saya dari Hulu (_Upstream_), sehingga mau tidak mau saya harus memperbarui nya secara manual.

Awal nya saya ingin memanfaatkan perintah `git` untuk memperbarui nya, tapi karena terlalu banyak berkas yang di modifikasi, akhirnya malah menimbulkan konflik, sehingga ini menjadi kurang efisien. Mungkin karena saya kurang jago dalam menggunakan `git` ini, hehe 😀

Dan menurut saya, 1 Repo terpisah hanya untuk Modifikasi Tema ini memang _gak banget_.

Bisa saja Tema nya saya letakkan di dalam Kode Sumber Blog saya, namun ujung-ujungnya yah sama saja + Ukuran Repo Git nya malah jadi "buncit" nantinya gara-gara Tema.

Sedangkan di Hugo, saya bisa memodifikasi tema cuma perlu merubah berkas-berkas seperlunya dengan memanfaatkan folder-folder yang ada di Kode Sumber Blog nya, seperti: `layouts` (Untuk Tata letak Tema), `data` (Untuk Data pada Tema/Blog) dan `i18n` (Untuk Terjemahan pada Tema) tanpa harus membuat _Repository_ baru lagi atau memodifikasi tema di dalam Kode Sumber Blog nya.

Caranya mudah, Anda tinggal copas berkas yang ingin Anda rubah ke dalam Kode Sumber Blog/Situs Web kamu, lalu tinggal modifikasi sesuka hati.

Pastikan lokasi berkas di Kode Sumber Blog/Situs Web nya mengikuti lokasi berkas pada Tema nya. 

Contoh: Jika Anda ingin merubah isi berkas `article.html` yang ada di Tema dan terletak di dalam lokasi `layouts/partials/article`, maka Anda perlu meletakkan nya di dalam folder `layouts/partials/article` pada Kode Sumber Blog/Situs Web nya juga.

Dan berkat ini, saya hanya perlu manfaatkan _Git Submodules_ saja untuk meng-install tema nya.

### Fitur
Di Pelican, fitur nya kurang begitu lengkap untuk kebutuhan saya, untuk menambahkan suatu fitur saja saya harus menambahkan sejumlah _Plugin_ yang menurut saya itu cukup _tricky_.

Bahkan agar bisa membuat artikel dengan lebih dari satu kategori saja harus memasang sebuah _Plugin_ yang mana ini akan membuat kecepatan untuk menghasilkan Blog Statis menjadi berkurang. Belum lagi rata-rata _Plugin_ yang ada kebanyakan malah tidak di perbarui.

Sedangkan di Hugo tidaklah perlu demikian, fitur-fitur yang ada di Hugo terbilang cukup lengkap bagi saya, bahkan Hugo sendiri telah menyediakan sejumlah Template Internal Google Analytics, Disqus, dll agar kemudian bisa di aplikasikan oleh pembuat Tema jika berkenan.

Dan dengan memanfaatkan fitur _Shortcodes_ saat membuat berkas Markdown, kita bisa menyisipkan _Tag_/Kode HTML yang kita butuhkan, bahkan ketika fitur tersebut tidak ada di Tema sekalipun. 

Seperti fitur "Daftar Isi" yang tidak semua Tema punya, termasuk Tema yang [saya gunakan ini](https://github.com/CaiJimmy/hugo-theme-stack/) yang sampai sekarang [belum ada fiturnya](https://github.com/CaiJimmy/hugo-theme-stack/issues/129).

### Optimalisasi Blog/Web
**Catatan**: Bagian ini masih berhubung dengan Bagian ["Fitur"](#Fitur).

Sudah menjadi umum memang bahwa Optimalisasi Blog/Web menjadi aspek yang sangatlah penting, karena tidak semua orang memiliki koneksi Internet yang cepat dan stabil, bahkan jika sudah menggunakan Layanan Jaringan Pengiriman Konten (CDN/_Content Delivery Network_) atau Jaringan Pengiriman Aplikasi (ADN/_Application Delivery Network_) sekalipun.

Sehingga memadatkan berkas Skrip, HTML (atau disebut: _minify_) dan mengoptimalkan Gambar yang di muat itu sudah menjadi kewajiban bagi pemilik/pemelihara Blog/Web.

Di Pelican, untuk bisa mengoptimalkan Skrip, HTML dan Gambar saja harus menggunakan Plugin dan meng-Install beberapa modul yang diperlukan, sehingga hal ini mengorbankan kecepatan dalam menghasilkan Blog Statis.

Belum lagi soal masalah _Web Browser Caching_ yang mengharuskan untuk menamai berdasarkan _Hash_ Berkas tersebut, agar jika berkas tersebut di modifikasi, maka pengunjung akan mendapatkan berkas terbaru nya ketika mengunjungi sebuah Blog/Web.

Sedangkan di Hugo, masalah di atas tidak terjadi, di Hugo juga tersedia fitur optimasi secara lengkap (Kecuali konversi gambar ke WebP, AVIF dan JXL) yang tentu nya itu merupakan fitur bawaan, tinggal pembuat/pemodifikasi Tema nya saja yang mau mengoptimalkan nya atau tidak.
