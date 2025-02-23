---
Title: Migrasi Blog ke Hugo, Alasan dan Rencana Kedepan nya
Slug: migrasi-ke-hugo-dan-rencana-kedepannya
Author: Farrel Franqois
Categories: 
    - Info Blog
    - Opini
Date: 2021-03-08 00:31:39+07:00
Tags: 
    - Migrasi
    - Hugo
    - Static-site Generator
    - SSG
readMore: true
DescriptionSEO: Artikel ini membahas tentang Alasan saya Migrasi ke Hugo dari Pelican, serta rencana untuk blog ini kedepan nya. Jika Anda penasaran, silahkan baca artikel ini.
Description: |-
    Sudah lama sekali saya tidak membuat postingan di blog ini, sudah hampir 2 tahun rasanya.

    Sebelumnya saya lagi tidak membuat artikel karena saya habiskan waktu nya untuk memahami SSG yang saya gunakan sebelumnya, yakni Pelican. Oleh karena itu, daripada saya gabut seperti itu, saya memutuskan untuk mencari SSG yang jauh lebih baik daripada SSG yang saya pakai sebelumnya, dan pada akhirnya, saya memutuskan untuk menggunakan Hugo + Mengganti Tema.    

    Kenapa saya gunakan Hugo daripada Pelican? Dan, apa rencana kedepan nya? Kalo penasaran silahkan baca artikel ini, kalau tidak, yah tidak apa-apa 🙂
---

## Alasan Migrasi dari Pelican ke Hugo
[Pelican](https://blog.getpelican.com) (bukan [Burung 'Pelican'](https://www.google.com/search?q=burung+pelikan&tbm=isch)) merupakan salah satu _Static-site Generator_ (atau saya singkat "SSG") berbasis Python yang cukup populer di kalangan pengguna Python, saya adalah salah satu pengguna sebelumnya.

Awalnya saya sendiri juga menggunakan nya daripada SSG lain seperti Hugo karena saat itu saya sedang belajar Bahasa Pemrograman Python.

Setelah beberapa waktu saya menggunakan nya, saya malah jadi gak posting-posting selama hampir 2 tahun karena saya menghabiskan waktu nya untuk memahami SSG tersebut agar Blog saya berjalan dengan fitur yang sesuai dengan kebutuhan saya, setelah lama mencari, akhirnya saya malah pindah hati ke Hugo + Mengganti Tema nya.

Kenapa saya lakukan itu? Alasan nya bisa Anda lihat di bawah ini.

### Saat Instalasi
Saat Instalasi, Pelican memerlukan untuk meng-instal Python dan beberapa modul nya terlebih dahulu agar bisa dieksekusi.

Jadi mau tidak mau dan suka tidak suka, saya harus menggunakan fitur "Virtual Environment" (Lingkungan Virtual) yang ada pada Python agar tidak terjadi konflik antar modul yang terinstall, serta supaya hanya modul yang diperlukan saja yang diinstal. 

Tapi tentu saja ini akan sulit untuk mengatur modul-modul nya, sehingga ini kurang bisa untuk mengatasi masalah "Ini bekerja di mesin saya, kok".

Akhirnya saya manfaatkan ["Poetry"](https://python-poetry.org) sebagai Pengelola Modul agar bisa mengelola modul-modulnya dengan lebih mudah, dan bahkan bisa dengan mudah meng-install modul Python yang diperlukan di Komputer lain.

Semua hal di atas tentu saja sangat merepotkan buat saya, sudah banyak langkah (Belum lagi Install Python dan "Poetry" nya sendiri), makan waktu dan tenaga pula.

Sedangkan Hugo? Semua hal di atas tidak pernah terjadi dan saya gak ada kendala ataupun keluhan sama sekali. Artinya, saya gak perlu Install Modul/Ketergantungan apapun hanya untuk menggunakan nya, bahkan termasuk Bahasa Pemrograman Go sekalipun.

Kenapa? Karena Hugo sendiri telah menyediakan Berkas Biner yang telah dihimpun (atau _di-compile_) sebelumnya. Sudah gitu, Hugo telah menyediakan berkas biner untuk beberapa Sistem Operasi dan beberapa _Platform_ yang berbeda pula (Lintas Platform/_Cross-platform_).

Lalu apa artinya itu? Ini Artinya Anda hanya perlu mempunyai 1 Berkas Biner Hugo (bisa dengan mengunduhnya) untuk Sistem Operasi yang Anda gunakan, lalu tinggal Anda eksekusikan saja. 

Mau Hugo nya bisa dieksekusi di manapun? Anda tinggal copas/pindahkan saja berkas tersebut ke dalam direktori yang sudah termasuk ke dalam Variabel [`PATH`](https://en.wikipedia.org/wiki/PATH_(variable)). Di Sistem Operasi GNU/Linux (apapun Distribusinya), Anda bisa meletakannya ke dalam direktori `/usr/local/bin`. 

Semua ini bisa Anda lakukan tanpa harus Install Modul/Ketergantungan apapun terlebih dahulu, alias tinggal langsung pakai saja dan tentu saja tanpa harus Install melalui Pengelola Paket (_Package Manager_), meskipun itu bisa dilakukan.

### Kecepatan
Komputer yang saya gunakan masih menggunakan _Harddisk_ sebagai Penyimpanan Utama (belum menggunakan SSD, kecuali Laptop, karena belum sanggup beli).

Maka kecepatan dalam membuat Blog Statis adalah hal yang paling terasa perbedaan nya. Di Pelican, dalam membuat Blog Statis, maka diperlukan beberapa detik untuk menyelesaikan nya, kadang 2-8 detik atau 1-5 detik jika adanya perubahan pada suatu berkas, bahkan sampai puluhan detik paling lambat nya, terutama jika itu dilakukan di Sistem Operasi Windows.

Sedangkan di Hugo? Paling Lambat sekitar 1-6 detik an saja atau sekitar beberapa milidetik jika adanya perubahan, dan itupun dalam posisi dinonaktifkan "Fast Render" nya, baik di GNU/Linux ataupun di Windows juga sama saja kecepatan nya.

Itu bisa saja banyak faktor dan relatif juga, mungkin banyaknya modul atau/dan konfigurasi itu yang membuatnya lama, tapi modul-modul tersebut saya perlukan juga agar blog nya berjalan sesuai kebutuhan saya.

Pada akhirnya, ini cuma masalah selera aja sih, hehe 😀

### Modifikasi Tema
Di Pelican, jika saya ingin memodifikasi tema nya, maka saya sampai harus membuat Repo Git khusus yang berisikan Tema yang saya gunakan sekarang, lalu tinggal saya modifikasi sesuka saya.

Memang ini merupakan hal yang mudah, tapi hal ini sangat merepotkan saya, terlebih kalo tema tersebut ada pembaruan penting buat blog saya dari Hulu (_Upstream_), sehingga mau tidak mau saya harus memperbarui nya secara manual, itu malesin banget.

Awalnya saya ingin memanfaatkan perintah `git` untuk memperbarui nya, tapi karena terlalu banyak berkas yang di modifikasi, akhirnya malah menimbulkan konflik, sehingga ini menjadi kurang efisien. Mungkin karena saya kurang jago dalam menggunakan `git` ini kali yah, hehe 😀

Dan menurut saya, 1 Repo terpisah hanya untuk Modifikasi Tema ini memang _gak banget_.

Bisa saja temanya saya letakkan di dalam Kode Sumber Blog saya, namun ujung-ujungnya yah sama saja + Ukuran Repo Git nya malah jadi "buncit" nantinya gara-gara tema.

Sedangkan di Hugo, saya cuma perlu merubah berkas-berkas seperlunya dengan memanfaatkan folder-folder yang ada di Kode Sumber Blog nya, seperti: `layouts` (Untuk Tata letak Tema), `data` (Untuk Data pada Tema/Blog) dan `i18n` (Untuk Terjemahan pada Tema) untuk memodifikasi tema tanpa harus membuat _Repository_ baru lagi atau gak perlu 'ngubek-ngubek' berkas dari tema aslinya secara keseluruhan, mirip seperti konsep ["WordPress Child Themes"](https://developer.wordpress.org/themes/advanced-topics/child-themes/).

Caranya mudah, Anda tinggal copas berkas yang ingin Anda rubah ke dalam Kode Sumber Blog/Situs Web kamu, lalu tinggal modifikasi sesuka hati Anda.

Pastikan lokasi/direktori berkas di Kode Sumber Blog/Situs Web nya mengikuti direktori berkas pada Tema nya. 

Contoh: Jika Anda ingin merubah isi berkas `article.html` yang terletak di dalam direktori `themes/(NAMA_TEMA)/layouts/partials/article`, maka Anda perlu meletakkannya ke dalam direktori `layouts/partials/article` pada Kode Sumber Blog/Situs Web nya juga.

Dan berkat ini, saya hanya perlu manfaatkan _Git Submodules_ saja untuk meng-install temanya.

### Fitur Bawaan
Di Pelican, fitur bawaannya kurang begitu lengkap untuk kebutuhan saya, untuk menambahkan suatu fitur saja, saya harus menambahkan sejumlah _Plugin_ yang menurut saya itu cukup rumit.

Bahkan agar bisa membuat artikel dengan lebih dari satu kategori saja saya harus memasang sebuah _Plugin_, yang mana ini akan membuat kecepatan untuk menghasilkan Blog Statis menjadi berkurang. Belum lagi rata-rata _Plugin_ yang ada kebanyakan malah tidak diperbarui/tak 'terawat'.

Sedangkan di Hugo, fitur-fitur bawaan yang ada di Hugo terbilang cukup lengkap bagi saya, bahkan Hugo sendiri telah menyediakan sejumlah Template Internal "Google Analytics", "Disqus", dll agar kemudian bisa di aplikasikan oleh pembuat Tema jika berkenan.

Dan dengan memanfaatkan fitur _Shortcodes_ saat membuat berkas Markdown, kita bisa menyisipkan _Tag_/Kode HTML yang kita butuhkan, bahkan ketika fitur tersebut tidak ada di Tema sekalipun. 

~~Seperti fitur "Daftar Isi" yang tidak semua Tema punya, termasuk Tema yang [saya gunakan ini](https://github.com/CaiJimmy/hugo-theme-stack/) yang sampai sekarang [belum ada fiturnya](https://github.com/CaiJimmy/hugo-theme-stack/issues/129).~~

**PEMBARUAN, 03 November 2021:** Sekarang tema ini memiliki fitur Daftar Isi sejak versinya yang ke [v2.4.0](https://github.com/CaiJimmy/hugo-theme-stack/releases/tag/v2.4.0).

### Optimalisasi Blog/Web
**Catatan**: Bagian ini masih berhubungan dengan Bagian ["Fitur Bawaan"](#fitur-bawaan).

Sudah menjadi rahasia umum memang bahwa Optimalisasi Blog/Web menjadi aspek yang sangatlah penting, karena tidak semua orang memiliki koneksi Internet yang cepat dan stabil, bahkan jika sudah menggunakan Layanan CDN (_Content Delivery Network_) atau ADN (_Application Delivery Network_) sekalipun.

Sehingga memadatkan berkas Skrip, HTML (atau disebut: _minify_) dan mengoptimalkan Gambar yang di muat itu sudah menjadi kewajiban bagi pemilik/pemelihara Blog/Web.

Di Pelican, untuk bisa mengoptimalkan Skrip, HTML dan Gambar saja harus menggunakan Plugin dan meng-install beberapa modul yang diperlukan, sehingga hal ini mengorbankan kecepatan dalam menghasilkan/_me-render_ Blog Statis itu sendiri.

Sedangkan di Hugo, masalah di atas tidak terjadi, di Hugo juga tersedia fitur optimasi yang cukup lengkap (Kecuali konversi gambar ke format ~~WebP,~~ AVIF dan JXL) yang tentu nya itu merupakan fitur bawaan, tinggal pembuat/pemodifikasi Tema nya saja yang mau mengoptimalkan nya atau tidak.

**PEMBARUAN, 03 November 2021:** Hugo sekarang mendukung pemrosesan gambar WebP, termasuk konversi gambar ke format WebP sejak versi [0.83.0](https://gohugo.io/news/0.83.0-relnotes/)

Untuk alasan nya, saya cukupkan disini saja, sebenarnya masih ada lagi alasan kenapa saya malah bermigrasi ke Hugo, cuma gak mau saya bahas aja, kepanjangan nanti nya, artikel segini aja udah panjang :face_with_tongue:

Setelah saya membahas Alasan nya, saya ingin menekankan bahwa membahas alasan Migrasi ke Hugo bukan berarti saya menjelekkan SSG sebelumnya, yakni Pelican. Saya cuma murni ingin membagikan pengalaman saya saja selama menggunakan nya, semua juga memiliki kelebihan dan kekurangan nya masing-masing tergantung kebutuhan pengguna nya saja, kalo untuk kasus saya yah Pelican ini kurang bisa memenuhi kebutuhan saya akan hal itu.

## Bagaimana Migrasi nya?
Untuk migrasinya sendiri cukup mudah, saya hanya perlu migrasi artikel-artikel dan beberapa laman saja.

Saya lakukan itu secara manual serta saya perlu untuk mengedit beberapa teks dan beberapa tautan agar mereka bisa tampil dengan layak.

Untuk gambarnya sendiri, seperti yang Anda lihat, sekarang saya tidak menggunakan Repo dari luar lagi, tapi sebagai gantinya saya meletakkan berkas gambarnya ke dalam direktori masing-masing Artikelnya secara bersamaan dengan berkas Markdown nya.

Untungnya saat ini artikelnya masih sedikit, sehingga saya gak terlalu capek melakukannya.

Konfigurasi dan Plugin tidak mungkin saya migrasikan kesini, begitupun dengan temanya, sehingga pada akhirnya saya ganti tema juga.

## Rencana Blog Kedepan
### Penggunaan SSG dan Arsip Blog lama
Karena saya sudah lebih puas menggunakan Hugo daripada SSG sebelumnya, maka sudah pasti saya tidak akan beralih lagi ke SSG sebelumnya.

Dan mungkin juga saya akan membuat Arsip untuk Blog dengan SSG sebelum nya, biar kalian nanti nya tahu seperti apa blog saya sebelumnya, itupun jika situasi dan kondisi nya memungkinkan.

Untuk saat ini, Arsip nya bisa Anda lihat [di sini](https://web.archive.org/web/20200922225546/https://farrel.franqois.id/).

Di bawah ini adalah cuplikan layar mengenai penampilan dari Blog Statis lama saya:

![Penampilan dalam Mode Terang](ksnip_20210310-220030.png) ![Penampilan dalam Mode Gelap](ksnip_20210312-153141.png)

### Hosting
Untuk sekarang ini, saya menggunakan Netlify sebagai Hos nya dan tentu saja ini versi gratis nya yang (sepertinya) cuma terdiri dari 6 PoP (_Point of Presence_).

Jumlah seperti ini tentu saja sangatlah sedikit, tapi memang ini masih jauh lebih baik ketimbang saya meng-hos-kan nya di Layanan _Web Hosting_ kebanyakan.

Pada awal tahun ini, [bunny.net](https://bunny.net) (sebelumnya BunnyCDN) berencana ingin memperkenalkan sebuah Produk Penyimpanan berbasiskan S3 nya, berdasarkan cuitan di bawah ini:

{{< x user="BunnyCDN" id="1333016696089526273" >}}

Jika itu benar-benar terjadi, maka saya akan berencana untuk pindah Hosting ke bunny.net dengan memanfaatkan Penyimpanan S3 nya + CDN nya selama Saldo saya masih banyak, daripada saya harus tinggal lama di Netlify.

**PEMBARUAN Kamis, 22 Maret 2021:** Sekarang saya telah menggunakan Bunny CDN untuk Hosting nya, meskipun mereka masih menggunakan protokol FTP, terlalu lama rasanya jika saya menunggu dan pindah Hosting ini dari awal bulan ini. Tapi, pada akhirnya saya bisa menemukan cara untuk men-_deploy_ Blog nya tanpa harus menggunakan JavaScript/NodeJS.

**PEMBARUAN Rabu, 07 Juli 2021:** Sekarang ini saya sudah menggunakan [Storj DCS (Decentralized Cloud Storage)](https://www.storj.io) sebagai Hosting, jadi saya gak terlalu perlu menunggu fitur dari Bunny\.net tentang _Object Storage_ nya.

### CI/CD (_Contnuous Integration/Continuous Delivery_)
Hingga saat ini, saya masih menggunakan layanan CI/CD (_Contnuous Integration/Continuous Delivery_) bawaan dari Netlify nya. Ini peran nya untuk menghasilkan Blog Statis dari Kode Sumber yang ada saat saya melakukan `git push`.

Sebelumnya saya gunakan ["GitHub Actions"](https://github.com/features/actions) untuk layanan CI/CD nya, namun karena proses pembuatan nya yang begitu ruwet (sampai harus melibatkan NodeJS segala untuk _Deploy_ ke Netlify), maka gak saya gunakan lagi untuk saat ini.

Jika Produk Penyimpanan S3 dari Bunny.net benar-benar di perkenalkan pada awal tahun ini, maka saya akan kembali gunakan "GitHub Actions" untuk layanan CI/CD nya.

**PEMBARUAN Kamis, 22 Maret 2021:** Karena saya telah menggunakan Bunny CDN untuk Hosting nya, maka saya menggunakan GitHub Actions untuk layanan CI/CD nya.

**PEMBARUAN Rabu, 07 Juli 2021:** Saya sudah menggunakan Storj DCS sebagai hosting, dan masih tetap menggunakan GitHub Actions sebagai CI/CD, hanya saja sekarang menjadi lebih mudah saja.

### Artikel Blog
Seperti yang Anda lihat, bahwa sekarang Iklan dan Analitik di blog ini sudah tidak ada sama sekali.

Kenapa? Sederhana, karena itu memperlambat akses blog serta mengurangi kenyamanan pengunjung karena Iklan dan Analitik yang terpasang. Belum lagi masalah Privasi yang ada pada Layanan tersebut (walaupun bisa saja diblokir menggunakan _Adblocker_ sih).

Lalu, bagaimana nanti saya mendapatkan Uang? Karena Iklan tidak ada, maka sebagai ganti nya saya akan membuat "Artikel Berbayar".

Ya, Anda gak salah lihat ataupun baca, "Artikel Berbayar". Dimana Anda perlu membayar atau berlangganan dengan biaya tertentu agar Anda bisa membaca nya. Tentu saja, tidak semua Artikel di sini berbayar dan hanya Artikel tertentu saja yang saya buat berbayar.

Saya akan gunakan _Platform_ Trakteer untuk melakukan hal itu, jika Anda ingin membaca Artikel Berbayar nya nanti, Anda hanya perlu mentraktir saya [disini](https://trakteer.id/farrelf).

### Sistem Komentar
Untuk saat ini saya masih menggunakan [Disqus](https://disqus.com) sebagai Sistem Komentar nya, namun Disqus disini juga memiliki sebuah masalah.

Selain masalah tentang banyaknya aset Web yang dimuat atau dengan kata lain "terlalu buncit" bagi kebanyakan orang (meskipun sudah menggunakan fitur "IntersectionObserver" sebagai _Lazy-load_ nya sih), Disqus juga memiliki [masalah pada Privasi Pengguna nya](https://www.google.com/search?q=Disqus+Privacy+Concerns), sehingga saya berencana ingin memigrasikan Sistem Komentar di Blog ini.

Rencana nya saya ingin menggunakan [Remark42](https://remark42.com) atau [Staticman](https://staticman.net) sebagai Sistem Komentar nya, tapi saya sendiri bingung untuk mempertimbangkan nya. 

"Remark42" memang memiliki fitur yang lumayan lengkap sebagai Sistem Komentar yang minimalis, bahkan Anda bisa menggunakan Akun dari Layanan lain untuk berkomentar atau bahkan berkomentar sebagai Anonim. Tapi sayangnya saya harus punya VPS minimalnya, sedangkan saya sendiri belum sanggup menyewanya karena belum punya duit.

Sedangkan "Staticman" meskipun Gratis, komentar yang ditampilkan nya bersifat statis, mendukung Markdown, serta ada fitur Anti-spam nya juga. Tapi sayang nya fiturnya tidak selengkap Remark42, seperti tidak adanya Login menggunakan Akun lain, Edit dan Hapus Komentar dari segi pengomentar, serta kurangnya dukungan dari tema nya juga karena implementasi nya sangatlah kompleks dan sulit, hal ini terjadi karena komentar yang ditampilkan nya bersifat statis semua.

Atau, mungkin saya migrasi ke [Comments dari Telegram](https://comments.app) atau [Utterances](https://utteranc.es) yang berbasis GitHub _Issues_ aja kali yah? Kalau Anda punya saran mengenai Sistem Komentar lain nya, bisa Anda sarankan itu di dalam kolom komentar atau bisa [Hubungi Saya](/tentang).

### Perbaikan, Peningkatan dan Penambahan Fitur
Hingga saat ini, fitur di Blog ini masih jauh dari kata 'sempurna' yang selalu saja merasa kurang atau terjadi Kutu (_Bug_)/Kesalahan dalam Koding.

~~Untuk saat ini, terjadi kesalahan pada bagian "Konten Terkait" yang terletak di setelah Akhir Artikel/Laman, yang gambar nya tidak menggunakan CDN dari Statically yang saya setel di dalam berkas Konfigurasi, padahal di Tema nya sudah saya setel juga.~~

**PEMBARUAN Rabu, 10 Maret 2021:** Saat ini, kutu tersebut sudah 'dimusnahkan' (alias sudah diperbaiki) berdasarkan _Commit_ [`5ee86d2`](https://github.com/FarrelF/Blog/commit/5ee86d24e2ce6875a70aab716f4bc9fa38f7dacf) di GitHub, sehingga gambar-gambar tersebut telah menggunakan CDN dari Statically.

~~Penampilan _Spoiler_ di dalam Artikel juga yang lebar nya tidak mengikuti huruf-huruf nya, alias kelebaran.~~

~~**EDIT dari Rabu, 10 Maret 2021:** Ehh salah deh, bukan 'kelebaran', melainkan saat diklik _Spoiler_ nya, malah ada garis seperti _Border_ yang kerap mengganggu kenyamanan. Seperti pada gambar berikut:~~

![Perhatikan persegi panjang yang ditunjuk anak panah itu. Nah, itu garis _border_ yang saya maksud!](ksnip_20210310-214151.png)

~~Ini rencana nya akan saya perbaiki, tapi gak tau kapan waktu nya 🙁~~

**PEMBARUAN Jum'at, 12 Maret 2021:** Masalah di atas sepertinya sudah diselesaikan berdasarkan dari _Commit_ [`f596ffe`](https://github.com/FarrelF/Blog/commit/f596ffe4d389728bdd00ddac042a4aa10bf47b57) di GitHub.

Dengan selesainya masalah-masalah di atas, bukan berarti saya tidak berniat untuk menambahkan fitur ataupun memperbarui tema, saya akan berusaha untuk menambahkan fitur di blog ini jika saya ingin, tapi itu tidak tahu kapan 🙁

## Penutup
Ya sudah, sepertinya pembahasan di artikel ini saya cukupkan sampai sini saja dulu, kalau misalnya saya berniat ingin merubah rencana nya, maka akan saya perbarui lagi artikel ini.

Di artikel ini saya cuma membahas kenapa saya Migrasi ke Hugo, Bagaimana Migrasi nya, lalu apa rencana kedepan nya, gak ada yang lebih juga.

~~Walaupun begitu, terima kasih bagi Anda yang telah membaca artikel ini yang saat ini belum ada gambar nya sama sekali.~~

**PEMBARUAN Rabu, 10 Maret 2021:** Sekarang artikel ini sudah ada gambar nya, walaupun sedikit, tapi saya usahakan untuk menambahkan gambar di artikel ini agar lebih menarik lagi.

Mohon maaf, jika artikel ini memiliki kekeliruan dan kesalahan, baik dari ada yang salah ngetik, terlalu panjang, bertele-tele, dll. Dan, saya juga tidak bermaksud untuk menyinggung siapapun disini, saya cuma mau mengungkapkan pengalaman saya saja, serta rencana kedepan nya.

Seperti yang sudah saya bilang sebelumnya. bahwa membahas alasan Migrasi ke Hugo bukan berarti saya menjelekkan SSG sebelumnya, yakni Pelican. Semua SSG mempunyai kelebihan dan kekurangan nya masing-masing, tergantung kebutuhan nya seperti apa, kalo untuk kasus saya yah Pelican ini kurang bisa memenuhi kebutuhan saya akan hal itu.

Jika adanya kesalahan dan kekeliruan, atau kalo Anda memiliki pertanyaan lain nya, bisa Anda berikan masukkan melalui kolom komentar yang tersedia. Masukkan dari Anda akan sangat berarti bagi saya dan artikel ini untuk kedepan nya nanti.

Terima kasih atas perhatian nya 😊
