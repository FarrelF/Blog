---
Title: Cara menghemat Konsumsi Bandwidth Server
Slug: menghemat-konsumsi-bandwidth-server
Author: Farrel Franqois
Categories: 
    - Tutorial
    - Web dan Blog
    - Server
Date: 2021-05-06 16:10:30+07:00
image: micheile-henderson-SoT4-mZhyhE-unsplash.webp
Tags: 
    - Bandwidth
    - Cara Menghemat
    - Cache
    - Optimalisasi
readMore: true
DescriptionSEO: Apakah Anda ingin menghemat konsumsi bandwidth server, sehingga web/blog Anda bisa bertahan? Kalau iya, silakan baca artikel ini!
Description: |-
    Apakah Anda menggunakan sebuah Hosting untuk web/blog Anda, tapi hosting tersebut membatasi kuota _bandwidth-nya_?

    Sehingga Anda ingin menghemat konsumsi _bandwidth_ server/hosting agar web/blog Anda bisa tetap bertahan meski 'dihantam' oleh pengunjung/bot selama ribuan atau bahkan jutaan kali, tapi tidak tahu caranya?

    Jika Anda ingin tahu caranya, silakan lanjut baca artikel ini, kalo tidak ya tidak usah 🙂
---

## Pembuka

Kita semua tahu bahwa tidak semua Hosting menerapkan _unmetered bandwidth_ atau _unlimited bandwidth_ sehingga diberlakukan batasan kuota _bandwidth_, jika melebihi batas tersebut maka web/blog menjadi tidak bisa diakses dan disuruh/disarankan membayar biaya tambahan untuk menambahkan batasan tersebut agar web/blog bisa diakses.

Bahkan Hosting untuk Web Statis seperti Netlify, GitHub Pages, Render, dan Surge.sh pun menerapkan batasan kuota ini. Maka mau-gak mau, suka-gak suka, para pemilik web/blog harus menghemat konsumsi _bandwidth_ server daripada web/blog-nya gak bisa diakses hanya karena kehabisan kuota. Belum lagi sama kuota internet pengunjung yang juga terbatas, kalau habis ya harus beli lagi, 'kan boros jadinya 🙂

Nah, saya berikan solusi bagi yang ingin menghemat konsumsi _bandwidth_ ketika web/blog Anda 'dihantam' oleh pengunjung dan bot selama beberapa kali yang mungkin bisa Anda implementasikan. Tentu saja solusinya tidak cukup dilakukan salah satu saja, melainkan 2 atau sampai 4 solusi harus kamu lakukan demi menghemat konsumsi _bandwidth_ server/hosting.

## Sanggahan

Perlu Anda pahami bahwa artikel ini hanyalah membahas bagaimana caranya untuk menghemat kuota _bandwidth_ server, bukan cara mengoptimalkan sebuah web/blog ataupun cara menghemat kuota internet pengunjung, karena itu merupakan dua hal yang sangat berbeda.

Namun dengan ini, Anda juga bisa mengoptimalkan web/blog Anda dan bahkan menghemat kuota internet pengunjung Anda (terutama jika pengunjung tersebut setia terhadap web Anda), atau malah justru sebaliknya.

Segala risiko yang ada setelah menerapkan salah satu atau lebih dari satu solusi pada web Anda, silakan Anda tanggung sendiri. Serta dengan menerapkan solusi-solusi di bawah ini, maka saya anggap bahwa Anda telah memahami solusi yang saya bahas serta risiko yang Anda terima nantinya.

Jadi, mohon perhatian dan pengertiannya dari pembaca sekalian 🙂

Terima kasih atas perhatian dan pengertiannya 😊

## Solusi-solusi untuk menghemat _bandwidth_ server

Berikut di bawah ini adalah solusi-solusi yang bisa Anda terapkan:

### Solusi ke-1: Lakukan kompresi terhadap berkas-berkas statik {#solusi-ke1}

Melakukan kompresi terhadap berkas-berkas statik (seperti berkas JS, CSS, Gambar, dll) sebelum digunakan oleh web/blog itu **Wajib Hukumnya!**

Ya kali, kamu ingin mengunggah dan menyebarkan serta 'menyajikan' berkas gambar yang besarnya beberapa puluhan bahkan ratusan Megabita ke dalam web/blog kamu kepada pengunjung, kalau saya jadi pengunjungnya, saya malah langsung kabur alih-alih mengunjunginya.

Selain membuang-buang kuota, hal tersebut akan membuat konsumsi sumber daya di perangkat meningkat drastis karena peramban web akan memproses berkas-berkas statiknya.

Sudah banyak sekali perangkat lunak atau situs web yang memiliki fitur untuk mengoptimalkan berkas-berkas statik, salah satunya mengkompresi berkas gambar tanpa harus menurunkan kualitas gambar secara kasat mata manusia, sebut saja situs web seperti [TinyJPG](https://tinyjpg.com/) atau [TinyPNG](https://tinypng.com/) yang dapat mengkompresi berkas gambar PNG aau JPG, ini bisa Anda lakukan sebelum mengunggah suatu berkas gambar ke dalam web/blog Anda.

Atau, untuk mengoptimalkan berkas-berkas gambar di komputer/laptop Anda tanpa harus mengunggahnya ke web/blog dulu, Anda bisa gunakan perangkat lunak seperti [Caesium](https://saerasoft.com/caesium)\*, [Imagine](https://github.com/meowtec/Imagine), [Squosh](https://squosh.app), [FileOptimizer](https://nikkhokkho.sourceforge.io/static.php?page=FileOptimizer)\* atau [ImageOptim](https://imageoptim.com/mac) untuk pengguna Apple macOS 10.9+.

**\*Catatan:** Dua perangkat lunak yang ditandai bintang itu hanya mendukung sistem operasi Windows saja.

Jika Anda menggunakan WordPress\.org (Hos Mandiri/_Self-hosted_), harusnya sudah banyak sekali yang menyediakan sejumlah _plugin_ untuk melakukan kompresi dan optimasi terhadap berkas-berkas statik sebelum akhirnya 'disajikan' kepada pengunjung.

Atau, jika Anda menggunakan SSG (_Static-site Generator_), terutama Hugo, maka seharusnya ada fitur ["Image Processing"](https://gohugo.io/content-management/image-processing/) untuk memproses berkas Gambar dan ["Hugo Pipes"](https://gohugo.io/hugo-pipes/) untuk memproses berkas-berkas JS, CSS dan SASS yang bisa diimplementasikan ke dalam Tema.

Selebihnya masih banyak cara lain yang dapat Anda lakukan untuk mengecilkan ukuran berkas-berkas statik, sebelum akhirnya digunakan untuk produksi.

### Solusi ke-2: Buatlah aset web dapat di-cache dalam waktu lama {#solusi-ke2}

Peramban Web akan menyimpan sumber daya tertentu, seperti berkas-berkas gambar, JS, CSS, HTML dan berkas statik lainnya disuatu tempat yang disebut dengan **Cache** setelah situs web/blog selesai dimuat atau dikunjungi oleh pengguna.

Solusi kali ini adalah membuat aset-aset web/blog kamu harus tersimpan di dalam _cache_ dalam waktu yang lama.

Kenapa? Biar supaya pengunjung tidak perlu lagi memuat ulang aset-aset web/blog dari server setiap kali membaca halaman lainnya. Apa pengaruhnya buat server? Ya pengaruhnya membuat server tidak perlu lagi mengirimkan aset kepada pengunjung, sekligus ini meringankan tugas server juga.

Maka dari itu, _caching_ itu menjadi syarat mutlak untuk membangun pengalaman pengguna yang baik, karena pengalaman akses yang cepat bukan semata-mata hanya karena servernya berkinerja tinggi atau pun karena berkas-berkasnya sudah teroptimasi dengan baik, tetapi karena setelan _cache_ yang ideal.

Untuk mengetahui perbedaan jika sumber daya disimpan ke dalam _cache_ peramban web, serta digunakan atau tidaknya, bisa Anda lihat cuplikan berikut:

![Tanda berkas belum _di-cache_ oleh peramban web saat kunjungan pertama](Sebelum_Di_Cache_Web_Browser.png) ![Tanda Berkas sudah _di-cache_ oleh Peramban Web dan digunakan setelah mengunjunginya kembali](Setelah_Di_Cache_Web_Browser.png)

Namun, seringkali bahwa aset-aset web/blog tidak tersimpan ke dalam _cache_ dengan benar, bahkan ada yang sengaja tidak menyimpan aset-aset tersebut ke dalam _cache_, padahal itu adalah aset statik yang tidak diubah setiap hari.

Kayak gimana contohnya? Contohnya saat pengunjung mengunjungi halaman lainnya setelah bersinggah ke halaman pertama, fon-fon eksternal pun harus dimuat agar teks bisa tampil dengan baik, tetapi karena tidak _di-cache_, maka fon-fon tersebut dimuat dari servernya langsung. Hal seperti ini sebenarnya kurang bagus, karena selain bikin boros kuota server, ini juga bikin boros kuota pengunjung (kalau ada).

Salah satu cara agar supaya aset-aset web dapat _di-cache_ dalam waktu lama adalah mengatur dan menyetel _HTTP Header_ `Cache-Control` dengan benar.

![Contoh Header Cache-Control untuk sebuah Berkas Gambar (ada di anak panah)](Contoh_Header_Cache-Control.png)

Mungkin Anda belum pernah mengenal _HTTP Header_ satu ini. Yap, `Cache-Control` merupakan sebuah _HTTP Header_ yang berfungsi untuk mendikte perilaku _cache_ yang dilakukan oleh peramban web.

Saat pengguna mengunjungi situs web-nya kembali, di sinilah _HTTP Header_ `Cache-Control` itu berperan, _header_ tersebut menetapkan sebuah aturan untuk menentukan apakah peramban web yang digunakan oleh pengguna tersebut akan memuat sumber daya yang diperlukannya melalui _cache_ atau justru malah sebaliknya, serta dapat mengatur/menentukan durasi penyimpanan _cache_-nya.

Dalam konteks menghemat konsumsi _bandwidth_ baik dari segi server atau klien, mungkin Anda berpikir bahwa membuat peramban web dapat menyimpan sumber dayanya dalam waktu yang sangat lama ke dalam _cache_ (seperti mengatur _header_ `Cache-Control`-nya menjadi `public, max-age=31536000, immutable`) itu merupakan solusi yang saling menguntungkan, bukan?

Kalau seperti itu, memang benar, tetapi akibatnya tampilan situs web menjadi tidak berubah sama sekali bahkan dapat merusak penampilan sebuah situs web, atau lebih parahnya konten-konten pada situs web menjadi tidak terlihat diperbarui (alias _"outdated\"_ atau "gak _update_") bahkan setelah menerbitkan pembaruannya selama beberapa kali.

Hal ini terjadi karena peramban web akan tetap memuatnya melalui _cache_ dan yang dimuat itu bukanlah berkas yang baru, melainkan yang telah disimpan sebelumnya atau yang lama, sehingga sumber dayanya tertahan oleh _cache_.

Jadi, aturlah _header_ tersebut dengan benar dan lakukan teknik _Cache Busting_ pada berkas-berkas statik sebelum mengatur `Cache-Control`-nya, serta bedakan mana sumber daya yang harus _di-cache_ dalam waktu yang lama atau tidaknya.

Untuk cara menyetel _HTTP Header_ (untuk _Response Header_)-nya, bisa Anda kunjungi referensi berikut:

- [How to modify HTTP headers using .htaccess files](https://www.a2hosting.com/kb/developer-corner/apache-web-server/modifying-http-headers) (Untuk Pengguna Apache/LiteSpeed Enterprise)
- [How to Set Up Custom Headers - OpenLiteSpeed](https://openlitespeed.org/kb/how-to-set-up-custom-headers/) (Untuk Pengguna OpenLiteSpeed)
- [Adding and using header (HTTP) in nginx - Stack Overflow](https://stackoverflow.com/questions/11973047/adding-and-using-header-http-in-nginx) (Untuk Pengguna NGINX)
- [Custom headers - Netlify Docs](https://docs.netlify.com/routing/headers/) (Untuk Pengguna Netlify)
- [HTTP Headers for Static Sites - Render](https://render.com/docs/static-site-headers) (Untuk Pengguna Render sebagai hosting web statis)
- [Configuration - Vercel](https://vercel.com/docs/configuration#project/headers) (Untuk Pengguna Vercel)

Sedangkan untuk mengatur _Header_ `Cache-Control` dengan benar, beserta dengan teknik _Cache Busting_-nya, ada referensi yang cukup bagus untuk Anda pelajari, bisa Anda kunjungi melalui tautan berikut:

- [Cache-Control for Civilians - CSS Wizardy](https://csswizardry.com/2019/03/cache-control-for-civilians/)
- [Caching best practices & max-age gotchas - JakeArchibald.com](https://jakearchibald.com/2016/caching-best-practices/)

Sebenarnya selain `Cache-Control`, ada _HTTP Header_ lain untuk urusan _cache_ seperti `Last-Modified` untuk mencocokan berkas di dalam _cache_ dan di server berdasarkan waktu modifikasi terakhir dan `ETag` yang berdasarkan _hash_ dari suatu berkas. Sehingga jika berkas di dalam _cache_ pengunjung itu cocok dengan yang ada di server, maka akan menggunakan berkas yang tersimpan di dalam _cache_, kalau tidak maka peramban web pengunjung akan mengunduh berkas baru dari server.

Karena kedua itu berdasarkan kecocokan, maka kedua itu tidak bisa kamu atur sendiri secara sembarangan, perlu dukungan _webserver_ untuk itu dan kontrol perilaku _cache_ yang sangat terbatas, bahkan kamu tidak mungkin mengatur perilaku _cache_ seperti pada halnya _header_ `Cache-Control`.

Contoh: Kamu tidak mungkin bisa meminta peramban web kamu dan yang lain seperti pengunjung kamu untuk _men-cache_ berkas tersebut hanya untuk komputernya saja, tidak untuk _proxy_ server seperti CDN, tidak seperti `Cache-Control` yang cukup memakai direktif `private` saja alih-alih menggunakan `public`, dll.

Untuk perbedaannya dan praktik terbaiknya, silakan kunjungi referensi berikut:

- [Browser Caching | Practical: ETags and Cache-control (oleh Tejendra Pal Singh di Medium)](https://medium.com/@ironman8318/browser-caching-practical-etags-and-cache-control-6c7139bdcb39)

Intinya, saya sarankan untuk tetap mengatur perilaku _cache_ meskipun servermu mendukung _header_ `Last-Modified` atau/dan `ETag` dengan _header_ `Cache-Control` untuk melengkapinya dan beri setelan yang ideal untuk web Anda.

Selain di atas, Anda juga bisa memasang dan memakai "Service Worker" di dalam web/blog Anda agar peramban tersebut dapat mengunduh, lalu memuat aset-aset yang telah tersimpan di dalam penyimpanan lokal sebelumnya tanpa harus terkoneksi dengan internet sama sekali.

### Solusi ke-3: Memuat berkas-berkas statik (atau bahkan web) dari server lain {#solusi-ke3}

Jika Anda ingin menghemat konsumsi _bandwidth_ server, maka Anda bisa menghoskan berkas-berkas statik lainnya di server yang berbeda. Contohnya?

Anda mempunyai blog yang disimpan di dalam Server A yang mempunyai kuota _bandwidth_ sebesar 100 GB/Bulan, untuk menyiasati atau mengakalinya, Anda bisa menyimpan berkas-berkas statik lainnya di Server B yang batasan _bandwidth-nya_ sangat besar (sampai dikira tidak terbatas).

Sehingga peramban web milik pengunjung akan memuat berkas-berkas statiknya melalui Server B jika mengunjungi blog Anda daripada Server A dan akan menghemat konsumsi _bandwidth_ pada Server A, karena pada dasarnya Server A tidak digunakan untuk memuat berkas-berkas statik.

Ini adalah salah satu cara yang paling ampuh untuk menghemat konsumsi _bandwidth_ server ketimbang solusi-solusi tersedia lainnya.

Contoh lain? Sesuai contoh di atas, Anda juga dapat menggunakan [Google Fonts](https://fonts.google.com) atau [Adobe Fonts](https://fonts.adobe.com) sebagai penyedia fon untuk web/blog Anda ketimbang melakukan hos mandiri (bahasa Inggris: _Self-host_) di server utama Anda.

Atau, Anda juga bisa memakai layanan CDN untuk publik seperti [cdnjs](https://cdnjs.com), [unpkg](https://unpkg.com), atau [jsDelivr](https://www.jsdelivr.com) untuk memuat pustaka-pustaka web/blog yang ada, seperti jQuery, Bootstrap, Twemoji dan pustaka lainnya ketimbang melakukan hos mandiri.

Bahkan Anda juga dapat menggunakan layanan CDN (_Content Delivery Network_) pihak ketiga yang dipasang pada web/blog Anda untuk mengakalinya, seperti menggunakan layanan CDN dari Cloudflare yang gratisan misalnya.

Lho, kok bisa? Karena pada dasarnya jika Anda menggunakan CDN pihak ketiga untuk web/blog Anda, maka pengunjung akan memuat web/blog atau berkas-berkas statiknya dari server CDN, meskipun perlu proses 'penarikan' berkas dari server aslinya.

Kira-kira, illustrasinya seperti berikut:

![Illustrasi tentang Distribusi dari Satu Server (Kiri) dan Distribusi menggunakan CDN (Kanan)](NCDN_-_CDN.png)

Untuk layanan CDN yang gratis, Anda bisa gunakan layanan CDN untuk publik yang saya sebut di atas, seperti jsDelivr, cdnjs atau unpkg.

Intinya, buatlah agar pengunjung memuat berkas statiknya dari server lain selain server utama untuk menghemat _bandwidth_ dari server utama, itu aja. Serta, sekali lagi saya sebutkan bahwa cara ini merupakan salah satu cara yang paling ampuh dalam menghemat konsumsi _bandwidth_ Server.

### Solusi ke-4: Buatlah agar berkas-berkas statik tidak bisa diakses dari luar {#solusi-ke4}

Jika Anda ingin lebih menghemat konsumsi _bandwidth_ server, maka buatlah berkas-berkas statik tidak bisa diakses dari luar web Anda.

Kenapa? Karena jika Anda membiarkan gambar-gambarnya diakses dari web lain, maka hal ini akan mengonsumsi _bandwidth_ dari server Anda secara terus-menerus dan ini bisa saja merupakan praktik pencurian aset web tanpa izin dari Anda. Praktik tersebut dinamakan _Hotlinking_.

Jika Anda bertanya bagaimana cara untuk mencegah hal seperti ini, maka jawabannya adalah blokir aksesnya jika berkas tersebut tidak merujuk dari web Anda ketika mengaksesnya. Contoh: Buatlah berkas-berkas yang ada di `website-a.com` hanya bisa diakses dari domain `website-a.com` saja, bukan dari domain `website-b.com`, dsb.

Jika Anda menggunakan CDN dari Cloudflare, maka Anda bisa mengaktifkan fitur **Hotlink Protection** yang terletak pada bagian **Scrap Shield** di dalam [Dasbor Cloudflare Anda](https://dash.cloudflare.com). Atau, jika Anda menggunakan layanan CDN, maka Anda perlu melakukannya melalui panel yang tersedia dari penyedia CDN-nya.

Jika Anda menggunakan layanan _shared hosting_ dan tidak menggunakan CDN sama sekali, maka di dalam kontrol panel yang digunakan oleh pihak hosting (seperti: cPanel, DirectAdmin, dll) harusnya sudah ada fitur proteksi dari praktik _hotlinking_ secara bawaan, Anda dapat gunakan itu jika ada.

Atau, Anda bisa kunjungi referensi berikut jika ingin menyetelnya secara manual:

- [What Is Hotlinking? - KeyCDN Support](https://www.keycdn.com/support/what-is-hotlinking)
- [How to Prevent Image Hotlinking in Apache with .htaccess - TecAdmin](https://tecadmin.net/disable-image-hotlinking-apache/) (Hanya untuk Pengguna Apache/LiteSpeed Enterprise)

### Solusi ke-5: Gak mau ribet? Tambah kuotanya atau pindah! {#solusi-ke5}

Iya, saya tahu bahwa ini bukanlah cara menghemat, karena saya kasih solusi bagi Anda yang tidak ingin kuota _bandwidth-nya_ habis, tetapi gak mau ribet dengan melakukan solusi-solusi di atas. Atau, ini akan cocok bagi Anda yang menyerah setelah melakukan solusi-solusi di atas.

Yap, Anda tinggal memikirkan bagaimana caranya menambah kuota _bandwidth_ yang tersedia jika tidak mau ribet. Untuk saat ini pilihannya cuma dua, yakni bayar biayanya atau pindah ke penyedia lain yang kuotanya lebih banyak.

Tidak ada pilihan selain itu dan ini merupakan solusi yang cukup realistis atau masuk akal. Jika Anda ingin gratis, lakukan kedua atau sampai keempat solusi di atas, sedangkan jika Anda tidak mau ribet atau sudah menyerah, tinggal tambahkan saja kuotanya, sesederhana itu bukan?

## Pertanyaan dan Jawaban yang (akan) sering ditanya {#pertanyaan-dan-jawaban}

Ini adalah bagian yang berisi tentang pertanyaan yang (akan) sering ditanyakan, beserta jawabannya.

Mungkin Anda perlu membaca pertanyaan dan jawabannya terlebih dahulu sebelum bertanya di kolom komentar sebagai referensi Anda.

### Pertanyaan ke-1: Apa itu _Cache Busting_? {#pertanyaan-ke1}

**Jawab:** _Cache Busting_ adalah sebuah teknik agar peramban web dapat memuat berkas yang lebih baru saat mengunjung sebuah situs web/blog setelah adanya perubahan pada berkas tersebut, tanpa harus menunggu selama itu, tapi berkas-berkas tersebut akan tetap _di-cache_ dalam waktu yang sangat lama.

Teknik ini akan menjawab pertanyaan seperti berikut:

> Sebelumnya, saya telah mengatur agar berkas-berkas statik bisa tersimpan _di-cache_ dalam waktu 1 tahun oleh peramban web, tapi masalahnya saya baru saja telah melakukan perubahan pada berkas tersebut.
>
> Jadi, bagaimana agar pengunjung tidak perlu menunggu selama 1 tahun untuk dapat menikmati perubahannya? Masa saya harus nyuruh pengunjung untuk membersihkan _Cache_ atau _Clear Cache_ pada peramban webnya?

Intinya, melakukan teknik _Cache Busting_ akan menyelesaikan masalah di atas.

### Pertanyaan ke-2: Situs web/blog saya terpasang iklan (salah satunya: Google AdSense), apakah hal itu akan membuat boros konsumsi _bandwidth_ server? {#pertanyaan-ke2}

**Jawab:** Tidak, karena pada dasarnya Anda tidak menyimpan berkas apa pun ke dalam server Anda, kecuali Anda menyisipkan skrip ke dalam HTML dan itu pun ukurannya sangat kecil.

Sehingga jika skrip tersebut termuat, maka yang dimuat adalah aset/sumber daya yang berasal dari server lain, bukan dari server Anda dan sangat sedikit pengaruhnya bagi server Anda.

Namun, kalau ditanya "Apakah ini akan membuat boros kuota internet pengunjung?" maka jawabannya adalah **Iya**.

Karena pada dasarnya peramban web pengunjung secara otomatis akan memuat iklan-iklan yang sangat dinamis dalam berbagai format (entah itu dalam bentuk teks, gambar, video, dan lain-lain) saat berkunjung ke situs web/blog Anda dan itu menggunakan koneksi internet dari pengunjung agar bisa termuat, kecuali jika diblokir dari sisi klien/pengunjung.

### Pertanyaan ke-3: Apakah tidak ada solusi lain? {#pertanyaan-ke3}

**Jawab:** Untuk saat ini tidak ada, solusi-solusi yang saya tulis itu merupakan solusi yang cukup realistis/masuk akal supaya Anda dapat mengimplementasinya dengan baik, sehingga hanya solusi itu yang saya tahu.

Jika Anda memiliki solusi lain, maka Anda bisa memanfaatkannya. Namun, jika Anda memiliki solusi masuk akal lainnya, silakan berikan masukkan dari Anda melalui kolom komentar 🙂

### Pertanyaan ke-4: Saya menggunakan CDN dari Cloudflare untuk Web/Blog saya demi menghemat konsumsi _bandwidth_, maka solusi mana yang saya implementasikan? {#pertanyaan-ke4}

**Jawab:** Kamu mengimplementasikan [Solusi ke-3](#solusi-ke3).

Lho, kenapa? Karena pada dasarnya kamu telah mengatur bahwa pengunjung situs web/blog kamu akan dilayani oleh Cloudflare, sehingga web kamu akan dimuat menggunakan Server dari Cloudflare ketika dikunjungi, bukan lagi oleh server Anda, meskipun Cloudflare membutuhkan penarikan berkas-berkas/sumber daya yang diperlukan dari server Anda.

Jadi maksudnya adalah jika Anda menggunakan CDN dan melakukan _reverse-proxy_ (seperti menggunakan CDN dari Cloudflare), maka pengunjung tidak lagi mengakses server aslinya, melainkan server CDN-nya, sehingga ini akan bisa menghemat konsumsi _bandwidth_ server.

### Pertanyaan ke-5: Apakah menghemat konsumsi _bandwidth_ server sama dengan menghemat kuota internet pengunjung? {#pertanyaan-ke5}

**Jawab:** Tidak selalu, bisa iya dan bisa juga tidak, terutama jika Anda memiliki sumber daya eksternal (dari luar server Anda) dan itu tetap dimuat oleh pengunjung saat mengunjungi web/blog Anda.

Kenapa bisa begitu? Karena setiap server memiliki kebijakan yang berbeda-beda, terutama perlakuan _Cache_ pada peramban web, ada server yang mengizinkan agar peramban web dapat menyimpan berkas-berkas/sumber daya ke dalam _Cache_ dalam waktu yang sangat lama, bahkan ada pula yang tidak mengizinkan sama sekali.

Terlebih, saat mengunjungi web/blog Anda, peramban web akan memuat segala sumber daya yang diperlukannya, baik yang asalnya dari dalam server itu sendiri dan dari luar server yang tentunya memiliki kebijakan yang berbeda-beda.

Jika server luarnya tidak mengizinkan peramban web untuk menyimpan berkas-berkas ke dalam _cache_, sedangkan server asli mengizinkannya, maka hal ini akan membuat konsumsi _bandwidth_ internet pengunjung akan meningkat dan akan membuat boros kuota internet jika itu terjadi terus-terusan, kecuali jika diblokir dari sisi klien/pengunjung.

Contohnya adalah _platform_ iklan seperti Google AdSense yang terpasang di web/blog (mengacu pada [pertanyaan kedua](#pertanyaan-ke2)), karena sifatnya yang sangat dinamis dan bisa tampil dalam berbagai format, supaya bisa tampil seperti itu dan bisa ganti iklan, maka tidak mungkin server akan mengizinkan peramban web menyimpan Iklan tersebut ke dalam _cache_.

Iklan tersebut dimuat dari server lain, sehingga konsumsi _bandwidth_ server utama tidak terpengaruh, tetapi hal tersebut membuat kuota internet pengunjung jadi boros karena membiarkan peramban web memuat iklannya, kecuali jika iklannya diblokir.

Namun, hal ini akan beda lagi jika kedua server (baik luar ataupun dalam) sama-sama mengizinkan peramban web untuk menyimpan berkas sumber dayanya ke dalam _cache_ dalam waktu yang lama, maka baik kuota internet pengunjung dan konsumsi _bandwidth_ server akan bisa sedikit diperhemat.

### Pertanyaan ke-6: Apakah ada perangkat lunak, situs web/solusi lain untuk mengoptimalkan berkas-berkas statik selain yang disebutkan di dalam artikel ini? {#pertanyaan-ke6}

**Jawab:** Banyak, tapi cari sendiri di mesin pencari aja, banyak jawabannya di sana.

Kata kunci yang bisa Anda gunakan untuk mesin pencari adalah, seperti: `Image Compression`, `Image Compressor`, `Image Optimizer`, `CSS Minify`, `JS Minify`, `CSS Minifier`, `JS Minifier` atau kata kunci lainnya yang bisa Anda kembangkan sendiri.

Jika Anda ingin mencari perangkat lunaknya, bisa tambahkan `Software` di akhir kata kuncinya, seperti `Image Compression Software` misalnya atau kembangkan saja sendiri biar hasilnya lebih akurat.

### Pertanyaan ke-7: Apakah semua solusi yang ada di sini itu mempercepat atau mengoptimalkan sebuah Situs Web/Blog? {#pertanyaan-ke7}

**Jawab:** Bisa iya, bisa juga tidak, atau bahkan bisa terjadi sebaliknya. Kecepatan akses dan kecepatan penyelesaian pemuatan pada web/blog itu terjadi karena banyak faktor.

Sedangkan untuk mengoptimalkan sebuah web/blog agar cepat diakses dan dimuat oleh peramban web itu banyak yang harus Anda lakukan selain melakukan solusi-solusi di atas.

Bahkan bisa terjadi sebaliknya, yakni web/blog menjadi lambat ketika diakses, atau malah sampai menjadi tidak tersedia (_nge-down_) setelah melakukan solusi-solusi di atas.

Jadi, jika Anda ingin menerapkan salah satu atau lebih dari solusi di atas, maka segala resiko harus Anda tanggung sendiri.

### Pertanyaan ke-8: Saya gak mau ribet kayak solusi-solusi di atas dan gak mau bayar juga, terus gimana solusi gratis yang paling mudah dan paling instannya, tentunya bebas ribet? {#pertanyaan-ke8}

**Jawab:** Menggunakan CDN dari Cloudflare yang Gratisan bisa cukup membantu untuk kasus seperti itu.

Atau jika bisa, terapkan [solusi ke-3](#solusi-ke3) untuk web/blog Anda, contoh paling mudah memakai [Google Fonts](https://fonts.google.com) atau [Adobe Fonts](https://fonts.adobe.com) sebagai penyedia fon atau simpan berkas gambar di penyedia hosting untuk gambar, seperti [Imgur](https://imgur.com), [Postimages](https://postimages.org/id/) atau [ImgBB](https://imgbb.com/).

Namun, kalau kamu masih menganggapnya ribet atau sulit untuk dilakukan, maka solusinya adalah dengan menutup akses pangunjung ke web/blog Anda, entah itu dengan mengosongkan web/blog-nya atau memblokir akses dari pengunjung melalui _Firewall_ atau menghapus/menutup Web/Blog Anda atau lainnya.

Dengan ini, kuota _bandwidth_ akan bisa diperhemat, bahkan kuotanya malah jadi tidak terpakai sama sekali.

Solusinya gak ribet, instan dan sangat mudah untuk dilakukan bagi semua orang, tanpa perlu mengeluarkan biaya sedikit pun.

## Penutup

Ya sudah, artikelnya saya cukupkan dulu saja di sini. Dari artikel ini, Anda belajar bahwa untuk menghemat kuota _bandwidth_ server memang harus ada usaha yang cukup dari yang punya web/blog, kalau gak mau ribet ya solusinya nambah kuota, entah itu bayar atau pindah ke penyedia lain.

Terima kasih bagi Anda yang telah membaca artikel ini. Gimana? Pusing kan? Yah, saya hanya memberitahukan konsepnya saja, terlebih satu bagian di artikel ini memang "Panjang x Lebar", jadi maaf kalau saya tidak bisa memberikan cara implementasinya secara detail.

Serta, mohon maaf jika artikel ini memiliki kekeliruan dan kesalahan, baik dari ada yang salah ngetik, terlalu panjang, bertele-tele, dll.

Jika adanya kesalahan dan kekeliruan dari saya, atau jika Anda memiliki pertanyaan lainnya/klarifikasi, bisa Anda berikan masukkan melalui kolom komentar yang tersedia. Masukkan dari Anda akan sangat berarti bagi saya dan artikel ini untuk kedepannya nanti.

Terima kasih atas perhatiannya 😊

## Penggunaan Gambar dan Atribusi

Berkas-berkas gambar (seperti cuplikan layar dan gambar lainnya) yang digunakan di dalam artikel ini, tersedia di dalam [repositori blog ini](https://github.com/FarrelF/Blog).

Jika Anda ingin menjelajahinya, silakan kunjungi alamat URL berikut:

```plain
https://github.com/FarrelF/Blog/tree/main/content/post/2021/05/06-cara-menghemat-konsumsi-bandwidth-server
```

Gambar Illustrasi yang nama berkasnya adalah {{< a-file path="NCDN_-_CDN.png" >}}`NCDN_-_CDN.png`{{< / a-file >}} itu merupakan illustrasi yang dibuat oleh "Kanoha" bersumber dari [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:NCDN_-_CDN.png) dan dilisensikan di bawah ["CC BY-SA 3.0 Unported"](https://creativecommons.org/licenses/by-sa/3.0/deed.en) oleh sang pembuat.

Serta, sebuah foto yang nama berkasnya adalah {{< a-file path="micheile-henderson-SoT4-mZhyhE-unsplash.jpg" >}}`micheile-henderson-SoT4-mZhyhE-unsplash.jpg`{{< / a-file >}} yang saya gunakan sebagai sampul artikel itu merupakan sebuah foto yang dipotret oleh ["Micheile Henderson"](https://unsplash.com/@micheile) bersumber dari [Unsplash](https://unsplash.com/photos/SoT4-mZhyhE) dan dilisensikan di bawah ["Unsplash License"](https://unsplash.com/license) oleh sang pembuat.
