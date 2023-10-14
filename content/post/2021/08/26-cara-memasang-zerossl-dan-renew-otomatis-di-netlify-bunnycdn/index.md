---
Title: Cara memasang ZeroSSL + Renew Otomatis di Netlify, BunnyCDN, cPanel dan DirectAdmin
Slug: cara-memasang-zerossl-di-netlify-bunnycdn-cpanel-directadmin
Aliases:
    - cara-memasang-zerossl-di-netlify-bunnycdn
    - cara-memasang-zerossl-di-netlify-bunnycdn-cpanel
    - cara-memasang-zerossl-di-netlify-bunnycdn-directadmin
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Info Blog
    - Tutorial
Image: ZeroSSL-Logo.webp
Date: 2021-08-26 20:51:00+07:00
Tags:
    - Sertifikat SSL/TLS
    - ZeroSSL
    - Netlify
    - BunnyCDN
    - cPanel
    - DirectAdmin
readMore: true
DescriptionSEO: Apakah Anda ingin memasang ZeroSSL, tetapi Anda juga ingin bisa me-renew-nya secara otomatis di Netlify, BunnyCDN, cPanel dan DirectAdmin? Jika iya, Anda bisa baca artikel ini untuk mengetahuinya.
Description: |-
    Blog ini telah menggunakan ZeroSSL sebagai Sertifikat SSL/TLS-nya, tetapi kendalanya adalah CA ini tidak didukung oleh Penyedia Web secara luas, artinya sertifikat tersebut belum bisa _di-renew_ secara otomatis.
    
    Namun akhirnya, kendala tersebut bisa saya atasi berkat bantuan dari beberapa referensi yang ada dan saya ingin membagikannya pada Anda, terutama untuk pengguna [Netlify](https://www.netlify.com), [BunnyCDN](https://afiliasi.farrel.franqois.id/bunny/cdn/), cPanel dan DirectAdmin.
    
    Jika Anda ingin memasang Sertifikat SSL/TLS dari ZeroSSL pada Web Statis Anda yang menggunakan Netlify sebagai Hosting atau menggunakan BunnyCDN sebagai CDN, cPanel atau DirectAdmin sebagai Panel untuk layanan Hosting Anda, serta _me-renew-nya_ secara otomatis atau sekadar ingin tahu saja, mungkin Anda bisa baca artikel ini.
---

## Pembuka

{{< info title="Catatan" >}}
Jika Anda tidak ingin membaca basa-basinya, Anda bisa langsung lanjut ke subbagian [**"Prakata"**](#prakata) sebelum ke subbagian [**"Persiapan"**](#persiapan).
{{< / info >}}

Artikel kali ini akan membahas tentang Cara memasang ZeroSSL + Renew secara Otomatis di [Netlify](https://www.netlify.com), [BunnyCDN](https://afiliasi.farrel.franqois.id/bunnycdn), cPanel dan DirectAdmin.

~~Blog ini telah menggunakan ZeroSSL sebagai Sertifikat SSL/TLS-nya dalam bentuk _Wildcard_. Gak percaya? Silakan Anda lihat sendiri.~~

**PEMBARUAN, 08 Mei 2022:** Blog ini telah memakai Google Trust Services (GTS), tidak lagi menggunakan ZeroSSL, tetapi semua instruksi yang artikel ini bahas tidak banyak berubah/tidak berubah total.

Kendala saat pemasangannya adalah tidak banyak penyedia yang mendukungnya, kebanyakan hanya mendukung Let's Encrypt saja.

Sehingga saya perlu menggunakan acme.sh untuk menerbitkan/memperbarui Sertifikat SSL/TLS, lalu saya melakukan _Request_ ke Server API-nya Netlify, BunnyCDN, cPanel dan DirectAdmin untuk memasangkan sertifikatnya menggunakan curl.

Terlihat sederhana, bukan? Iya, tetapi sebenarnya itu tidak sesederhana dan semudah yang Anda bayangkan.

Berkat bantuan dari beberapa referensi, akhirnya saya dapat memasangkan sertifikat tersebut dan membuatnya dapat diperbarui secara otomatis.

Nah, makanya saya buat artikel ini, siapa tahu mungkin Anda tertarik atau merasa tertantang untuk memasang Sertifikat SSL/TLS dari ZeroSSL ini ke dalam Web/Blog Anda bila dibandingkan dengan Let's Encrypt. Semoga artikel ini akan bermanfaat buat Anda 🙂

Di sini, Anda akan mempelajari untuk menerbitkan Sertifikat SSL/TLS yang bisa Anda dapatkan dari ZeroSSL, baik jangkauannya untuk 1 domain, banyak domain atau subdomain, atau _wildcard_ dengan menggunakan acme.sh sebagai perkakasnya, setelah itu Anda akan memasangkannya dengan cara memanggil Server API milik bunny.net dan Netlify memakai curl.

Bagi yang belum tahu, [ZeroSSL](https://zerossl.com) adalah salah satu CA (_Certificate Authority_) atau Otoritas Sertifikat yang menerbitkan/mengelola/mencabut Sertifikat SSL/TLS untuk Internet. Ia merupakan salah satu produk dari [Stack Holdings](https://www.linkedin.com/company/stackholdings/about/).

Sedangkan [acme.sh](https://acme.sh) adalah sebuah perkakas klien untuk Protokol ACME, yang bertujuan sebagai alat bantu untuk menerbitkan, memperbarui, mencabut atau mengelola Sertifikat SSL/TLS. Perkakas tersebut dibuat dengan menggunakan _Shell_ dan Kompatibel di hampir semua sistem operasi berbasis \*nix.

### Tunggu, ZeroSSL Gratis? Bukannya bayar? {#zerossl-gratis}

Iya, untuk saat ini ZeroSSL memanglah gratis, bahkan Anda juga dapat menerbitkan Sertifikat SSL/TLS secara gratis dalam bentuk apa pun (termasuk _Wildcard_) dengan jumlah sertifikat yang tidak terbatas, baik dengan menggunakan RSA maupun ECC sebagai Algoritma Kunci Publiknya.

Namun, itu hanya berlaku jika Anda menerbitkannya melalui Server ACME-nya, bukan melalui Situs Web ataupun REST API-nya. Semua sertifikat yang diterbitkan melalui Protokol ACME akan memiliki masa berlaku selama 90 hari ke depan.

Serta, jika Anda membuat/menerbitkan sebuah Sertifikat SSL/TLS melalui Protokol ACME dan Server ACME-nya, maka jumlah sertifikat yang telah diterbitkan yang tampil di Situs Web-nya tidak akan bertambah sama sekali, jadi kuota gratisannya tidak akan berkurang.

Infonya dari mana? Salah satu infonya berasal dari [dokumentasinya](https://zerossl.com/documentation/acme/).

~~Namun, sebetulnya jika kamu lebih teliti lagi, di Halaman "[Pricing](https://zerossl.com/pricing/)"-nya pun kamu akan menemukan tulisan "90-Day ACME Certs" yang bersebelahan dengan Simbol "tidak terbatas", yang artinya kamu dapat menerbitkan Sertifikat SSL/TLS dari Server ACME-nya dalam bentuk apa pun secara gratis tanpa batasan jumlah.~~

**PEMBARUAN, 16 Oktober 2021:** Simbol tersebut sekarang sudah tidak ada lagi di halaman tersebut, mungkin tujuannya memang untuk _marketing_ biar ZeroSSL tidak dianggap gratis.

![Halaman "Pricing" di ZeroSSL, per tanggal: 16 Oktober 2021](ZeroSSL_Pricing.webp)

Nah, sekarang sudah paham, kan? Jadi, Anda tidak perlu jadi orang kaya atau berduit banyak dulu biar bisa menerbitkan Sertifikat SSL/TLS dari ZeroSSL, kecuali jika Anda ingin Layanan Dukungan, Akses REST API-nya, serta Sertifikat SSL/TLS dengan masa berlaku selama 1 Tahun, Anda bisa berlangganan yang berbayar.

### Kenapa ZeroSSL? Dan, kenapa gak pakai Let's Encrypt aja? {#zerossl-vs-lets-encrypt}

#### Kompatibilitas Perangkat

Sertifikat SSL/TLS dari ZeroSSL bergantung pada Sectigo (sebelumnya dikenal sebagai "COMODO CA"/"COMODO" saja) sebagai sertifikat akar dari rantai sertifikatnya (yang bisa disebut dengan "Rantai Kepercayaan", bahasa Inggrisnya: _Chain of Trust_), yang telah didukung dan dipercaya oleh mayoritas perangkat lunak sejak lama.

Informasi mengenai sertifikat akarnya sebagai berikut:

- Akar untuk Rantai (_Chain of Trust_) Pertama: "[AAA Certificate Services](https://crt.sh/?id=331986)" yang masa berlakunya sampai 31 Desember 2028 pukul 23:59:59 atau 01 Januari 2029 dalam waktu UTC

- Akar untuk Rantai (_Chain of Trust_) Kedua: "[USERTrust RSA Certification Authority](https://crt.sh/?id=1199354)" atau "[USERTrust ECC Certification Authority](https://crt.sh/?id=2841410)" yang masing-masing masa berlakunya sampai 18 Januari 2038 pukul 23:59:59 atau 19 Januari 2038 dalam waktu UTC

Ini artinya, hampir semua perangkat lunak bisa menggunakan sertifikat ini, bahkan oleh perangkat lunak versi lama sekali pun (cth. Internet Explorer 6.0+, Mozilla Firefox 1.0+, Opera 6.1+, AOL 5+, Peramban pada Blackberry 4.3.0+, Android 1.5+, dll)

Untuk lebih lanjut, Anda bisa kunjungi halaman [daftar kompatibilitasnya](https://help.zerossl.com/hc/en-us/articles/360058294074-ZeroSSL-Compatibility-List).

Sedangkan Akar dari _Chain of Trust-nya_ Let's Encrypt adalah "[DST Root CA X3](https://crt.sh/?id=8395)" (dari "IdenTrust") yang juga mendukung dan dipercaya oleh mayoritas perangkat lunak, termasuk Windows XP SP3 dan Android 7.1.1 kebawah.

Namun, sebelumnya sempat ada ["kegundahan"](https://letsencrypt.org/2020/11/06/own-two-feet.html) karena Akar yang mereka gunakan sudah mau habis masa berlakunya, akar tersebut akan habis pada tanggal 30 September 2021 dan akan digantikan dengan yang baru, yakni "[ISRG Root X1](https://crt.sh/?id=9314791)" (dari "Internet Security Research Group"), sehingga ini berimbas pada perangkat lama, terutama untuk Android 7.1.1 kebawah.

Namun, masalah ini [selesai](https://letsencrypt.org/2020/12/21/extending-android-compatibility.html) untuk Android dengan melakukan _Cross-Signing_, yang artinya sertifikat akar yang lama (DST Root CA X3) telah menerbitkan sertifikat yang 'sama dengan' sertifikat akar barunya, yakni "[ISRG Root X1](https://crt.sh/?id=3958242236)" sebagai sertifikat penengah, agar 'rantai' dapat terus digunakan meski ada bagian yang rapuh karena sudah habis masanya.

![Cuplikan layar Rantai Kepercayaan dari Let's Encrypt di Android 6.0 (di dalam Peramban Web berbasis Chrome/Chromium), bukti bahwa Cross-sign itu bekerja](Hierarki_Sertifikat_SSL_Lets_Encrypt_di_Android_6.webp)

Hal ini bukan berarti masalah sudah selesai sepenuhnya, kemungkinan besar bahwa ada perangkat lain yang tidak kompatibel dengan Akar baru ini setelah Akar pertama habis masa berlakunya, kecuali Windows XP SP3 (jika Anda memperbarui sertifikat akarnya) dan Android 2.3.6 (atau di atasnya).

Berdasarkan Halaman [Kompatibilitas sertifikatnya](https://letsencrypt.org/docs/certificate-compatibility/), sepertinya perangkat yang mempercayai "ISRG Root X1" itu berkurang bila dibandingkan dengan perangkat yang mempercayai "DST Root CA X3". Sehingga, ada kemungkinan bahwa banyak perangkat lain yang tidak kompatibel dengan Let's Encrypt.

{{< info title="**PEMBARUAN, 03 Oktober 2021:**" >}}
Per tanggal 30 September 2021 kemarin, sertifikat akar "DST Root CA X3" telah habis masa berlakunya dan telah diganti menjadi "ISRG Root X1".

Meski masa berlakunya habis, Let's Encrypt tetap kompatibel dengan sistem operasi Android 7.1.1 ke bawah, tetapi masih menggunakan "DST Root CA X3" sebagai akarnya (lihat cuplikan layar di atas).

Jadi, jika Anda menggunakan Android 7.1.1 ke bawah, maka Anda tidak perlu melakukan apa pun.

Namun jika Anda tidak menggunakan Android, tidak bisa mengakses Web/Blog yang menggunakan Let's Encrypt atau sekadar ingin menikmati akar baru dari Let's Encrypt, silakan unduh sertifikat akar "[ISRG Root X1](https://letsencrypt.org/certs/isrgrootx1.pem)", lalu instal sertifikat akar tersebut agar dapat dipercaya oleh perangkat Anda.

Setelah selesai menginstal, nonaktifkan/hapus sertifikat akar lama, yakni "DST Root CA X3" dari perangkat Anda.

Selain mengunduh dan menginstal sertifikat akarnya secara manual, Anda juga dapat memperbarui sistem pada perangkat Anda agar dapat menikmati sertifikat akar yang baru.
{{< / info >}}

Jadi, jika Anda ingin sebuah Sertifikat SSL/TLS Gratis untuk Web/Blog atau Aplikasi Anda serta dapat diakses oleh hampir semua orang atau/dan Anda kurang yakin dengan resolusi dari pihak Let's Encrypt, mungkin ZeroSSL bisa menjadi pilihan yang terbaik untuk Anda.

#### Tidak (atau Belum?) menerapkan _Rate Limit_ {#tidak-menerapkan-rate-limit}

Sampai artikel ini diterbitkan, ZeroSSL tidak (atau Belum?) menerapkan _Rate Limit_ atau batasan penerbitan Sertifikat SSL/TLS, tidak seperti Let's Encrypt yang telah menerapkannya sejak lama.

Gak percaya? Silakan Anda kunjungi [halaman komparasinya](https://zerossl.com/letsencrypt-alternative/#acme) (Baca bagian "ACME"-nya) atau [halaman dokumentasinya](https://zerossl.com/documentation/acme/).

Jadi, Anda tidak perlu takut jika Anda mengalami kegagalan menerbitkan Sertifikat SSL/TLS dengan alasan apa pun, karena _Rate Limit_ tidak ditentukan di sana.

#### Memiliki antarmuka untuk mengelola sertifikat {#antarmuka-pengelola-sertifikat}

ZeroSSL memiliki antarmuka untuk mengelola Sertifikat SSL/TLS di dalam Situs Web-nya. Di sana, Anda bisa melihat Sertifikat SSL/TLS yang telah Anda terbitkan, sekaligus mengelola sertifikatnya.

![Cuplikan Layar Halaman Dasbor ZeroSSL](ZeroSSL_Dashboard.webp) ![Cuplikan Layar mengenai sertifikat yang telah diterbitkan](ZeroSSL_Issued_Certificates.webp)

Selain itu, Anda bisa menghabiskan kuota "SSL Gratis" yang telah diberikan oleh mereka dengan membuat Sertifikat SSL/TLS dari Situs Web-nya.

Namun sayangnya, Anda tidak bisa mencabut Sertifikat SSL/TLS yang telah Anda terbitkan melalui server ACME-nya di dalam Situs Web-nya, jadi Anda hanya bisa melihat dan mengunduhnya saja.

### Prakata

Sebelum Anda lanjut, saya peringati bahwa Artikel/Tutorial yang dibahas ini sangatlah "Panjang x Lebar", jika Anda tidak sanggup membaca Artikel yang terlalu panjang, saran saya cari artikel lain yang membahas ini dengan lebih sederhana, jangan paksakan diri Anda kecuali jika ingin belajar.

Meskipun artikel ini panjang kali lebar, saya usahakan agar semuanya saya bahas dalam langkah-demi-langkah, sehingga lebih mudah dipahami oleh Anda.

Oleh karena itu, saya sarankan untuk memakai perangkat dengan layar yang lebih besar ketimbang layar dari ponsel yang Anda pakai sekarang (cth. PC/Laptop, Monitor, Tablet/Televisi Pintar, Penggunaan fitur "Desktop Mode" pada Ponsel/Tablet Pintar, dll) dan memiliki sebuah papan ketik (_Keyboard_) untuk mengikuti artikel ini.

Jika Anda mengalami kesulitan dalam bernavigasi, gunakan fitur "Cari di Halaman" di Peramban Web Anda dengan menekan tombol <kbd>Ctrl</kbd> + <kbd>F</kbd>, lalu isi dengan bagian atau teks yang ingin Anda cari.

Saya usahakan agar pembahasan di artikel ini dapat diterapkan atau diikuti oleh hampir semua pengguna sistem operasi, termasuk sistem operasi Windows dan hampir semua sistem operasi berbasis \*nix, seperti sistem operasi yang berbasis Linux (cth. GNU/Linux, Android, Alpine Linux, dll), macOS, BSD, dan sistem operasi \*nix lainnya.

Namun, bukan berarti Anda dapat mengikuti semuanya meskipun saya berusaha agar ini bisa diikuti oleh hampir semua sistem operasi, karena saya belum mencoba di sistem operasi selain GNU/Linux, Windows dan Android, sehingga saya tidak berani menjaminnya.

Jadi, mohon perhatian dan pengertiannya, jika Anda melanjutkan berarti Anda sudah memahami semuanya.

Terima kasih dan selamat melanjutkan 😊

### Persiapan {#persiapan}

Di artikel ini, Anda akan mempelajari menerbitkan Sertifikat SSL/TLS dengan menggunakan [acme.sh](https://acme.sh) yang (harusnya) hanya kompatibel dengan sistem operasi berbasis Unix atau mirip Unix (\*nix), termasuk GNU/Linux, macOS, BSD dan Android.

Dengan ini, tentu saja salah satu hal yang harus Anda siapkan adalah pengetahuan tentang perintah-perintah dasar dari sistem operasi berbasis \*nix, seperti `ls`, `cd`, dan dibarengi dengan pengenalan variabel dasar seperti `$HOME` dan `$PATH` serta fitur `~` di dalam _Shell_, menambahkan variabel, penavigasian, bisa _copy-paste_ dari luar ke dalam Terminal dan sebaliknya, dan bisa mengedit berkas di dalam Terminal.

Kata "Terminal" di sini bukan merujuk pada "Terminal Kendaraan" atau "Terminal Bis" ya, "Terminal" yang saya maksudkan di sini adalah aplikasi Emulator Terminal (_Terminal Emulator_) seperti x-term, Konsole, GNOME Terminal, Windows Terminal, Git Bash, dll.

Selain itu, Anda juga harus mempersiapkan perangkat lunak yang diminta agar perkakas acme.sh bisa digunakan dan Anda bisa mengikuti artikel ini secara keseluruhan, apalagi jika Anda menggunakan sistem operasi Windows.

Berikut di bawah ini adalah persiapan perangkat lunaknya:

#### Untuk Pengguna GNU/Linux, macOS, BSD dan Sistem Operasi berbasis \*nix lainnya {#persiapan-pengguna-unix-like}

{{< spoiler title="tl;dr" >}}
Jika terlalu panjang, maka perangkat lunak yang harus Anda siapkan adalah sebagai berikut:

- OpenSSL (atau LibreSSL?)
- curl
- Cron
- [`jq`](https://jqlang.github.io/jq/) (khusus pengguna cPanel dan/atau DirectAdmin)

Socat (Socket Cat) di sini bersifat opsional, ini hanya berlaku jika Anda ingin menjalankan acme.sh dalam "Standalone Mode", jadi ini tidak wajib Anda instal dan artikel ini tidak membahasnya lebih lanjut.
{{< / spoiler >}}

Kalau Anda adalah pengguna sistem operasi berbasis Unix/Mirip-Unix (\*nix) seperti GNU/Linux, macOS, dan BSD, sebetulnya tidak usah ditanya, mereka sudah pasti kompatibel dengan acme.sh karena perkakas tersebut memang dirancang untuk sistem operasi tersebut.

Asal punya OpenSSL (atau LibreSSL?), curl dan Cron, maka acme.sh dapat dijalankan sebagaimana mestinya, serta Anda dapat mengikuti artikel ini secara keseluruhan. Wget juga bisa Anda gunakan, tetapi di artikel ini saya bahas Wget hanya untuk mengunduh dan menginstal acme.sh saja.

Jika Anda adalah pengguna cPanel atau/dan DirectAdmin, Anda perlu menginstal sebuah perangkat lunak yang bernama [`jq`](https://jqlang.github.io/jq/) di dalam sistem operasi Anda agar pemasangan sertifikat SSL/TLS dapat dipermudah.

Anda juga dapat menginstal Socat (Socket Cat) agar acme.sh dapat dijalankan dalam "Standalone Mode", tetapi itu tidak saya bahas lebih lanjut di sini.

Untuk perangkatnya sih terserah kamu saja, saya lebih menyarankan perangkat komputer yang dapat dioperasikan selayaknya Server (diam di satu tempat, tanpa monitor dan tidak pernah sengaja dimatikan) atau pakai komputer kecil seperti Raspberry Pi atau perangkat sejenis kalau punya.

Walau bisa saja pakai PC Desktop atau Laptop yang kamu pakai sekarang, tetapi sumber dayanya akan berebutan dengan lainnya dan mungkin kamu akan perlu mengoperasikannya dengan lebih lama untuk keperluan pembaruan sertifikat, kalau menurutmu itu tidak masalah maka dipakai saja.

#### Untuk Pengguna Windows {#persiapan-pengguna-windows}

{{< spoiler title="tl;dr" >}}
Jika terlalu panjang, maka hal-hal yang harus Anda siapkan adalah sebagai berikut:

- Memiliki Akses ke Lingkungan Unix/Mirip-Unix: (Pilih salah satu caranya)
  - Mengaktifkan fitur [WSL (Windows Subsystem for Linux)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) untuk Windows 10 atau di atasnya
  - Menggunakan Perangkat Lunak yang dapat mengemulasikan lingkungan UNIX, seperti Git Bash, Cygwin, dll, tetapi opsi ini belum saya coba
  - Mesin Virtual atau Kontainer dengan Sistem Operasi berbasis Unix/Mirip-Unix (disarankan GNU/Linux)
  - Mengakses server atau perangkat Anda yang menggunakan sistem operasi \*nix dengan menggunakan klien SSH
- Persiapan perangkat lunak pada WSL, mesin virtual, kontainer atau pada server bisa mengikuti [persiapan untuk sistem operasi \*nix](#persiapan-pengguna-unix-like)
{{< / spoiler >}}

Jika Anda menggunakan Windows, maka Anda perlu untuk mengakses lingkungan Unix/Mirip-Unix (\*nix), Anda bisa pakai cara apa pun untuk melakukannya.

Anda bisa memakai salah satu cara berikut untuk melakukannya:

- Memakai fitur [WSL (Windows Subsystem for Linux)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) agar bisa menggunakan sistem operasi GNU/Linux di dalam Windows (Jika Anda menggunakan Windows 10 atau di atasnya)
- Memakai perangkat lunak yang dapat mengemulasikan lingkungan UNIX, seperti Git Bash, Cygwin, dan lainnya (belum saya coba)
- Memakai mesin virtual/kontainer yang terinstal GNU/Linux
- _Me-remote_/mengakses perangkat lain (entah itu Server, PC Desktop/Laptop biasa, bahkan Telepon Pintar/Tablet, dll) yang memakai sistem operasi berbasis \*nix dengan klien SSH

Ketika Anda sedang mengemulasikan lingkungan \*nix di Windows, Anda dapat mengikuti persiapan perangkat lunak untuk sistem operasi \*nix. Jadi pastikan kalau curl, OpenSSL (atau LibreSSL?) dan Cron sudah ada di dalam sistem kamu.

Namun, jika Anda mempunyai ponsel berbasis Android 7.0 atau di atasnya, daripada repot-repot memakai WSL, Docker, Server, dsb, lebih baik instal Termux di ponselmu saja dan buatlah agar Termux-nya dapat diakses dari komputer PC atau Laptop kamu melalui SSH, dan kamu pakai itu di sana, lalu kamu atur agar Termux-nya dapat diaktifkan setelah perangkat dinyalakan dan terus aktif di latar belakang, caranya [kunjungi artikel ini](https://farrel.franqois.id/cara-menggunakan-termux-dari-komputer/).

#### Untuk Pengguna Android (tidak perlu akses _root_) {#persiapan-pengguna-android}

{{< spoiler title="tl;dr" >}}
Jika terlalu panjang, maka hal-hal yang harus Anda siapkan adalah sebagai berikut:

- Menggunakan sistem operasi Android versi 7.0 atau di atasnya, sebagai syarat untuk menggunakan Termux. Jika di bawah 7.0, maka Anda dapat gunakan [versi lamanya](https://archive.org/details/termux-repositories-legacy), tetapi saya tidak dapat menjamin bahwa Anda akan dapat mengikuti artikel ini ke depannya, karena saya belum mengujinya, mungkin saja caranya akan berbeda dibandingkan dengan yang saya bahas di sini
- Terinstalnya Termux di dalam Perangkat Android Anda. Bisa Anda unduh di [F-Droid resminya](https://f-droid.org/repository/browse/?fdid=com.termux), jangan unduh di [Google Play Store](https://play.google.com/store/apps/details?id=com.termux)! (Alasannya [di sini](https://wiki.termux.com/wiki/Termux_Google_Play))
- Persiapan yang harus Anda lakukan pada Termux setelah di-instal adalah sebagai berikut:
    1. Buka Termux-nya
    2. Perbarui semua paket yang ada di Termux dengan perintah: `pkg upg`
    3. Instal semua keperluannya dengan perintah: `pkg i -y curl wget openssl-tool jq cronie termux-services`, lalu mulai ulang Termux jika berhasil
    4. Aktifkan Layanan (_Service_) Cron di Latar Belakang dengan Perintah: `sv-enable crond && sv up crond`
    5. Jika Anda memiliki komputer PC atau Laptop dan ponsel pintar berbasis Android yang terkoneksi dengan jaringan yang sama, maka sebaiknya kamu instal `openssh` (atau sejenisnya) di dalam Termux, lalu kamu lakukan semua itu secara remot dari komputer PC atau Laptop kamu melalui perkakas klien SSH. Caranya bisa Anda baca [artikel ini](https://farrel.franqois.id/cara-menggunakan-termux-dari-komputer/)

**Catatan:** Semua hal di atas dapat Anda lakukan tanpa perlu akses _root_ sedikit pun dan perangkat tidak perlu dalam keadaan _rooted_.
{{< / spoiler >}}

Jika Anda menggunakan Android, maka Anda bisa gunakan Termux untuk itu, selalu gunakan versi terbaru untuk pengalaman yang lebih nyaman dan lebih baik. Sebelum mengunduh, pastikan bahwa Android yang Anda gunakan sudah versi 7.0 atau di atasnya, sebagai syarat untuk menggunakan Termux.

Namun jika versi Android Anda berada di bawah 7.0 (terutama versi 5 atau 6), maka Anda bisa gunakan [versi lamanya](https://archive.org/details/termux-repositories-legacy), tetapi saya tidak bisa menjamin bahwa Anda akan bisa mengikuti artikel ini ke depan karena versi pustaka yang digunakan masih lama dan saya belum mengujinya (dan jujur saya sendiri males), jadi mungkin caranya akan berbeda dibandingkan dengan yang akan saya bahas di sini.

Setelah itu, pastikan Termux tidak diunduh melalui [Google Play Store](https://play.google.com/store/apps/details?id=com.termux), melainkan melalui [F-Droid](https://f-droid.org/repository/browse/?fdid=com.termux).

Kenapa? Karena Termux sudah tidak lagi diperbarui di Google Play Store sejak 02 November 2020 yang lalu, untuk alasannya silakan baca [halaman dokumentasinya](https://wiki.termux.com/wiki/Termux_Google_Play).

Ketika Anda sedang menggunakan Termux, maka Anda bisa mengikuti persiapan perangkat lunak untuk sistem operasi berbasis \*nix. Jadi pastikan jika curl, OpenSSL, jq (untuk pengguna cPanel atau/dan DirectAdmin) dan Cron sudah ada di dalam Termux Anda.

Namun sayangnya, di dalam Termux belum terinstal OpenSSL, jq dan Cron secara bawaan. Jadi setelah Anda Instal Termux, maka hal yang perlu Anda lakukan adalah perbarui semua paket-paket yang ada, lalu instal semua paket yang diperlukan dengan perintah berikut:

```bash
pkg upg -y; pkg i -y curl wget openssl-tool jq cronie termux-services
```

Setelah itu, mulai ulang Termux Anda dengan eksekusi perintah `exit`, lalu buka lagi Termux-nya agar perubahannya bisa diterapkan. Setelah Termux dibuka lagi, aktifkan Cron dari latar belakang dengan mengeksekusi perintah `sv-enable crond && sv up crond`.

Jika Anda memiliki komputer/laptop dan ponsel pintar berbasis Android yang terkoneksi dengan jaringan yang sama, maka sebaiknya kamu instal `openssh` (atau sejenisnya) di dalam Termux, lalu kamu lakukan semua itu secara remot dari komputer/laptop kamu melalui perkakas klien SSH, sehingga tidak perlu melakukan pemindahan lagi ke dalam Android.

Anda bisa baca [artikel ini](https://farrel.franqois.id/cara-menggunakan-termux-dari-komputer/) untuk mengetahui caranya.

Semua hal di atas bisa Anda lakukan tanpa perlu akses _root_ sedikit pun dan perangkat tidak perlu dalam keadaan _rooted_, ini sama sekali tidak menghilangkan garansi pada perangkat Anda, jadi tidak usah khawatir.

## Sebelum menerbitkan Sertifikat SSL/TLS

Sebelum menerbitkannya, Anda perlu mengikuti beberapa poin pembahasan terlebih dahulu. Poin-poin akan saya bahas dalam langkah-demi-langkah.

Jadi, harap Anda jangan melewati satu langkah pun, kecuali jika ada catatan yang mengizinkannya.

Atau, Anda juga bisa lewati bagian ini jika Anda sudah pernah mendaftarkan akun ZeroSSL, meng-install dan konfigurasi acme.sh, serta melakukan pengaitan akun ZeroSSL dengan acme.sh sebelumnya.

### Membuat Akun ZeroSSL dan mendapatkan Kredensial EAB-nya {#membuat-akun-zerossl}

{{< info title="**Catatan:**" >}}
Jika Anda belum mempunyai akunnya dan ingin menggunakan acme.sh tanpa harus mendaftarkan akun ZeroSSL-nya, lewati ini dan langsung [lanjut saja](#install-acme-sh).

Namun, saya tetap sarankan agar Anda tidak melewati langkah ini.
{{< / info >}}

Sebelum Anda menerbitkan sertifikatnya, saya sarankan untuk mendaftar akun ZeroSSL terlebih dahulu melalui [situs webnya](https://zerossl.com).

Setelah mendaftar, kamu tidak perlu membuat/menerbitkan sertifikatnya di sana, melainkan hanya perlu Kredensial EAB (_External Account Binding_) yakni **"EAB KID"** dan **"EAB HMAC Key"**-nya saja.

**Apa itu Kredensial EAB?** Kredensial EAB adalah sebuah kredensial untuk menghubungkan antara perkakas/perangkat lunak yang merupakan klien untuk protokol ACME dengan akun CA yang telah Anda daftarkan.

Tanpa basa-basi lagi, langkah-langkahnya sebagai berikut:

0. Daftar Akun ZeroSSL-nya [di Situs Web-nya](https://app.zerossl.com/signup) dan Login setelah itu (Atau, kamu hanya perlu [Login](https://app.zerossl.com/login) saja jika kamu sudah pernah mendaftar akun sebelumnya)
1. Pada Dasbor ZeroSSL, klik **"Developer"**
2. Setelah itu, pada bagian **"EAB Credentials for ACME Clients"**, klik _Button_ **"Generate"**
3. Simpan **"EAB KID"** dan **"EAB HMAC Key"** yang telah dihasilkan itu dengan baik, nanti akan digunakan lagi untuk acme.sh
4. Setelah menyimpannya, kamu tinggal klik _Button_ **"Done"** dan Selesai

Jika Anda tidak memahami langkah-langkah di atas, Anda dapat melihat Cuplikan Layar berikut yang cukup menyesuaikan dengan langkah-langkah di atas: (Silakan perbesar gambarnya dengan mengkliknya)

![1](ZeroSSL_EAB_Credential_1.webp) ![2](ZeroSSL_EAB_Credential_2.webp)

Setelah Kredensial EAB dibuat, perlu diingat bahwa sejak Maret 2022 yang lalu kredensial EAB dapat digunakan kembali, sehingga kredensial yang sama dapat digunakan berkali-kali. Jadi, simpanlah kredensial tersebut dengan baik dan jangan beritahu ke siapa pun, kecuali jika Anda mempercayai orang tersebut dan siap menanggung sendiri atas risiko yang disebabkan oleh Anda sendiri.

Sekarang lanjut ke langkah berikutnya, yakni instal acme.sh, dan Anda sama sekali tidak perlu menerbitkan sertifikat SSL/TLS-nya di sana.

### Instal acme.sh {#install-acme-sh}

Setelah mendaftar akun ZeroSSL, salah satu hal yang perlu Anda lakukan adalah menginstal acme.sh terlebih dahulu di dalam sistem operasi Anda.

Tidak perlu menggunakan Akun Administrator atau `root` untuk menginstalnya, atau tidak perlu dieksekusikan melalui perintah `sudo` layaknya Certbot, cukup gunakan saja akun Anda yang sekarang, seperti biasanya.

Cara menginstalnya adalah dengan mengeksekusikan salah satu perintah berikut:

Dengan curl:

```shell
curl https://get.acme.sh | sh -s email=emailku@domain.com
```

Atau dengan GNU Wget:

```shell
wget -O - https://get.acme.sh | sh -s email=emailku@domain.com
```

Ganti `emailku@domain.com` dengan alamat surel Anda, jangan lupa dimasukkan, tetapi jika Anda telanjur lupa, tidak memasukkan atau salah memasukkan alamat surel saat menginstalnya, Anda dapat eksekusi perintah di bawah ini setelah terinstal:

```shell {linenos=true}
cp "$HOME"/.acme.sh/account.conf "$HOME"/.acme.sh/account.conf.1 ## Backup dulu
sed -i '/ACCOUNT\_EMAIL\=/d' "$HOME"/.acme.sh/account.conf ## Hapus Variabel `ACCOUNT_EMAIL` yang sudah ada
printf "ACCOUNT_EMAIL='%s'\n" "emailku@domain.com" >> "$HOME"/.acme.sh/account.conf
```

Ganti `emailku@domain.com` dengan alamat surel Anda.

Setelah selesai instal, pastikan bahwa acme.sh dapat dieksekusi dengan baik dengan mengetikkan `acme.sh --version` di dalam Terminal, lalu tekan tombol <kbd>&#8629; Enter</kbd>.

Jika dapat dieksekusi dengan baik, maka akan tampil versi dari acme.sh dan selamat Anda telah menginstalnya dengan benar, silakan [klik di sini](#registrasi-akun-acme-sh) untuk melanjutkan ke langkah berikutnya.

Jika tidak, gunakan perintah `source <LETAK_KONFIGURASI_SHELL>` atau tutup Terminal lalu buka lagi untuk memperbarui _Shell_. Kalau masih tidak bisa juga, maka Anda perlu memasukkan direktori acme.sh ke dalam variabel `PATH` dengan menambahkan teks berikut di bawah ini ke dalam berkas konfigurasi _Shell_ yang nantinya akan digunakan ketika Anda menjalankan sebuah _Shell_ secara interaktif.

Berikut adalah teksnya:

```shell {linenos=true}
source ~/.acme.sh/acme.sh.env
```

Tambahkan baris di atas ke dalam berkas `~/.bashrc` jika Anda menggunakan GNU Bash atau `~/.zshrc` jika Anda adalah pengguna Z Shell.

Atau, berikut di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish {linenos=true}
fish_add_path "$HOME"/.acme.sh
set -xU LE_WORKING_DIR "$HOME"/.acme.sh
```

Atau, di bawah ini jika Anda menggunakan `fish` dengan versi di bawah 3.2.0:

```fish {linenos=true}
set -Ua fish_user_paths "$HOME"/.acme.sh
set -xU LE_WORKING_DIR "$HOME"/.acme.sh
```

Tambahkan baris di atas ke dalam berkas `~/.config/fish/conf.d/acme.sh.fish` jika Anda menggunakan `fish` sebagai _Shell_.

Setelah selesai menambahkannya, simpanlah berkas tersebut dari Editor Teks favorit Anda dan perbarui _Shell-nya_ dengan menggunakan perintah `source <LETAK_KONFIGURASI_SHELL>` atau keluar dari Terminal lalu buka lagi, setelah itu coba eksekusikan ulang perkakas acme.sh-nya.

### Registrasi Akun melalui acme.sh {#registrasi-akun-acme-sh}

Secara baku, acme.sh menggunakan ZeroSSL sebagai CA (_Certificate Authority_)-nya, jadi jika Anda adalah orang yang pertama kali menggunakan acme.sh, silakan registrasikan akun ZeroSSL yang telah Anda buat terlebih dahulu ke Server ACME-nya menggunakan acme.sh dengan perintah berikut:

```shell
acme.sh --register-account \
        --eab-kid EAB_KID_KAMU_DI_SINI \
        --eab-hmac-key EAB_HMAC_KEY_KAMU_DI_SINI
```

Ganti `EAB_KID_KAMU_DI_SINI` dan `EAB_HMAC_KEY_KAMU_DI_SINI` dengan "EAB KID" dan "EAB HMAC Key" yang telah kamu simpan sebelumnya.

**Kalau saya belum daftar sama sekali gimana?** Jika Anda belum pernah daftar akun ZeroSSL sama sekali dan ingin menggunakan acme.sh tanpa harus mendaftarkan akun ZeroSSL dari Web, maka Anda dapat eksekusi perintah berikut:

```shell
acme.sh --register-account
```

Keluarannya akan seperti di bawah ini:

```plain {linenos=true}
[Sel 10 Agu 2021 05:31:16  WIB] Create account key ok.
[Sel 10 Agu 2021 05:31:16  WIB] No EAB credentials found for ZeroSSL, let's get one
[Sel 10 Agu 2021 05:31:17  WIB] Registering account: https://acme.zerossl.com/v2/DV90
[Sel 10 Agu 2021 05:31:20  WIB] Registered
[Sel 10 Agu 2021 05:31:20  WIB] ACCOUNT_THUMBPRINT='f4qxxxxxxxxxxxxxxxxx_xxxxxxx-xxxxxxxxx_xxxx'
```

**Kalau saya gak peroleh Kredensial EAB-nya gimana? Apakah bisa memakai perintah di atas?** Sepengalaman saya dulu, bisa.

{{< info title="**Perhatian !**" >}}
Dengan mengeksekusi perintah di atas (`acme.sh --register-account` saja), itu bukan berarti Anda telah mendaftarkan akun ZeroSSL yang kemudian bisa Anda gunakan untuk login ke dalam [Situs Web ZeroSSL-nya](https://app.zerossl.com/login).

Jika Anda ingin mengelola sertifikat tersebut di Web-nya, saya sarankan agar Anda membuat akunnya terlebih dahulu melalui Situs Web-nya, caranya bisa Anda baca di [langkah pertama](#membuat-akun-zerossl), lalu kaitkan Kredensial EAB-nya di acme.sh.
{{< / info >}}

Anda bisa simpan `ACCOUNT_THUMBPRINT`-nya dengan baik, barangkali suatu saat nanti Anda ingin menjalankan acme.sh dalam "[Stateless Mode](https://github.com/acmesh-official/acme.sh/wiki/Stateless-Mode)", tetapi Anda bisa dapatkan itu kembali dengan mengeksekusi perintah `acme.sh --register-account`.

Jika sudah, silakan lanjut ke [langkah berikutnya](#membuat-akses-api).

### Membuat Akses API

Sebelum menerbitkan Sertifikat SSL/TLS, maka ada baiknya untuk membuat Kode Token untuk Akses API-nya terlebih dahulu.

Ini akan sangat berguna untuk verifikasi DNS ke depannya dan juga memasang sertifikat SSL/TLS itu sendiri. Jadi, Anda wajib membuatnya, tetapi Anda tidak perlu membuat semuanya, melainkan sesuai dengan layanan yang Anda gunakan.

Misalnya, jika Anda menggunakan Cloudflare sebagai Penyedia DNS dan Netlify sebagai Hosting atau cPanel/DirectAdmin sebagai Kontrol Panel Hosting, maka Anda hanya perlu membuat akses API dari Cloudflare untuk keperluan verifikasi DNS dan Netlify/cPanel/DirectAdmin untuk keperluan memasang Sertifikat SSL/TLS.

Atau, jika Anda menggunakan Netlify sebagai Penyedia DNS dan Hostingnya, Anda hanya cukup membuat 1 Akses API dari Netlify saja untuk keperluan verifikasi DNS dan memasang sertifikatnya, iya cukup 1 saja, tidak perlu membuat banyak untuk keperluan yang berbeda-beda.

Kalau sudah tahu caranya dan sudah pernah Anda lakukan sebelumnya, Anda bisa langsung [lewati ini](#verifikasi-dns-di-acmesh).

Kalau belum, silakan ikuti cara-caranya berikut di bawah ini.

#### Penyedia DNS Cloudflare {#cloudflare-api-token}

Untuk membuat Kode Token Akses API-nya, silakan baca [dokumentasinya](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/), di sana sudah dijelaskan secara lengkap tentang bagaimana cara membuat kodenya.

Jika belum jelas, saya bahas saja caranya di sini. Caranya sebagai berikut:

0. Pastikan Anda sudah login terlebih dahulu menggunakan akun Cloudflare Anda dengan mengunjungi [Halaman Dasbornya](https://dash.cloudflare.com/login). Udah? Kalau begitu, Anda bisa lanjut
1. Jika Anda sudah sampai di halaman dasbornya:
   - a. Klik pada Ikon Orang di pojok kanan atas
   - b. Lalu, klik **"My Profile"**
   - c. Setelah itu, klik pada tab **"API Tokens"**

    Atau sederhananya, silakan [klik di sini](https://dash.cloudflare.com/profile/api-tokens)
2. Setelah Anda memasukki bagian **"API Token"**, klik pada _Button_ **"Create Token"**

    Kira-kira untuk no. 1 dan 2 cuplikannya akan seperti berikut:

![Menuju ke bagian "API Token"](Cloudflare_Create_API_Token_1.webp)

3. Saat proses membuat Token, Anda akan memilih templat yang dipakai untuk membuat Akses API-nya. Maka dari itu, pakai saja templat **"Edit zone DNS"** dengan mengklik _Button_ **"Use this template"** di sebelahnya (Seperti pada cuplikan berikut)

![Memilih Templat untuk membuat Token](Cloudflare_Create_API_Token_2.webp)

4. Setelah menentukan templatnya, nanti Anda akan diminta untuk melengkapi informasi yang ada di sana. Lengkapi informasi berikut ini:
   - **Token Name**: Itu merupakan nama token yang ingin Anda buat. Secara baku, nama token menggunakan nama templatnya, bisa diubah sesuka hati Anda dengan mengklik pada ikon pensil di sebelah namanya
   - **Permissions**: Itu merupakan perizinan untuk token yang Anda buat nantinya, karena menggunakan templat **"Edit zone DNS"**, maka seharusnya informasi tersebut sudah dilengkapi. Pastikan itu sudah diisi dengan **"Zone"**, **"DNS"** dan **"Edit"**, kalau sudah, Anda bisa lewati ini.
   - **Zone Resources**: Itu merupakan cakupan zona (_Zone_) untuk token ini. Jika Anda ingin tokennya itu dapat mencakup semua domain yang telah Anda tambahkan di Cloudflare, maka pastikan pilih: (salah satu)
       - **"Include"** dan **"All zones"**
       - **"Include"**, **"All zones from an account"**, lalu pilih Akun yang ingin Anda cakup
   - **Client IP Address Filtering**: Jika Anda ingin mengatur atau menyaring alamat IP klien atau pengguna API, maka Anda bisa atur itu, ini akan cocok jika Anda ingin menggunakan API tersebut di perangkat yang alamat IP-nya tidak berubah-ubah dan bersifat publik (seperti VPS/Server). Jika tidak, maka sebaiknya lewati saja.
   - **TTL**: Atur itu jika Anda ingin token yang Anda buat memiliki masa berlaku, jika tidak maka sebaiknya lewati saja

5. Jika Anda sudah mengisi semua informasinya, klik pada _Button_ **"Continue to summary"**

    Kira-kira untuk no. 4 dan 5, cuplikannya akan menjadi seperti berikut:

![Melengkapi Informasi untuk Token](Cloudflare_Create_API_Token_3.webp)

6. Di sana Anda akan melihat kesimpulan dari Token yang ingin Anda buat, jika merasa yakin, silakan klik pada _Button_ **"Create Token"** (Seperti pada cuplikan berikut)

![Kesimpulan dari Token yang ingin dibuat](Cloudflare_Create_API_Token_4.webp)

7. Setelah itu, kodenya akan tampil di sana. Salinkan **"API Token"** tersebut dengan mengklik pada _button_ **"Copy"**, lalu simpan itu baik-baik karena kode tersebut tidak akan tampil lagi, serta pastikan bahwa tidak ada satu pun orang lain yang mengetahuinya kecuali dengan seizin Anda. Selain itu, Anda juga dapat mengujinya di sana untuk memastikan apakah kode terebut bekerja atau tidak.

!["API Token" yang telah dibuat di Cloudflare](Cloudflare_Create_API_Token_5.webp)

Nah, setelah **"API Token"** dibuat, Anda harus mendapatkan **"Account ID"**-nya, kalau kamu perlu bisa dapatkan **"Zone ID"**-nya juga.

Untuk mendapatkan kedua itu, pergi ke [Halaman Dasbor Cloudflare](https://dash.cloudflare.com), pilih domainnya, lalu gulirkan kebawah, nanti akan ketemu Informasi mengenai **"Account ID"** dan **"Zone ID"**, seperti di bawah ini:

!["Account ID" dan "Zone ID" di Cloudflare](Cloudflare_Zone_and_Account_ID.webp)

Setelah mendapatkan semua itu, sekali lagi, simpanlah informasi tersebut baik-baik karena akan digunakan kembali, pastikan juga bahwa tidak ada seorang pun yang dapat mengetahui informasi tersebut kecuali Anda sendiri atau orang yang dapat Anda percayakan.

Jika tidak ada lagi penyedia lain yang perlu Anda buatkan Akses API-nya, silakan langsung lanjut ke bagian [Verifikasi DNS di acme.sh](#verifikasi-dns-di-acmesh)

#### Netlify {#netlify-personal-access-token}

Jika Anda menggunakan Netlify sebagai Hosting ataupun Penyedia DNS untuk domain-mu atau kedua-duanya, Anda perlu buat sebuah Akses API yang bernama **"Personal access token"**.

Ngomong-ngomong, selain bisa untuk verifikasi DNS, kode token ini bisa Anda gunakan juga untuk memasang sertifikatnya nanti. Jadi setelah Anda membuatnya, simpanlah kode tersebut dengan baik agar bisa digunakan nanti.

Namun, jika sebelumnya sudah pernah menerbitkan sertifikatnya dan membuat kode token Netlify, serta ingin memasangkan sertifikatnya di sana melalui Akses API, silakan lewati bagian ini dan verifikasi DNS dengan [klik di sini](#pasang-ssl-di-netlify) untuk langsung melompat ke caranya.

Kalau belum, silakan dibuat terlebih dahulu, caranya sebagai berikut:

0. Anda bisa langsung masuk [ke sini](https://app.netlify.com/user/applications), lakukan login terlebih dahulu jika diminta.
1. Klik pada _button_ **"New access token"** di bagian **"Personal access tokens"**

!["Personal access tokens" di Netlify](Netlify_Access_Token_1.webp)

2. Masukkan Nama/Deskripsi mengenai Tokennya
3. Setelah itu, klik pada _Button_ **"Generate"** untuk menghasilkan **"Access Token"**-nya

![Membuat "Personal access token" di Netlify](Netlify_Access_Token_2.webp)

4. Setelah **"Access Token"** tampil, simpan itu baik-baik, karena **"Access Token"** tersebut tidak bisa tampil lagi dan itu akan digunakan kembali, serta pastikan bahwa tidak ada orang lain yang mengetahuinya
5. Klik pada _Button_ **"Done"** jika merasa sudah selesai

![Setelah Token berhasil dibuat](Netlify_Access_Token_3.webp)

Setelah mendapatkan semua itu, sekali lagi, simpanlah informasi tersebut baik-baik karena akan digunakan kembali, pastikan juga bahwa tidak ada seorang pun yang dapat mengetahui informasi tersebut kecuali Anda sendiri atau orang yang dapat Anda percayakan.

Jika tidak ada lagi penyedia lain yang perlu Anda buatkan Akses API-nya, silakan langsung lanjut ke bagian [Verifikasi DNS di acme.sh](#verifikasi-dns-di-acmesh)

#### bunny\.net (sebelumnya BunnyCDN) {#bunny-access-key}

Jika Anda menggunakan bunny\.net (sebelumnya: BunnyCDN) sebagai CDN, _Reverse-proxy_, Penyedia DNS ataupun Hosting, maka Anda bisa mendapatkan **"Access Key"**-nya di sini.

Namun, jika sebelumnya sudah sudah pernah menerbitkan sertifikatnya, sudah mendapatkan dan menyimpan **Access Key**-nya, serta ingin memasangkan sertifikatnya di sana melalui Akses API, silakan lewati bagian ini dan verifikasi DNS dengan [klik di sini](#pasang-ssl-di-bunnycdn) untuk langsung melompat ke caranya.

Kalau belum, silakan dapatkan terlebih dahulu, caranya sebagai berikut:

0. Silakan akses ke [Dasbor bunny.net-nya](https://dash.bunny.net/), login jika diminta.
1. Klik pada foto profilmu, lalu klik **"Edit account details"**
2. Gulirkan tetikus (_mouse_) kamu sampai ketemu tulisan **"API"** atau tekan <kbd>Ctrl</kbd> + <kbd>F</kbd> untuk mencari teks di halaman web, lalu masukkan kata `API` untuk mencari bagian tersebut
3. Kalau ketemu, maka di bagian tersebut kamu akan melihat sebuah kotak teks yang diisikan dengan lingkaran atau tanda bintang, klik pada ikon papan klip untuk langsung menyalinkan kodenya atau ikon mata jika Anda ingin melihat isi yang sebenarnya
4. Nah, **"Access Key"** sudah disalin atau tampil, simpan itu baik-baik untuk digunakan nanti dan pastikan tidak ada siapa pun yang mengetahuinya

Jika Anda tidak memahami langkah-langkah di atas, maka Anda dapat melihat cuplikan layar berikut: (Silakan perbesar gambarnya dengan mengkliknya)

![1. Langkah ke Pengaturan Akun di bunny.net](bunny.net_Dashboard_to_Edit_Account.webp) ![2. "Access Key" untuk API bunny.net](bunny.net_API_Access_Key.webp)

Setelah mendapatkan semua itu, sekali lagi, simpanlah informasi tersebut baik-baik karena akan digunakan kembali, pastikan juga bahwa tidak ada seorang pun yang dapat mengetahui informasi tersebut kecuali Anda sendiri atau orang yang dapat Anda percayakan.

Jika tidak ada lagi penyedia yang perlu Anda buatkan Kode Token-nya, silakan langsung lanjut ke [Verifikasi DNS di acme.sh](#verifikasi-dns-di-acmesh)

#### cPanel {#cpanel-api-token}

Jika Anda merupakan pengguna cPanel, baik di Server Anda sendiri ataupun di layanan hosting yang Anda gunakan, Anda diharuskan untuk membuat Token API agar sertifikat dapat terpasang secara otomatis dengan mengakses API-nya.

Namun, jika sebelumnya sudah pernah menerbitkan sertifikatnya dan sudah membuat Token API di cPanel, serta ingin memasangkan sertifikatnya melalui Akses API, silakan lewati bagian ini dan verifikasi DNS dengan [klik di sini](#pasang-ssl-di-cpanel) untuk langsung melompat ke caranya.

{{< info title="**Catatan:**" >}}
Fitur ini masih dalam tahap eksperimental, jadi silakan tanggung sendiri segala risiko yang akan Anda hadapi ke depan, seperti perubahan yang terjadi dengan cepat dan risiko lainnya.
{{< / info >}}

Kalau belum, silakan buat terlebih dahulu, caranya sebagai berikut:

1. Masuk ke cPanel menggunakan Akun cPanel Anda, bukan Akun _Billing_ (Akun cPanel dan _Billing_ itu beda lho, jangan salah)
2. Setelah masuk ke cPanel, gulirkan tetikusnya ke arah bawah sampai ke bagian **"Security"** (bahasa Indonesia: **"Keamanan"**), pada bagian tersebut kamu klik **"Manage API Tokens"**, seperti cuplikan berikut: (Atau, langsung cari aja **"Manage API Tokens"**, terus tinggal kamu klik aja hasilnya)

![Fitur "Manage API Tokens" di cPanel](cPanel_Manage_API_Tokens.webp)

3. Jika Anda baru pertama kali membuat _API Token_, Anda akan langsung diminta untuk melengkapi informasi yang ada di sana untuk dibuatkan _API Token_-nya. Lengkapi informasi berikut ini:

    ![Pembuatan "API Token" di cPanel](cPanel_Create_API_Token.webp)

    - **API Token Name:** Itu merupakan Nama _API Token_ yang ingin Anda buat, Anda bisa mengisinya dengan bebas, tetapi karakter yang boleh dimasukkan adalah alfanumerik (besar dan kecil diperbolehkan), tanda hubung/pisah dan tanda garis bawah saja, serta peka terhadap huruf besar dan kecil (_case sensitive_)
    - **Should the API Token Expire?:** Itu menentukan masa berlaku _API Token_ yang Anda buat, jika tidak ingin ada masa berlaku, Anda tinggal pilih **"The API Token will not expire"** atau **"Specify an expiration date"** jika Anda ingin menyetel tanggalnya (Saran saya jangan ada masa berlaku, kalau mau ada masa berlakunya pastikan Anda bisa memperbaruinya secara otomatis)

4. Jika sudah selesai, klik pada _button_ **"Create"** (bahasa Indonesia: **"Buat"**)

5. Setelah mengkliknya, kamu akan melihat Kode _API Token_ yang hanya bisa dilihat sekali saja, jadi simpanlah _API Token_ tersebut baik-baik dan pastikan tidak ada seorang pun yang mengetahuinya kecuali Anda sendiri.

   Jika sudah, centang pada bagian **"Create another token after I click Yes, I saved my token."**, lalu klik pada _Button_ **"Yes, I Saved My Token"**, seperti cuplikan berikut:

    ![Setelah sukses membuat "API Token" di cPanel](cPanel_API_Token_Created.webp)

Setelah mendapatkan semua itu, sekali lagi, simpanlah informasi tersebut baik-baik karena akan digunakan kembali, pastikan juga bahwa tidak ada seorang pun yang dapat mengetahui informasi tersebut kecuali Anda sendiri atau orang yang dapat Anda percayakan.

Jika tidak ada lagi penyedia lain yang perlu Anda buatkan Akses API-nya, silakan langsung lanjut ke bagian [Verifikasi DNS di acme.sh](#verifikasi-dns-di-acmesh)

#### DirectAdmin {#directadmin-login-key}

Jika Anda merupakan pengguna DirectAdmin, baik di Server Anda sendiri ataupun di Layanan _Shared Hosting_ yang Anda gunakan, sebaiknya Anda membuat **"Login Key"** (bahasa Indonesia: Kunci Masuk) terlebih dahulu agar dapat memasangkan Sertifikat SSL/TLS secara otomatis melalui Akses API-nya.

Namun, jika sebelumnya sudah pernah menerbitkan sertifikatnya dan sudah membuat **"Login Key"**-nya di DirectAdmin, serta ingin memasangkan sertifikatnya melalui Akses API, silakan lewati bagian ini dan verifikasi DNS dengan [klik di sini](#pasang-ssl-di-directadmin) untuk langsung melompat ke caranya.

Kalau belum, silakan dibuat terlebih dahulu, caranya sebagai berikut:

1. Masuk ke DirectAdmin menggunakan Akun DirectAdmin Anda, bukan Akun _Billing_ (Akun DirectAdmin dan _Billing_ itu beda lho, jangan salah)

2. Setelah masuk ke DirectAdmin, gunakan fasilitas Pencarian untuk mencari **"Login Keys"** (tanpa kutip), jika ketemu klik pada **"Login Keys"**. Seperti cuplikan berikut:

!["Login Keys" pada DirectAdmin](DirectAdmin_Login_Keys.webp)

3. Setelah masuk ke **"Login Keys"**, klik pada _Button_ **"Create"** untuk membuat **"Login Key"**-nya. Seperti cuplikan berikut:

![Proses pembuatan "Login Key" di DirectAdmin](DirectAdmin_Create_Login_Key.webp)

4. Lalu, lengkapi informasi berikut untuk membuatnya:

    ![Informasi yang dilengkapi untuk membuat "Login Key"](DirectAdmin_Create_Login_Key_2.webp)

    - **Key Type:** Pilih jenis kuncinya, pilih saja **"Key"**
    - **Key Name:** Tentukan nama kuncinya, nama hanya boleh mengandung karakter alfanumerik saja, besar-kecilnya diperhatikan, tidak boleh ada karakter apa pun selain itu termasuk simbol dan spasi
    - **Key Value:** Tentukan nilai kuncinya, saran saya klik pada ikon dadu saja agar bisa dihasilkan dengan acak, tidak disarankan untuk menggunakan kata sandi Anda sebagai nilai kuncinya
    - **Expires On:** Tentukan masa berlaku kuncinya, saran saya centang **"Never"** saja, kecuali jika Anda dapat memperbaruinya secara terprogram
    - **Clear Key:** Di bagian ini ada opsi **"Automatically delete the key once the key expires"** yang bisa Anda centang, ini tidak akan berpengaruh kalau **"Login Key"**-nya tidak memiliki masa berlaku
    - **Allow HTM:** Di bagian ini ada opsi **"Allows browsing of the DA interface to HTM, IMG and CSS files."** yang bisa Anda centang, entah ini fungsinya buat apaan, sepertinya untuk kasus ini dicentang atau tidak juga tidak terlalu berpengaruh
    - **Commands:** Di bagian ini, Anda harus menentukan perintah mana yang diizinkan dan ditolak. Untuk kasus ini, Anda harus menolak semua perintah selain `CMD_API_SSL` dan `CMD_SSL` yang diizinkan. Caranya tinggal centang **"Deny"**, lalu cari dengan kata kunci **"SSL"** (tanpa kutip), setelah itu centang dua-duanya di kolom **"Allow"** (Untuk lebih jelas, bisa lihat pada cuplikan di atas)
    - **Allowed IPs:** Anda bisa menentukan hanya dari Alamat IP apa saja yang diperpolehkan untuk menggunakan kunci ini, saran saya tidak usah diisi untuk mengijinkan semua Alamat IP untuk menggunakan kunci ini, kecuali jika Anda mempunyai kebutuhan khusus
    - **Current Password:** Isikan ini dengan kata sandi Akun DirectAdmin Anda yang sekarang

5. Jika sudah selesai, klik pada _Button_ **"Create"** untuk membuatkan kuncinya

6. Setelah mengkliknya, kamu akan melihat **"Key Value"** yang kamu isi dan itu adalah **"Login Key"**-nya yang hanya bisa dilihat satu kali saja, jadi simpanlah kunci tersebut baik-baik dan pastikan tidak ada seorang pun yang dapat mengetahuinya kecuali Anda sendiri dan orang yang Anda percayakan.

    Jika sudah, Anda tinggal menutupinya saja dengan mengklik ikon silangnya. Seperti cuplikan berikut:

    ![Setelah dibuatkan "Login Key" di DirectAdmin](DirectAdmin_After_Create_Login_Key.webp)

Jika tidak ada lagi penyedia lain yang perlu Anda buatkan Akses API-nya, silakan langsung lanjut ke bagian [Verifikasi DNS di acme.sh](#verifikasi-dns-di-acmesh)

### Verifikasi DNS di acme.sh

Agar Sertifikat SSL/TLS dapat diterbitkan melalui Protokol ACME, maka pengguna diperlukan melakukan verifikasi. Salah satunya adalah dengan verifikasi DNS.

Verifikasi DNS merupakan sebuah metode yang menggunakan rekaman DNS (_DNS Record_) pada Domain untuk memverifikasi bukti kepemilikan domain sebelum sertifikat diterbitkan atau diperbarui.

Verifikasi seperti ini tidak memerlukan keberadaan _Web Server_ dan tidak perlu mengakses konten apa pun (cth. Mengakses `http://domain.com/.well-known/.acme-challenge-xxxxxxxxxxxx`) untuk itu, sehingga Anda bisa menerbitkannya di mana saja dan di perangkat apa saja (termasuk Ponsel Pintar, Komputer PC, Laptop, dll), tanpa harus mempunyai/menyewa sebuah Server/Perangkat terlebih dahulu, selama Anda bisa menjalankan acme.sh di dalam perangkat Anda.

Ini juga sebagai syarat agar Anda dapat menerbitkan sertifikat SSL/TLS untuk semua subdomain Anda (_Wildcard SSL_) dengan mudah.

Selain itu, karena Anda ingin memasang sertifikat SSL/TLS di penyedia web yang sedang saya bahas di artikel ini, yakni Netlify, Bunny CDN, cPanel dan DirectAdmin, serta Anda melakukannya di dalam perangkat seperti Komputer PC, Laptop, Ponsel Pintar Anda atau perangkat lain yang Anda miliki, maka metode verifikasi seperti ini wajib Anda pelajari.

Namun, agar perkakas acme.sh dapat melakukan verifikasi DNS secara otomatis saat menerbitkan dan memperbarui Sertifikat SSL/TLS-nya, maka acme.sh harus dapat mengakses dan mengubah rekaman DNS di dalam domain milik Anda dengan mengakses akun penyedia DNS milik Anda.

Untuk itu, Anda perlu berikan sebuah izin untuk membaca dan mengubah rekaman DNS dengan memberinya sebuah kredensial milik Anda, seperti: _API Token_, Kunci API untuk Akses API atau bahkan Nama Pengguna dan Kata Sandi.

**Kalau saya gak mau gimana?** Bisa saja Anda melakukannya secara manual, sehingga Anda menambahkan rekaman DNS-nya secara manual juga.

Namun sertifikat SSL/TLS tersebut memiliki masa berlaku selama 90 hari, sehingga harus diperbarui sebelum habis masanya (minimal 60 hari setelah sertifikat diterbitkan) dan saat pembaruan Anda harus masukkan lagi rekaman DNS-nya secara manual, sehingga tidak mungkin kamu bisa memperbarui Sertifikat SSL/TLS tersebut secara otomatis.

Pertanyaannya, apa kamu gak capek kayak gitu terus? Ya terserah kamu, sih. Kalo saya jadi kamu, mending saya pake metode yang otomatis saja ketimbang pake yang manual.

Jadi, kamu gak perlu takut, perkakas acme.sh ini gak bakalan ngumpulin data-data kamu, kok, kamu hanya perlu hati-hati aja dalam menjaga perangkatnya 😊

#### Untuk Pengguna DNS Otoritatif Cloudflare {#untuk-pengguna-cloudflare}

Jika Anda menggunakan Cloudflare sebagai DNS Otoritatif/Penyedia DNS untuk domain Anda, maka Anda perlu membuat kode Token API-nya (`CF_Token`) dan mendapatkan **"Account ID"**-nya (`CF_Account_ID`).

Kalau perlu, kamu juga bisa dapatkan **"Zone ID"**-nya juga, agar acme.sh dapat menargetkan domain/zona yang spesifik tanpa harus mencarinya lagi, tetapi itu tidak wajib, kalo menurutmu gak perlu ya gak usah.

Untuk cara membuatnya, silakan [klik di sini](#cloudflare-api-token).

Setelah semuanya berhasil didapat, tinggal Anda masukkan saja semua informasinya ke dalam variabel. Dengan cara berikut:

```shell {linenos=true}
### Di bawah ini adalah Informasi yang wajib dimasukki
export CF_Token="API_TOKEN_KAMU_DI_SINI"
export CF_Account_ID="ACCOUNT_ID_KAMU_DI_SINI"

### Anda juga dapat memasukkan "Zone ID" supaya acme.sh dapat menargetkan
### Domain/Zona yang spesifik dengan cepat tanpa harus mencarinya lagi
### Namun kalau gak perlu, maka sebaiknya tidak usah
export CF_Zone_ID="ZONE_ID_KAMU_DI_SINI"
```

Atau di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish {linenos=true}
set -x CF_Token "API_TOKEN_KAMU_DI_SINI"
set -x CF_Account_ID "ACCOUNT_ID_KAMU_DI_SINI"
set -x CF_Zone_ID "ZONE_ID_KAMU_DI_SINI"
```

Di mana saya memasukkannya? Saran saya di dalam Terminal-nya langsung, sebenarnya bisa juga di dalam berkas konfigurasi masing-masing _Shell_ yang Anda gunakan, hanya saja Anda perlu memulai ulang Terminal-nya atau perlu muat ulang dulu konfigurasi _Shell-nya_ dengan perintah `source <LETAK_KONFIGURASI_SHELL>`.

Udah itu aja, jika Anda menggunakan Cloudflare dan sudah memasukkan kredensial di atas, Anda hanya perlu langsung melanjutkan ke [langkah berikutnya](#menerbitkan-sertifikat-ssl) saja untuk mempelajari penerbitan sertifikat.

#### Untuk Pengguna Netlify DNS {#untuk-pengguna-netlify-dns}

Jika Anda menggunakan Netlify sebagai Penyedia DNS, Anda cuma perlu membuat **"Personal Access Token"**-nya (`NETLIFY_ACCESS_TOKEN`) saja sebagai kredensial untuk akses API-nya.

Untuk cara membuatnya, silakan [klik di sini](#netlify-personal-access-token).

Setelah berhasil dibuat, tinggal Anda masukkan saja informasinya ke dalam variabel. Dengan cara berikut:

```shell
export NETLIFY_ACCESS_TOKEN="ACCESS_TOKEN_KAMU_DI_SINI"
```

Atau, di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish
set -x NETLIFY_ACCESS_TOKEN "ACCESS_TOKEN_KAMU_DI_SINI"
```

Di mana saya memasukkannya? Saran saya di dalam Terminal-nya langsung, sebenarnya bisa juga di dalam berkas konfigurasi masing-masing _Shell_ yang Anda gunakan, hanya saja Anda perlu memulai ulang Terminal-nya atau perlu muat ulang dulu konfigurasi _Shell-nya_ dengan perintah `source <LETAK_KONFIGURASI_SHELL>`.

Udah itu aja, jika Anda menggunakan Netlify dan sudah memasukkan informasi di atas, Anda hanya perlu langsung melanjutkan ke [langkah berikutnya](#menerbitkan-sertifikat-ssl) saja untuk mempelajari penerbitan sertifikat.

#### Untuk Pengguna Bunny DNS {#untuk-pengguna-bunny-dns}

Jika Anda menggunakan Bunny DNS sebagai Penyedia DNS, Anda cuma perlu mendapatkan **"Access Key"**-nya saja sebagai kredensial untuk akses API-nya.

Untuk cara mendapatkannya, silakan [klik di sini](#bunny-access-key).

Setelah berhasil ditemukan, tinggal Anda masukkan saja informasinya ke dalam variabel. Dengan cara berikut:

```shell
export BUNNY_API_KEY="ACCESS_KEY_KAMU_DI_SINI"
```

Atau, di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish
set -x BUNNY_API_KEY "ACCESS_KEY_KAMU_DI_SINI"
```

Di mana saya memasukkannya? Saran saya di dalam Terminal-nya langsung, sebenarnya bisa juga di dalam berkas konfigurasi masing-masing _Shell_ yang Anda gunakan, hanya saja Anda perlu memulai ulang Terminal-nya atau perlu muat ulang dulu konfigurasi _Shell-nya_ dengan perintah `source <LETAK_KONFIGURASI_SHELL>`.

Udah itu aja, jika Anda menggunakan Netlify dan sudah memasukkan informasi di atas, Anda hanya perlu langsung melanjutkan ke [langkah berikutnya](#menerbitkan-sertifikat-ssl) saja untuk mempelajari penerbitan sertifikat.

#### Untuk Pengguna Penyedia DNS lain {#untuk-pengguna-dns-lain}

Jika Anda menggunakan Penyedia DNS selain Cloudflare, Netlify DNS dan Bunny DNS, seperti Hurricane Electric Free DNS, Constellix, NS1, ClouDNS, Amazon Route 53, Google Cloud DNS, dll, maka Anda perlu membaca [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).

Karena setiap Penyedia DNS mempunyai cara yang berbeda-beda untuk mengaksesnya. Jadi, silakan ikuti yang ada di dokumentasinya.

Setelah itu, kamu telah dapat menggunakan acme.sh seperti biasanya untuk menerbitkan/membuat dan memperbarui Sertifikat SSL/TLS kamu.

## Menerbitkan Sertifikat SSL/TLS dengan acme.sh {#menerbitkan-sertifikat-ssl}

Nah, setelah mengikuti beberapa langkah, akhirnya Anda bisa sampai di sini, yakni menerbitkan Sertifikat SSL/TLS.

Ada beberapa cara untuk menerbitkannya menggunakan acme.sh, tidak perlu Anda ikuti semua dan sesuaikan dengan selera Anda, kecuali jika ada teks "Wajib dipelajari"-nya, bagian itu yang wajib Anda pelajari.

Berikut adalah cara-caranya:

### Menerbitkan Sertifikat SSL/TLS (Wajib dipelajari) {#issue-cert}

Jika Anda ingin menerbitkan Sertifikat SSL/TLS dengan acme.sh (cth. hanya untuk 1 Domain dan 1 Subdomain), maka format perintahnya akan menjadi seperti berikut:

```shell
acme.sh --issue -d www.domain.com -d domain.com METODE_VERIFIKASI PARAMETER_TAMBAHAN
```

Perintah di atas akan menerbitkan Sertifikat SSL/TLS yang hanya menjangkau 1 Domain dan 1 Subdomain saja, yakni `www.domain.com` dan `domain.com`.

Parameter `-d` berfungsi untuk menentukan domain yang dijangkau oleh Sertifikat SSL/TLS tersebut saat diterbitkan, isikan itu dengan domain Anda.

Sebenarnya, Anda juga dapat menambahkan perameter `-d` agar Sertifikat SSL/TLS menjangkau setiap domain yang Anda masukkan, sebanyak yang Anda mau.

Domain pertama yang Anda masukkan itu merupakan Domain Utama dan akan menjadi **"Common Name"**, **"Subject"** atau **"Issued to"** pada Sertifikat SSL/TLS, selain SAN (_Subject Alternative Name_), sedangkan domain kedua dan seterusnya atau selain itu hanya dimasukkan kedalam SAN saja.

Selain itu, nama direktori untuk Sertifikat SSL/TLS-nya sendiri akan ditentukan berdasarkan domain pertama yang Anda masukkan.

Contohnya seperti cuplikan berikut di Windows:

![“Issued to” pada Sertifikat SSL/TLS saya](Windows_Certificate_Viewer_1.webp) ![SAN pada Sertifikat SSL/TLS saya](Windows_Certificate_Viewer_2.webp)

Atau, di bawah ini untuk GNU/Linux: (Lebih tepatnya di Peramban Web berbasis Chromium/Google Chrome untuk GNU/Linux)

!["Common Name" pada Sertifikat SSL/TLS saya](Certificate_Viewer_1.webp) ![SAN pada Sertifikat SSL/TLS saya](Certificate_Viewer_2.webp)

Jika Anda melihat cuplikan di atas, "Common Name" yang tampil adalah `farrel.franqois.id` bukan `*.farrel.franqois.id`, padahal sertifikat yang saya terbitkan itu adalah Sertifikat SSL/TLS _Wildcard_, dan `*.farrel.franqois.id` malah cuma dimasukkan ke dalam SAN (_Subject Alternative Name_) saja bersamaan dengan Domain Utamanya.

**Kenapa bisa begitu?** Sederhananya karena Domain Pertama yang saya masukkan ketika menerbitkan sebuah Sertifikat SSL/TLS adalah `farrel.franqois.id`, bukan `*.farrel.franqois.id`. Nah, sekarang sudah paham, kan?

Parameter `--issue` berfungsi agar acme.sh menerbitkan Sertifikat SSL/TLS Anda. Parameter selain `--issue` adalah sebagai berikut:

- `--renew` untuk memperbarui Sertifikat SSL/TLS yang ada
- `--revoke` untuk mencabut salah satu Sertifikat SSL/TLS yang ada di dalam perangkat Anda
- `--remove` untuk menghapus salah satu Sertifikat SSL/TLS dari perangkat Anda
- `--renew-all` untuk memperbarui semua Sertifikat SSL/TLS yang ada (**Catatan:** Anda tidak perlu menambahkan parameter `-d` jika menggunakan parameter ini)
- Dan lain-lainnya

#### Metode Verifikasi (`METODE_VERIFIKASI`)

Anda harus menggantikan `METODE_VERIFIKASI` di atas dengan parameter/argumen mengenai metode verifikasi yang ada, menjadi parameter berikut: (Setidaknya gunakan salah satu parameter)

- `--webroot lokasi_webroot` atau `-w lokasi_webroot` jika Anda ingin menggunakan metode _Webroot_.

    Ganti `lokasi_webroot` dengan lokasi Web Anda, seperti `/var/www/html`, `/home/username/public_html`, atau apa aja yang penting itu menandakan lokasi Web Anda.

- `--dns nama_dns` jika Anda ingin menggunakan metode DNS.

    Ganti `nama_dns` dengan yang ada di [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi) dan sesuaikan dengan Penyedia DNS yang Anda gunakan. (Saya bahas ini di bagian terpisah)

- `--apache` jika Anda ingin menggunakan _Web Server_ Apache2 sebagai verifikasinya.
- `--nginx (lokasi_conf)` jika Anda ingin meggunakan _Web Server_ NGINX sebagai verifikasinya.

    Anda bisa ganti `(lokasi_conf)` dengan lokasi berkas konfigurasi untuk NGINX Anda jika diinginkan barangkali acme.sh tidak dapat mendeteksi berkas konfigurasi NGINX secara otomatis, kalau acme.sh dapat mengenalinya maka cukup tulis `--nginx` saja.

- `--standalone` jika Anda tidak mempunyai Aplikasi _Web Server_ atau sedang tidak berada di dalam Server Web (cth. Sedang berada di dalam Server FTP atau SMTP).

Dengan adanya verifikasi seperti ini, artinya Anda tidak bisa sembarangan membuat Sertifikat SSL/TLS untuk domain lain, berhasil atau gagal akan menambahkan _Rate Limit_ jika Anda menggunakan CA seperti Let's Encrypt dan Buypass.

Jadi, berhati-hatilah ketika Anda ingin menerbitkan Sertifikat SSL/TLS dengan menggunakan Protokol ACME, terutama jika Anda menggunakan CA selain ZeroSSL.

#### Parameter Tambahan (`PARAMETER_TAMBAHAN`)

Anda bisa menggantikan `PARAMETER_TAMBAHAN` dengan parameter lain yang ingin Anda tambahkan saat menerbitkan Sertifikat SSL/TLS, parameter lainnya sebagai berikut:

- `--force` jika Anda ingin melakukannya dengan cara paksa. Ini cocok bagi Anda yang ingin menerbitkan ulang sertifikat, memperbarui masa berlaku sertifikat meski belum mau habis/belum waktunya, dll
- `--test` atau `--staging` jika Anda ingin menjalankannya dalam mode pengujian. Ini cocok bagi Anda yang sedang belajar menggunakan acme.sh atau menguji penerbitan Sertifikat SSL/TLS dengan metode verifikasi yang berbeda tanpa mempengaruhi _Rate Limit_ aslinya.

    Jadi, saya sarankan agar Anda selalu memakai parameter ini jika Anda sedang mempelajari penggunaan acme.sh atau memastikan apakah Sertifikat SSL/TLS bisa diterbitkan dengan benar atau tidaknya tanpa mempengaruhi _Rate Limit_ dari suatu CA.

    Kalau sudah merasa yakin, Anda dapat terbitkan ulang Sertifikat SSL/TLS-nya untuk produksi dengan menggunakan parameter `--issue --force`, tanpa parameter `--test` atau `--staging`

- `--server opsi_ca` jika Anda ingin menerbitkan Sertifikat SSL/TLS oleh CA lain, yang secara baku diterbitkan oleh ZeroSSL sebagai CA.

    Ganti `opsi_ca` menjadi nama pendek dari CA yang mendukung, seperti: `zerossl`, `buypass`, `buypass_test`, `letsencrypt`, `letsencrypt_test`, `sslcom`, `google`, `googletest`.

    Atau, Anda juga bisa ganti `opsi_ca` dengan memasukkan Alamat URL Server ACME dari Penyedia CA Anda. Untuk lebih lengkapnya, silakan pelajari itu dari [Halaman Wiki-nya](https://github.com/acmesh-official/acme.sh/wiki/Server)

- `--keylength opsi` atau `-k opsi` jika Anda ingin menerbitkan Sertifikat SSL/TLS dengan ukuran kunci atau kunci yang berbeda. Ganti `opsi` dengan `2048`, `3072`, `4096`, `8192`, `ec-256`, `ec-384`, atau `ec-512` (Saya bahas di bagian terpisah)
- `--cert-file file` untuk menyalinkan berkas sertifikat ke dalam direktori lain setelah menerbitkan/memperbarui Sertifikat SSL/TLS-nya. Ganti `file` menjadi lokasi atau/dan nama berkas yang Anda inginkan
- `--key-file file` untuk menyalinkan berkas Kunci ke dalam direktori lain setelah menerbitkan/memperbarui Sertifikat SSL/TLS-nya. Ganti `file` menjadi lokasi atau/dan nama berkas yang Anda inginkan
- `--ca-file file` untuk menyalinkan berkas sertifikat CA/Sertifikat Penengah ke dalam direktori lain setelah menerbitkan/memperbarui Sertifikat SSL/TLS-nya. Ganti `file` menjadi lokasi atau/dan nama berkas yang Anda inginkan
- `--fullchain-file file` untuk menyalinkan berkas sertifikat _Fullchain_ ke dalam direktori lain setelah menerbitkan/memperbarui Sertifikat SSL/TLS-nya. Ganti `file` menjadi lokasi atau/dan nama berkas yang Anda inginkan.
- `--reloadcmd perintah` untuk mengeksekusikan perintah _reload_ Server setelah menerbitkan/memperbarui Sertifikat SSL/TLS-nya. Ganti `perintah` menjadi perintahnya.

    Jika Anda tidak mempunyai _web server_ di dalam perangkat kamu, dan ingin memasangkannya ke luar perangkat kamu, maka saya sarankan agar memakai parameter `--renew-hook` saja

- `--renew-hook perintah` untuk menentukan perintah yang akan dieksekusi setelah sertifikat berhasil diperbarui (_di-renew_). Ganti `perintah` menjadi perintah yang ingin Anda eksekusikan.

    Karena acme.sh tidak akan langsung mengeksekusi perintahnya, melainkan nanti saat diperbarui, maka saya sarankan langsung gunakan parameter ini saat ingin menerbitkan sertifikat dan isikan parameter tersebut dengan menggantikan `perintah` menjadi perintah untuk memasang sertifikatnya (cth. `--renew-hook env sh deploy.sh`).

    Berkas `deploy.sh` adalah berkas skrip untuk memasang sertifikat yang Anda buat nanti, bisa diganti dengan nama berkas yang Anda inginkan.

    Jika telanjur, maka Anda perlu mengkonfigurasinya secara manual, dan itu akan saya bahas lebih lanjut di bagian terpisah tentang konfigurasi acme.sh untuk domain

- `--pre-hook perintah` untuk menentukan perintah yang akan dieksekusi sebelum perkakas acme.sh menjalankan tugasnya. Ganti `perintah` menjadi perintah yang ingin Anda eksekusikan.

    Bedanya dengan `--renew-hook` adalah bahwa perintah tersebut langsung dieksekusi sebelum acme.sh menjalankan tugasnya

- `--post-hook perintah` untuk menentukan perintah yang akan dieksekusi sebelum perkakas acme.sh menjalankan tugasnya. Ganti `perintah` menjadi perintah yang ingin Anda eksekusikan.

    Bedanya dengan `--pre-hook` adalah bahwa perintah tersebut langsung dieksekusi setelah acme.sh menjalankan tugasnya, tidak peduli apakah tugas sebelumnya berhasil atau gagal

- `--always-force-new-domain-key` untuk membuat kunci pribadi (_Private Key_) baru setiap kali pembaruan sertifikat, parameter ini hanya bisa digunakan saat ingin menerbitkan sertifikat saja. Perkakas acme.sh secara baku tidak membuat kunci pribadi baru setiap kali pembaruan sertifikat, makanya ada parameter ini
- `--ecc` agar perintah tersebut ditujukan untuk Sertifikat SSL/TLS yang telah diterbitkan menggunakan ECC/ECDSA sebagai algoritma kunci publiknya.

    Tanpa parameter ini, maka perintah tersebut akan dieksekusi untuk Sertifikat SSL/TLS yang menggunakan RSA sebagai algoritma kuncinya. Parameter ini hanya bisa digunakan jika ada parameter `--renew`, `--revoke`, `--remove`, `--install-cert`, `--to-pkcs12` dan `--create-csr` saja.

    Contoh penggunaannya di bawah ini:
  - `acme.sh --remove -d www.domain.com --ecc` untuk menghapus salah satu Sertifikat SSL/TLS yang menggunakan ECC sebagai algoritma kuncinya dari perangkat Anda
  - `acme.sh --revoke -d www.domain.com --ecc` untuk mencabut salah satu Sertifikat SSL/TLS yang menggunakan ECC sebagai algoritma kuncinya dari perangkat Anda
  - Dan masih banyak lagi!

    Jadi, Anda tidak bisa menggunakan parameter ini untuk menerbitkan Sertifikat SSL/TLS, atau bisa dibilang bahwa Anda hanya bisa memakainya saat Sertifikat SSL/TLS tersebut telah diterbitkan dengan kunci ECC/ECDSA saja.

    Kalau mau menerbitkannya dengan kunci ECC/ECDSA, kamu bisa pelajari penggunaan parameter `--keylength` saat menerbitkan sertifikatnya (yang akan saya bahas ini di bagian-bagian selanjutnya).

Udah itu saja yang saya bahas, parameter lainnya masih banyak, tetapi yang saya bahas di sini adalah kasus umumnya saja.

Jika Anda ingin mempelajari parameter lainnya lebih lanjut, silakan gunakan perintah `acme.sh --help` untuk menampilkan parameter apa saja yang bisa Anda gunakan.

Jika Anda tidak ingin menambahkan parameter lain, Anda bisa menghapus `PARAMETER_TAMBAHAN`-nya.

#### Setelah menerbitkan Sertifikat SSL/TLS

Jika Anda menerbitkan Sertifikat SSL/TLS memakai acme.sh dan dinyatakan berhasil, maka akhir dari keluarannya kira-kira akan seperti berikut:

```plain
[Kam 12 Agu 2021 02:14:50  WIB] Cert success.
-----BEGIN CERTIFICATE-----
ISI SERTIFIKAT
-----END CERTIFICATE-----
[Kam 12 Agu 2021 02:14:50  WIB] Your cert is in: /home/username/.acme.sh/domain.com/domain.com.cer
[Kam 12 Agu 2021 02:14:50  WIB] Your cert key is in: /home/username/.acme.sh/domain.com/domain.com.key
[Kam 12 Agu 2021 02:14:50  WIB] The intermediate CA cert is in: /home/username/.acme.sh/domain.com/ca.cer
[Kam 12 Agu 2021 02:14:50  WIB] And the full chain certs is there: /home/username/.acme.sh/domain.com/fullchain.cer
```

Ini artinya, bahwa Sertifikat SSL/TLS telah berhasil dibuat/diterbitkan oleh CA dan berkas-berkas yang diperlukan telah tersimpan di dalam direktori `/home/username/.acme.sh/domain.com` atau di `$HOME/.acme.sh/domain.com`.

Berkas-berkas seperti `domain.com.cer`, `domain.com.key` dan `ca.cer` atau `fullchain.cer` dan `domain.com.key` akan diperlukan untuk pemasangan Sertifikat SSL/TLS di Layanan Hosting/CDN, untuk lebih lanjut akan saya bahas di bagian terpisah.

Namun, nama direktori untuk menyimpan dan bahkan nama dari berkas-berkas tersebut biasanya bergantung pada domain pertama yang dimasukkan saat ingin menerbitkan sebuah Sertifikat SSL/TLS.

Sebagai contoh, Anda ingin menerbitkan Sertifikat SSL/TLS dengan perintah berikut:

```shell
acme.sh --issue -d www.domain.com -d domain.com -w $HOME/public_html
```

Karena domain pertama yang dimasukkan adalah `www.domain.com`, bukan `domain.com` sesuai perintah di atas, maka berkas-berkas yang diperlukan akan tersimpan di dalam direktori `/home/username/.acme.sh/www.domain.com`, bukan di dalam direktori `/home/username/.acme.sh/domain.com`.

Nah, sekarang sudah paham, kan? Kalau sudah paham, tinggal pelajari verifikasi menggunakan DNS dan tentukan cara menerbitkan Sertifikat SSL/TLS-nya dengan sesuka kamu.

### Menerbitkan Sertifikat SSL/TLS dengan menggunakan DNS sebagai Metode Verifikasi (Wajib dipelajari) {#verifikasi-dns}

Jika Anda ingin menerbitkan Sertifikat SSL/TLS yang menggunakan DNS sebagai Metode verifikasinya, maka tinggal tambahkan saja parameter `--dns nama_dns`.

Contoh di bawah ini adalah perintah untuk menerbitkan Sertifikat SSL/TLS untuk 1 Domain dan 1 Subdomain dengan menggunakan DNS dari Cloudflare sebagai Metode Verifikasi:

```shell
acme.sh --issue -d www.domain.com -d domain.com --dns dns_cf
```

{{< info title="**Perhatian !**" >}}
Jika Anda sedang mempelajari penggunaan perkakas acme.sh, maka saya sarankan agar Anda selalu tambahkan parameter `--test` atau `--staging` untuk menjalankan perkakas acme.sh dalam mode pengujian, ini cocok untuk Anda yang sedang belajar.

Kalau ingin memperbarui sertifikatnya, pastikan Anda menambahkan parameter `--force --server letsencrypt_test`, karena sekarang acme.sh akan secara otomatis membalikkan opsi CA-nya ke Let's Encrypt versi produksi yang mana itu bukan lagi termasuk tahap uji coba.

Kalau sudah merasa yakin, Anda dapat terbitkan ulang Sertifikat SSL/TLS-nya untuk produksi dengan menggunakan parameter `--issue --force`, tanpa parameter `--test` atau `--staging`.
{{< / info >}}

Jika Anda menggunakan Penyedia DNS selain Cloudflare, ganti saja `dns_cf`-nya menjadi yang ada di dalam [dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).

Misalnya: Anda ingin menerbitkan sebuah Sertifikat SSL/TLS untuk `www.domain.com` dan ingin menggunakan Netlify DNS sebagai Metode Verifikasinya, maka tinggal Anda tambahkan saja parameter `--dns dns_netlify`. Jadinya seperti berikut:

```shell
acme.sh --issue -d www.domain.com -d domain.com --dns dns_netlify
```

Nah, sekarang paham, kan? Ini juga sangat penting untuk menerbitkan Sertifikat SSL/TLS [dalam bentuk _Wildcard_](#wildcard-ssl), karena Verifikasi melalui DNS merupakan salah satu syarat yang wajib.

Selain itu, jika Anda ingin memasang Sertifikat SSL/TLS di Penyedia Web yang sedang saya bahas di artikel ini, yakni Netlify dan BunnyCDN, serta Anda melakukannya di dalam perangkat seperti Komputer PC, Laptop dan Ponsel Pintar Anda atau di dalam perangkat yang sepenuhnya milik Anda, maka metode verifikasi seperti ini wajib Anda pelajari.

Sekadar Informasi saja, sebelum menggunakan DNS sebagai metode verifikasinya, saya sarankan agar Anda membaca dan pahami terlebih dahulu bagaimana cara menambahkan kredensial untuk akses API-nya, silakan [klik di sini](#verifikasi-dns-di-acmesh).

### Menerbitkan Sertifikat SSL/TLS untuk Banyak Domain dan Subdomain {#multi-domain}

Untuk menerbitkan Sertifikat SSL/TLS yang menargetkan banyak domain dan subdomain, sebenarnya tinggal Anda masukkan parameter `-d` untuk setiap domainnya. Contohnya seperti berikut:

Untuk 2 Domain dan 4 Subdomain:

```shell
acme.sh --issue -d domain1.com -d www.domain1.com -d sub.domain1.com -d domain2.com -d www.domain2.com -d sub.domain2.com
```

{{< info title="**Perhatian !**" >}}
Jika Anda sedang mempelajari penggunaan perkakas acme.sh, maka saya sarankan agar Anda selalu tambahkan parameter `--test` atau `--staging` untuk menjalankan perkakas acme.sh dalam mode pengujian, ini cocok untuk Anda yang sedang belajar.

Kalau ingin memperbarui sertifikatnya, pastikan Anda menambahkan parameter `--force --server letsencrypt_test`, karena sekarang acme.sh akan secara otomatis membalikkan opsi CA-nya ke Let's Encrypt versi produksi yang mana itu bukan lagi termasuk tahap uji coba.

Kalau sudah merasa yakin, Anda dapat terbitkan ulang Sertifikat SSL/TLS-nya untuk produksi dengan menggunakan parameter `--issue --force`, tanpa parameter `--test` atau `--staging`.
{{< / info >}}

Untuk 4 Domain saja:

```shell
acme.sh --issue -d domain1.com -d domain2.com -d domain3.com -d domain4.com
```

Atau, jika Anda ingin menggunakan metode verifikasi yang berbeda-beda untuk setiap domain, maka Anda bisa meraciknya dengan contoh seperti berikut:

```shell {linenos=true}
acme.sh --issue \
        -d www.domain1.com -d domain1.com --dns dns_cf \
        -d www.domain2.com -d domain2.com --dns dns_netlify \
        -d www.domain3.com -d domain3.com -w /home/username/public_html \
        -d www.domain4.com -d domain4.com --apache \
        -d www.domain5.com -d domain5.com --nginx
```

Dan seterusnya akan seperti itu caranya.

### Menerbitkan Sertifikat SSL/TLS yang menjangkau Seluruh Subdomain {#wildcard-ssl}

Jika Anda ingin menerbitkan Sertifikat SSL/TLS yang menjangkau seluruh subdomain atau dalam bentuk _Wildcard_, maka tambahkan parameter `-d '*.domain.com'` saja, tetapi Anda juga harus menambahkan parameter `--dns nama_dns`, karena dibutuhkan [verifikasi melalui Metode DNS](#verifikasi-dns) sebagai syarat wajib agar bisa menerbitkannya dalam bentuk _Wildcard_.

Contoh di bawah ini adalah perintah untuk menerbitkan sertifikat SSL/TLS untuk 1 domain dan semua subdomainnya dengan menggunakan DNS dari Cloudflare sebagai verifikasi:

```shell
acme.sh --issue -d '*.domain.com' -d domain.com --dns dns_cf
```

{{< info title="**Perhatian !**" >}}
Jika Anda sedang mempelajari penggunaan perkakas acme.sh, maka saya sarankan agar Anda selalu tambahkan parameter `--test` atau `--staging` untuk menjalankan perkakas acme.sh dalam mode pengujian, ini cocok untuk Anda yang sedang belajar.

Kalau ingin memperbarui sertifikatnya, pastikan Anda menambahkan parameter `--force --server letsencrypt_test`, karena sekarang acme.sh akan secara otomatis membalikkan opsi CA-nya ke Let's Encrypt versi produksi yang mana itu bukan lagi termasuk tahap uji coba.

Kalau sudah merasa yakin, Anda dapat terbitkan ulang Sertifikat SSL/TLS-nya untuk produksi dengan menggunakan parameter `--issue --force`, tanpa parameter `--test` atau `--staging`.
{{< / info >}}

Sertifikat yang diterbitkan dengan perintah di atas adalah untuk `*.domain.com` dan `domain.com` dengan menggunakan DNS dari Cloudflare sebagai verifikasi.

Jika Anda bukan pengguna Cloudflare, maka tinggal Anda ganti saja `dns_cf`-nya.

**Kenapa _Wildcard-nya_ dikutip?** Karena terkadang _Shell_ lain memperlakukan tanda bintang dengan berbeda jika tidak dikutip, seperti Zsh (Z shell) misalnya.

**Kenapa _Wildcard-nya_ diletakkan di awal?** Agar Domain _Wildcard-nya_ tampil sebagai "Common Name"/"Subject"/"Issued to" pada Sertifikat SSL/TLS.

**Kenapa seperti itu?** Karena Sertifikat SSL/TLS _Wildcard_ yang saya lihat menampilkan Domain _Wildcard_ sebagai "Issued to"/"Common Name"-nya. Sebenarnya terserah kamu saja sih maunya kayak gimana, toh di atas cuma contoh aja.

**Apa itu "Issued to"/"Common Name"?** Itu sudah saya jelaskan [di bagian awal](#issue-cert).

**Apakah itu menjangkau Sub-subdomain seperti `sub.sub.domain.com`?** Tentu saja tidak, karena Sertifikat SSL/TLS tersebut cuma diterbitkan untuk `*.domain.com` dan `domain.com`, yang mana cuma menjangkau `sub1.domain.com`, `sub2.domain.com`, dst, bukan `sub.sub.domain.com`.

Kalau mau seperti itu, tambahkan saja subdomain Anda dalam bentuk _Wildcard-nya_, jadi parameter yang Anda tambahkan adalah `-d '*.sub.domain.com' -d sub.domain.com` atau `-d *.sub.domain.com` saja.

Contohnya menjadi seperti berikut:

```shell
acme.sh --issue -d '*.domain.com' -d '*.sub.domain.com' -d domain.com --dns dns_cf
```

Nah, sekarang paham, kan?

### Menerbitkan Sertifikat SSL/TLS dengan menggunakan Mode Alias DNS {#dns-alias-mode}

Jika penyedia DNS Anda tidak mendukung akses API/didukung oleh acme.sh, atau khawatir tentang masalah keamanan karena memberikan akses API DNS ke domain utama Anda, maka Anda dapat menggunakan mode alias DNS (_DNS Alias Mode_).

Sebagai contoh, domain utamanya adalah `domain.com` yang mana DNS yang digunakan oleh domain tersebut tidak memiliki akses API ataupun didukung oleh acme.sh atau Anda tidak mau memberikan akses API-nya karena domain tersebut penting bagi Anda.

Selain domain utama, kamu mempunyai domain satunya lagi, yakni `domain-lain.com`, yang mana DNS yang dipakai mendukung akses API dan yang paling pentingnya adalah bahwa domain tersebut tidak terlalu penting bagi Anda, sehingga Anda bisa meminimalkan risiko keamanan yang terjadi pada domain utama Anda.

#### 1. Membuat Rekaman DNS-nya {#dns-alias-mode-1}

Pertama-tama, Anda perlu membuat rekaman DNS berjenis CNAME terlebih dahulu yang diarahkan ke domain alias (cth. `domain-lain.com`).

{{< info title="**Tips:**" >}}
Jika Anda ingin menggunakan Mode Alias DNS, tetapi belum mempunyai domainnya, Anda bisa membeli atau menyewa domain dengan ekstensi `.my.id` yang biayanya mulai dari Rp10.000,00 sampai Rp25.000,00 per tahunnya<sup>**\***</sup>.

Anda bisa menyewa domainnya di [Rumahweb](https://www.rumahweb.com/domain-murah/) atau [Dewaweb](https://afiliasi.farrel.franqois.id/dewaweb/) dengan harga Rp13.320,00/tahun<sup>**\*\***</sup>, atau di [Biznet Gio](https://www.biznetgio.com/product/domain) dengan harga Rp11.100,00/tahun<sup>**\*\***</sup>

Setelah menyewa domainnya, saya sarankan agar memakai Cloudflare sebagai Penyedia DNS untuk domain Anda, karena selain gratis, dukungan akses API dan perangkat lunaknya juga sangat luas.

<sup>**\***</sup>Biaya tersebut bisa saja berbeda-beda, tergantung penyedia domainnya dan itu belum termasuk PPN 11%

<sup>**\*\***</sup>Biaya sewa domain dari ketiga penyedia yang tercantum sudah termasuk PPN 11%
{{< / info >}}

Misalnya jika Anda ingin menerbitkan Sertifikat SSL/TLS yang menjangkau `*.domain.com` dan `domain.com`, maka Anda hanya perlu membuat rekaman DNS berjenis CNAME dengan nama `_acme-challenge.contoh.com` dari domain utama Anda kemudian arahkan rekaman tersebut ke `_acme-challenge.domain-lain.com`.

Jika belum jelas, Anda bisa melihat informasi berikut:

```plain
_acme-challenge.domain.com
   =>   _acme-challenge.domain-lain.com
```

Atau, di bawah ini jika Anda ingin melihatnya dalam format standar berkas zona DNS (_DNS Zone File_) (cth. ISC BIND atau NSD):

```bind
_acme-challenge.domain.com IN CNAME _acme-challenge.domain-lain.com.
```

**Catatan:** Jika Anda sedang menggunakan Cloudflare dan Anda sedang membuat rekaman CNAME-nya di sana, pastikan bahwa `Proxy Status`-nya adalah `DNS Only` dan warna awannya menjadi abu-abu, serta **JANGAN PERNAH DIUBAH MENJADI AWAN ORANYE, INI AKAN MENYEBABKAN CA TIDAK BISA MEMBACA REKAMANNYA DENGAN BAIK UNTUK VERIFIKASI**.

Jika Anda ingin menerbitkan Sertifikat SSL/TLS hanya untuk domain utama dan beberapa subdomain tertentu saja, seperti `domain.com`, `www.domain.com`, `sub.domain.com`, `sub2.domain.com`, dsb, maka rekaman dengan informasi di atas seharusnya sudah cukup.

Namun, jika Anda ingin menerbitkan Sertifikat SSL/TLS yang tidak hanya pada domain utamanya saja dalam bentuk _Wildcard_, melainkan subdomainnya yang dalam bentuk _Wildcard_ juga, yakni `*.sub.domain.com`, `*.domain.com` dan `domain.com`, maka Anda perlu membuat rekaman DNS untuk subdomainnya juga, contohnya seperti di bawah ini:

```plain
_acme-challenge.domain.com
   =>   _acme-challenge.domain-lain.com

_acme-challenge.sub.domain.com
   =>   _acme-challenge.domain-lain.com
```

Atau, di bawah ini jika Anda ingin melihatnya dalam format standar berkas zona DNS (_DNS Zone File_) (cth. ISC BIND atau NSD):

```bind
_acme-challenge.domain.com IN CNAME _acme-challenge.domain-domain-alias.com.
_acme-challenge.sub.domain.com IN CNAME _acme-challenge.domain-domain-alias.com.
```

Setelah membuat rekaman DNS-nya, Anda perlu menyiapkan kode akses API ke pengaturan rekaman DNS untuk domain alias Anda.

Yap, Anda tidak salah baca, untuk domain alias, karena Anda memakai _DNS alias mode_, maka rekaman DNS yang akan dibuat oleh acme.sh secara otomatis adalah untuk domain alias, bukan domain utama Anda.

Setelah semyua telah dipersiapkan, Anda dapat lanjut menerbitkan sertifikatnya.

#### 2. Menerbitkan Sertifikat SSL/TLS {#dns-alias-mode-2}

Untuk menerbitkan Sertifikat SSL/TLS-nya, Anda dapat memakai perintah biasanya yang tentunya memakai DNS sebagai metode verifikasinya, tetapi Anda perlu menambahkan parameter `--challenge-alias <nama_domain_alias>`. Ganti `<nama_domain_alias>` dengan domain alias Anda, contoh kali ini adalah `domain-lain.com`.

Contoh perintahnya ada di bawah ini:

```shell
acme.sh --issue \
        -d '*.domain.com' \
        -d domain.com \
        --challenge-alias domain-lain.com --dns dns_cf
```

Perintah di atas akan menerbitkan Sertifikat SSL/TLS yang menjangkau domain `*.domain.com` dan `domain.com` dengan menggunakan _DNS alias mode_ dan diverifikasi menggunakan Cloudflare sebagai Penyedia DNS.

Setelah menjalankan perintah di atas, maka secara otomatis perkakas acme.sh akan membuatkan rekaman DNS berjenis TXT untuk domain `domain-lain.com` dengan nama `_acme-challenge`.

Nanti server milik CA akan secara otomatis memeriksa salah satu rekaman TXT dari `_acme-challenge.domain.com`, akan tetapi karena subdomain tersebut Anda buatkan rekaman CNAME-nya dan diarahkan ke `_acme-challenge.domain-lain.com` seperti yang telah kamu kerjakan di [langkah pertama](#dns-alias-mode-1), maka CA akan dapat menemukan rekaman TXT yang dicari dan kemudian memverifikasinya.

Setelah menerbitkannya, tolong jangan hapus rekaman `_acme-challenge` dari domain utama Anda, karena itu akan dipakai lagi untuk memperbarui Sertifikat SSL/TLS nantinya.

#### 3. Berbagi domain alias yang sama {#dns-alias-mode-3}

Anda juga dapat memakai domain alias yang sama, meski domain utamanya berbeda-beda, Anda tinggal buat saja rekaman DNS berjenis CNAME dan arahkan itu ke domain alias Anda.

Di bawah ini adalah contohnya:

```plain
_acme-challenge.domain.com
   =>   _acme-challenge.domain-lain.com

_acme-challenge.domain.id
   =>   _acme-challenge.domain-lain.com

_acme-challenge.domain.net
   =>   _acme-challenge.domain-lain.com

_acme-challenge.domain.org
   =>   _acme-challenge.domain-lain.com
```

Maka untuk menerbitkannya, Anda bisa pelajari contoh perintah berikut:

```shell
acme.sh --issue \
        -d domain.com \
        -d www.domain.com \
        -d sub.domain.com \
        -d domain.id \
        -d domain.net \
        -d domain.org \
        --challenge-alias domain-lain.com --dns dns_cf
```

Atau, perintah di bawah ini jika Anda ingin menerbitkannya dalam bentuk _Wildcard_:

```shell
acme.sh --issue \
        -d '*.domain.com' \
        -d '*.domain.id' \
        -d '*.domain.net' \
        -d '*.domain.org' \
        -d domain.com \
        -d domain.id \
        -d domain.net \
        -d domain.org \
        --challenge-alias domain-lain.com --dns dns_cf
```

#### 4. (Sub)Domain alias yang berbeda untuk tiap domain {#dns-alias-mode-4}

Di acme.sh, Anda bisa menggunakan domain/subdomain alias yang berbeda-beda, bahkan penyedia DNS yang berbeda pula untuk menerbitkan sebuah sertifikat.

Anda bisa menyetel rekaman CNAME-nya dengan contoh berikut:

```plain
_acme-challenge.domain.com
   =>   _acme-challenge.domain-lain.com

_acme-challenge.domain.id
   =>   _acme-challenge.domain-lain-2.com
```

Lalu, terbitkan sertifikatnya dengan mempelajari perintah berikut:

```shell
acme.sh --issue \
        -d domain.com --challenge-alias domain-lain.com \
        -d domain.id --challenge-alias domain-lain-2.com \
        --dns dns_cf
```

Bahkan Anda juga bisa menggunakan penyedia DNS yang berbeda juga, berikut adalah contohnya:

```shell
acme.sh --issue \
        -d domain.com --challenge-alias domain-lain.com --dns dns_cf \
        -d domain.id --challenge-alias domain-lain-2.com --dns dns_netlify
```

Contoh di atas diasumsikan bahwa domain `domain-lain.com` menggunakan Cloudflare sebagai Penyedia DNS, sedangkan domain `domain-lain-2.com` menggunakan Netlify sebagai Penyedia DNS.

**Bagaimana jika dalam bentuk _Wildcard_?** Tetap saja Anda harus menambahkan `--challenge-alias`-nya juga satu per satu, contohnya berikut di bawah ini:

```shell
acme.sh --issue \
        -d '*.domain.com' --challenge-alias domain-lain.com \
        -d '*.domain.id' --challenge-alias domain-lain-2.com \
        -d domain.com --challenge-alias domain-lain.com \
        -d domain.id --challenge-alias domain-lain-2.com \
        --dns dns_cf
```

Atau, di bawah ini jika Anda menggunakan Penyedia DNS yang berbeda-beda:

```shell
acme.sh --issue \
        -d '*.domain.com' --challenge-alias domain-lain.com --dns dns_cf \
        -d '*.domain.id' --challenge-alias domain-lain-2.com --dns dns_netlify \
        -d domain.com --challenge-alias domain-lain.com --dns dns_cf \
        -d domain.id --challenge-alias domain-lain-2.com --dns dns_netlify
```

Kira-kira begitu.

#### 5. Mencampuri antara Mode Alias DNS dan Mode DNS Biasa {#dns-alias-mode-5}

Di acme.sh, Anda bisa mencampuri Mode Alias DNS dan Mode Autentikasi DNS Biasa, yang artinya Anda bisa tidak menggunakan Mode Alias DNS untuk domain tertentu.

Pakai parameter `--challenge-alias no` untuk menandai domain agar tidak memakai Mode Alias DNS, sehingga akan menggunakan Mode DNS Biasa.

Contoh kali ini adalah `domain.com` yang menggunakan Mode Alias DNS, sedangkan `domain.id` tidak, maka `domain.com` perlu ditambahkan rekaman CNAME-nya yang diarahkan ke domain alias-nya, seperti berikut:

```plain
_acme-challenge.domain.com
   =>   _acme-challenge.domain-lain.com
```

Lalu, terbitkan sertifikatnya dengan mempelajari perintah berikut:

```shell
acme.sh --issue \
        -d domain.com --challenge-alias domain-lain.com \
        -d domain.id --challenge-alias no \
        --dns dns_cf
```

Contoh di atas diasumsikan bahwa Anda memakai Cloudflare sebagai Penyedia DNS. Kalau Anda memakai penyedia DNS yang berbeda, maka Anda dapat mempelajari contoh perintah berikut:

```shell
acme.sh --issue \
        -d domain.com --challenge-alias domain-lain.com --dns dns_cf \
        -d domain.id --challenge-alias no --dns dns_netlify
```

Contoh di atas diasumsikan bahwa `domain-lain.com` menggunakan Cloudflare sebagai Penyedia DNS, sedangkan `domain.id` menggunakan Netlify sebagai Penyedia DNS-nya.

**Bagaimana jika dalam bentuk _Wildcard_?** Ya tetap saja harus ditambahkan satu per satu parameter `--challenge-alias`-nya, contohnya seperti berikut:

```shell
acme.sh --issue \
        -d '*.domain.com' --challenge-alias domain-lain.com \
        -d '*.domain.id' --challenge-alias no \
        -d domain.com --challenge-alias domain-lain.com \
        -d domain.id --challenge-alias no \
        --dns dns_cf
```

Atau, berikut di bawah ini jika Anda ingin memakai penyedia DNS yang berbeda-beda:

```shell
acme.sh --issue \
        -d '*.domain.com' --challenge-alias domain-lain.com --dns dns_cf \
        -d '*.domain.id' --challenge-alias no --dns dns_netlify \
        -d domain.com --challenge-alias domain-lain.com --dns dns_cf \
        -d domain.id --challenge-alias no --dns dns_netlfy
```

Contoh di atas diasumsikan bahwa `domain-lain.com` menggunakan Cloudflare sebagai Penyedia DNS, sedangkan `domain.id` menggunakan Netlify sebagai Penyedia DNS-nya.

Kira-kira begitu.

#### 6. Pakai `--challenge-alias` atau `--domain-alias` {#dns-alias-mode-6}

Perkakas acme.sh mempunyai parameter selain `--challenge-alias`, yakni `--domain-alias` yang secara fungsi memang hampir sama.

Namun, dengan `--domain-alias` Anda tidak perlu menambahkan rekaman CNAME dengan berawalan `_acme-challenge`. Sebagai contoh, ketika Anda memakai parameter `--challenge-alias`, maka Anda harus menambahkan rekaman CNAME berikut:

```plain
_acme-challenge.domain.com
   =>   _acme-challenge.domain-lain.com
```

Lalu, perintah untuk menerbitkan sertifikatnya akan seperti berikut:

```shell
acme.sh --issue \
        -d domain.com \
        --challenge-alias domain-lain.com --dns dns_cf
```

Hal di atas berlaku jika Anda menerbitkannya dengan parameter `--challenge-alias`. Namun, ketika Anda menggunakan `--domain-alias`, maka rekaman CNAME yang perlu ditambahkan contohnya sebagai berikut:

```plain
_acme-challenge.domain.com
   =>   alias.domain-lain.com
```

Lalu, perintah untuk menerbitkan sertifikatnya akan seperti berikut:

```shell
acme.sh --issue -d domain.com --domain-alias alias.domain-lain.com --dns dns_cf
```

**Catatan:** Jangan gunakan nama domainnya saja untuk `--domain-alias`

Ini akan meminta perkakas untuk membuatkan rekaman TXT di dalam puncak domain Anda (_apex domain_). Karena menambahkan sebuah rekaman dan nilainya di puncak domain itu memerlukan sintaks yang berbeda, maka hal ini tidak bisa dilakukan dalam bentuk di atas.

Jika Anda benar-benar ingin membuat rekaman tersebut di puncak domain, Anda dapat gunakan perintah berikut: (Namun hal ini akan bergantung pada implementasi dukungan DNS API pada acme.sh dan juga penyedia DNS-nya)

```shell
acme.sh --issue -d domain.com --domain-alias @.domain-lain.com --dns dns_cf
```

Atau:

```shell
acme.sh --issue -d domain.com --domain-alias .domain-lain.com --dns dns_cf
```

**Bisakah menggunakan domain atau subdomain yang berbeda?** Tentu saja bisa, hanya saja nantinya Anda perlu memasukkan satu per satu parameternya saat menerbitkan sertifikat, seperti pada `--challenge-alias`.

Sebagai contohnya Anda ingin `domain.com` menggunakan `alias1.domain-lain.com` sebagai alias, sedangkan `domain.id` menggunakan `alias2.domain-lain.com`, maka Anda perlu menambahkan rekaman CNAME seperti berikut:

```plain
_acme-challenge.domain.com
   =>   alias1.domain-lain.com

_acme-challenge.domain.id
   =>   alias2.domain-lain.com
```

Lalu, perintah untuk menerbitkan sertifikatnya akan seperti berikut:

```shell
acme.sh --issue \
        -d domain.com --domain-alias alias1.domain-lain.com \
        -d domain.id --domain-alias alias2.domain-lain.com \
        --dns dns_cf
```

Atau berikut di bawah ini jika Anda ingin menerbitkannya dalam bentuk _Wildcard_:

```shell
acme.sh --issue \
        -d '*.domain.com' --domain-alias alias1.domain-lain.com \
        -d '*.domain.id' --domain-alias alias2.domain-lain.com \
        -d domain.com --domain-alias alias1.domain-lain.com \
        -d domain.id --domain-alias alias2.domain-lain.com \
        --dns dns_cf
```

Kira-kira begitu.

#### 7. Terakhir {#dns-alias-mode-7}

Kalau sudah selesai menerbitkannya, tolong rekaman CNAME yang telah Anda buat tadi jangan dihapus, karena rekaman tersebut akan dipakai saat memperbarui sertifikat nanti untuk melakukan verifikasi ulang.

### Menerbitkan Sertifikat SSL/TLS dengan ukuran kunci yang berbeda {#ssl-beda-ukuran-kunci}

Secara baku, perkakas acme.sh akan menerbitkan Sertifikat SSL/TLS dengan kunci RSA yang berukuran 2048 bit (RSA-2048).

Jika Anda ingin menerbitkan Sertifikat SSL/TLS dengan ukuran kunci yang berbeda, tambahkan saja parameter `--keylength ukuran_kunci_rsa` atau `-k ukuran_kunci_rsa`. Ganti `ukuran_kunci_rsa` dengan Ukuran kunci RSA yang didukung.

Contoh Perintah di bawah ini jika Anda ingin menerbitkannya dengan kunci RSA yang berukuran 3072 bit (RSA-3072):

```shell
acme.sh --issue -d domain.com -d www.domain.com -k 3072
```

{{< info title="**Perhatian !**" >}}
Jika Anda sedang mempelajari penggunaan perkakas acme.sh, maka saya sarankan agar Anda selalu tambahkan parameter `--test` atau `--staging` untuk menjalankan perkakas acme.sh dalam mode pengujian, ini cocok untuk Anda yang sedang belajar.

Kalau ingin memperbarui sertifikatnya, pastikan Anda menambahkan parameter `--force --server letsencrypt_test`, karena sekarang acme.sh akan secara otomatis membalikkan opsi CA-nya ke Let's Encrypt versi produksi yang mana itu bukan lagi termasuk tahap uji coba.

Kalau sudah merasa yakin, Anda dapat terbitkan ulang Sertifikat SSL/TLS-nya untuk produksi dengan menggunakan parameter `--issue --force`, tanpa parameter `--test` atau `--staging`.
{{< / info >}}

Atau, berikut di bawah ini jika Anda ingin menerbitnya dalam bentuk _Wildcard_:

```shell
acme.sh --issue -d '*.domain.com' -d domain.com -k 3072 --dns dns_cf
```

Jika Anda ingin menerbitkannya dengan ukuran kunci sebesar 4096 bit, maka tinggal Anda ganti saja parameternya menjadi `--keylength 4096` atau `-k 4096`. Intinya, perhatikan saja nilai parameternya.

Ukuran Kunci RSA yang didukung oleh acme.sh beserta nilai parameter `keylength`-nya adalah:

- RSA-2048 (Bawaan)
- RSA-3072 (`3072`)
- RSA-4096 (`4096`)
- RSA-8192 (`8192`)

**Catatan:** Didukung oleh perkakas acme.sh, bukan berarti didukung oleh CA yang digunakan, salah satunya adalah Let's Encrypt yang tidak mendukung penggunaan kunci RSA dengan ukuran di atas 4096 bit.

{{< info title="**PERINGATAN !**" >}}
Saya tidak menyarankan Anda untuk menerbitkan serta menggunakan ukuran kunci yang terlalu besar.

Karena selain menghasilkan kunci dengan ukuran yang besar, terkadang proses pemuatan konten pada perangkat lunak (termasuk peramban web) akan memakan waktu saat sedang proses 'jabat tangan' TLS (_TLS handshake_), yang berakibat pada membengkaknya penggunaan CPU atau prosesor pada perangkat tertentu untuk mengenkripsi transaksi data saat proses 'jabat tangan'.

Jika Anda merupakan pemilik situs web atau blog, maka kemungkinan hal ini akan mempengaruhi performa situs web secara keseluruhan dan ini mungkin akan berpotensi mengurangi pengunjung pada situs web Anda.

Saya sarankan agar Anda gunakan ukuran kunci yang ideal. Ukuran kunci yang ideal untuk kebanyakan kasus adalah 2048 bit, 3072 bit, atau yang paling besar adalah 4096 bit, tidak perlu terlalu besar.
{{< / info >}}

### Menerbitkan Sertifikat SSL/TLS dengan kunci ECC/ECDSA {#ecdsa-ssl}

Secara baku, acme.sh akan menerbitkan Sertifikat SSL/TLS menggunakan RSA sebagai algoritma kunci publiknya.

Jika Anda ingin menerbitkannya menggunakan kunci ECC (_Eliptic Curve Cryptography_)/ECDSA (_Eliptic Curve Digital Signature Algorithm_) yang ukuran kuncinya jauh lebih kecil, maka Anda hanya perlu tambahkan saja parameter `--keylength ec-ukuran_kuncinya` atau `-k ec-ukuran_kuncinya`. Ganti `ukuran_kuncinya` dengan ukuran kunci ECC yang didukung.

Contoh Perintah di bawah ini jika Anda ingin menerbitkan Sertifikat SSL/TLS ECDSA dengan ukuran P-384:

```shell
acme.sh --issue -d domain.com -d www.domain.com -k ec-384
```

{{< info title="**Perhatian !**" >}}
Jika Anda sedang mempelajari penggunaan perkakas acme.sh, saya sarankan agar Anda selalu tambahkan parameter `--test` atau `--staging` untuk menjalankan perkakas acme.sh dalam mode pengujian, ini cocok untuk Anda yang sedang belajar.

Kalau ingin memperbarui sertifikatnya, pastikan Anda menambahkan parameter `--force --server letsencrypt_test`, karena sekarang acme.sh akan secara otomatis membalikkan opsi CA-nya ke Let's Encrypt versi produksi yang mana itu bukan lagi termasuk tahap uji coba.

Kalau sudah merasa yakin, Anda dapat terbitkan ulang Sertifikat SSL/TLS-nya untuk produksi dengan menggunakan parameter `--issue --force`, tanpa parameter `--test` atau `--staging`.
{{< / info >}}

Atau, berikut di bawah ini jika Anda ingin menerbitkannya dalam bentuk _Wildcard_:

```shell
acme.sh --issue -d '*.domain.com' -d domain.com -k ec-384 --dns dns_cf
```

Jika Anda ingin menerbitkannya dengan kunci ECDSA P-256, tinggal ganti saja menjadi `-k ec-256`. Intinya, perhatikan saja nilai parameternya.

Ukuran Kunci ECC/ECDSA yang didukung oleh acme.sh beserta nilai dari parameter `keylength` adalah:

- ECDSA P-256 (`ec-256`)
- ECDSA P-384 (`ec-384`)
- ECDSA P-512 (`ec-512`)

**Catatan:** Didukung oleh acme.sh, bukan berarti didukung oleh CA yang digunakan, termasuk Let's Encrypt yang belum mendukung kunci ECDSA dengan ukuran kunci P-512.

{{< info title="**PERINGATAN !**" >}}
Saya tidak menyarankan Anda untuk menerbitkan serta menggunakan ukuran kunci yang terlalu besar.

Karena selain menghasilkan kunci dengan ukuran yang besar, terkadang proses pemuatan konten pada perangkat lunak (termasuk peramban web) akan memakan waktu saat sedang proses 'jabat tangan' TLS (_TLS handshake_), yang berakibat pada membengkaknya penggunaan CPU atau prosesor pada perangkat tertentu untuk mengenkripsi transaksi data saat proses 'jabat tangan'.

Jika Anda merupakan pemilik situs web atau blog, maka kemungkinan hal ini akan mempengaruhi performa situs web secara keseluruhan dan ini mungkin akan berpotensi mengurangi pengunjung pada situs web Anda.

Saya sarankan agar Anda gunakan ukuran kunci yang ideal. Ukuran kunci yang ideal untuk kebanyakan kasus adalah P-256, atau yang paling besar adalah P-384, tidak perlu terlalu besar.
{{< / info >}}

Sekadar Informasi saja, jika Anda menerbitkan Sertifikat SSL/TLS dengan kunci ECC/ECDSA, maka berkas-berkas Sertifikat SSL/TLS akan tersimpan di dalam direktori yang berakhiran dengan `_ecc`, seperti: `/home/username/.acme.sh/domain.com_ecc`, bukan di dalam direktori yang biasanya.

Nama berkas-berkasnya akan sama saja, tidak ada yang berbeda. Satu hal lagi, jika Anda ingin mencabut, menghapus, atau memperbarui/_me-renew_ Sertifikat SSL/TLS secara manual, maka Anda perlu menambahkan parameter `--ecc` juga.

Contoh perintahnya sebagai berikut:

```shell
acme.sh --remove -d domain.com --ecc
```

- Contoh di atas merupakan perintah untuk menghapus Sertifikat SSL/TLS yang berkunci ECC/ECDSA. Ganti `--remove` dengan parameter/argumen lain yang Anda inginkan

    Salah satunya: `--renew` jika Anda ingin memperbarui sertifikatnya, atau `--revoke` jika Anda ingin mencabut sertifikatnya, atau parameter lainnya.

- Ganti `domain.com` dengan alamat domain pertama yang Anda masukkan saat menerbitkan Sertifikat SSL/TLS.

Nah, akhirnya Anda telah berhasil menerbitkan Sertifikat SSL/TLS-nya, selanjutnya Anda perlu mengetahui berkas-berkas yang berada di dalam direktori acme.sh-nya, terutama mengetahui berkas mana yang perlu dikirimkan nantinya beserta konfigurasi akunnya.

Jika Anda merasa itu gak penting, maka Anda bisa langsung lanjut ke bagian [Memasang Sertifikat SSL/TLS-nya](#memasang-ssl).

## Berkas-berkas acme.sh {#berkas-berkas-acme-sh}

Bagian ini akan membahas tentang berkas-berkas yang berada di dalam direktori acme.sh itu terinstal.

Ini bukanlah hal yang wajib, sehingga bisa Anda [lewati](#memasang-ssl) jika berkenan, tetapi ini sangat disarankan untuk dipelajari, selain supaya Anda bisa memasang Sertifikat SSL/TLS-nya dengan baik, ini juga dapat membantu Anda untuk menyelesaikan masalah Anda saat menggunakannya.

### Letak acme.sh, isi direktorinya beserta fungsi-fungsinya {#letak-acme-sh}

Biasanya, acme.sh akan terinstal di dalam direktori `$HOME/.acme.sh`. Isi dari direktorinya sebagai berikut:

```shell {linenos=true}
$ ls -la "$HOME"/.acme.sh
total 256
drwx------ 10 user user   4096 Aug 27 15:43  .
drwx------ 12 user user   4096 Sep 27 11:56  ..
-rw-r--r--  1 user user   1747 Aug 27 15:38  account.conf
-rwxr-xr-x  1 user user 205958 Jul  5 16:41  acme.sh
-rw-r--r--  1 user user     92 Jul  4 18:22  acme.sh.env
drwxr-xr-x  3 user user   4096 Jul  4 18:33  ca
drwxr-xr-x  2 user user   4096 Jul  5 16:41  deploy
drwxr-xr-x  2 user user   4096 Jul  5 16:41  dnsapi
drwxr-xr-x  2 user user   4096 Jul  8 08:50  domain.com
drwxr-xr-x  2 user user   4096 Aug 27 11:45  domain.com_ecc
drwxr-xr-x  2 user user   4096 Aug 27 15:38 '*.domain.com'
drwxr-xr-x  2 user user   4096 Aug 27 15:37 '*.domain.com_ecc'
-rw-r--r--  1 user user    224 Aug 27 16:26  http.header
drwxr-xr-x  2 user user   4096 Jul  5 16:41  notify
```

**Catatan:** Huruf `d` di paling awal baris pada keluaran (cth. `drwxr` yang berawalan huruf `d`) itu merupakan direktori, bukan sebuah berkas.

Setiap direktori dan berkas yang ada di dalam sana memiliki fungsinya masing-masing. Fungsi-fungsi dari isi direktori acme.sh adalah sebagai berikut:

1. Berkas `acme.sh`: Berkas utama untuk perkakas acme.sh, berkas tersebut akan dieksekusi ketika Anda menjalankan perkakas acme.sh
2. Berkas `acme.sh.env`: Berkas yang digunakan untuk menyimpan lingkungan variabel (_environment variables_) yang mengatur bagaimana perkakas acme.sh dijalankan
3. Berkas `account.conf`: Berkas konfigurasi untuk perkakas acme.sh
4. Direktori `ca`: Direktori yang digunakan sebagai tempat penyimpanan Informasi mengenai akun CA yang telah Anda registrasikan/kaitkan sebelumnya melalui parameter `--register-account` atau secara otomatis jika Anda menerbitkan Sertifikat SSL/TLS untuk pertama kalinya.

    Direktori tersebut (dan berkas-berkas di dalamnya) akan digunakan oleh perkakas acme.sh untuk menerbitkan, memperbarui dan mencabut Sertifikat SSL/TLS dengan menggunakan akun yang telah Anda registrasikan/kaitkan sebelumnya

5. Direktori `deploy`: Direktori yang digunakan sebagai tempat penyimpanan berkas skrip _Shell_ untuk penggunaan fitur _Deploy Hook_ yang ada pada perkakas acme.sh, isi direktori tersebut adalah skrip _Deploy Hook_ yang disediakan oleh perkakas tersebut.

    Direktori tersebut (dan berkas-berkas di dalamnya) akan digunakan oleh perkakas acme.sh jika Anda menggunakan fitur _Deploy Hook-nya_. Untuk cara penggunaannya, silakan kunjungi [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/deployhooks)

6. Direktori `dnsapi`: Direktori yang digunakan sebagai tempat penyimpanan berkas skrip _Shell_ untuk penggunaan fitur verifikasi DNS yang ada pada perkakas acme.sh saat menerbitkan dan memperbarui Sertifikat SSL/TLS. Isi direktori tersebut adalah penyedia DNS yang telah didukung oleh acme.sh untuk verifikasi.

    Direktori tersebut (dan berkas-berkas di dalamnya) akan digunakan oleh perkakas acme.sh jika Anda menggunakan DNS sebagai verifikasi dalam menerbitkan dan memperbarui Sertifikat SSL/TLS-nya. Untuk cara penggunaannya itu sudah saya jelaskan sebelumnya, yakni di dalam bagian "[Menerbitkan Sertifikat SSL/TLS dengan Menggunakan DNS sebagai Metode Verifikasi](#verifikasi-dns)".

7. Direktori yang berawalan dengan nama domain (cth. `domain.com` dan `'*.domain.com'`) merupakan direktori yang digunakan sebagai tempat penyimpanan Sertifikat SSL/TLS yang telah Anda terbitkan, beserta konfigurasinya. Isi di dalam direktori tersebut adalah berkas-berkas yang diperlukan untuk memasang Sertifikat SSL/TLS ke dalam Web/Blog Anda, berkas CSR untuk memperbarui sertifikat, dan berkas konfigurasinya.

    Direktori tersebut (terutama berkas-berkas di dalamnya) sangat wajib untuk diketahui, karena itu akan sangat diperlukan untuk pemasangan dan pengaktifan Sertifikat SSL/TLS yang telah Anda terbitkan ke dalam Web/Blog Anda. Berkas Konfigurasi di dalamnya (cth. `domain.com.conf`) bisa Anda gunakan untuk mengkonfigurasi perilaku acme.sh baik sebelum dan sesudahnya.

    Nama dari direktori tersebut ditentukan oleh domain pertama yang telah Anda masukkan saat menerbitkan Sertifikat SSL/TLS dengan perkakas acme.sh sebelumnya atau merupakan domain utama

8. Direktori yang berawalan dengan nama domain dan berakhiran `_ecc` (cth. `domain.com_ecc` dan `'*.domain.com_ecc'`): Sama saja seperti no. 7, bedanya di sini menyimpan Sertifikat SSL/TLS yang telah diterbitkan dengan kunci ECC/ECDSA, yang telah saya bahas di dalam [bagian sebelumnya](#ecdsa-ssl).
9. Berkas `http.header`: Entah berkas ini fungsinya untuk apaan, tetapi mungkin berkas ini akan digunakan untuk menerbitkan dan memperbarui Sertifikat SSL/TLS dengan perkakas acme.sh, jadi sebaiknya jangan dihapus
10. Direktori `notify`: Direktori yang digunakan sebagai tempat penyimpanan berkas skrip _Shell_ untuk penggunaan fitur _Notify Hook_ yang ada pada perkakas acme.sh, isi direktori tersebut adalah skrip _Notify Hook_ yang disediakan oleh perkakas tersebut.

    Direktori tersebut (dan berkas-berkas di dalamnya) akan digunakan oleh perkakas acme.sh jika Anda menggunakan fitur _Notify Hook-nya_. Untuk cara penggunaannya, silakan kunjungi [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/notify)

Nah, itulah letak acme.sh, isi direktorinya beserta fungsi-fungsinya.

### Konfigurasi utama acme.sh

Letak berkas konfigurasi utama acme.sh terletak di `$HOME/.acme.sh/account.conf`.

Berkas tersebut menyimpan sejumlah kredensial yang Anda masukkan melalui variabel dari sebuah _Shell_ (Seperti _Token_, Kunci API, atau bahkan Nama Pengguna dan Kata Sandi), acme.sh akan menyimpan informasi tersebut secara otomatis ke dalam berkas `account.conf` jika dijalankan dan akan digunakan kembali jika tersimpan.

Berikut adalah contoh isi berkas `account.conf`:

```shell {linenos=true}
$ cat "$HOME"/.acme.sh/account.conf
LE_WORKING_DIR=/home/username/.acme.sh
LE_CONFIG_HOME=/home/username/.acme.sh
UPGRADE_HASH='8ded524236347d5a1f7a3169809cab9cf363a1c8'
ACCOUNT_EMAIL='emailku@domain.com'
#AUTO_UPGRADE='1'
USER_PATH='/home/username/bin:/home/username/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/var/lib/snapd/snap/bin'
```

Jadi, jika Anda memiliki masalah saat menggunakan acme.sh hanya karena kredensialnya tidak valid, entah itu salah memasukkan atau tidak ada, Anda bisa menggantinya dengan mengubah berkas tersebut dengan memakai Editor Teks favorit Anda.

### Isi direktori `domain.com` dan berkas yang diperlukan {#isi-direktori-domain-com}

Berikut di bawah ini adalah isi dari direktori `domain.com` yang ada di dalam perkakas acme.sh, di dalamnya ada berkas-berkas yang diperlukan untuk memasangkan Sertifikat SSL/TLS.

```shell {linenos=true}
$ ls -la "$HOME"/.acme.sh/domain.com
total 44
drwxr-xr-x  2 user user 4096 Jul  8 08:46 .
drwx------ 10 user user 4096 Jul  8 08:50 ..
-rw-r--r--  1 user user 4399 Jul  8 08:46 ca.cer
-rw-r--r--  1 user user 2472 Jul  8 08:46 domain.com.cer
-rw-r--r--  1 user user  580 Jul  8 08:46 domain.com.conf
-rw-r--r--  1 user user 1318 Jul  8 08:45 domain.com.csr
-rw-r--r--  1 user user  164 Jul  8 08:45 domain.com.csr.conf
-rw-r--r--  1 user user 2459 Jul  8 08:45 domain.com.key
-rw-r--r--  1 user user 6871 Jul  8 08:46 fullchain.cer
```

Jika Penyedia Hosting/CDN nanti memerlukan 3 informasi agar dapat memasangkan Sertifikat SSL/TLS-nya, maka berkas yang perlu Anda gunakan/kirimkan/masukkan adalah:

- `domain.com.cer` (Sebagai sertifikatnya)
- `domain.com.key` (Sebagai Kuncinya)
- `ca.cer` (Sebagai sertifikat CA/Sertifikat Penengah/"Intermediate Certificate"-nya)

Atau, jika mereka cuma memerlukan 2 informasi saja, maka berkas yang perlu Anda gunakan/kirimkan/masukkan adalah:

- `fullchain.cer` (Sebagai sertifikatnya)
- `domain.com.key` (Sebagai Kuncinya)

**Kenapa bukan `domain.com.cer`?** Karena `fullchain.cer` itu merupakan gabungan dari `domain.com.cer` dan `ca.cer`.

Udah itu saja? Udah, hanya itu yang perlu kamu unggah nantinya. Berkas `.csr`, `.csr.conf` dan `.conf` tidak perlu kamu unggah sama sekali, karena itu akan berguna nantinya untuk memperbarui Sertifikat SSL/TLS Anda.

Praktik terbaik dalam memasang Sertifikat SSL/TLS, selain sertifikat untuk domain, adalah Anda diharuskan untuk memasang/memberikan Informasi mengenai Kunci dan sertifikat Penengah (_Intermediate Certificate_) dari CA kepada penyedianya.

Jika Anda hanya menggunakan berkas `domain.com.cer` daripada `fullchain.cer` sebagai Informasi sertifikat saat penyedia hanya perlu 2 informasi saja, maka rantai pada Sertifikat SSL/TLS yang terpasang malah tidak sempurna, karena tidak ada Sertifikat Penengah dari CA-nya.

Selain berkas CSR dan Sertifikat, berkas `domain.com.conf` juga berguna sebagai konfigurasi acme.sh untuk domain tertentu (cth. `domain.com`), Anda bisa atur perintah yang akan dieksekusi sebelum atau setelah sertifikat sukses diperbarui melalui berkas tersebut, akan saya bahas ini di setelah bagian Pemasangan Sertifikat SSL/TLS.

## Memasang Sertifikat SSL/TLS {#memasang-ssl}

Setelah menerbitkan Sertifikat SSL/TLS, Anda perlu memasangkannya supaya sertifikat yang telah Anda terbitkan bisa diaktifkan. Setiap penyedia Web mempunyai cara memasang yang berbeda-beda, kali ini saya bahas cara memasang Sertifikat SSL/TLS untuk Netlify, Bunny CDN, cPanel dan DirectAdmin.

Memasang Sertifikat SSL/TLS yang saya bahas di sini tidaklah menggunakan metode unggah manual melalui Web, melainkan kamu 'Nembak' ke API-nya atau melakukan pemanggilan ke Server API-nya melalui curl.

Berikut adalah cara-caranya:

### Di Netlify {#pasang-ssl-di-netlify}

#### Membuat "Personal Access Token" dan Mendapatkan "Site ID" {#membuat-personal-access-token-dan-site-id}

Agar Anda bisa memanggil Server API-nya, maka Anda perlu membuat kunci aksesnya, salah satunya adalah dengan membuat **"Personal Access Token"**-nya.

Untuk membuat **"Personal Access Token"**-nya sendiri sudah saya bahas di bagian "Membuat Kode Token API". Jika Anda belum sempat membuatnya, silakan [klik di sini](#netlify-personal-access-token) untuk caranya.

Setelah **"Personal Access Token"** dibuat, maka Anda perlu mendapatkan **"Site ID"**-nya juga. Untuk mendapatkannya, Anda bisa pergi ke **"Site settings"**, lalu klik pada **"General"** -> Terakhir, klik **"Site details"**, di situ akan muncul informasi-informasi mengenai Web Anda, seperti cuplikan berikut:

!["Site ID" di Netlify](Netlify_Site_ID.webp)

Jika Anda melihat cuplikan di atas, **"API ID"** yang saya tunjuk itu merupakan **"Site ID"**-nya, simpan ID tersebut baik-baik. Selain **API ID**, Anda juga bisa menggunakan domain Anda atau menggunakan subdomain dari Netlify sebagai **"Site ID"**-nya.

Langkah selanjutnya adalah memasang Sertifikat SSL/TLS melalui API-nya.

#### Memasang Sertifikat SSL/TLS melalui API dari Netlify

Sekarang tinggal pasang sertifikatnya saja melalui API dari Netlify.

Pertama-tama, Anda perlu menavigasikan Terminal/_Shell_ Anda ke dalam folder tempat berkas sertifikat itu disimpan dengan perintah `cd` terlebih dahulu. Contoh:

```shell
cd "$HOME"/.acme.sh/domain.com
```

Lalu, simpan isi dari berkas-berkas yang diperlukannya ke dalam sebuah variabel.

Anda dapat menyimpannya dengan perintah berikut:

```shell {linenos=true}
PLAIN_CERT="$(awk '{printf "%s\\n", $0}' < domain.com.cer)"
PLAIN_KEY="$(awk '{printf "%s\\n", $0}' < domain.com.key)"
PLAIN_CA="$(awk '{printf "%s\\n", $0}' < ca.cer)"
NETLIFY_ACCESS_TOKEN="ACCESS_TOKEN_KAMU_DI_SINI"
```

Atau, di bawah ini jika Anda ingin cara lain:

```shell {linenos=true}
PLAIN_CERT="$(awk -vORS="\\\n" '1' domain.com.cer)"
PLAIN_KEY="$(awk -vORS="\\\n" '1' domain.com.key)"
PLAIN_CA="$(awk -vORS="\\\n" '1' ca.cer)"
NETLIFY_ACCESS_TOKEN="ACCESS_TOKEN_KAMU_DI_SINI"
```

Atau, di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish {linenos=true}
set PLAIN_CERT (awk -vORS="\\\n" '1' domain.com.cer)
set PLAIN_KEY (awk -vORS="\\\n" '1' domain.com.key)
set PLAIN_CA (awk -vORS="\\\n" '1' ca.cer)
set NETLIFY_ACCESS_TOKEN "ACCESS_TOKEN_KAMU_DI_SINI"
```

Silakan ubah direktori dan nama berkas di atas sesuai dengan letak berkas sertifikat yang telah tersimpan di dalam perangkat Anda dan ubah teks `ACCESS_TOKEN_KAMU_DI_SINI` menjadi _Personal access token_ yang telah Anda buat dan simpan sebelumnya.

Selain nilai variabel, Anda juga bisa bebas menggantikan nama variabelnya sesuka hati Anda, misalnya variabel `PLAIN_CERT` diubah menjadi `PLAIN_CERT_1`, atau `CERT`, atau apa saja, asal bisa Anda gunakan kembali variabel tersebut.

Setelah memasukkannya ke dalam variabel, Anda tinggal panggil saja API-nya dengan perintah berikut:

```shell {linenos=true}
curl -s \
     -H "Authorization: Bearer $NETLIFY_ACCESS_TOKEN" \
     -H "content-type: application/json" \
     -d "{\"certificate\": \"$PLAIN_CERT\", \"key\": \"$PLAIN_KEY\", \"ca_certificates\": \"$PLAIN_CA\"}" \
     "https://api.netlify.com/api/v1/sites/SITE_ID_KAMU_DI_SINI/ssl"
```

Atau, gunakan perintah berikut ini jika Anda ingin memanggilnya dalam satu baris saja:

```shell
curl -sH "Authorization: Bearer $NETLIFY_ACCESS_TOKEN" -H "content-type: application/json" --data "{\"certificate\": \"$PLAIN_CERT\", \"key\": \"$PLAIN_KEY\", \"ca_certificates\": \"$PLAIN_CA\"}" --url "https://api.netlify.com/api/v1/sites/SITE_ID_KAMU_DI_SINI/ssl"
```

Sebelum dieksekusi, silakan ganti `SITE_ID_KAMU_DI_SINI` terlebih dahulu dengan _Site ID_, domain atau subdomain di Netlify yang ingin Anda pasangkan sertifikatnya.

Jika sukses, maka akan tampil pesan dalam format JSON, seperti di bawah ini:

```json
{"id":"5dxxxxxxxxxxxxxxxxxxxxxx","state":"custom","domains":["*.domain.com","domain.com"],"created_at":"2019-08-30T06:39:58.331Z","updated_at":"2021-07-12T17:07:40.622Z","expires_at":"2021-10-06T23:59:59.000Z","custom":true,"migrate_to_le_running":false,"renewal_error_message":null,"renewable":false,"renew_running":false}
```

Atau, penampilannya akan seperti di bawah ini jika dipercantik:

```json {linenos=true}
{
   "id":"5dxxxxxxxxxxxxxxxxxxxxxx",
   "state":"custom",
   "domains":[
      "*.domain.com",
      "domain.com"
   ],
   "created_at":"2019-08-30T06:39:58.331Z",
   "updated_at":"2021-07-12T17:07:40.622Z",
   "expires_at":"2021-10-06T23:59:59.000Z",
   "custom":true,
   "migrate_to_le_running":false,
   "renewal_error_message":null,
   "renewable":false,
   "renew_running":false
}
```

Jika gagal, maka pesan yang muncul tidak seperti di atas, melainkan pesan galat (_error_) yang isinya berbeda-beda tergantung penyebabnya.

Nah, gimana? Cukup mudah, bukan? Jika Anda berhasil memasang Sertifikat SSL/TLS di Netlify melalui pemanggilan Server API-nya dan tidak ada penyedia lain, maka Anda hanya perlu membuat sebuah skrip _Shell_ agar SSL bisa [diperbarui secara otomatis](#renew-ssl) atau mungkin Anda perlu mempelajari [Konfigurasi acme.sh untuk Domain tertentu](#konfigurasi-acme-sh-untuk-domain) terlebih dahulu sebelum itu.

### Di bunny\.net (Sebelumnya: BunnyCDN) {#pasang-ssl-di-bunnycdn}

#### Mendapatkan "Access Key" dan "Pull Zone ID"-nya

Sebelum Anda bisa memasang Sertifikat SSL/TLS dengan melakukan pemanggilan Server API dari bunny\.net (sebelumnya: BunnyCDN), maka Anda perlu mendapatkan **"Access Key"** dan **"Pull Zone ID"**-nya terlebih dahulu.

Untuk mendapatkan **"Access Key"**-nya sendiri sudah saya bahas di bagian "Membuat Kode Token API". Jika belum sempat mendapatkannya, silakan [klik di sini](#bunny-access-key) untuk caranya.

Untuk **"Pull Zone ID"**-nya, Anda bisa dapatkan itu di pengaturannya. Caranya setelah login dan diarahkan ke Halaman Dasbor, klik **"Delivery"** yang letaknya di sebelah kiri halaman -> Lalu, klik pada **"CDN"** -> Setelah itu, pilih _Pull Zone_ yang ingin kamu pasangkan sertifikatnya -> Setelah dipilih dan diklik, maka alamat URL pada Peramban Web akan menjadi seperti format di bawah ini:

```plain
https://dash.bunny.net/cdn/ANGKA_YANG_MUNCUL
```

Angka yang muncul di akhir alamat URL (`ANGKA_YANG_MUNCUL`) itu adalah **"Pull Zone ID"** kamu, jadi simpan itu baik-baik jika Anda ingin memasangkan sertifikatnya dan pastikan kamu telah membuat **"Custom Hostname"** sebelumnya di sana.

Karena selain **"Access Key"** dan **"Pull Zone ID"**, mempunyai **"Custom Hostname"** merupakan hal yang wajib hukumnya, karena Anda tidak bisa menggunakan Subdomain dari bunny\.net (`b-cdn.net`) untuk dipasangkan sertifikatnya.

Setelah mendapatkan semuanya, selanjutnya adalah memasang Sertifikat SSL/TLS melalui Akses API-nya.

#### Memasang Sertifikat SSL/TLS melalui API dari bunny\.net

Sekarang Anda tinggal memasang sertifikatnya saja dengan melakukan pemanggilan Server API dari bunny\.net.

Pertama-tama, Anda perlu menavigasikan Terminal/_Shell_ Anda ke dalam folder tempat berkas sertifikat itu disimpan dengan perintah `cd` terlebih dahulu. Contoh:

```shell
cd "$HOME"/.acme.sh/domain.com
```

Lalu, simpan isi dari berkas-berkas yang diperlukannya ke dalam sebuah variabel.

Anda dapat menyimpannya dengan perintah berikut:

```shell {linenos=true}
BASE64_FULLCHAIN_CER="$(openssl base64 -A < fullchain.cer)"
BASE64_KEY="$(openssl base64 -A < domain.com.key)"
BUNNY_ACCESS_KEY="ACCESS_KEY_KAMU_DI_SINI"
```

Atau, di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish {linenos=true}
set BASE64_FULLCHAIN_CER (openssl base64 -A < fullchain.cer)
set BASE64_KEY (openssl base64 -A < domain.com.key)
set BUNNY_ACCESS_KEY "ACCESS_KEY_KAMU_DI_SINI"
```

Silakan ubah direktori dan nama berkas di atas sesuai dengan Sertifikat SSL/TLS yang tersimpan di dalam perangkat Anda dan ubah teks `ACCESS_KEY_KAMU_DI_SINI` menjadi _Access Key_ yang telah Anda simpan sebelumnya.

Selain nilai variabel, Anda juga bisa bebas menggantikan nama variabelnya sesuka hati Anda, misalnya variabel `BASE64_FULLCHAIN_CER` diubah menjadi `FULLCHAIN_CER`, atau `FULLCHAIN`, atau apa saja, asal dapat Anda gunakan kembali variabel tersebut.

Setelah memasukkannya ke dalam variabel, Anda tinggal panggil saja API-nya dengan perintah berikut:

```shell {linenos=true}
curl -s \
     -H "Accept: application/json" \
     -H "AccessKey: $BUNNY_ACCESS_KEY" \
     -H "Content-Type: application/json" \
     -d "{\"Hostname\": \"CUSTOM_HOSTNAME_KAMU_DI_SINI\", \"Certificate\": \"$BASE64_FULLCHAIN_CER\", \"CertificateKey\": \"$BASE64_KEY\"}" \
     "https://api.bunny.net/pullzone/PULL_ZONE_ID_KAMU_DI_SINI/addCertificate"
```

Atau, gunakan perintah berikut ini jika Anda ingin memanggilnya dalam satu baris saja:

```shell
curl -sH "Accept: application/json" -H "AccessKey: $BUNNY_ACCESS_KEY" -H "Content-Type: application/json" --data "{\"Hostname\": \"CUSTOM_HOSTNAME_KAMU_DI_SINI\", \"Certificate\": \"$BASE64_FULLCHAIN_CER\", \"CertificateKey\": \"$BASE64_KEY\"}" --url "https://api.bunny.net/pullzone/PULL_ZONE_ID_KAMU_DI_SINI/addCertificate"
```

Sebelum dieksekusi, silakan ganti `PULL_ZONE_KAMU_DI_SINI` terlebih dahulu dengan ID _Pull Zone_ dan `CUSTOM_HOSTNAME_KAMU_DI_SINI` dengan Nama Hos/Domain Kustom di dalam _Pull Zone_ yang ingin Anda pasangkan sertifikatnya.

Jika berhasil, maka tidak akan muncul pesan apa pun (Kode Status: [**204 No Content**](https://http.cat/204)), berbeda bila dibandingkan dengan Netlify yang menampilkan pesan dalam format JSON. Sebaliknya, jika tidak berhasil, maka pesan galat akan muncul dengan pesan yang berbeda-beda, tergantung penyebabnya.

Nah, gimana? Cukup mudah, bukan? Jika Anda berhasil memasang sertifikat SSL/TLS Anda di Bunny CDN dengan memanggil API-nya dan tidak ada penyedia lain yang sedang dipakai, maka Anda hanya perlu membuat sebuah skrip _Shell_ agar SSL bisa [diperbarui secara otomatis](#renew-ssl) atau mungkin Anda perlu mempelajari [Konfigurasi acme.sh untuk Domain tertentu](#konfigurasi-acme-sh-untuk-domain) terlebih dahulu sebelum itu.

### Di cPanel {#pasang-ssl-di-cpanel}

#### Membuat API Token dan Persiapannya

Jika Anda merupakan pengguna cPanel sebagai kontrol panelnya, baik itu di dalam server ataupun pada layanan _Shared Hosting_ yang Anda gunakan, maka Anda dapat melakukannya tanpa harus mengakses SSH-nya terlebih dahulu.

Tidak ada syarat khusus dalam _hosting_ untuk memasangkan sertifikat SSL/TLS melalui Akses API ini, jadi Anda dapat memasangnya dengan memakai paket _hosting_ termurah sekali pun, selama layanan _hosting_ mendukung pemasangan sertifikat SSL/TLS kustom dan mendukung cPanel API yang sepertinya mayoritas layanan hosting mendukungnya, kecuali Domainesia dengan paket termurahnya.

Namun sebelum itu, Anda harus membuat **"API Token"**-nya terlebih dahulu di cPanel-nya, yang tentu saja Anda perlu masuk ke dalam cPanel-nya untuk ini.

Jika kamu belum pernah membuat **"API Token"** sebelumnya (di dalam bagian **"Membuat Kode Token API"**), silakan [klik di sini](#cpanel-api-token) untuk caranya.

Setelah membuat **"API Token"** dan menyimpannya, Anda perlu menginstal [`jq`](https://jqlang.github.io/jq/) di dalam perangkat Anda, ini akan sangat diperlukan untuk memasang sertifikat SSL/TLS melalui API dari cPanel nantinya, karena kamu memerlukan fitur **URI Encode** untuk mengirim datanya.

Jika sudah diinstal, silakan lanjut ke langkah berikutnya.

#### Memasang Sertifikat SSL/TLS melalui API dari cPanel

Pada langkah ini Anda akan memasangkan sertifikat SSL/TLS-nya melalui panggilan API dari cPanel. Pemasangannya sendiri agak beda dari yang lain, kedua penyedia di atas menggunakan metode POST, sedangkan yang ini menggunakan metode GET.

Kedua metode ini memiliki perbedaan dalam mengirimkan datanya, tetapi dengan tujuan yang sama.

Tanpa basa-basi lagi, pertama-tama, Anda perlu menavigasikan Terminal/_Shell_ Anda ke dalam folder tempat berkas sertifikat itu disimpan dengan perintah `cd` terlebih dahulu. Contoh:

```shell
cd "$HOME"/.acme.sh/domain.com
```

Lalu, simpan isi dari berkas-berkas yang diperlukannya ke dalam sebuah variabel.

Anda dapat menyimpannya dengan perintah berikut:

```shell {linenos=true}
CPANEL_PLAIN_CERT="$(jq -sRr @uri < domain.com.cer)"
CPANEL_PLAIN_KEY="$(jq -sRr @uri < domain.com.key)"
CPANEL_PLAIN_CA="$(jq -sRr @uri < ca.cer)"
CPANEL_HOSTNAME="cpanel.domain.com" # Alamat Domain/IP yang Anda gunakan untuk mengakses cPanel
CPANEL_USERNAME="USERNAME_CPANEL_KAMU_DI_SINI" # Username cPanel kamu
CPANEL_API_TOKEN="API_TOKEN_KAMU_DI_SINI" # API Token cPanel kamu
```

Atau, di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish {linenos=true}
set CPANEL_PLAIN_CERT (jq -sRr @uri < domain.com.cer)
set CPANEL_PLAIN_KEY (jq -sRr @uri < domain.com.key)
set CPANEL_PLAIN_CA (jq -sRr @uri < ca.cer)
set CPANEL_HOSTNAME "cpanel.domain.com" # Alamat Domain/IP yang Anda gunakan untuk mengakses cPanel
set CPANEL_USERNAME "USERNAME_CPANEL_KAMU_DI_SINI" # Username cPanel kamu
set CPANEL_API_TOKEN "API_TOKEN_KAMU_DI_SINI" # API Token cPanel kamu
```

Silakan ubah direktori dan nama berkas di atas sesuai dengan berkas sertifikat SSL/TLS yang tersimpan di dalam perangkat Anda, serta ubah nilai dari ketiga variabel di atas lainnya sesuai kredensial cPanel Anda dan cara Anda mengaksesnya.

Selain nilai variabel, Anda juga bisa bebas menggantikan nama variabelnya sesuka hati Anda, misalnya variabel `CPANEL_PLAIN_CA` diubah menjadi `PLAIN_CA`, atau `CA`, atau apa saja, asal dapat Anda gunakan kembali variabel tersebut.

Sedangkan variabel `CPANEL_HOSTNAME` adalah alamat domain/IP yang kamu gunakan untuk mengakses cPanel, biasanya bisa Anda dapatkan itu di halaman _Billing_ dari _Hosting-nya_ atau ada di pesan surel Anda mengenai informasi login-nya.

Usahakan bahwa domain tersebut dapat diakses menggunakan HTTPS tanpa terkena galat apa pun, termasuk karena sertifikatnya.

Kalau kamu tidak tahu alamat domainnya dan tidak tahu cara mendapatkannya, biasanya pihak _hosting_ menyediakan akses langsung ke cPanel melalui HTTPS, caranya sebagai berikut:

1. Login ke akun _Billing-nya_
2. Lalu, pilih layanan _hosting_ yang aktif
3. Klik pada tautan **"Log in to cPanel"** di bagian **"Actions"**
4. Setelah itu Anda akan diarahkan langsung ke cPanel yang diakses melalui HTTPS di tab baru dan lihatlah Alamat URL di dalam kolom Alamat URL pada Peramban Web Anda, Anda bisa gunakan alamat domain tersebut dan memasukkannya ke dalam variabel `CPANEL_HOSTNAME`.

Setelah memasukkannya ke dalam variabel, Anda tinggal panggil saja API-nya dengan perintah berikut:

```shell {linenos=true}
curl -sGH "Authorization: cpanel $CPANEL_USERNAME:$CPANEL_API_TOKEN" \
     -d "domain=<ALAMAT_DOMAIN_KAMU_DI_SINI>" \
     -d "cert=$CPANEL_PLAIN_CERT" \
     -d "key=$CPANEL_PLAIN_KEY" \
     -d "cabundle=$CPANEL_PLAIN_CA" \
     "https://$CPANEL_HOSTNAME:2083/execute/SSL/install_ssl"
```

Atau, gunakan perintah berikut ini jika Anda ingin memanggilnya dalam satu baris saja:

```shell {linenos=true}
curl -sGH "Authorization: cpanel $CPANEL_USERNAME:$CPANEL_API_TOKEN" -d "domain=<ALAMAT_DOMAIN_KAMU_DI_SINI>" -d "cert=$CPANEL_PLAIN_CERT" -d "key=$CPANEL_PLAIN_KEY" -d "cabundle=$CPANEL_PLAIN_CA" "https://$CPANEL_HOSTNAME:2083/execute/SSL/install_ssl"
```

Ganti `<ALAMAT_DOMAIN_KAMU_DI_SINI>` menjadi alamat Domain/Subdomain di cPanel yang ingin kamu pasangkan sertifikatnya.

Jika sukses, maka akan tampil pesan dalam format JSON, seperti di bawah ini:

```json
{"metadata":{},"messages":["The certificate was successfully installed on the domain “domain.com”."],"data":{"extra_certificate_domains":["sub.domain.com"],"servername":"domain.com","message":"Sertifikat SSL ini sekarang diinstal ke domain “domain.com” menggunakan alamat IP “144.xxx.xxx.xxx”. Apache diaktifkan ulang di latar belakang.\n","status":1,"domain":"domain.com","user":"username","cert_id":"ec-_wildcard__domain_com_000xxxxxxx_16xxxxxx65_3cxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1","key_id":"ec-000xxxxx38_4dxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc","action":"install","warning_domains":[],"statusmsg":"Sertifikat SSL ini sekarang diinstal ke domain “domain.com” menggunakan alamat IP “144.xxx.xxx.xxx”. Apache diaktifkan ulang di latar belakang.\n","aliases":"","working_domains":["domain.com"],"ip":"144.xxx.xxx.xxx","html":"<br>Sertifikat SSL ini sekarang diinstal ke domain “domain.com” menggunakan alamat IP “144.xxx.xxx.xxx”.<br />Apache diaktifkan ulang di latar belakang."},"errors":["The event UAPI::SSL::install_ssl was handled successfully."],"status":1,"warnings":null}
```

Atau, penampilannya akan seperti berikut jika dipercantik:

```json {linenos=true}
{
    "metadata": {},
    "messages": [
        "The certificate was successfully installed on the domain “domain.com”."
    ],
    "data": {
        "extra_certificate_domains": [
            "sub.domain.com"
        ],
        "servername": "domain.com",
        "message": "Sertifikat SSL ini sekarang diinstal ke domain “domain.com” menggunakan alamat IP “144.xxx.xxx.xxx”. Apache diaktifkan ulang di latar belakang.\n",
        "status": 1,
        "domain": "domain.com",
        "user": "username",
        "cert_id": "ec-_wildcard__domain_com_000xxxxxxx_16xxxxxx65_3cxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1",
        "key_id": "ec-000xxxxx38_4dxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc",
        "action": "install",
        "warning_domains": [],
        "statusmsg": "Sertifikat SSL ini sekarang diinstal ke domain “domain.com” menggunakan alamat IP “144.xxx.xxx.xxx”. Apache diaktifkan ulang di latar belakang.\n",
        "aliases": "",
        "working_domains": [
          "domain.com"
        ],
        "ip": "144.xxx.xxx.xxx",
        "html": "<br>Sertifikat SSL ini sekarang diinstal ke domain “domain.com” menggunakan alamat IP “144.xxx.xxx.xxx”.<br />Apache diaktifkan ulang di latar belakang."
    },
    "errors": [
        "The event UAPI::SSL::install_ssl was handled successfully."
    ],
    "status": 1,
    "warnings": null
}
```

Jika gagal, maka pesan yang muncul tidak seperti di atas, melainkan pesan galat (_error_) yang isinya berbeda-beda tergantung penyebabnya.

Nah, gimana? Cukup mudah, bukan? Jika berhasil memasang sertifikat SSL/TLS Anda di cPanel melalui API-nya dan tidak ada penyedia lain, maka Anda hanya perlu membuat sebuah skrip _Shell_ agar sertifikat tersebut dapat [diperbarui secara otomatis](#renew-ssl) atau mungkin Anda perlu mempelajari [Konfigurasi acme.sh untuk Domain tertentu](#konfigurasi-acme-sh-untuk-domain) terlebih dahulu sebelum itu.

### Di DirectAdmin {#pasang-ssl-di-directadmin}

Jika Anda merupakan pengguna DirectAdmin sebagai kontrol panelnya, baik itu di dalam server Anda ataupun pada layanan _Shared Hosting_ yang Anda gunakan, maka Anda dapat melakukannya tanpa harus mengakses SSH-nya terlebih dahulu.

Tidak ada syarat khusus dalam hosting untuk memasangkan sertifikat SSL/TLS melalui API ini, jadi Anda bisa memasangnya dengan memakai paket hosting termurah sekali pun, selama hosting mendukung pemasangan sertifikat SSL/TLS kustom.

Namun sebelum itu, saya sarankan bahwa Anda perlu membuat **"Login Key"**-nya terlebih dahulu di dalam DirectAdmin-nya.

Sebenarnya bisa saja memakai kata sandi akun DirectAdmin Anda sebagai gantinya, hanya saja saya tidak merekomendasikan ini, selain karena orang lain dapat mengetahui kata sandi utamanya, hak akses yang diberikan telalu luas untuk keperluan akses yang spesifik saja sehingga metode ini kurang aman.

Dengan menggunakan **"Login Key"**, Anda dapat mengatur hak akses dan batasannya dengan bebas, sehingga jika orang lain dapat mengetahui **"Login Key"**-nya tanpa sengaja, maka hal tersebut tidak berpengaruh/merembet ke yang lain karena aksesnya dibatasi.

Jika kamu belum pernah membuatnya (di dalam bagian **"Membuat Kode Token API"**), silakan [klik di sini](#directadmin-login-key) untuk caranya.

Setelah membuat **"Login Key"** dan menyimpannya, Anda perlu menginstal [`jq`](https://jqlang.github.io/jq/) di dalam perangkat Anda, ini akan sangat diperlukan untuk memasang sertifikat SSL/TLS melalui API dari DirectAdmin nantinya, karena kamu memerlukan fitur **URI Encode** untuk mengirim datanya.

Jika sudah diinstal, silakan lanjut ke langkah berikutnya.

#### Memasang Sertifikat SSL/TLS melalui API dari DirectAdmin

Sekarang Anda tinggal memasang sertifikatnya saja melalui Akses API dari DirectAdmin.

Pertama-tama, Anda perlu menyimpan isi dari berkas-berkas yang diperlukannya terlebih dahulu ke dalam sebuah variabel.

Tanpa basa-basi lagi, pertama-tama, Anda perlu menavigasikan Terminal/_Shell_ Anda ke dalam folder tempat berkas sertifikat itu disimpan dengan perintah `cd` terlebih dahulu. Contoh:

```shell
cd "$HOME"/.acme.sh/domain.com
```

Lalu, simpan isi dari berkas-berkas yang diperlukannya ke dalam sebuah variabel.

Anda dapat menyimpannya dengan perintah berikut:

```shell {linenos=true}
DIRECTADMIN_PLAIN_FULLCHAIN="$(jq -sRr @uri < fullchain.cer)"
DIRECTADMIN_PLAIN_KEY="$(jq -sRr @uri < domain.com.key)"
DIRECTADMIN_HOSTNAME="NAMA_HOS_UNTUK_DIRECTADMIN_KAMU_DI_SINI"
DIRECTADMIN_USERNAME="USERNAME_DIRECTADMIN_KAMU_DI_SINI"
DIRECTADMIN_LOGIN_KEY="LOGIN_KEY_KAMU_DI_SINI"
```

Atau, di bawah ini jika Anda menggunakan `fish` sebagai _Shell_:

```fish {linenos=true}
set DIRECTADMIN_PLAIN_FULLCHAIN (jq -sRr @uri < fullchain.cer)
set DIRECTADMIN_PLAIN_KEY (jq -sRr @uri < domain.com.key)
set DIRECTADMIN_HOSTNAME "NAMA_HOS_UNTUK_DIRECTADMIN_KAMU_DI_SINI"
set DIRECTADMIN_USERNAME "USERNAME_DIRECTADMIN_KAMU_DI_SINI"
set DIRECTADMIN_LOGIN_KEY "LOGIN_KEY_KAMU_DI_SINI"
```

Silakan ubah direktori, nama berkas dan nilai variabel di atas sesuai dengan Sertifikat SSL/TLS yang tersimpan di dalam perangkat Anda dan kredensial DirectAdmin Anda.

Selain nilai variabelnya, Anda juga bisa bebas menggantikan nama variabelnya sesuka hati Anda, misalnya variabel `DIRECTADMIN_PLAIN_FULLCHAIN` diubah menjadi `PLAIN_FULLCHAIN`, atau `FULLCHAIN`, atau apa saja, asal dapat Anda gunakan kembali variabel tersebut.

Variabel `DIRECTADMIN_HOSTNAME` adalah alamat domain yang kamu gunakan untuk login ke dalam DirectAdmin, biasanya bisa Anda dapatkan itu di halaman _Billing_ dari Hosting-nya dan usahakan bahwa domain tersebut dapat diakses menggunakan HTTPS tanpa terkena galat apa pun, termasuk karena sertifikatnya.

Setelah memasukkannya ke dalam variabel, Anda tinggal panggil saja API-nya dengan perintah berikut:

```shell {linenos=true}
curl -s \
     -u "$DIRECTADMIN_USERNAME:$DIRECTADMIN_LOGIN_KEY" \
     -d "domain=<ALAMAT_DOMAIN_KAMU_DI_SINI>" \
     -d "action=save" \
     -d "type=paste" \
     -d "certificate=$DIRECTADMIN_PLAIN_FULLCHAIN" "$DIRECTADMIN_PLAIN_KEY" \
     "https://$DIRECTADMIN_HOSTNAME:2222/CMD_API_SSL"
```

Atau, gunakan perintah berikut ini jika Anda ingin memanggilnya dalam satu baris saja:

```shell
curl -su "$DIRECTADMIN_USERNAME:$DIRECTADMIN_LOGIN_KEY" -d "domain=<ALAMAT_DOMAIN_KAMU_DI_SINI>" -d "action=save" -d "type=paste" -d "certificate=$DIRECTADMIN_PLAIN_FULLCHAIN" "$DIRECTADMIN_PLAIN_KEY" "https://$DIRECTADMIN_HOSTNAME:2222/CMD_API_SSL"
```

Ganti `<ALAMAT_DOMAIN_KAMU_DI_SINI>` menjadi alamat "Domain" yang ada di DirectAdmin yang ingin kamu pasangkan sertifikatnya.

Jika Anda ingin memasangkan sertifikatnya untuk subdomain, maka Anda perlu menambahkan subdomain tersebut ke dalam **"Domain"** di DirectAdmin-nya (Bukan ke dalam **"Subdomain Management"** yah).

Jika sukses, maka akan tampil pesan seperti di bawah ini:

```plain
error=0&text=Certificate%20and%20Key%20Saved%2E&details=&
```

Yap, tidak ada rincian lebih lanjut, hanya pesan itu saja yang tampil, tetapi jika tidak berhasil maka pesannya tidak seperti di atas, melainkan pesan galat yang berbeda-beda tergantung penyebabnya.

Nah, gimana? Cukup mudah, bukan? Jika Anda berhasil memasang sertifikat SSL/TLS di DirectAdmin melalui Akses API-nya dan tidak ada penyedia lain, maka Anda hanya perlu membuat sebuah skrip _Shell_ agar SSL bisa [diperbarui secara otomatis](#renew-ssl) atau mungkin Anda perlu mempelajari [Konfigurasi acme.sh untuk Domain tertentu](#konfigurasi-acme-sh-untuk-domain) terlebih dahulu sebelum itu.

### Lainnya

Jika Anda menggunakan Penyedia Hosting selain Netlify (seperti GitHub Pages, Vercel, Surge\.sh, Render\.com), Kontrol Panel untuk Hosting selain cPanel dan DirectAdmin (seperti Virtualmin/Webmin, Webuzo, CyberPanel, aaPanel, CWP, Kloxo-MR, InterWorx, dll) atau menggunakan Penyedia CDN selain Bunny CDN (seperti Cloudflare, Fastly, AWS CloudFront, Akamai, Edgio, SwiftServe, dll), mohon maaf di sini belum tersedia.

Kenapa? Karena setiap penyedia dan perangkat lunak mempunyai cara yang berbeda untuk memanggil API-nya dan mengirim datanya, kalau saya ingin mengetahui cara kerjanya, maka saya harus mencobanya terlebih dahulu, oleh karena itu saya belum (atau mungkin tidak) bisa menyediakan semuanya di sini.

Anda dapat membaca dan mempelajari masing-masing dokumentasinya sebagai referensi Anda dalam memasang sertifikat SSL/TLS di penyedia lain. Bila berkenan, Anda juga dapat membantu saya menambahkan penyedianya di sini dengan berkomentar di dalam kolom komentar yang tersedia.

## Konfigurasi acme.sh untuk Domain tertentu {#konfigurasi-acme-sh-untuk-domain}

Salah satu kelebihan acme.sh selain ringan dan kompatibel di hampir semua sistem operasi berbasis \*nix adalah mampu memberikan fleksibilitas bagi Anda untuk mengatur perkakasnya dan mengatur apa yang dilakukan baik sebelum dan sesudah mengeksekusi perkakas tersebut melalui konfigurasinya.

Konfigurasi tersebut dapat Anda lakukan untuk alamat domain tertentu, sehingga tidak semua domain yang menggunakan acme.sh terkena efeknya. Hal ini akan menjadi kelebihan tersendiri sejak domain dan subdomainnya dapat menggunakan Hosting/CDN yang berbeda-beda.

Jadi, sebelum membuat/menentukan skrip untuk _me-renew_/memperbarui sertifikat SSL/TLS, mungkin ada baiknya Anda pelajari terlebih dahulu cara mengkonfigurasi acme.sh untuk alamat domain tertentu di sini, meskipun ini bisa langsung Anda [lewati](#renew-ssl) kalau mau.

Pertama-tama, lihatlah isi dari berkas `domain.com.conf` terlebih dahulu, biasanya berkas tersebut ada di dalam folder `$HOME/.acme.sh/domain.com`. Ganti `domain.com` dengan alamat domain Anda.

Contoh isi dari berkas `domain.com.conf` adalah sebagai berikut:

```shell {linenos=true}
$ cat "$HOME/.acme.sh/domain.com/domain.com.conf"
Le_Domain='domain.com'
Le_Alt='*.domain.com'
Le_Webroot='dns_cf'
Le_PreHook=''
Le_PostHook=''
Le_RenewHook=''
Le_API='https://acme.zerossl.com/v2/DV90'
Le_Keylength='ec-384'
Le_OrderFinalize='https://acme.zerossl.com/v2/DV90/order/kyxxxxxxxxxxxxxxxxxxxx/finalize'
Le_LinkOrder='https://acme.zerossl.com/v2/DV90/order/kyxxxxxxxxxxxxxxxxxxxx'
Le_LinkCert='https://acme.zerossl.com/v2/DV90/cert/20xxxxxxxxxxxxxxxxxxxx'
Le_CertCreateTime='1625708943'
Le_CertCreateTimeStr='Thu Jul  8 01:49:03 UTC 2021'
Le_NextRenewTimeStr='Mon Sep  6 01:49:03 UTC 2021'
Le_NextRenewTime='1630806543'
```

Kalau Anda ingin mengubahnya, silakan ubah/edit isi dari berkas tersebut dengan Editor Teks favorit Anda.

Dari semua opsi, yang boleh diubah adalah nilai dari opsi `Le_PreHook`, `Le_PostHook`, dan `Le_RenewHook` saja.

**Bagaimana dengan lainnya?** Untuk lainnya saya sarankan agar Anda tidak mengubahnya, apalagi `Le_Domain`, `Le_Alt`, `Le_API`, `Le_OrderFinalize`, `Le_LinkOrder`, dan `Le_LinkCert`, kecuali jika Anda memahami apa yang sedang Anda lakukan dan siap menerima risikonya.

Jadi, saya bahas yang boleh diubah saja. Berikut adalah penjelasan mengenai nilai dari opsi di atas:

- `Le_PreHook`: Opsi ini menentukan perintah yang akan dieksekusi sebelum perkakas acme.sh menjalankan tugasnya untuk menerbitkan/memperbarui Sertifikat SSL/TLS.

    Nilai baku untuk opsi ini adalah tidak ada, tetapi jika Anda menerbitkan sertifikatnya dibarengi parameter `--pre-hook`, maka opsi tersebut akan _di-encode_ menjadi Base64 dan terisi secara otomatis

- `Le_PostHook`: Opsi ini menentukan perintah yang akan dieksekusi setelah perkakas acme.sh menjalankan tugasnya untuk menerbitkan/memperbarui Sertifikat SSL/TLS, tidak peduli apakah berhasil atau gagal

    Nilai baku untuk opsi ini adalah tidak ada, tetapi jika Anda menerbitkan sertifikatnya dibarengi parameter `--post-hook`, maka opsi tersebut akan _di-encode_ menjadi Base64 dan terisi secara otomatis

- `Le_RenewHook`: Opsi ini menentukan perintah yang akan dieksekusi setelah perkakas acme.sh berhasil memperbarui Sertifikat SSL/TLS-nya

    Nilai baku untuk opsi ini adalah tidak ada, tetapi jika Anda menerbitkan sertifikatnya dibarengi parameter `--renew-hook`, maka opsi tersebut akan _di-encode_ menjadi Base64 dan terisi secara otomatis

Ketiga opsi tersebut dapat Anda isi dengan perintah itu langsung, contoh berikut ini adalah ketika Anda ingin menyetak teks `Halo, Dunia!` di sebelum perkakas acme.sh menjalankan tugasnya:

```shell
Le_PreHook='echo "Halo, Dunia!"'
```

Namun, jika perintah yang ingin Anda jalankan itu mengandung multibaris atau lebih dari satu baris perintah, saya sarankan buat saja berkas _Shell_ di dalam direktori di mana berkas `domain.com.conf` itu berada (cth. di dalam direktori `$HOME/.acme.sh/domain.com`).

Setelah itu, ubah nilai dari opsi `Le_RenewHook`, `Le_PreHook` atau `Le_PostHook` menjadi cara Anda mengeksekusikan/menjalankan berkas skripnya.

Anda dapat tentukan sendiri perintah untuk menjalankan skrip pemasangan sertifikatnya, seperti `sh deploy.sh`, `bash deploy.sh`, `./deploy.sh` atau `env sh deploy.sh` atau memakai perintah yang lebih lengkap seperti `/usr/bin/env sh deploy.sh` juga tidak masalah, meski saya lebih menyarankan agar menggunakan yang lebih pendek biar gak repot.

Namun perlu diingat, perintah yang dieksekusi/dijalankan melalui acme.sh akan menggunakan direktori di mana berkas `domain.com.conf` itu berada sebagai direktori kerjanya.

Jadi, segala aktivitas masukkan/keluaran pada penyimpanan yang telah Anda lakukan saat perintah tersebut dijalankan (cth. membuat sebuah berkas atau folder, melihat isi dari berkas dengan perintah `cat`, dll) tanpa menyertakan direktori lengkapnya, maka Anda akan melakukannya di dalam direktori `$HOME/.acme.sh/domain.com/`.

Setelah perintah tersebut berhasil dieksekusi, maka nilai opsi yang telah Anda ubah sebelumnya akan menjadi seperti berikut:

```shell
__ACME_BASE64__START_<BARIS_PERINTAH_DALAM_BENTUK_BASE64>__ACME_BASE64__END_
```

`<BARIS_PERINTAH_DALAM_BENTUK_BASE64>` adalah Base64 dari perintah yang sebelumnya Anda terapkan di dalam opsi tersebut. Ya, acme.sh secara otomatis _meng-encode_ perintah yang telah Anda tentukan menjadi Base64.

Selain ketiga opsi di atas, Anda dapat menambahkan opsi-opsi lain di dalam konfigurasinya, berikut adalah salah satu opsinya beserta penjelasannya:

- `Le_ForceNewDomainKey`: Opsi ini bertujuan agar acme.sh membuat kunci pribadi (_Private key_) baru setiap pembaruan sertifikat. Nilai pada opsi ini adalah `0` untuk menonaktifkan opsinya atau `1` untuk mengaktifkan opsinya.

    Contoh: `Le_ForceNewDomainKey='1'` untuk mengaktifkan pembuatan kunci setiap pembaruan sertifikat.

    Nilai baku untuk opsi ini meskipun tidak disetel adalah `0`, yang berarti secara baku acme.sh tidak membuat kunci pribadi baru setiap pembaruan sertifikat

- `Le_RealCertPath`: Opsi ini bertujuan untuk menyalinkan berkas sertifikatnya setelah sertifikat berhasil diperbarui, isi opsi tersebut dengan menentukan lokasi mana berkas sertifikat itu akan disalinkan, beserta menentukan nama berkasnya juga.

    Contoh: `Le_RealCertPath='/etc/ssl-certificates/domain.com.cer'`

    Jika Anda mengisinya seperti contoh di atas, maka saat pembaruan sertifikat nanti, berkas tersebut akan disalinkan ke dalam lokasi `/etc/ssl-certificates` sebagai berkas dengan nama `domain.com.cer`.

    Nilai baku untuk opsi ini adalah tidak ada, tetapi jika Anda menerbitkan sertifikatnya dibarengi dengan parameter `--cert-file`, maka opsi tersebut akan terisi secara otomatis sesuai dengan nilai dari parameternya.

    Ini artinya, secara baku acme.sh tidak menyalinkan berkas sertifikatnya ke mana pun.

- `Le_RealCACertPath`: Sama seperti `Le_RealCertPath`, hanya saja opsi ini ditujukan untuk berkas sertifikat penengah atau sertifikat CA-nya (atau berkas yang biasanya dinamai dengan `ca.cer`).

    Nilai baku untuk opsi ini adalah tidak ada, tetapi akan terisi secara otomatis jika Anda menerbitkan sertifikatnya dibarengi dengan parameter `--ca-file`

- `Le_RealKeyPath`: Sama seperti `Le_RealCertPath` dan `Le_RealKeyPath`, hanya saja opsi ini ditujukan untuk berkas kunci pribadinya (atau berkas yang biasanya dinamai dengan `domain.com.key`).

    Nilai baku untuk opsi ini adalah tidak ada, tetapi akan terisi secara otomatis jika Anda menerbitkan sertifikatnya dibarengi dengan parameter `--key-file`

- `Le_RealFullChainPath`: Sama seperti `Le_RealCertPath`, `Le_RealKeyPath` dan `Le_RealKeyPath`, hanya saja opsi ini ditujukan untuk berkas sertifikat dengan rantai penuhnya (atau berkas yang biasanya dinamai dengan `fullchain.cer`).

    Nilai baku untuk opsi ini adalah tidak ada, tetapi akan terisi secara otomatis jika Anda menerbitkan sertifikatnya dibarengi dengan parameter `--fullchain-file`

- `Le_ReloadCmd`: Opsi ini bertujuan agar acme.sh mengeksekusi sebuah skrip setelah proses menyalinkan berkas-berkas yang diperlukan ke lokasi tertentu itu selesai jika ada opsi `Le_RealCertPath`, `Le_RealCACertPath`, `Le_RealKeyPath`, atau/dan `Le_RealFullChainPath` di dalam konfigurasi.

    Anda dapat mengisi opsi ini dengan perintah yang ingin Anda eksekusikan, tetapi biasanya perintah yang diisi adalah perintah untuk memuat ulang konfigurasi perangkat lunak server (termasuk _Web Server_), sesuai nama opsinya.

    Contoh: `Le_ReloadCmd='systemctl reload nginx'`

    Jika Anda mengisinya seperti contoh di atas, maka setelah pembaruan sertifikat, lebih tepatnya setelah berkas-berkas yang diperlukan tadi telah disalin ke lokasi tertentu, maka acme.sh akan secara otomatis menjalankan perintah `systemctl reload nginx` untuk memuat ulang konfigurasi NGINX.

    Setelah dieksekusi, nilai dari opsi tersebut akan _di-encode_ ke Base64, sama seperti skrip _Renew Hook_.

    Bedanya dengan _Renew Hook_ (`Le_RenewHook`) adalah skala prioritasnya dan peruntukannya, skrip _Reload Command_ (`Le_ReloadCmd`) akan dijalankan lebih dulu dan akan dijalankan setelah proses menyalinkan berkasnya selesai, skrip tersebut untuk memuat ulang konfigurasi perangkat lunak server.

    Sedangkan skrip _Renew Hook_ akan dijalankan setelahnya dan peruntukannya lebih luas daripada itu.

- Kredensial Penyedia DNS kamu: Anda dapat menyimpan kredensial dari Penyedia DNS yang Anda gunakan di konfigurasi khusus domain ini.

    Jika Anda adalah pengguna Cloudflare, Anda dapat menyimpan variabel `CF_Token`, `CF_Account_ID` dan `CF_Zone_ID` beserta nilainya di dalam konfigurasi tersebut tanpa perlu meletakkannya lagi di dalam berkas `~/.acme.sh/account.conf`, sehingga menjadi lebih spesifik.

    Mungkin hal itu berlaku juga bagi pengguna layanan Penyedia DNS lainnya, seperti Netlify DNS yang hanya perlu menyimpan `NETLIFY_ACCESS_TOKEN` saja (tetapi itu belum saya coba).

Ya udah, itu saja dulu mengenai opsi-opsinya, di bawah ini membahas contoh kasusnya.

### Contoh Kasus: Menjalankan sebuah Berkas Skrip setelah Memperbarui Sertifikat SSL/TLS

Contohnya Si Udin membuat sebuah berkas skrip yang bernama `deploy.sh` untuk memperbarui SSL pada domain `www.si-udin.com` miliknya yang _di-hosting_ menggunakan Netlify dan dia ingin agar skrip tersebut dijalankan/dieksekusi setelah Sertifikat SSL/TLS sukses diperbarui.

Isi berkas skripnya sebagai berikut:

```shell {linenos=true}
#!/usr/bin/env sh

# Skrip ini saya lisensikan di bawah lisensi "The Unlicense" (https://unlicense.org/)
# Silakan kembangkan sendiri kode skrip di bawah ini

PLAIN_CERT="$(awk '{printf "%s\\n", $0}' < www.si-udin.com.cer)"
PLAIN_KEY="$(awk '{printf "%s\\n", $0}' < www.si-udin.com.key)"
PLAIN_CA="$(awk '{printf "%s\\n", $0}' < ca.cer)"
NETLIFY_ACCESS_TOKEN="ACCESS_TOKEN_KAMU_DI_SINI"
NETLIFY_SITE_ID="www.si-udin.com"

curl -s \
     -H "Authorization: Bearer $NETLIFY_ACCESS_TOKEN" \
     -H "content-type: application/json" \
     -d "{\"certificate\": \"$PLAIN_CERT\", \"key\": \"$PLAIN_KEY\", \"ca_certificates\": \"$PLAIN_CA\"}" \
     "https://api.netlify.com/api/v1/sites/$NETLIFY_SITE_ID/ssl"
```

**Kenapa perintah di atas mengarahkan kepada berkasnya langsung? Kenapa tidak ditentukan direktorinya?** Itu karena suatu saat skrip tersebut dijalankan, maka direktori kerjanya adalah `$HOME/.acme.sh/www.si-udin.com` yang di dalamnya ada berkas `www.si-udin.com.cer`, `www.si-udin.com.key` dan `ca.cer` dan itu diperlukan bagi Netlify, serta itu merupakan tempat berkas `www.si-udin.com.conf` berada, yang gunanya untuk mengkonfigurasi supaya skrip tersebut bisa digunakan.

Sehingga, dia tidak perlu menentukan direktorinya lagi secara absolut, dia cuma perlu menuliskan nama berkasnya saja.

Setelah pembuatan skripnya selesai, ia simpan berkas tersebut, berkas skrip tersebut ia simpan di dalam direktori `$HOME/.acme.sh/www.si-udin.com/`, sehingga berkas tersebut berdekatan dengan berkas konfigurasinya, yakni `www.si-udin.com.conf`.

Setelah menyimpannya, ia perlu melakukan konfigurasi supaya skripnya bisa dijalankan saat acme.sh sukses memperbarui sertifikatnya. Untuk melakukan konfigurasi, maka ia perlu mengubah isi dari berkas `$HOME/.acme.sh/www.si-udin.com/www.si-udin.com.conf`.

Di dalam berkas tersebut ada banyak opsi yang kosong, termasuk `Le_PreHook`, `Le_PostHook`, dan `Le_RenewHook`. Karena ia mau menjalankan skrip tersebut saat sertifikat SSL/TLS sukses diperbarui, jadi ia memilih untuk mengisi opsi `Le_RenewHook` ketimbang opsi lain.

Nah, dia isi itu dengan `/usr/bin/env sh deploy.sh`. Jadi, opsinya akan menjadi seperti berikut:

```shell
Le_RenewHook='/usr/bin/env sh deploy.sh'
```

Setelah itu, ia simpan berkas tersebut dan beberapa bulan kemudian, acme.sh memperbarui Sertifikat SSL/TLS tersebut dan berhasil, lalu skrip tersebut akhirnya berhasil dijalankan dan `www.si-udin.com` telah menggunakan sertifikat yang lebih baru.

Setelah skrip tersebut berhasil dijalankan dan melihat lagi konfigurasinya, ia melihat kalau nilai dari opsi `Le_RenewHook` itu berubah menjadi seperti berikut:

```shell
Le_RenewHook='__ACME_BASE64__START_L3Vzci9iaW4vZW52IHNoIGRlcGxveS5zaA==__ACME_BASE64__END_'
```

Itu artinya, perintah tersebut telah dikonversikan menjadi Base64 secara otomatis oleh acme.sh saat perintah tersebut dieksekusi.

Teks `L3Vzci9iaW4vZW52IHNoIGRlcGxveS5zaA==` di atas adalah Base64 dari perintah `/usr/bin/env sh deploy.sh`.

Nah, sekarang Anda sudah paham, kan? Kalau sudah paham, silakan lanjut ke [bagian selanjutnya](#renew-ssl).

## Membuat Skrip untuk _me-renew_ Sertifikat SSL/TLS {#renew-ssl}

Setelah mempelajari di bagian-bagian sebelumnya, sekarang tinggal membuat sertifikat SSL/TLS ini dapat diperbarui/_di-renew_ secara otomatis. Bagaimana caranya?

Caranya Anda perlu membuat sebuah skrip terlebih dahulu agar sertifikat SSL/TLS dapat diperbarui, ada dua metode yang dapat Anda coba. Metodenya sebagai berikut:

### Metode ke-1: Memanfaatkan Konfigurasi dari acme.sh {#memanfaatkan-konfigurasi-acme-sh}

Anda bisa gunakan konfigurasi dari perkakas acme.sh agar dia mengeksekusi baris perintah setelah acme.sh berhasil memperbarui sertifikatnya untuk Domain tertentu. Untuk selengkapnya, bisa Anda pelajari itu di [bagian sebelumnya](#konfigurasi-acme-sh-untuk-domain).

Hal yang menarik mengenai metode ini adalah sebagai berikut:

- Anda tidak perlu memanggil API setiap hari yang memakan kuota Internet Anda (terlebih jika Anda menggunakan Data Seluler) karena mengunggah berkas-berkas yang diperlukan, Anda bisa memanggil API tersebut hanya di saat tertentu saja (cth. Hanya saat acme.sh sukses memperbarui sertifikatnya)

- Jika Anda menyalinkan/memindahkan acme.sh ke perangkat lain, maka acme.sh tetap dapat mengeksekusikan skrip tersebut di perangkat lain sesuai konfigurasi yang telah Anda atur di dalamnya

Di samping hal menarik, berikut ini adalah hal yang perlu Anda perhatikan ketika memakai metode ini:

- Skrip pembaruan di tiap domain itu tidaklah sama, jadi kalau Anda ingin membuat skrip tersebut untuk domain lain, maka Anda harus menyesuaikan skrip tersebut untuk domain itu dan skripnya harus diletakkan ke dalam folder domain lain itu juga.

    Hal seperti ini dianggap kurang efisien karena harus menyesuaikan skrip untuk domain lainnya, tetapi kalau Anda tidak menganggapnya itu sebagai masalah, maka harusnya ini bukanlah sebuah kekurangan bagi Anda

Setelah melakukan konfigurasi, Anda tinggal perlu menunggu sampai acme.sh berhasil memperbarui sertifikatnya untuk Anda, pastikan _Cron Job_ dalam keadaan aktif.

### Metode ke-2: Membuat Berkas Skrip _Shell_ {#membuat-berkas-skrip-shell}

Jika Anda lebih suka membuat skrip secara terpisah, maka Anda bisa membuat sebuah berkas skrip _shell-nya_ terlebih dahulu agar Sertifikat SSL/TLS dapat diperbarui melalui _Shell_/di dalam Terminal, untuk isinya Anda bisa pelajari contohnya berikut:

```shell {linenos=true}
#!/usr/bin/env sh

# Skrip ini saya lisensikan di bawah lisensi "The Unlicense" (https://unlicense.org/)
# Silakan Anda kembangkan sendiri kode skrip di bawah ini

## Deklarasi variabel untuk direktori acme.sh dan direktori sertifikatnya
ACME_DIR="$HOME/.acme.sh"
CERT_DIR="$ACME_DIR/domain.com" # Ganti 'domain.com' dengan alamat domain Anda, sesuaikan dengan direktori sertifikat yang sebenarnya, begitupula dengan nama berkasnya nanti setelah ini

### Di bawah ini adalah perintah untuk memperbarui sertifikat SSL/TLS melalui acme.sh
### dengan memanfaatkan parameter `--cron`-nya
"$ACME_DIR"/acme.sh --cron --home "$ACME_DIR"

### Di bawah ini adalah memasukkan berkas-berkas yang diperlukan untuk memasang SSL di Netlify ke dalam variabel
NETLIFY_ACCESS_TOKEN="ACCESS_TOKEN_KAMU_DI_SINI" # Ini adalah Kode Token untuk mengakses API Netlify, ganti itu dengan kode yang Anda buat
PLAIN_CERT="$(awk '{printf "%s\\n", $0}' < $CERT_DIR/domain.com.cer)"
PLAIN_KEY="$(awk '{printf "%s\\n", $0}' < $CERT_DIR/domain.com.key)"
PLAIN_CA="$(awk '{printf "%s\\n", $0}' < $CERT_DIR/ca.cer)"

### Di bawah ini adalah memasukkan berkas-berkas yang diperlukan untuk memasang SSL di bunny.net ke dalam variabel
BUNNY_ACCESS_KEY="ACCESS_KEY_KAMU_DI_SINI" # Ini adalah kunci akses ke API bunny.net, dapatkan kunci tersebut di pengaturan akun, lalu ganti nilai dari variabel ini
BASE64_FULLCHAIN_CER="$(openssl base64 -A < $CERT_DIR/fullchain.cer)"
BASE64_KEY="$(openssl base64 -A < $CERT_DIR/domain.com.key)"

### Di bawah ini adalah memasukkan berkas-berkas yang diperlukan untuk memasang SSL di cPanel ke dalam variabel
CPANEL_PLAIN_CERT="$(jq -sRr @uri < $CERT_DIR/domain.com.cer)"
CPANEL_PLAIN_KEY="$(jq -sRr @uri < $CERT_DIR/domain.com.key)"
CPANEL_PLAIN_CA="$(jq -sRr @uri < $CERT_DIR/ca.cer)"
CPANEL_HOSTNAME="cpanel.domain.com" # Ini adalah alamat domain/IP yang Anda gunakan untuk mengakses cPanel, silakan ganti sesuai hosting yang Anda gunakan atau gunakan alamat domain Anda
CPANEL_USERNAME="demo" # Ini adalah Nama Pengguna/Username cPanel yang Anda gunakan, ganti 'demo' dengan username Anda
CPANEL_API_TOKEN="API_TOKEN_KAMU_DI_SINI" # Ini adalah Kode Token untuk mengakses API dari cPanel, ganti itu dengan kode yang Anda buat

### Di bawah ini adalah memasukkan berkas-berkas yang diperlukan untuk memasang SSL di DirectAdmin ke dalam variabel
DIRECTADMIN_PLAIN_FULLCHAIN="$(jq -sRr @uri < $CERT_DIR/fullchain.cer)"
DIRECTADMIN_PLAIN_KEY="$(jq -sRr @uri < $CERT_DIR/domain.com.key)"
DIRECTADMIN_HOSTNAME="NAMA_HOS_UNTUK_DIRECTADMIN_KAMU_DI_SINI" # Ini adalah alamat domain yang Anda gunakan untuk login ke DirectAdmin
DIRECTADMIN_USERNAME="demo" # Ini adalah Nama Pengguna/Username DirectAdmin yang Anda gunakan sekarang, ganti 'demo' dengan username Anda
DIRECTADMIN_LOGIN_KEY="LOGIN_KEY_KAMU_DI_SINI" # Ini adalah Login Key untuk mengakses API dari DirectAdmin, ganti itu dengan Login Key yang Anda buat

### Di bawah ini adalah perintah untuk memasang/memperbarui sertifikat SSL/TLS di Netlify
### Ada beberapa yang perlu diubah agar perintah bisa berjalan dengan baik, jadi silakan Anda ubah itu sendiri
curl -s \
     -H "Authorization: Bearer $NETLIFY_ACCESS_TOKEN" \
     -H "content-type: application/json" \
     -d "{\"certificate\": \"$PLAIN_CERT\", \"key\": \"$PLAIN_KEY\", \"ca_certificates\": \"$PLAIN_CA\"}" \
     "https://api.netlify.com/api/v1/sites/SITE_ID_KAMU_DI_SINI/ssl"

### Di bawah ini adalah perintah untuk memasang/memperbarui sertifikat SSL/TLS di bunny.net
### Ada beberapa yang perlu diubah agar perintah bisa berjalan dengan baik, jadi silakan Anda ubah itu sendiri
curl -s \
     -H "Accept: application/json" \
     -H "AccessKey: $BUNNY_ACCESS_KEY" \
     -H "Content-Type: application/json" \
     -d "{\"Hostname\": \"CUSTOM_HOSTNAME_KAMU_DI_SINI\", \"Certificate\": \"$BASE64_FULLCHAIN_CER\", \"CertificateKey\": \"$BASE64_KEY\"}" \
     "https://api.bunny.net/pullzone/PULL_ZONE_ID_KAMU_DI_SINI/addCertificate"

### Di bawah ini adalah perintah untuk memasang/memperbarui sertifikat SSL/TLS di cPanel
### Ada beberapa yang perlu diubah agar perintah bisa berjalan dengan baik, jadi silakan Anda ubah itu sendiri
curl -sGH "Authorization: cpanel $CPANEL_USERNAME:$CPANEL_API_TOKEN" \
     -d "domain=<ALAMAT_DOMAIN_KAMU_DI_SINI>" \
     -d "cert=$CPANEL_PLAIN_CERT" \
     -d "key=$CPANEL_PLAIN_KEY" \
     -d "cabundle=$CPANEL_PLAIN_CA" \
     "https://$CPANEL_HOSTNAME:2083/execute/SSL/install_ssl"

### Di bawah ini adalah perintah untuk memasang/memperbarui sertifikat SSL/TLS di DirectAdmin
### Ada beberapa yang perlu diubah agar perintah bisa berjalan dengan baik, jadi silakan Anda ubah itu sendiri
curl -s \
     -u "$DIRECTADMIN_USERNAME:$DIRECTADMIN_LOGIN_KEY" \
     -d "domain=<ALAMAT_DOMAIN_KAMU_DI_SINI>" \
     -d "action=save" \
     -d "type=paste" \
     -d "certificate=$DIRECTADMIN_PLAIN_FULLCHAIN" "$DIRECTADMIN_PLAIN_KEY" \
     "https://$DIRECTADMIN_HOSTNAME:2222/CMD_API_SSL"

### Di bawah ini adalah baris perintah untuk membuat berkas log untuk memastikan bahwa Cron telah berhasil dijalankan
echo "Cron sukses dijalankan. Waktu: $(date +"%Y-%m-%d %H:%M:%S%z")" >> renew-ssl.log
```

**Catatan:** Skrip di atas juga dapat bekerja di _Shell_ yang sangat berbeda dan tidak sesuai dengan POSIX seperti `fish`, karena mengikuti _Shebang_ yang telah saya tentukan, yakni `/usr/bin/env sh`. Jadi, skrip di atas seharusnya dapat dieksekusi oleh _Shell_ apa pun selama mengikuti/'menghormati' _Shebang_ yang telah ditentukan.

Namun, jika Anda adalah pengguna Termux dan kalau mau, Anda dapat mengganti `/usr/bin/env` di atas menjadi `/data/data/com.termux/files/usr/bin/env`, meskipun Termux sendiri mentoleransi _shebang_ di atas.

Silakan pelajari skrip di atas dan kembangkan sendiri skripnya menjadi versi Anda sendiri. Jika sudah selesai, maka simpanlah berkas tersebut, boleh Anda namakan dengan apa saja dan disimpan di mana saja asal bisa Anda gunakan kembali.

Namun, saya sarankan agar Anda menyimpannya di dalam folder `$HOME` dan saya asumsikan bahwa Anda menamainya dengan `renew-ssl.sh` agar mempermudah saya dalam membahasnya, karena pastinya Anda menamainya dengan nama yang berbeda.

Jika sudah tersimpan, berikan ijin eksekusi terhadap berkas tersebut dengan perintah `chmod +x renew-ssl.sh` atau `chmod +x /lokasi/ke/berkas/renew-ssl.sh`.

Setelah itu, Anda bisa tes skrip tersebut dengan perintah `sh /lokasi/ke/berkas/renew-ssl.sh` atau `./lokasi/ke/berkas/renew-ssl.sh` di dalam Terminal Anda. Jika sudah berhasil, Anda tinggal jadwalkan saja agar skrip otomatis dijalankan sesuai jadwal yang telah Anda atur.

## Otomatisasi Skrip dengan _Cron Job_ {#otomatisasi-skrip-dengan-cron-jobs}

Biasanya, setelah perkakas acme.sh diinstal, maka _Cron Job_ akan otomatis terpasang untuk keperluan pembaruan sertifikat kalau ada. Jadi, sebenarnya Anda tidak perlu membuatnya lagi secara manual.

Namun, Anda dapat mengubah jadwal dan waktu eksekusi perkakas acme.sh-nya kalau mau. Selain itu, kalau Anda menggunakan berkas `renew-ssl.sh` untuk pembaruan sertifikat, maka Anda perlu membuat atau mengubah _Cron Job-nya_ secara manual juga agar skrip tersebut dapat berjalan secara otomatis/terjadwal.

Bagaimana caranya? Caranya sebagai berikut:

Edit _Crontab_ dengan perintah berikut: (tanpa perlu akses _root_ ataupun memakai `sudo`)

```shell
crontab -e
```

Saat mengedit, Anda akan menemukan sebuah Cron dengan teks yang mirip seperti berikut:

```crontab
6 0 * * * "/home/username/.acme.sh"/acme.sh --cron --home "/home/username/.acme.sh" > /dev/null
```

`6 0 * * *` adalah parameter _Crontab_ yang menentukan kapan perintah tersebut dilaksanakan, `6 0 * * *` artinya kalau perintah tersebut akan dilaksanakan pada pukul 00:06 untuk setiap harinya. Parameter yang Anda temukan nanti mungkin berbeda-beda, jadi silakan ganti parameter tersebut sesuka hati Anda, selama masih mengikuti aturan dari Cron.

Misalnya, kalau Anda ingin perintah tersebut dieksekusi pada menit ke-0 dan setiap jam ke-2 dari pukul 0 hingga 23, atau setiap 2 jam sekali pada pukul dengan kelipatan 2 di menit ke-0 (seperti pukul 00:00, 02:00, 04:00, 06:00, 08:00, 10:00, 12:00, 14:00, dst), maka Anda dapat menggantinya menjadi `0 */2 * * *`.

Atau, manfaatkan situs web [Crontab.guru](https://crontab.guru/) untuk membantu Anda dalam menentukan parameter pada _Crontab-nya_.

`"/home/username/.acme.sh"/acme.sh` adalah perintahnya dan seterusnya adalah parameter atau argumen dari perintah tersebut. Perintah pada _Crontab_ untuk acme.sh mungkin akan berbeda-beda, karena perbedaan nama pengguna, dll.

Kalau Anda menggunakan [Metode ke-2](#membuat-berkas-skrip-shell) untuk pembaruan sertifikatnya, ganti itu dengan perintah untuk mengeksekusi berkas `renew-ssl.sh`, contohnya seperti di bawah ini:

```shell
/usr/bin/env sh /lokasi/ke/berkas/renew-ssl.sh
```

Untuk `> /dev/null`-nya biarkan saja, fungsinya itu hanya membuang keluaran, karena ini dijalankan melalui _Cron Job_ maka keluaran tidak diperlukan untuk itu, tetapi Anda dapat mengganti atau menghapusnya jika merasa tidak yakin.

Setelah semuanya selesai, simpanlah berkas tersebut dan keluar dari editor teks yang Anda gunakan sekarang. Setelahnya, _Cron Job_ akan dijalankan, tinggal tunggu waktunya saja agar skrip dijalankan sesuai jadwal.

Ya udah, itu aja langkah-langkahnya.

## Hal-hal lain yang dapat Anda lakukan dengan acme.sh {#hal-lainnya}

Di sini Anda akan menjelajahi hal-hal lain yang dapat Anda lakukan melalui acme.sh, ini bukan hal yang wajib, sehingga Anda dapat lewati/akhiri saja karena ini sudah akhir artikel sebenarnya.

Berikut di bawah ini adalah hal lain yang dapat Anda lakukan.

### Melihat Daftar Sertifikat SSL/TLS yang ada {#melihat-dafat-sertifikat}

Anda dapat melihat daftar sertifikat yang ada di acme.sh dengan perintah berikut:

```shell
acme.sh --list
```

Keluarannya sebagai berikut:

```shell {linenos=true}
$ acme.sh --list
Main_Domain    KeyLength  SAN_Domains   CA          Created               Renew
*.domain.com   "ec-384"   domain.com    ZeroSSL     2022-08-11T09:42:26Z  2022-10-10T09:42:26Z
```

Seperti yang Anda lihat, keluarannya berbentuk tabel, tetapi tanpa garis. Saya jelaskan satu per satu mengenai kolomnya di bawah ini:

- `Main_Domain` merupakan bahasa Inggris dari "Domain Utama" dan domain utama adalah domain pertama yang Anda masukkan saat menerbitkan sertifikat tadi
- `KeyLength` merupakan kunci dan ukuran yang digunakan sekarang, di tabel tersebut menunjukkan `ec-384` yang berarti sertifikat tersebut diterbitkan dengan ECC/ECDSA sebagai algoritma kunci publik yang berukuran P-384
- `SAN_Domains` merupakan domain SAN (_Subject Alternative Names_) dan singkat kata ini adalah domain lain selain domain utama di dalam sertifikat atau domain kedua dan seterusnya yang Anda masukkan saat menerbitkan sertifikat
- `CA` merupakan CA yang digunakan, di tabel tersebut menunjukkan `ZeroSSL` yang berarti sertifikat tersebut diterbitkan oleh ZeroSSL
- `Created` merupakan tanggal dan waktu sertifikat tersebut dibuat/diterbitkan, format yang digunakan sesuai dengan standar internasional [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html)
- `Renew` merupakan tanggal dan waktu sertifikat tersebut akan diperbarui, format yang digunakan sesuai dengan standar internasional ISO 8601

Nah, kira-kira begitu.

### Mengganti CA Baku {#mengganti-ca-baku}

Secara baku, perkakas acme.sh menggunakan ZeroSSL sebagai CA-nya. Jika Anda ingin menggantikan CA baku pada acme.sh, maka Anda tinggal jalankan perkakas acme.sh dengan parameter `--set-default-ca --server opsi_ca`.

Contoh perintahnya akan seperti berikut:

```shell
acme.sh --set-default-ca --server opsi_ca
```

Anda bisa ganti `opsi_ca` dengan nama pendek dari CA yang didukung oleh acme.sh atau dengan Alamat URL Server ACME yang dimiliki oleh CA. Untuk mengetahui apa saja nama pendek dari CA yang didukung, Anda bisa mengunjungi [Halaman Wikinya](https://github.com/acmesh-official/acme.sh/wiki/Server).

Contoh perintah di bawah ini adalah menggantikan CA baku menjadi Let's Encrypt:

```shell
acme.sh --set-default-ca --server letsencrypt
```

Selain menggunakan nama pendek, Anda juga dapat menggunakan Alamat URL Direktori ACME, cukup ganti saja `letsencrypt` di atas menjadi Alamat URL lengkap Direktori ACME dari CA Anda.

Penggantian CA baku ini harusnya dilakukan sebelum Anda menerbitkan sertifikat SSL/TLS apa pun, karena ini hanya berefek jika Anda menerbitkan sertifikat terbaru.

Namun, kalau Anda melakukan itu setelah menerbitkan sertifikatnya, maka Anda perlu menggantikan sertifikat tersebut dengan menerbitkannya lagi secara paksa oleh CA yang berbeda.

### Melihat konfigurasi utama acme.sh atau konfigurasi domain {#melihat-konfigurasi}

Anda dapat melihat konfigurasi yang tersedia pada perkakas acme.sh, baik konfigurasi utama maupun konfigurasi yang dispesifikasikan untuk domain tertentu.

Anda dapat melihat isi konfigurasi utamanya dengan perintah berikut:

```shell
acme.sh --info
```

Keluarannya sebagai berikut:

```shell {linenos=true}
$ acme.sh --info
LE_WORKING_DIR=/home/username/.acme.sh
LE_CONFIG_HOME=/home/username/.acme.sh
UPGRADE_HASH='8ded524236347d5a1f7a3169809cab9cf363a1c8'
ACCOUNT_EMAIL='emailku@domain.com'
#AUTO_UPGRADE='1'
USER_PATH='/home/username/bin:/home/username/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/var/lib/snapd/snap/bin'
```

Perintah di atas sama saja dengan melihat isi dari `account.conf` di dalam direktori acme.sh.

Untuk melihat konfigurasi domainnya, Anda perlu menambahkan parameter `-d domain.com`. Contoh perintahnya sebagai berikut:

```shell
acme.sh --info -d domain.com
```

Ganti `domain.com` di atas dengan domain utama Anda (gunakan `acme.sh --list` untuk mencari tahu domain utamanya).

Maka keluarannya akan seperti berikut:

```shell {linenos=true}
DOMAIN_CONF=/home/username/.acme.sh/domain.com/domain.com.conf
Le_Domain=domain.com
Le_Alt=*.domain.com
Le_Webroot=dns_cf
Le_PreHook=
Le_PostHook=
Le_RenewHook=/usr/bin/env sh deploy.sh
Le_API=https://acme.zerossl.com/v2/DV90
Le_Keylength=2048
Le_OrderFinalize=https://acme.zerossl.com/v2/DV90/order/kyxxxxxxxxxxxxxxxxxxxx/finalize
Le_LinkOrder=https://acme.zerossl.com/v2/DV90/order/kyxxxxxxxxxxxxxxxxxxxx
Le_LinkCert=https://acme.zerossl.com/v2/DV90/cert/20xxxxxxxxxxxxxxxxxxxx
Le_CertCreateTime=1660210946
Le_CertCreateTimeStr=2022-08-11T09:42:26Z
Le_NextRenewTimeStr=2022-10-10T09:42:26Z
Le_NextRenewTime=1665308546
```

Apabila Anda ingin melihat konfigurasi domain yang menggunakan ECC, tambahkan parameter `--ecc`-nya juga diakhir perintah. Contoh perintahnya sebagai berikut:

```shell
acme.sh --info -d domain.com --ecc
```

Nah, kira-kira begitu.

### Mencabut dan Menghapus Sertifikat

Anda dapat mencabut dan menghapus sertifikat SSL/TLS dari perangkat Anda (meskipun ini sudah beberapa kali dibahas di bagian sebelumnya sih), tetapi dengan catatan bahwa mencabut (_revoke_) sertifikat akan menyebabkan aplikasi, web ataupun blog yang menggunakan sertifikat tersebut menjadi tidak dapat diakses, terutama dari perangkat Desktop.

Jika sudah siap, Anda dapat mencabutnya dengan perintah berikut:

```shell
acme.sh --revoke -d domain.com
```

Perintah di atas akan mencabut sertifikat yang diterbitkan menggunakan RSA sebagai algoritma kunci publiknya, jika Anda hanya ingin mencabut sertifikat yang menggunakan ECC/ECDSA, tinggal tambahkan saja parameter `--ecc`-nya, sehingga contoh perintahnya menjadi seperti berikut:

```shell
acme.sh --revoke -d domain.com --ecc
```

Keluarannya akan seperti berikut:

```shell {linenos=true}
[Fri Sep  9 13:19:38 WIB 2022] Try domain key first.
[Fri Sep  9 13:19:42 WIB 2022] Revoke success.
```

Setelah mencabutnya, Anda dapat menghapusnya dengan perintah berikut:

```shell
acme.sh --remove -d domain.com
```

Apabila Anda ingin menghapus sertifikat yang menggunakan ECC, tinggal tambahkan saja parameter `--ecc`-nya, sehingga contoh perintahnya menjadi seperti berikut:

```shell
acme.sh --remove -d domain.com --ecc
```

Keluarannya akan seperti berikut:

```plain {linenos=true}
[Fri Sep  9 13:20:22 WIB 2022] domain.com is removed, the key and cert files are in /home/username/.acme.sh/domain.com
[Fri Sep  9 13:20:22 WIB 2022] You can remove them by yourself.
```

Setelah sukses menjalankan perintah di atas, silakan hapus sendiri foldernya dengan menggunakan perintah `rm -rf`. Jika terdapat tanda bintang di nama foldernya, saya sarankan agar kamu mengutip nama folder tersebut dengan kutip dua agar _Shell_ tidak salah menghapus folder/berkas dikarenakan salah mengintepretasi nama folder/berkas yang dituju.

Akhirnya, selesai juga setelah mengikuti langkah-langkah di atas. Gimana, pusing kan? Atau, malah bosen? Iyalah, gimana tidak, artikel ini saja panjang lebarnya kebangetan.

Ya sudah, semua pembahasan di artikel ini sudah selesai, kamu bisa akhiri saja sampai sini jika Anda tidak mempunyai keluhan/pertanyaan apa pun.

Namun, jika Anda memiliki pertanyaan, maka ada baiknya baca terlebih dahulu bagian berikutnya sebelum bertanya, barangkali saja pertanyaan dari pikiran kamu bisa terjawab di sini.

## Pertanyaan yang (mungkin) akan sering ditanya, beserta jawabannya {#pertanyaan-dan-jawaban}

### Pertanyaan ke-1: Apa itu Protokol ACME? {#pertanyaan-ke1}

Menurut salah satu Artikel di [Wikipedia](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment), Protokol ACME (singkatan dari "Automatic Certificate Management Environment") adalah protokol komunikasi untuk mengotomatisasi interaksi antara Penyelenggara sertifikat (bahasa Inggris: **_Certificate Authority_** atau disingkat dengan **CA**) dan Pengguna Server Web-nya.

Hal ini memungkinkan untuk penyebaran/penginangan Infrastruktur Kunci Publik (bahasa Inggris: **_Public Key Infrastructure_** atau disingkat dengan **PKI**) dengan biaya yang rendah/murah.

Protokol tersebut dirancang oleh pihak [Internet Security Research Group](https://www.abetterinternet.org/) (ISRG), yang pada awalnya untuk layanan [Let's Encrypt](https://letsencrypt.org/) mereka.

Protokol yang berbasis pada penyampaian pesan berformat JSON melalui Protokol HTTPS ini telah ditetapkan sebagai Standar Internet di dalam [RFC 8555](https://datatracker.ietf.org/doc/html/rfc8555) oleh kelompok kerja IETF yang disewanya sendiri.

### Pertanyaan ke-2: Apa itu CA? {#pertanyaan-ke2}

**_Certificate Authority_** (disebut juga sebagai: **_Certification Authority_**) atau disingkat **CA** (bahasa Indonesia: **Otoritas Sertifikat**) adalah sebuah entitas yang mengeluarkan/menerbitkan sertifikat digital dengan memverifikasi identitas pihak subjek (seperti Situs Web, Alamat Surel, Perusahaan, Organisasi/Lembaga/Yayasan atau Perseorangan).

Dalam Sertifikat SSL/TLS, CA juga bertindak sebagai pihak ketiga yang tepercaya/dipercaya baik oleh subjek (pemilik) sertifikat dan oleh pihak yang mengandalkan sertifikat (Perangkat Lunak).

### Pertanyaan ke-3: Apa itu PKI? {#pertanyaan-ke3}

Menurut salah satu Artikel di [Wikipedia](https://en.wikipedia.org/wiki/Public_key_infrastructure), **_Public key Infrastructure_** (bukan tentang **Partai Komunis Indonesia**) atau disingkat **PKI** (bahasa Indonesia: **Infrastruktur Kunci Publik** atau disingkat dengan **IKP**) adalah seperangkat peran, kebijakan, perangkat keras, perangkat lunak, dan prosedur yang diperlukan untuk membuat, mengelola, mendistribusikan, menggunakan, menyimpan, dan mencabut sertifikat digital dan mengelola enkripsi kunci publik.

Tujuan IKP adalah untuk memfasilitasi transfer informasi elektronik yang aman untuk berbagai aktivitas jaringan seperti perdagangan elektronik (_e-commerce_), perbankan melalui internet (_internet banking_), dan perpesanan surel rahasia.

IKP diperlukan untuk aktivitas di mana kata sandi sederhana merupakan metode otentikasi yang kurang memadai dan juga diperlukan sebagai bukti yang lebih ketat untuk mengonfirmasi identitas pihak yang terlibat dalam komunikasi, serta untuk memvalidasi informasi yang ditransfer.

### Pertanyaan ke-4: Apa saja CA selain ZeroSSL dan Let's Encrypt yang bisa menggunakan Protokol ACME? {#pertanyaan-ke4}

Untuk yang gratisan, ada [Buypass Go SSL](https://www.buypass.com/products/tls-ssl-certificates/go-ssl), [SSL.com](https://www.ssl.com/certificates/free/) dan Google Public CA yang saya bahas di [artikel ini](https://farrel.franqois.id/cara-mendapatkan-sertifikat-ssl-dari-google/).

Sedangkan yang berbayar ada [DigiCert](https://www.digicert.com/tls-ssl/certcentral-tls-ssl-manager), [Entrust](https://www.entrust.com/digital-security/certificate-solutions/products/digital-certificates/tls-ssl-certificates/entrust-certificate-services), [GlobalSign Atlas](https://www.globalsign.com/atlas) dan mungkin SSL\.com ada versi berbayarnya juga.

### Pertanyaan ke-5: Saya memasang CAA Record pada DNS Domain saya, apa CAA yang harus saya isi biar supaya saya bisa menggunakan ZeroSSL? {#pertanyaan-ke5}

Anda bisa mengisinya dengan `sectigo.com`. Kenapa? Karena pada dasarnya ia menggunakan Sertifikat SSL/TLS dari Sectigo, sehingga ZeroSSL itu sebenarnya tidak 'berdiri sendiri', melainkan menjalin kerjasama dengan Sectigo.

### Pertanyaan ke-6: Bagaimana caranya agar saya dapat menggantikan sertifikat SSL/TLS menjadi dari Let's Encrypt atau CA lainnya, saya tidak ingin Sertifikat SSL/TLS dari ZeroSSL? {#pertanyaan-ke6}

Caranya tinggal Anda terbitkan ulang sertifikat SSL/TLS oleh CA yang berbeda secara paksa.

Saat menerbitkan sertifikat SSL/TLS, Anda perlu menambahkan parameter `--server opsi_ca` dan itu harus dibarengi dengan parameter `--force` agar acme.sh dapat melakukannya dengan paksa. Tanpa parameter/argumen `--force`, maka Anda tidak mungkin bisa menggantinya.

Contoh perintahnya akan seperti berikut:

```shell
acme.sh --issue -d domain.com -d www.domain.com --server opsi_ca --force
```

Anda bisa mengganti `opsi_ca` dengan nama pendek dari CA yang didukung oleh acme.sh atau dengan Alamat URL Direktori ACME yang dimiliki oleh CA, serta domain-domain tersebut menjadi alamat domain milik Anda.

Setelah menerbitkan ulang sertifikatnya, tentu saja acme.sh tidak mengeksekusikan skrip _renewal-nya_ secara otomatis, jadi sertifikat SSL/TLS yang terpasang pada aplikasi atau situs web yang Anda miliki tidak terganti, apalagi jika Anda lebih memilih untuk membuatkan skripnya secara terpisah.

**Lalu, bagaimana caranya agar saya bisa menggantikan sertifikatnya?** Ya, Anda tinggal eksekusikan saja skrip _renewal_ tersebut secara manual untuk memasangkan sertifikat SSL/TLS yang terbaru di Situs Web/Blog atau Aplikasi Anda.

### Pertanyaan ke-7: Apa bedanya dengan mengikuti tutorial di sini kalau dari panel saja ada? Apa saja kelebihannya dan sebaiknya metode apa yang saya pakai? {#pertanyaan-ke7}

Saya tahu bahwa DirectAdmin dan cPanel memiliki antarmukanya sendiri dalam menerbitkan sertifikat SSL/TLS-nya, tetapi hal yang menarik dalam mengelola sertifikat SSL/TLS-nya sendiri seperti yang ditulis di artikel ini adalah sebagai berikut:

- Pilihan CA yang lebih beragam ketimbang DirectAdmin yang cuma bisa menerbitkan sertifikat dari Let's Encrypt dan ZeroSSL, dan cPanel yang hanya bisa menerbitkan sertifikat dari Comodo/Sectigo melalui AutoSSL dan Let's Encrypt jika ada pengayanya
- Anda dapat menerbitkan dan bahkan memperbarui/_me-renew_ sertifikat-sertifikat tersebut ke mana saja dengan mengatur skripnya dengan benar, tanpa harus berdiam di satu tempat saja, ini akan cocok bagi Anda yang tidak hanya menggunakan 1 server/layanan dalam 1 domain saja dan ini membuat sertifikat SSL/TLS dalam bentuk _Wildcard_ menjadi lebih berguna
- Anda dapat menggunakan metode verifikasi yang Anda suka ketimbang di cPanel yang hanya bisa menerbitkan sertifikatnya jika terhubung ke dalam layanannya saja dan DirectAdmin yang hanya mendukung DNS (bisa dari luar) dan HTTP sebagai metode verifikasinya
- Anda dapat mengelola dan mengatur sertifikat SSL/TLS beserta skrip dan konfigurasinya dengan lebih fleksibel ketimbang menggunakan antarmuka yang tersedia

Hal yang perlu diperhatikan:

- Ribet, belum lagi galatnya
- Koneksi Internet harus aktif setiap saat agar dapat menerbitkan dan memperbarui sertifikat SSL/TLS secara otomatis

Pilih yang mana? Tergantung kebutuhan, jika Anda lebih menginginkan kemudahan dan langkah yang lebih sederhana, mungkin menggunakan antarmuka yang disediakan itu cocok buat Anda dan biarkan server yang memperbaruinya secara otomatis setelah ini, tetapi mengorbankan fleksibilitas dan kemungkinan untuk dapat digunakan oleh server/layanan lain.

Atau, jika Anda ingin sertifikatnya dapat digunakan di mana saja dan dapat diperbarui ke mana saja, dapat menggunakan metode verifikasi yang Anda suka, pilihan CA yang lebih beragam serta konfigurasi yang lebih fleksibel, mungkin mengelola sertifikatnya sendiri akan lebih cocok buat Anda, tetapi ini akan mengorbankan kemudahan dan kesederhanaan langkah yang ada pada antarmuka di panel atau mungkin keamanan juga semenjak kunci pribadi (_private key_) disebar ke server lain, tergantung bagaimana Anda mengelola sertifikatnya.

### Pertanyaan ke-8: Sertifikat SSL/TLS sudah saya hapus, tetapi pas saya jalankan acme.sh dalam Cron atau untuk memperbarui semua SSL (`--renew-all`), kok domain yang terhapus masih ada saat saya cek di Terminal? {#pertanyaan-ke8}

Itu karena Anda belum menghapus direktorinya setelah menghapus sertifikat SSL/TLS dari perkakas acme.sh-nya. Jadi, Anda perlu menghapus direktori tersebut secara manual.

Solusinya adalah hapus direktori tersebut (cth. `$HOME/.acme.sh/domain.com` untuk `domain.com`) secara manual setelah menghapus sertifikatnya.

### Pertanyaan ke-9: Kenapa harus acme.sh dan kenapa tidak pakai yang lain seperti Certbot atau Lego? {#pertanyaan-ke9}

Karena acme.sh lebih sederhana dan lebih mudah dipelajari, serta fiturnya pun lumayan lengkap juga, apalagi untuk kasus umum seperti menerbitkan dan memperbarui sertifikat SSL/TLS.

Perkakas tersebut bisa diakses tanpa perlu akun `root` atau perintah `sudo` sama sekali, sehingga bisa diakses seperti biasa.

Saya dengar kalau Certbot memerlukan akses root atau menggunakan perintah `sudo` untuk itu, kalau itu benar maka hal itu gak banget, apalagi kalau kasusnya adalah memasangkan sertifikat SSL/TLS di Netlify dan BunnyCDN.

Selain itu, acme.sh juga mendukung berbagai sistem operasi \*nix dan lebih ringan karena itu merupakan berkas skrip _Shell_, serta mendukung berbagai layanan Penyedia DNS yang ada di Internet dan berbagai CA baku selain Let's Encrypt dan ZeroSSL yang bisa Anda ganti tanpa perlu memasukkan Alamat URL-nya lagi, mudah dipindahkan atau digandakan ke perangkat lain, dan sebagainya.

Mengenai alasan kenapa saya tidak menggunakan [Lego](https://github.com/go-acme/lego) sebagai perkakas klien ACME, karena jujur saja saya baru tahu perkakas tersebut dan saya sendiri sudah lama terbiasa dengan acme.sh, jadi saya perlu waktu untuk mempelajarinya.

Namun, jika Anda lebih suka atau lebih memilih untuk menggunakan Lego atau Certbot, ya silakan saja.

### Pertanyaan ke-10: Selain acme.sh, apakah ada alternatifnya untuk Windows? {#pertanyaan-ke10}

Ada, namanya [win-acme](https://www.win-acme.com/) atau [Lego](https://github.com/go-acme/lego) yang mendukung Windows secara _native_.

Selain itu, ada juga [Posh-ACME](https://poshac.me/) yang merupakan modul untuk PowerShell, sehingga dapat dijalankan oleh hampir semua sistem operasi termasuk Windows, GNU/Linux, dan macOS selama terinstal [PowerShell](https://microsoft.com/PowerShell) sebagai _Shell-nya_.

Namun sayangnya, saat ini PowerShell [belum bisa diinstal secara langsung](https://github.com/termux/termux-packages/issues/1729) di Termux, sehingga harus memakai [beberapa "trik"](https://dev.to/thementor/i-run-powershell-on-android-and-so-can-you-458k) terlebih dahulu agar bisa memakainya.

Saya belum coba semuanya dan keliatannya saya lebih suka (atau mungkin lebih tepatnya "lebih terbiasa" dengan) acme.sh daripada lainnya. Kalau mau pakai ya silakan.

### Pertanyaan ke-11: Bagaimana cara menghapus acme.sh sepenuhnya? {#pertanyaan-ke11}

Anda tinggal ketik perintah berikut:

```shell
acme.sh --uninstall
```

Lalu, hapus sebuah skrip yang berkaitan dengan acme.sh di dalam berkas konfigurasi _Shell_ yang Anda gunakan, seperti di dalam berkas `$HOME/.bashrc` atau `$HOME/.zshrc`.

Setelah itu, gunakan perintah `source <LETAK_KONFIGURASI_SHELL>` atau menutup, lalu membuka lagi Terminal untuk menyegarkan kembali _Shell_ Anda. Kalau perlu, Anda juga dapat menghapus direktori acme.sh dengan perintah `rm -rf "$HOME"/.acme.sh` jika direktori tersebut masih ada.

### Pertanyaan ke-12: Jika Netlify hanya menerima Sertifikat SSL/TLS dalam bentuk Teks Biasa, kenapa kita pake perintah `awk`? Kenapa gak pake perintah `cat` aja? {#pertanyaan-ke12}

Karena isi berkas sertifikat itu mengandung multibaris, sedangkan Netlify tidak menerima itu.

Jika saya hanya menggunakan perintah `cat`, maka akan tampil isi dari berkas sertifikat yang sebenarnya sebagai keluaran.

Jadi, saya ganti setiap jeda baris/baris pemutus (_line break_) dengan `\n` menggunakan perintah `awk`, agar si Netlify bisa memproses permintaan dari kita.

### Pertanyaan ke-13: Kenapa pake OpenSSL untuk melakukan konversi/_encoding_ teks ke Base64? Kenapa gak pake perintah `base64` aja? {#pertanyaan-ke13}

Karena artikel ini saya buat agar bisa diikuti oleh banyak perangkat dan sistem operasi, seperti oleh Pengguna Windows, GNU/Linux, Android, BSD dan macOS. Maka saya usahakan agar perintah-perintah yang saya bahas di sini kompatibel oleh banyak perangkat lunak dengan hasil yang sama.

Sedangkan `base64` itu belum tentu kompatibel dan belum tentu akan sama baik perintah ataupun hasil keluarannya di kebanyakan sistem operasi berbasis Unix/Mirip-Unix (\*nix), `base64` [milik GNU (GNU coreutils)](https://www.gnu.org/software/coreutils/manual/html_node/base64-invocation.html) dan yang bukan milik GNU itu benar-benar berbeda, baik dari segi perintah ataupun hasil keluaran bakunya.

Lagipula, tidak semua sistem operasi berbasis \*nix memakai GNU coreutils, sebut saja macOS, Alpine Linux, dan BSD yang merupakan tiga di antaranya, jadi ya wajar saja jika mereka berbeda bila dibandingkan dengan GNU/Linux.

Oleh karena itu, saya memakai OpenSSL sebagai gantinya, selain karena kompatibilitas, saya yakin OpenSSL pasti terinstal di hampir semua sistem operasi yang berbasis \*nix seperti GNU/Linux, BSD, macOS, dan lainnya.

Kalau di Android Anda tinggal Instal Termux, lalu instal `openssl-tool` saja di dalam Termux.

**Lalu, bagaimana dengan Windows?** Untuk Pengguna Windows sudah saya bahas dari awal di bagian [Persiapan](#persiapan-pengguna-windows).

Lagian, acme.sh hanya kompatibel dengan sistem operasi atau lingkungan \*nix, jadi mau-gak mau harus pakai perangkat lunak yang bisa menyediakan lingkungan \*nix atau pakai WSL saja sekalian.

Namun, jika Anda bisa menawarkan solusi yang lebih baik daripada ini, silakan berikan masukan di dalam kolom komentar yang telah disediakan.

### Pertanyaan ke-14: Saya menggunakan Windows 10 dan WSL, saya berhasil memasang Sertifikat SSL/TLS dengan mengikuti artikel ini, tetapi bagaimana caranya agar saya bisa memperbaruinya secara otomatis? {#pertanyaan-ke14}

Jika Anda mempunyai ponsel pintar yang menggunakan sistem operasi Android, saya lebih menyarankan Anda untuk memperbaruinya secara otomatis melalui ponsel saja dan komputer PC atau laptopnya Anda gunakan untuk meremot ponselnya menggunakan klien SSH dan menerbitkan serta mengelola sertifikatnya di sana memakai acme.sh.

Saya sarankan ini karena selain bisa dibawa ke mana-mana (karena berukuran kecil) dan konektivitasnya lebih luas/banyak, ponsel juga bisa diaktifkan lebih lama ketimbang Komputer/Laptop kamu, bahkan bisa diaktifkan selama 24/7 jam nonstop kalau kamu mau selama suhu perangkatnya terjaga dan arus listriknya sehat.

Caranya sudah saya bahas secara lengkap di artikel ini.

Namun, jika Anda terpaksa tidak menggunakannya dengan alasan apa pun, Anda bisa melakukannya di Windows 10 atau di atasnya melalui WSL.

Untuk saat ini ada dua cara, yakni dengan menggunakan _Cron Job_ yang ada di salah satu distribusi WSL atau menggunakan "Task Scheduler". Cara-caranya sebagai berikut:

#### Cara ke-1: Menggunakan _Cron Job_ yang ada di salah satu distribusi WSL

Di salah satu distribusi WSL, seperti Ubuntu 20.04, Anda dapat menggunakan Cron dengan mengaktifkan layanannya terlebih dahulu dengan perintah `sudo service cron start`, lalu atur _Crontab-nya_ seperti biasa.

Namun, jika sesi distribusi WSL tersebut diterminasi (cth. Diterminasi dengan perintah `wsl -t Nama-Distribusi`, Komputer PC/Laptop dimatikan/_di-shutdown_ atau dimulai ulang/_di-restart_, dll), maka semua proses WSL termasuk proses layanan Cron akan dinonaktifkan, sehingga Anda perlu pakai WSL, lalu aktifkan layanannya dan membiarkan WSL tetap berjalan.

Anda bisa eksekusi perintah berikut saat _Start-up_ agar layanan Cron bisa diaktifkan tanpa harus mengakses Terminal WSL:

```powershell
C:\Windows\System32\wsl.exe -d <Nama-Distribusi> -u root /usr/bin/env sh -c service cron start
```

Silakan ganti `<Nama-Distribusi>` dengan Nama Distribusi WSL yang Anda gunakan sekarang.

#### Cara ke-2: Menggunakan _Task Scheduler_

Anda juga dapat menggunakan "Task Scheduler" untuk memperbarui SSL secara otomatis, ini lebih cocok jika Anda membuat skripnya dengan terpisah (menjadi Berkas Skrip tersendiri), tetapi Anda juga bisa menjalankan Layanan Cron di WSL saat _Start-up_ dengan "Task Scheduler" juga, kok.

Caranya sebagai berikut:

1. Buka "**Task Scheduler**"
2. Di dalam folder "**Task Scheduler Library**", klik "**Create Basic Task**" untuk membuat sebuah "Tugas" baru
3. Nanti akan muncul dialog Wisaya atau _Wizard_ yang menuntun kamu dalam membuat sebuah Tugas. Pertama-tama, tulis Nama dan Deskripsi tugasnya, lalu klik "**Next >**"
4. Pada langkah "**Trigger**", nanti kamu menentukan kapan Tugas tersebut dieksekusi/SSL akan diperbarui, di situ ada salah satu opsi berikut yang bisa Anda pilih: (Klik "**Next >**" jika sudah selesai)
    - "**Daily**" yang artinya setiap hari
    - "**Weekly**" yang artinya setiap minggu
    - "**Monthly**" yang artinya setiap bulan
    - "**One time**" yang artinya satu kali saja
    - "**When the computer starts**" yang artinya setiap kali komputer dinyalakan dan sistem sudah siap, tidak peduli apakah sudah login atau belum
    - "**When I log on**" yang artinya setiap kamu login

5. Jika ada sub-langkah setelah "**Trigger**", maka tentukan kapan Tugas tersebut dieksekusi dengan memilih opsi-opsi yang ada. Klik "**Next >**" jika sudah selesai.
6. Pada langkah "**Action**", nanti akan ada 3 pilihan, maka Anda pilih "**Start a program**"
7. Pada sub-langkah "**Start a program**", nanti akan ada kotak teks yang harus Anda isi, berikut adalah Informasinya: (Klik "**Next >**" jika sudah selesai)
   - Isikan **Program/script** dengan `C:\Windows\System32\wsl.exe`
   - Isikan **Add arguments (optional)** dengan `-d Nama-Distribusi -u nama-pengguna /usr/bin/env sh "$HOME"/lokasi/ke/berkas/renew-ssl.sh &`
        - Ganti `Nama-Distribusi` dengan Nama Distribusi WSL yang kamu gunakan
        - Ganti `nama-pengguna` dengan Nama Pengguna/_Username_ di WSL kamu
        - Ganti `$HOME/lokasi/ke/berkas/renew-ssl.sh` dengan lokasi berkas skrip `renew-ssl.sh` yang telah kamu buat sebelumnya atau ganti itu dengan `$HOME/.acme.sh/acme.sh --cron` jika Anda menggunakan Metode Pertama dalam membuat skrip.

8. Pada langkah "**Finish**", kamu akan diperlihatkan tugas yang ingin kamu buat. Periksa terlebih dahulu tugas yang ingin kamu buat sebelum diinangkan, jika merasa yakin, silakan klik "**Finish**".

Cuma kekurangan dari cara "Task Scheduler" adalah jika tugas tersebut dieksekusi, maka akan muncul Jendela/_Window_ yang akibatnya cukup menganggu aktivitas yang sedang Anda lakukan saat menggunakan Aplikasi di Windows (cth. Saat bermain sebuah Gim/Gim Daring, dll)

Mungkin ini bisa diakali jika tugas tersebut dieksekusi setelah kamu masuk/_login_ saja, siapa tahu bisa.

### Pertanyaan ke-15: Apa yang terjadi jika rantai pada Sertifikat SSL/TLS yang terpasang malah tidak sempurna/tidak lengkap? {#pertanyaan-ke15}

Tergantung pada ketidaksempurnaannya/tidak lengkapnya seperti apa, jika Anda hanya memasang sertifikat dan kunci pribadi (_private key_)-nya saja tanpa sertifikat CA-nya, ada perangkat lunak yang mendukung dan ada yang tidak.

Biasanya kebanyakan peramban web di desktop dan seluler (terutama versi terbaru) masih mendukungnya karena mereka memanfaatkan dukungan ekstensi AIA (_Authority Information Access_) yang ada pada sertifikat untuk mengunduh sertifikat penengah (_Intermediate Certificate_) yang hilang sesuai [RFC3280 bagian 4.2.2.1](https://datatracker.ietf.org/doc/html/rfc3280#section-4.2.2.1) dan ada pula yang menembolokan (_cache_) sertifikat penengah untuk melengkapi rantai sertifikat.

Namun, ada beberapa perangkat lunak klien lainnya yang tidak mendukung ekstensi AIA ini dan ada pula yang tidak menembolokan sertifikat penengah, sehingga mereka tidak mendukung sertifikat SSL/TLS yang rantainya tidak lengkap.

Kalau Anda ingin menguji 'reaksi' dari peramban web yang Anda gunakan, silakan kunjungi alamat URL ~~[https://incomplete-chain.badssl.com/](https://incomplete-chain.badssl.com/)~~ atau situs web [badssl.com](https://badssl.com) untuk pengujian lainnya.

**PEMBARUAN Senin, 06 Februari 2023:** Sertifikat SSL/TLS pada `incomplete-chain` telah kedaluwarsa, bukan cuma itu saja, ada beberapa pengujian lainnya yang mengalami kehabisan masa berlaku pada sertifikat SSL/TLS mereka, silakan lihat halaman ["Issue"](https://github.com/chromium/badssl.com/issues) di repositori mereka untuk lebih lanjut.

Atau, kalau Anda ingin mengecek rantai sertifikat yang terpasang di situs web ,blog atau aplikasi Anda, silakan kunjungi halaman [SSL Checker](https://www.sslshopper.com/ssl-checker.html) dari SSL Shopper atau [SSL Server Test](https://www.ssllabs.com/ssltest/) dari Qualys SSL Labs.

Selain hal di atas, jika Anda tidak memasang kunci pribadi, maka sertifikat tersebut biasanya tidak bisa digunakan/tidak diterima oleh perangkat lunak, karena server memerlukan kunci pribadi untuk melakukan dekripsi data.

Kalau kuncinya tidak cocok dengan sertifikatnya, maka akan ada galat seperti cuplikan di bawah ini jika Anda mengaksesnya:

![Galat di Peramban Web Brave saat mengakses blog ini](SSL_TLS_Cipher_Misatch_Error.webp) ![Galat pada SSLTest saat ingin menguji blog ini](SSLTest_Error.webp)

Atau, jika Anda tidak memasang sertifikat untuk domainnya, sepertinya Anda sudah bisa menebak apa yang akan terjadi.

Kalau jawabanmu adalah "Sertifikat TLS/SSL menjadi gagal terpasang dan tidak diterima oleh perangkat lunak" maka jawabanmu benar, karena sama saja seperti kamu membuat sebuah Sertifikat, tetapi tidak tahu untuk siapa.

Jadi, pasanglah sertifikatnya dengan benar!

### Pertanyaan ke-16: Kok sertifikat USERTrust yang saya lihat masa berlakunya cuma sampai tahun 2029 saja, bukannya sampai tahun 2038 seperti yang dibahas tadi? {#pertanyaan-ke16}

USERTrust yang Anda lihat itu bukanlah sertifikat akarnya. Kenapa? Karena ia masih bergantung pada sertifikat "AAA Certificate Services" sebagai sertifikat akar.

Syarat agar menjadi "Sertifikat Akar" adalah bahwa ia tidak mengakar pada sertifikat apa pun, melainkan mengakari sertifikat lain dan dalam hierarki sertifikat SSL/TLS atau rantai kepercayaan, posisi sertifikat akar itu merupakan yang paling tinggi dibandingkan dengan bawahannya.

Jika Anda bingung, silakan lihat cuplikan berikut:

![Hierarki/Rantai Sertifikat SSL/TLS dari ZeroSSL di Windows 10](Hierarki_Sertifikat_SSL.webp) ![Hierarki/Rantai Sertifikat SSL/TLS dari ZeroSSL di Peramban berbasis Chromium untuk GNU/Linux](Hierarki_Sertifikat_SSL_di_Chromium_GNU+Linux.webp)

Seperti yang Anda lihat pada cuplikan di atas, hierarki tertinggi untuk sertifikat SSL/TLS dari ZeroSSL di Windows 10 adalah "Sectigo (AAA)" (sebutan lain dari "AAA Certificate Service"), bukan "USERTrust ECC Certification Authority".

Berbeda bila dibandingkan dengan hierarki/rantai sertifikat SSL/TLS di sistem operasi berbasis \*nix seperti GNU/Linux dan Android (terutama versi terbaru), serta perangkat lunak lain seperti Mozilla Firefox yang malah menempatkan "USERTrust ECC Certification Authority" sebagai sertifikat akarnya.

Jadi, sertifikat akar/rantai (atau _Chain of Trust_) yang Anda dapatkan itu bergantung pada perangkat lunak yang Anda gunakan.

### Pertanyaan ke-17: Kenapa Sertifikat Akar/Rantai yang didapat bisa berbeda-beda di tiap perangkat? {#pertanyaan-ke17}

Salah satu alasan kenapa masih menggunakan sertifikat akar yang lama oleh perangkat lunak adalah karena perangkat lunak tersebut sudah 'berumur', tidak diperbarui ataupun tidak bisa memperbarui sertifikat yang ada, sehingga sertifikat akar alternatif belum/tidak ada.

Alasan selain itu saya kurang tahu, mungkin ini masalah implementasi teknis yang berbeda di tiap perangkat lunak, seperti pada Windows (baik versi terbaru ataupun yang lama) yang seringkali menggunakan sertifikat akar lama ketimbang sertifikat akar baru yang mengakibatkan rantai kepercayaan yang didapat terlalu banyak. (Lihat di jawaban pada pertanyaan sebelumnya)

Namun yang jelas, agar sertifikat SSL/TLS dapat bekerja dengan baik, maka perangkat lunak perlu 'mempercayai'/mengenali sertifikat akar tersebut, salah satunya adalah perlu memiliki sertifikat akarnya dan memasangkannya ke dalam perangkat Anda.

Masalahnya, sertifikat akar memiliki masa berlaku, sehingga perlu diperbarui agar aplikasi/web yang menggunakan sertifikat tersebut dapat diakses/digunakan secara terus-menerus di dalam perangkat itu.

Memperbarui Perangkat Lunak adalah salah satu cara untuk memperbarui masa berlaku dari sertifikat akar yang lama dan dapat mengenali sertifikat akar baru yang sudah bermunculan seiring berjalannya waktu.

Namun, jika tidak bisa diperbarui, maka perangkat lunak akan menggunakan sertifikat akar lama yang tersimpan di dalam tempat penyimpanan sertifikatnya.

Jika sertifikat akar tersebut habis masa berlakunya, maka skenario terburuknya adalah Aplikasi/Web yang terpasang Sertifikat SSL/TLS dengan akar tersebut akan tidak bisa diakses dari perangkat itu sebagaimana mestinya.

Kalau Anda memakai Windows sebagai sistem operasinya, maka seharusnya Anda tidak perlu khawatir soal ini karena secara otomatis [Windows akan mengunduh sertifikat akarnya untuk Anda](https://community.letsencrypt.org/t/microsoft-windows-root-certificate-lazy-loading/160389) (dengan asumsi bahwa fitur [Pembaruan Sertifikat Akar Otomatis](https://docs.microsoft.com/en-us/answers/questions/202270/how-to-enable-the-34automatic-root-certificates-up.html) dan Windows Update tetap aktif).

Jadi, selama akar tersebut dipercaya oleh Microsoft dan Anda tetap mengaktifkan Windows Update, maka seharusnya aman dan akan lebih baik untuk selalu memperbarui sistem Windows Anda, terutama untuk pengguna Windows 7 (bukan "memperbaharuinya" atau menggantikan versi Windows ke versi terbaru).

Apabia Anda ingin memperbarui Windows 7 sampai pembaruan terakhir, silakan ikuti tutorial yang tersedia melalui [tautan ini](https://www.howtogeek.com/255435/how-to-update-windows-7-all-at-once-with-microsofts-convenience-rollup/).

Ketika Anda mengikuti tutorial pada tautan tersebut, tolong abaikan kalimat di bawah ini:

> Unfortunately, this website requires ActiveX, which means it only works in Internet Explorer–you can’t use Google Chrome, Mozilla Firefox, or even Microsoft Edge on a Windows 10 PC.

Karena nyatanya situs web **Microsoft Update Catalog** tersebut tidak membutuhkan fitur ActiveX agar bisa diakses dan digunakan sebagaimana mestinya, sehingga situs web tersebut bisa diakses menggunakan peramban web mana pun, begitupula dengan pengunduhannya, jadi Anda bisa mengikuti tutorial tersebut seperti biasanya asal mengabaikan kalimat yang saya kutip di atas.

### Pertanyaan ke-18: Saya mengalami galat/_error_ selama menggunakan acme.sh, bagaimana cara mengatasinya? {#pertanyaan-ke18}

Cara mengatasinya itu bergantung dengan galatnya. Berbeda pesan galat, maka akan beda penyebabnya, beda penyebab maka solusi pun akan berbeda pula. Sehingga, saya tidak bisa memberikan solusi yang pasti.

Jadi, pertama-tama Anda perlu diagnosa terlebih dahulu mengenai penyebabnya. Untuk caranya, silakan kunjungi [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/How-to-debug-acme.sh).

Anda perlu melihat-lihat/membaca barisan keluarannya saat acme.sh sedang bekerja, jika ada yang menurut Anda mencurigakan, mungkin saja itu adalah penyebabnya.

Jika Anda merasa kesulitan untuk mengatasi masalahnya, mungkin Anda bisa salinkan semua keluarannya terlebih dahulu, lalu tempelkan itu ke dalam layanan Pastebin seperti [Pastebin dari Teknik.io](https://paste.teknik.io/), [GitHub Gist](https://gist.github.com), [IX](http://ix.io/), dll.

Setelah menempelkannya, Anda perlu mengirimkan teksnya, sebelum dikirimkan mungkin Anda perlu menutupi beberapa informasi terlebih dahulu, setelah dikirimkan maka akan muncul alamat URL untuk mengakses teksnya, salinkan alamat URL tersebut dan tempelkan itu ke dalam kolom komentar nantinya.

Serta, berikan pembuka dan detail seperti informasi mengenai sistem operasi, versi acme.sh, kronologi, dll, selengkap mungkin di dalam kolom komentarnya, agar saya dan yang lain bisa lebih cepat membantu Anda, karena Informasi yang diperlukan telah tersedia.

### Pertanyaan ke-19: Bagaimana cara menggantikan kredensial akses API untuk Penyedia DNS yang telah saya masukkan sebelumnya? Soalnya tadi saya salah memasukkannya {#pertanyaan-ke19}

Jika Anda ingin mengganti kredensial yang telah Anda masukkan sebelumnya dengan alasan apa pun, seperti salah ketik, kredensialnya telah diganti, dll, maka ada beberapa cara yang dapat Anda tempuh untuk mengubah kredensialnya, yakni:

#### Metode 1: Mengubah kredensial di dalam `account.conf`

Anda dapat mengubah isi berkas `account.conf`, nanti di situ akan ada variabel/opsi yang berawalan `SAVED_` dan diakhiri dengan informasi yang telah disimpan. Lokasi berkas `account.conf` itu berada di `$HOME/.acme.sh/account.conf`. Berkas tersebut dapat diubah menggunakan editor teks apa pun, termasuk editor teks favorit Anda.

Kalau bingung itu apaan, saya bahas saja bagaimana cara kerjanya. Sebagai contoh, Anda menggunakan Cloudflare sebagai penyedia DNS untuk domain Anda, maka Anda perlu menyimpan kredensial berupa "API Token" ke dalam variabel `CF_Token` dan "Account ID" ke dalam variabel `CF_Account_ID` di dalam Terminal terlebih dahulu sebelum menerbitkan sertifikat.

Setelah menyimpannya dan menjalankan perkakas acme.sh untuk menerbitkan sertifikatnya, maka secara otomatis acme.sh akan menyimpan kedua informasi tersebut ke dalam berkas `account.conf`, tetapi dalam bentuk variabel `SAVED_CF_Token` untuk `CF_Token` dan `SAVED_CF_Account_ID` untuk `CF_Account_ID`-nya.

Nah, jika Anda menggunakan Cloudflare sebagai penyedia DNS dan ingin menggantikan kredensialnya, entah itu ganti "API Token" atau/dan "Account ID"-nya, maka cukup ganti saja nilai dari variabel `SAVED_CF_Token` dan `SAVED_CF_Account_ID` atau salah satunya di dalam berkas `$HOME/.acme.sh/account.conf`.

Kalau mau cepat, Anda bisa salin, lalu tempelkan perintah berikut ke dalam Terminal Anda.

Gunakan Perintah berikut ini jika Anda ingin menggantikan dua-duanya:

```shell {linenos=true}
cp "$HOME"/.acme.sh/account.conf "$HOME"/.acme.sh/account.conf.1 ## Backup dulu
sed -i '/SAVED\_CF\_Token\=/d' "$HOME"/.acme.sh/account.conf
sed -i '/SAVED\_CF\_Account\_ID\=/d' "$HOME"/.acme.sh/account.conf
printf "SAVED_CF_Token='%s'\n" "API_TOKEN_KAMU_DI_SINI" >> "$HOME"/.acme.sh/account.conf
printf "SAVED_CF_Account_ID='%s'\n" "ACCOUNT_ID_KAMU_DI_SINI" >> "$HOME"/.acme.sh/account.conf
```

Atau, contoh perintah di bawah ini jika Anda hanya ingin menggantikan `CF_Token`-nya saja:

```shell {linenos=true}
cp "$HOME"/.acme.sh/account.conf "$HOME"/.acme.sh/account.conf.1 ## Backup dulu
sed -i '/SAVED\_CF\_Token\=/d' "$HOME"/.acme.sh/account.conf
printf "SAVED_CF_Token='%s'\n" "API_TOKEN_KAMU_DI_SINI" >> "$HOME"/.acme.sh/account.conf
```

Namun jika Anda menggunakan penyedia DNS lain, maka variabel yang digunakan akan berbeda-beda untuk setiap penyedia, oleh karena itu Anda perlu mengetahui dan menyesuaikan variabel-variabel tersebut, untuk mengetahui variabel yang mereka gunakan, silakan kunjungi terlebih dahulu [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).

Setelah itu, coba perbarui/terbitkan lagi sertifikatnya, dengan begini acme.sh akan menggunakan kredensial barunya.

#### Metode 2: Mengubah kredensial di dalam konfigurasi domainnya

Selain menggunakan `account.conf`, Anda juga dapat mengubah kredensial bahkan menambahkan kredensial akses API dari Penyedia DNS Anda melalui konfigurasi domainnya.

Berkas Konfigurasi Domainnya berada di `$HOME/.acme.sh/domain.com/domain.com.conf`. Berkas tersebut dapat diubah menggunakan editor teks apa pun, termasuk editor teks favorit Anda, serta Anda dapat mengubah ataupun menambahkan variabelnya di situ.

Kalau bingung itu apaan, saya bahas saja bagaimana cara kerjanya. Sebagai contoh, Anda menggunakan Cloudflare sebagai penyedia DNS untuk domain Anda, maka Anda perlu menyimpan kredensial berupa "API Token" ke dalam variabel `CF_Token`, "Account ID" ke dalam variabel `CF_Account_ID` dan "Zone ID" ke dalam variabel `CF_Zone_ID` di dalam Terminal terlebih dahulu.

Setelah menyimpannya dan menjalankan perkakas acme.sh untuk menerbitkan sertifikatnya, maka secara otomatis acme.sh akan menyimpan kedua informasi tersebut bukan ke dalam berkas `account.conf`, melainkan ke dalam konfigurasi domainnya, tanpa diubah variabel beserta nilainya tidak seperti ketika disimpan ke dalam `account.conf`.

Nah, jika Anda menggunakan Cloudflare sebagai penyedia DNS dan ingin menggantikan kredensialnya, entah itu ganti "API Token", "Account ID" atau/dan "Zone ID"-nya, maka cukup ganti saja nilai dari variabel `CF_Token`, `CF_Account_ID` dan `CF_Zone_ID` atau salah satunya di dalam berkas `$HOME/.acme.sh/domain.com/domain.com.conf`, bahkan Anda bisa menambahkan variabel lainnya di dalam sana.

Namun jika Anda menggunakan penyedia DNS lain, maka variabel yang digunakan akan berbeda-beda untuk setiap penyedia, oleh karena itu Anda perlu mengetahui dan menyesuaikan variabel-variabel tersebut, untuk mengetahui variabel yang mereka gunakan, silakan kunjungi terlebih dahulu [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).

Jangan lupa untuk menghapus kredensial yang ada di dalam berkas tersebut setelah Anda menambahkannya. Setelah itu, tunggu saja sampai waktu pembaruan sertifikat telah tiba.

### Pertanyaan ke-20: Apakah ini juga bisa diikuti oleh pengguna perangkat komputer kecil seperti Raspberry Pi dan perangkat sejenis lainnya? {#pertanyaan-ke20}

Sangat bisa, saya bahkan menyarankan agar Anda memakai perangkat seperti ini kalau punya, Anda sangat bisa untuk mengikuti semua tutorial yang ada di sini menggunakan perangkat komputer kecil Anda, seperti Raspberry Pi atau perangkat sejenisnya.

Untuk sistem operasinya, saya sarankan Anda gunakan GNU/Linux yang merupakan salah satu sistem operasi berbasis \*nix dibandingkan dengan Windows, kalau mau yang lain seperti macOS, BSD, Solaris, dll, juga boleh. Di Android juga bisa, tetapi saya sarankan unduh, instal dan gunakan aplikasi Termux di dalamnya untuk itu.

### Pertanyaan ke-21: Bagaimana cara memindahkan salinan acme.sh ke dalam perangkat lain? {#pertanyaan-ke21}

Bisa sekali, cara memindahkan acme.sh ke dalam perangkat lainnya adalah sebagai berikut:

1. Pastikan perangkat yang Anda tuju atau perangkat baru Anda sudah memenuhi [persiapannya](#persiapan) terlebih dahulu. Sudah? Kalau begitu, Anda bisa lanjut.
2. Sebelum itu, Anda perlu menyalinkan direktori acme.sh ke perangkat baru dari perangkat lama Anda. Kompresi direktori dan berkas tersebut dengan perintah berikut dari perangkat lama Anda:

```shell {linenos=true}
cd
tar --exclude '.acme.sh/deploy' --exclude '.acme.sh/notify' --exclude '.acme.sh/dnsapi' --exclude '.acme.sh/acme.sh' --exclude '.acme.sh/*.env' --format pax -cvzf acme.sh.tar.gz .acme.sh
```

Anda bisa mengganti `acme.sh.tar.gz` menjadi nama berkas yang Anda inginkan, asal akhirannya ada `.tar.gz`.

**Catatan:** Jika Anda menggunakan [Metode ke-2](#membuat-berkas-skrip-shell), maka Anda perlu kompresi berkas `renew-ssl.sh`-nya juga.

3. Setelah mengkompresinya, silakan langsung menyalinkannya ke dalam perangkat yang ingin Anda tuju/perangkat baru Anda. Jika perlu, silakan lakukan enkripsi pada berkas tersebut terlebih dahulu sebelum menyalinkan/mengirimkannya
4. (**Catatan:** Mulai sekarang/di langkah ini, gunakan perangkat yang Anda tuju/perangkat baru Anda sampai seterusnya) Setelah disalin ke dalam perangkat baru, pindahkan berkas tersebut ke dalam direktori `$HOME` atau `~` yang ada di dalam perangkat baru Anda.

5. Setelah itu, buka Terminalnya dari perangkat baru, lalu instal terlebih dahulu acme.sh-nya dengan perintah berikut:

```bash
curl https://get.acme.sh | sh -s
```

6. Setelah Anda menginstalnya, dekripsi berkas `acme.sh.tar.gz` jika Anda melakukan enkripsi, lalu ekstrak berkas tersebut dengan perintah berikut:

```bash
tar -xvzf acme.sh.tar.gz
```

7. Setelah diekstrak, aturlah `USER_PATH` di dalam berkas `$HOME/.acme.sh/account.conf` dengan perintah berikut:

```bash {linenos=true}
cp "$HOME"/.acme.sh/account.conf "$HOME"/.acme.sh/account.conf.1 ## Backup dulu
sed -i '/USER\_PATH\=/d' "$HOME"/.acme.sh/account.conf
printf "USER_PATH='%s'\n" "$PATH" >> "$HOME"/.acme.sh/account.conf
```

8. Jika Anda membuat berkas skrip terpisah (mengikuti [Metode ke-2](#membuat-berkas-skrip-shell)), maka aturlah _Crontab_ melalui Terminal agar berkas skrip `renew-ssl.sh` bisa dieksekusi secara terjadwal oleh _Cron Job_. Bila masih belum paham/lupa, silakan baca bagian "[Otomatisasi dengan _Cron Job_](#otomatisasi-skrip-dengan-cron-jobs)" di atas.

   Jika Anda mengikuti [Metode Pertama](#memanfaatkan-konfigurasi-acme-sh), maka harusnya Anda dapat lewati langkah ini, karena biasanya _Crontab_ secara otomatis diatur setelah Anda menginstal perkakas acme.sh-nya.

   Kalau tidak yakin, Anda bisa mengaturnya secara manual atau eksekusikan perintah `acme.sh --install-cronjob` di dalam perangkat baru Anda untuk memasang _Cron Job-nya_.

9. Kalau sudah selesai, pastikan agar layanan Cron selalu aktif di dalam perangkat baru Anda, baik saat perangkat dijalankan, bahkan saat perangkat dalam posisi _start-up_/setelah dinyalakan.

10. Setelah ini semua berhasil dan selesai, maka sebaiknya Anda hapus _Cron Job_ yang berkaitan dengan acme.sh atau pembaruan Sertifikat SSL/TLS di dalam perangkat lama Anda, hal ini dilakukan supaya tidak menimbulkan konflik saat memperbarui sertifikatnya hanya karena kredensialnya sama.

    Caranya bisa hapus manual melalui `crontab -e`, atau gunakan perintah `acme.sh --uninstall-cronjob` untuk menghapusnya secara otomatis dari perangkat lama Anda

    Kalau perlu, Anda juga dapat menghapus acme.sh sepenuhnya dari perangkat lama Anda dengan perintah `acme.sh --uninstall; rm -rf ~/.acme.sh`

### Pertanyaan ke-22: Saat saya menerbitkan/memperbarui Sertifikat SSL/TLS melalui acme.sh, kok malah muncul error 5xx yah? (cth. "504 Gateway Time-Out") {#pertanyaan-ke22}

Penyebab dari masalah ini kemungkinan terbesarnya adalah bahwa Server tersebut sedang mengalami gangguan, kendala atau ketidaktersediaan (_downtime_) karena suatu masalah, seperti banyaknya pengguna, koneksi dari Server/Proksi yang melambat, dll.

Jadi, sabarlah menunggu sampai beberapa waktu kemudian, entah itu beberapa menit, jam atau beberapa hari, siapa tahu nanti permasalahan pada servernya bisa terselesaikan, sehingga bisa digunakan kembali.

Namun, kalau Anda mau agar sertifikatnya dapat diperbarui dengan lebih cepat di saat sertifikatnya sudah mencapai beberapa hari (biasanya 30 hari) sebelum habis masa berlaku, maka aturlah _Cron Job-nya_ agar acme.sh dapat dieksekusi setiap 2 jam dalam seharian penuh, dengan begini Anda dapat mengurangi keterlambatan pembaruan sertifikat karena masalah seperti ini.

### Pertanyaan ke-23: Apakah benar bahwa SSL Gratisan itu memiliki Enkripsi yang lemah? {#pertanyaan-ke23}

Itu tidak benar, jika ada artikel yang menyatakan demikian, itu bisa dipastikan sesat. Karena Enkripsi, baik itu Algoritma, _Cipher_ (Penyandian) dan Entropi pada Enkripsi itu ditentukan sepenuhnya oleh Konfigurasi _Cipher Suite_ yang ada pada Server.

Sertifikatnya memang punya andil yang sangat penting sih dalam keamanan, karena ia membawa kunci publik di dalamnya, tetapi yang melakukan enkripsi dan dekripsi tetap saja oleh Server dan Kliennya, bukan oleh sertifikat atau pun pihak CA-nya.

Lagipula, algoritma dan ukuran kunci publik yang bisa Anda dapatkan baik dari Sertifikat SSL/TLS berbayar atau bahkan gratisan itu sama aja, kok, dan yang pasti Anda tidak akan mendapatkan kunci yang sudah 'tertinggal' (cth. RSA dengan ukuran 1024-bit).

Bahkan algoritma kunci publik yang digunakan pada Sertifikat SSL/TLS berbayar yang terpasang di dalam Situs Web/Blog yang saya lihat kebanyakan pada memakai algoritma kunci RSA dengan ukuran 2048-bit saja, yang merupakan kunci yang cukup ideal untuk saat ini, walaupun saat ini ada yang memakai algoritma yang lebih baru (seperti ECC/ECDSA), empat di antaranya adalah Facebook, Twitter, Cloudflare dan Google (meski rantainya tidak sepenuhnya ECC).

Selain itu, saat Sertifikat SSL/TLS ingin dibuat memakai acme.sh saja, Anda bisa menentukan ukuran dan jenis kuncinya dengan bebas selama didukung oleh acme.sh dan pihak CA-nya, semakin besar ukuran kuncinya maka semakin kuat kuncinya.

Namun, semakin besar pula pengorbanan kinerja dari sebuah perangkat saat mengunjunginya, karena perangkat keras belum tentu dapat memprosesnya dengan cepat, apalagi jika tidak memiliki fitur akselerasi dari perangkat keras, sehingga ini akan mengorbankan kinerja dari sebuah Web/Blog juga.

Jadi, harus dipertimbangkan dengan baik untuk pemilihan kuncinya ya 🙂

### Pertanyaan ke-24: Masa aktif Sertifikat SSL/TLS gratisan (termasuk dari ZeroSSL) rata-rata hanya 90 hari, apakah itu tidak bermasalah? {#pertanyaan-ke24}

Selama bisa diperbarui secara otomatis, maka seharusnya tidak masalah.

Sekarang ini sudah sangat banyak atau bahkan mayoritas perangkat lunak klien untuk Protokol ACME, Penyedia Web (seperti Layanan Hosting Web dan CDN), dll, sanggup memperbarui sertifikat tersebut secara otomatis berkat dukungan protokol ACME-nya.

Untuk kasus pembaruan Sertifikat SSL/TLS dari ZeroSSL (yang telah saya bahas di artikel ini), itu juga diperbarui secara otomatis melalui perkakas acme.sh yang telah dijalankan di dalam latar belakang pada ponsel atau perangkat Anda.

Jadi, Anda hanya perlu duduk diam dan menunggu bahwa Sertifikat SSL/TLS berhasil diperbarui, tidak perlu melakukan apa pun, Anda hanya perlu pastikan bahwa koneksi Internet selalu ada pada ponsel atau perangkat Anda.

Ada beberapa manfaat yang bisa Anda dapatkan untuk masa berlaku yang pendek ini, seperti:

1. Sertifikat yang kamu gunakan akan selalu mendapatkan algoritma tandatangan dan kunci yang tidak tertinggal, serta dapat cepat "beradaptasi" jika suatu saat para _root program_ (seperti Google, Microsoft, Apple, Mozilla dan Cisco) memutuskan untuk memblokir atau "tidak lagi mempercayai" sertifikat yang ditandatangani dengan algoritma atau/dan menggunakan kunci tertentu yang telah usang, karena alasan keamanan.

    Kalau kamu tidak paham apa yang saya maksud, coba kamu bayangkan kalau di tahun 2008 yang lalu kamu menyewa sebuah [Sertifikat SSL/TLS dengan masa berlaku 10 tahun](https://crt.sh/?id=35520072) (yang artinya berlaku sampai tahun 2018), yang mana saat itu Sertifikat SSL/TLS masih ditandatangani dengan algoritma SHA1 dan menggunakan kunci RSA 1024-bit.

    Namun 3-5 tahun kemudian, _root program_ tersebut malah memutuskan untuk tidak lagi mempercayai atau memblokir sertifikat yang ditandatangani dengan algoritma yang telah usang seperti SHA1 dan menggunakan kunci yang telah usang seperti RSA dengan ukuran 1024-bit.

    Nah, kira-kira seperti itulah maksudnya, paham kan?

2. Dengan mengotomatiskan pembaruan sertifikat, Anda dapat meminimalkan pembaruan dalam keadaan mendadak secara manual. Memperbaruinya secara manual akan menguras waktu lain berharga Anda.
3. Meminimalisir terjadinya salah penerbitan (_mis-issuance_) pada Sertifikat SSL/TLS dan terkomprominya kunci pribadi untuk sertifikatnya.

    Jika terjadinya _mis-issuance_ pada sertifikat atau kunci pribadimu dikompromikan/dicuri, maka hal ini tidak akan bertahan lama karena masanya yang pendek.

    Jadi, Anda tinggal menunggu sampai masa berlakunya habis atau menerbitkan ulang sertifikatnya, tanpa perlu _me-revoke_ sertifikat lamanya terlebih dahulu yang membuat situs web/aplikasi menjadi _down_/tidak berfungsi (kalau bisa sih _di-revoke_ dulu), ini akan mengurangi ketergantungan Anda pada proses _Revocation_ yang menurut Scott Helme itu ["kacau balau"](https://scotthelme.co.uk/revocation-is-broken/)

4. Anda selalu bisa mendapatkan kunci terbaru (dengan merotasi kunci pribadi) ketika memperbarui sertifikatnya secara otomatis.

    **Catatan:** Ini tergantung dari Perkakas Klien ACME yang Anda gunakan, perkakas acme.sh secara baku tidak merotasi kunci pribadi, dengan kata lain tidak membuat kunci pribadi baru ketika memperbarui sertifikatnya, sehingga ia tetap menggunakan kunci yang ada sebelumnya.

    Ketika Anda ingin menerbitkan sertifikatnya, Anda dapat menambahkan parameter `--always-force-new-domain-key` atau jika telanjur, Anda dapat menambahkan `Le_ForceNewDomainKey=1` di dalam berkas `domain.com.conf` agar acme.sh selalu membuat kunci baru setiap pembaruan sertifikat

Tentu saja hal ini bukan berarti tanpa kekurangan, mengotomatiskan pembaruan Sertifikat SSL/TLS itu merupakan tugas yang menantang.

Jika Anda adalah pengguna Netlify, Bunny CDN, cPanel atau/dan DirectAdmin, mungkin Anda dapat menyelesaikannya dengan mengikuti artikel ini, tetapi ini akan menantang jika Anda tidak menggunakan salah satu dari keempat itu atau apalagi jika Anda menggunakan perangkat yang berumur tua atau jadul, maka mengimplementasikan ini akan sangat sulit atau bahkan menjadi tidak mungkin.

Itu pun belum sama kendala kebijakan organisasi, perusahaan, atau kendala yang nantinya dialami jika Anda berada di dalam DMZ (Singkatan dari: **_demilitarized zone_**, bahasa Indonesia: **Zona demiliterisasi**), sehingga mungkin tidak disarankan untuk menggunakan Sertifikat SSL/TLS dengan masa berlaku yang pendek.

Kalau Anda ingin masa aktif yang lebih dari itu, mungkin bisa Anda coba Sertifikat SSL/TLS dari Buypass, yakni "[**Buypass Go SSL**](https://www.buypass.com/products/tls-ssl-certificates/go-ssl)" yang memiliki masa aktif maksimal 180 hari atau sekitar 6 bulan saja.

Namun sayangnya, Anda tidak bisa menerbitkannya dalam bentuk _Wildcard_, tetapi mungkin Anda bisa menerbitkannya dalam bentuk multi-domain atau/dan multi-subdomain, meski terbatas hanya bisa 5 SAN saja.

### Pertanyaan ke-25: Apakah Sertifikat SSL/TLS dari ZeroSSL (baik gratisan atau berbayarnya) itu boleh dipasang pada Situs Web untuk keperluan komersial (seperti Perdagangan Elektronik, dll)? {#pertanyaan-ke25}

Saya kurang tahu secara pastinya apakah Sertifikat SSL/TLS tersebut boleh tidak digunakan oleh Situs Web yang punya keperluan komersial, seperti Perdagangan elektronik (bahasa Inggris: **_e-commerce_**).

Namun, di dalam halaman [Syarat & Ketentuan Layanannya](https://zerossl.com/terms/), tertulis kalimat berikut:

> You may not use ZeroSSL for any commercial purpose including but not limited to selling, licensing, providing services, or distributing ZeroSSL to any third party unless you have received the express written consent of ZeroSSL beforehand.

Saya kurang tahu/kurang paham apa maksud dari kalimat `for any commercial purpose` di sini, apakah tidak boleh dipasang di Situs Web Perdagangan Elektronik secara keseluruhan atau melarang tindakan komersil pada layanan ZeroSSL-nya saja.

Kalaupun tidak boleh dipasang di Situs Web tersebut, saya juga kurang tahu apakah itu berlaku untuk pengguna gratisan, yang berbayar atau malah semua. Karena TOS ini sepertinya melingkupi semua layanan yang ada pada ZeroSSL, gak peduli itu gratisan ataupun berbayar.

Jadi, jawabannya saya kurang tahu dan belum saya tanya ke mereka, mungkin saja diperbolehkan sama mereka selama tidak mengkomersilkan layanan mereka tanpa izin dari mereka.

### Pertanyaan ke-26: Apa alasan kamu menggunakan ZeroSSL? Kenapa kamu gak pakai Let's Encrypt aja? Padahal tampilan blog ini akan lebih baik apabila diakses dengan Peramban Web yang Sangat Modern {#pertanyaan-ke26}

Alasan saya menggunakan ZeroSSL (atau CA lain) sebagai berikut:

#### Karena ingin mencoba hal yang baru dan merasa ZeroSSL lebih baik ketimbang Let's Encrypt

Setelah beberapa tahun saya menggunakan Sertifikat SSL/TLS dari Let's Encrypt (entahlah, mungkin sekitar dari 2016 atau 2017-an), karena sekarang ini saya baru tahu kalau ada CA selain Let's Encrypt yang menawarkan Sertifikat SSL/TLS-nya secara gratis, seperti ZeroSSL, maka saya memutuskan untuk tidak lagi menggunakan Let's Encrypt sebagai CA yang 'eksklusif'.

Selain itu, dari beberapa aspek, Sertifikat SSL/TLS dari ZeroSSL jelas lebih baik ketimbang Let's Encrypt untuk saat ini. Mungkin Let's Encrypt mendapatkan banyak sponsor/donatur dari luaran sana, tetapi bukan berarti sertifikatnya lebih baik dibandingkan lainnya.

Bisa jadi uang hasil sponsor atau donasi tersebut digunakan untuk memperbarui infrastruktur mereka, pengembangan fitur-fitur, perangkat lunak dan protokol ACME-nya.

Jadi, selama ZeroSSL lebih baik daripada Let's Encrypt pada beberapa aspek, kenapa tidak? Toh, saya pake ini juga bukan sekadar untuk blog ini saja.

#### Membantu Let's Encrypt

Alasan ini mungkin terlihat aneh, tetapi saya jelaskan kenapa menggunakan alasan ini.

Let's Encrypt itu merupakan organisasi nirlaba yang super sibuk, CA tersebut terkenal di mana-mana dan hampir semua penyedia Hosting/CDN menyediakan fitur pemasangan Sertifikat SSL/TLS tersebut dari Panelnya, salah satunya adalah Netlify, Vercel, Render, GitHub Pages, GitLab Pages, Bunny CDN, Akamai, Cloudflare, bahkan di layanan _Shared Hosting_ biasa pun mayoritasnya ada fitur tersebut.

Karena saya tidak bisa berdonasi dalam bentuk uang, sponsor atau dalam bentuk apa pun itu, maka saya tidak lagi mengekslusifkan Let's Encrypt untuk seluruh domain dan subdomain saya sebagai CA demi menghemat pengeluaran mereka serta memaksimalkan anggarannya.

Dengan memaksimalkan anggarannya, maka mereka bisa memfokuskan anggarannya untuk hal lain, seperti mengembangkan protokol ACME agar protokol tersebut bisa lebih baik lagi dari yang sekarang.

Lagipula, memiliki lebih dari 1 CA Gratisan yang menggunakan Protokol ACME itu merupakan hal yang sangat, sangat baik untuk ekosistem IKP dan penggunanya sama-sama diuntungkan di sini, karena ada pilihan lain.

#### Merasa tertantang dan mendapat ilmu baru

Saat ingin menggunakan ZeroSSL, mayoritas penyedia web belum mendukung antarmuka untuk pemasangan Sertifikat SSL/TLS dari ZeroSSL secara otomatis, kebanyakan dari mereka cuma mendukung Let's Encrypt saja, seperti yang pernah saya bahas di awal.

Sehingga saya merasa tertantang untuk menerbitkan, memasang dan mengotomasi pembaruan Sertifikat SSL/TLS tersebut sendirian, dengan menggunakan acme.sh untuk mengelola sertifikatnya dan curl untuk memasang sertifikatnya dengan memanfaatkan Server API dari Penyedia Web-nya.

Pada akhirnya, saya mendapatkan ilmu baru yang cukup berguna juga, setidaknya untuk saya sendiri.

### Pertanyaan ke-27: Apa kekurangan ZeroSSL menurut Anda? {#pertanyaan-ke27}

Kekurangannya menurut saya adalah:

- Server ACME-nya yang kadang-kadang bermasalah. Jadi, Anda harus bersabar jika Anda mengalami masalah saat menerbitkan/memperbarui Sertifikat SSL/TLS melalui server ACME-nya. Kalo gak mau sabar, ya berlangganan aja, lalu gunakan REST API-nya atau ganti dengan yang lain
- Memiliki kelebihan di Pengelolaan Sertifikatnya, tetapi tidak bisa mencabut atau menghapus Sertifikat SSL/TLS yang diterbitkan melalui server ACME-nya

Itu aja sih kekurangannya untuk saat ini.

## Referensi lain di Artikel ini

Di bawah ini adalah referensi-referensi yang saya gunakan untuk Artikel ini yang sebelumnya tidak saya sebut/bahas.

Berikut adalah referensinya:

### Referensi Penggunaan API bunny.net

- Halaman [Dokumentasi API bunny.net](https://docs.bunny.net/reference/pullzonepublic_addcertificate)
- Cuplikan berikut adalah Obrolan di Dukungan Tiket yang menyatakan jika ingin memasangkan Sertifikat SSL/TLS menggunakan panggilan API-nya, maka berkas-berkas tersebut harus dikirimkan dalam bentuk Base64:

![Percakapan saya di Tiket Dukungan, pesan awalnya sengaja tidak saya perlihatkan](bunny.net_API_Support_Ticket.webp)

Ngomong-ngomong, saya tanya di Tiket Dukungan itu karena saat artikel ini ditulis sampai pertama kali diterbitkan belum ada dokumentasi resmi yang menyatakan bahwa itu dikirimkan dalam bentuk Base64, kalau sekarang sih sudah ada.

- Untuk konversi ke dalam Base64, komentar-komentar di dalam [jawaban dari "Steve Folly"](https://superuser.com/a/120815) di Super User sangat membantu saya.

### Referensi Penggunaan API Netlify

- Halaman [Dokumentasi API Netlify](https://open-api.netlify.com/#operation/provisionSiteTLSCertificate)
- Halaman yang berjudul **"[Get started with the Netlify API](https://docs.netlify.com/api/get-started/)"** dari Netlify
- Melakukan Inspeksi Jaringan di Peramban Web saat memasang Sertifikat SSL/TLS secara manual di dalam Situs Web-nya, dengan bertujuan untuk mengetahui bagaimana Netlify mengirimkan datanya ke dalam Server dan hasilnya itulah yang dijadikan referensi.

  Anda bisa lakukan itu sendiri dengan cara berikut:
  1. Tekan tombol <kbd>Ctrl</kbd> + <kbd>&#8679; Shift</kbd> + <kbd>I</kbd> sebelum memasang Sertifikat SSL/TLS di Netlify
  2. Klik pada tab "Network", nanti di situ akan tampil sebuah panel kosong dan hanya berpesan kalau kamu perlu menyegarkan (_refresh_) halamannya atau menekan tombol <kbd>Ctrl</kbd> + <kbd>R</kbd> terlebih dahulu, tetapi jangan Anda lakukan itu.
  3. Pasang Sertifikat SSL/TLS kamu secara manual di Halaman Web-nya
  4. Jika kamu sudah selesai mengisi semua informasi yang diperlukan, klik pada _button_ **"Install certificate"**
  5. Setelah kamu mengklik _button_ tersebut, maka di dalam Panel Inspeksi Jaringan akan muncul sebuah permintaan (_request_) dari `api.netlify.com`, klik pada permintaan tersebut, nanti akan muncul sebuah Informasi mengenai permintaan tersebut di sebelah kanan Panelnya.
  6. Setelah muncul, arahkan kursor kamu ke sebelah kanan Panel, lalu kamu gulirkan itu ke bawah menggunakan tetikus (_mouse_) kamu sampai kamu menemukan bagian **"Request Payload"** atau sejenisnya.
  7. Jika ketemu, seperti itulah data yang akan kamu kirimkan ke Netlify saat memasang Sertifikat SSL/TLS kamu secara manual

- Untuk cara menghilangkan jeda barisnya (_line break_) dan menggantinya dengan karakter `\n`, saya pakai [jawaban dari "Ed Morton"](https://stackoverflow.com/a/38674872) di Stack Overflow sebagai referensi, jawabannya dilisensikan di bawah [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

### Referensi untuk lainnya

- Utas forum yang berjudul **"[How do I Crontab on Termux..](https://www.reddit.com/r/termux/comments/i27szk/how_do_i_crontab_on_termux/)"** di Reddit sebagai referensi untuk menginstal _Cron Job_ di Termux
- Utas forum yang berjudul **"[Do I need to set crontab again when I restart termux?](https://www.reddit.com/r/termux/comments/n6y82b/do_i_need_to_set_crontab_again_when_i_restart/)"** di Reddit sebagai referensi untuk mengaktifkan Layanan Cron jika Termux diterminasi
- Halaman yang berjudul **"[RSA key lengths](https://www.javamex.com/tutorials/cryptography/rsa_key_length.shtml)"** dari Javamex sebagai referensi untuk pengaruh Ukuran kunci RSA bagi kecepatan
- Hasil dari pengujian dengan perintah `openssl speed rsa2048 rsa3072 rsa4096` yang rata-rata menyatakan/menyimpulkan bahwa semakin besar ukuran kuncinya (terutama untuk kunci RSA), maka akan semakin besar pengaruhnya terhadap kecepatan.

Di bawah ini adalah hasil pengujian di Laptop: (Menggunakan Laptop Lenovo Legion 5 15ARH05, Prosesor: AMD Ryzen 7 4800H, RAM: 8x2 GB DDR4)

```plain {linenos=true}
                  sign    verify    sign/s verify/s
rsa 2048 bits 0.000516s 0.000015s   1937.1  66884.5
rsa 3072 bits 0.001568s 0.000031s    637.9  32169.3
rsa 4096 bits 0.003504s 0.000054s    285.4  18588.0
```

Dan, di bawah ini adalah hasil pengujian di PC saya: (PC-nya menggunakan Prosesor: Intel Pentium G2030, RAM: 2x2 GB DDR3)

```plain {linenos=true}
                  sign    verify    sign/s verify/s
rsa 2048 bits 0.001680s 0.000050s    595.1  19946.8
rsa 3072 bits 0.005208s 0.000106s    192.0   9463.3
rsa 4096 bits 0.012121s 0.000186s     82.5   5368.5
```

- Halaman **"[Making tar Archives More Portable](https://www.gnu.org/software/tar/manual/html_section/Portability.html)"** dari Proyek GNU
- Halaman [Manual Perintah `tar` untuk macOS](https://ss64.com/osx/tar.html) (yang entah apakah benar sesuai atau tidaknya untuk versi sekarang, itu pun bukan halaman resmi dari Apple)

## Penutup

Ya udah, segitu aja dulu artikel kali ini. Gimana? Pusing? Meriang? Ya makanya pelan-pelan bacanya, sudah saya jelaskan dari awal kalau artikel ini bakalan panjang kali lebar.

Saya tulis artikel ini sejak 10 Juli 2021 dan perlu waktu 1 bulan lebih agar saya bisa menerbitkannya, karena artikel ini membahas banyak hal dan juga sedikit 'riset' agar artikel ini bisa diikuti oleh banyak perangkat, belum lagi sama kalimat-kalimatnya, itu pun belum sama pengujiannya.

Terima kasih bagi Anda yang telah membaca serta mempelajari yang ada di artikel ini, mohon maaf jika artikel ini memiliki beberapa kekeliruan dan kesalahan, seperti salah ketik, kurang jelas, salah informasi, dll, karena artikel ini jauh dari sempurna.

Saya akan berusaha untuk terus-terusan memperbarui artikel ini seiring berkembangnya Informasi yang ada, karena yang saya pos ini adalah tutorial, sehingga perlu adanya penyesuaian.

Jika adanya kesalahan dan kekeliruan, atau kalau Anda memiliki pertanyaan lainnya, bisa Anda berikan masukkan melalui kolom komentar yang tersedia. Masukkan dari Anda akan sangat berarti bagi saya dan artikel ini untuk ke depannya nanti.

Terima kasih atas perhatiannya 😊

## Penggunaan Gambar dan Atribusi

Berkas-berkas Gambar (seperti Cuplikan layar dan Gambar lainnya) yang di gunakan di dalam artikel ini, disediakan di dalam [repositori blog ini](https://github.com/FarrelF/Blog).

Jika Anda ingin menjelajahinya, silakan kunjungi Alamat URL berikut:

```plain
https://github.com/FarrelF/Blog/tree/main/content/post/2021/08/26-cara-memasang-zerossl-dan-renew-otomatis-di-netlify-bunnycdn
```

ZeroSSL dan logonya merupakan Merek Dagang, Merek Dagang Terdaftar, atau/dan Pakaian Dagang dari "Stack Holdings GmbH", sehingga nama merek dan logo tersebut bukanlah milik saya pribadi, saya hanya dapatkan itu dari Situs Web Resminya dan di sana belum ada petunjuk penggunaan logonya.
