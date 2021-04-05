---
Title: Apa itu Cloudflare? Perlukah untuk menggunakan nya?
Slug: apa-itu-cloudflare-dan-perlukah
Author: Farrel Franqois
Categories: 
    - Layanan Internet
    - Opini
Date: 2021-04-06 02:22:39+07:00
image: cf-logo-v-rgb.jpg
draft: true
Tags: 
    - Cloudflare
    - CDN
    - DNS
    - Firewall
    - Pengelola DNS
enableSummary: true
Description: Banyak Situs Web/Blog yang menyarankan untuk menggunakan Cloudflare demi mengoptimalkan dan mengamankan suatu Web/Blog. Apa iya?
Summary:
    <p>
    Seperti yang Anda tahu bahwa Cloudflare merupakan Layanan Internet yang cukup populer di kalangan Blogger atau para Pengembang Web, banyak sekali Situs Web/Blog yang menyarankan untuk menggunakan nya demi mengoptimalkan dan mengamankan suatu Web/Blog dari serangan yang berasal dari luar (seperti Serangan DDoS, <i>Defacer</i>, dll).
    </p>
    <p>
    Tapi, Apa itu Cloudflare? Perlukah untuk menggunakan nya? Apakah benar bahwa Cloudflare bisa membantu untuk mengoptimalkan dan mengamankan sebuah Web/Blog? Jika penasaran, silahkan baca artikel ini lebih lanjut, jika tidak ya tidak usah 🙂
    </p>
---

## Daftar Isi
{{< toc >}}

## Apa itu Cloudflare?
**Cloudflare&reg;** (atau lengkapnya: **Cloudflare, Inc.**) adalah sebuah perusahaan Amerika Serikat yang menyediakan jasa-jasa yang diperuntukan bagi pembuat ataupun yang mengelola sebuah Web/Blog, seperti jasa jaringan pengantaran konten/_Content Delivery Network_ (CDN), pencegah serangan DDoS, mengamankan Web/Blog, Analitik, Pengelola Domain dan DNS.

Selain untuk Pembuat atau Pengelola Web/Blog, Cloudflare juga menyediakan sebuah Layanan DNS Rekursif yang di tujukan untuk semua pengguna, yang bernama [**1.1.1.1&trade;**](https://1.1.1.1) dan bahkan Cloudflare telah menyediakan Aplikasi nya agar semua orang bisa menggunakan nya dengan mudah.

Jadi sekarang udah jelaskan Cloudflare itu apaan? Namun apakah saya perlu untuk menggunakan nya? Jawaban nya ya "entar dulu", abis ini nanti akan saya bahas dulu apa kelebihan dan kekurangan nya, karena jawaban nya akan sangat berhubungan dengan ini.

## Kelebihan menggunakan Cloudflare untuk Web/Blog
Untuk pembahasan kali ini, saya cuma membahas kelebihan menggunakan Cloudflare sebagai CDN, Pengelola DNS dan _Firewall_ saja mengingat banyak sekali jasa/layanan dari Cloudflare, namun ketiga ini yang paling sering di gunakan oleh para Blogger atau Pengembang/Pengelola Web di bandingkan lain nya.

Kelebihan menggunakan Cloudflare saya jabarkan berikut di bawah ini.

### Membuat Web/Blog menjadi lebih hemat Kuota _Bandwidth_
Kalau kamu menggunakan Hosting yang mana Kuota _Bandwidth_ (Pita lebar) nya terbatas atau cuma dapat sedikit saja, siapa sih yang gak mau menghemat penggunaan Kuota nya? Apalagi jika Web/Blog nya ramai di kunjungi orang dan robot tiap hari?

Dengan menggunakan Layanan CDN nya, maka Anda dapat menghemat penggunaan _Bandiwdth_ Server. 

Lho, kok bisa? Karena dengan menggunakan CDN pada Web/Blog Anda, maka ketika orang lain mengunjungi Web/Blog Anda, Penjelajah Web milik Pengunjung tersebut hanya mengunduh berkas-berkas statis dari Server CDN nya alih-alih dari Server Asli nya.

Kira-kira, Illustrasi nya seperti berikut:
![Illustrasi tentang Distribusi dari Satu Server (Kiri) dan Distribusi menggunakan CDN (Kanan)](NCDN_-_CDN.png)

Hal inilah yang membuat penggunaan _Bandwidth_ akan menjadi jauh lebih hemat dari biasanya, apalagi jika Anda menyetel _Header_ `Cache-Control` nya dengan benar, maka Anda akan bisa mengurangi penggunaan _Bandwidth_ nya secara signifikan!

Terlebih jika sistem pembiayaan untuk paket-paket pada layanan/jasa dari Cloudflare pun tidak menggunakan Sistem _Pay-as-you-Go_ (PAYG) sebagai Sistem Pembiayaan atau tidak perlu membayar tergantung pada penggunaan, melainkan itu merupakan Biaya _Flat_ per bulan saja, bahkan ada Gratisan nya juga. 

Sehingga, ini akan sangat cocok bagi Anda yang memiliki Web/Blog yang kunjungan nya sangat ramai, tapi tidak mau di bebani oleh tagihan yang membludak akibat penggunaan _Bandwidth_ yang sangat besar.

### DNS Otoritatif nya yang sangat cepat, reliabel dan cukup kaya fitur
Tahukah Anda bahwa Layanan DNS Otoritatif dari Cloudflare itu sangatlah cepat dan reliabel?

Jika Domain Anda terhubung ke DNS Cloudflare dan menggunakan nya sebagai Pengelola DNS dibandingkan dengan Pengelola DNS bawaan, maka Anda bisa mengurangi potensi _Downtime_ atau ketidaktersediaan pada Domain Anda dan Domain Anda bisa di _resolve_ lebih cepat oleh pengunjung.

Kenapa bisa gitu? Karena Cloudflare telah di tenagai oleh Server-server di 200 Kota dari 100 Negara di seluruh dunia yang mana ini akan saling berkaitan, begitupun juga CDN nya. 

Jadi, jika satu server DNS Cloudflare tidak tersedia, maka hanya perlu di rute ulang ke server lain nya dan hal ini memungkinkan untuk mempercepat _Resolve_ DNS dari segi Pengunjung, karena pengunjung mendapatkan server terdekat nya saat me-_resolve_ domain yang terhubung dengan DNS Cloudflare.

Karena DNS Otoritatif dari Cloudflare merupakan Pengelola DNS Eksternal, sehingga jika Server Hosting mengalami ketidaktersediaan atau _Downtime_, maka layanan lain seperti surel eksternal, subdomain yang terhubung ke server lain, dll, tidak akan mengalami hal demikian.

Selain itu, DNS Otoritatif ini memiliki cukup kaya akan fitur. DNSSEC untuk keamanan DNS? Ada! Cloudflare mendukung hal itu, Anda tinggal tambahkan Pengaturan DNSSEC pada Domain Anda melalui _Registrar_, untuk nilai-nilai nya, ikuti dengan yang ada di Cloudflare. 

"CNAME Flattening"? Ada! Cloudflare malah mendukung nya dan ini di aktifkan secara bawaan untuk 'root' nya saja. Anda juga bisa ekspor dan impor pengaturan DNS Anda dalam format BIND9 sewaktu-waktu jika ingin migrasi.

### SSL Gratis dan mendukung Browser yang lebih tua
Jika Hosting yang Anda gunakan tidak menyediakan SSL sama sekali, maka Anda bisa gunakan CDN dari Cloudflare agar Web/Blog Anda bisa di akses dengan Protokol HTTPS secara gratis, masa berlaku akan di perbarui secara otomatis oleh mereka.

Akar (atau _Root_) dari Sertifikat SSL yang di gunakan nya pun telah di dukung oleh Web Browser dari Perangkat yang lebih tua, selama Web Browser tersebut mendukung SNI (singkatan dari "Server Name Indication") yang merupakan fitur dari protokol TLS.

### 
