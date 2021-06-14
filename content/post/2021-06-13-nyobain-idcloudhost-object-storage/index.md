---
Title: Nyobain Penyimpanan S3 dari IDCloudHost (IS3)
Slug: nyobain-penyimpanan-s3-dari-idcloudhost
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Opini
    - Info Blog
Date: 2021-06-13 08:10:30+07:00
draft: true
Tags: 
    - Preview
    - IDCloudHost
    - IS3
    - Penyimpanan S3
    - Penyimpanan berbasis Objek
readMore: true
DescriptionSEO: Apakah Anda ingin menghemat konsumsi Bandwidth Server, sehingga Web/Blog Anda bisa bertahan? Kalo iya, silahkan baca artikel ini!
Description: >
    Beberapa bulan kemarin, saya sudah berencana kalau saya akan menggunakan Penyimpanan yang menggunakan Protokol S3 ini sebagai tempat penyimpanan untuk Blog ini.
    
    
    Karena sampai sekarang BunnyCDN belum juga membuat layanan penyimpanan yang menggunakan protokol S3, maka saya pun menggunakan layanan dari IDCloudHost ini.

    Bagaimana pengalaman nya? Berikut adalah pengalaman saya ketika menggunakan Layanan Penyimpanan ini 🙂
---
## Daftar Isi
{{< toc >}}

## Pembuka
Setelah berbulan-bulan saya menggunakan FTP sebagai Protokol nya, kini saya menggunakan S3 sebagai Protokol Penyimpanan nya, yang tentunya untuk blog ini.

Karena sampai artikel ini ditulis, Bunny CDN masih belum merilis layanan penyimpanan yang menggunakan Protokol S3, masih menggunakan FTP hingga sekarang, akhirnya saya pindah ke IDCloudHost. 

Tentu saja saya tidak berlangganan hosting nya disana, melainkan saya hanya berlangganan "Object Storage" nya saja yang menggunakan Protokol S3.

Di Artikel ini, saya akan bahas pengalaman saya saat menggunakan menggunakan layanan ini sekaligus penggunaan nya sebagai seorang yang pertama kali menyicipi Penyimpanan yang berbasis Objek ini.

Ya Anda benar, saya sendiri baru pertama kali menggunakan layanan penyimpanan dengan protokol S3 ini. Jadi, kalau ada kesalahan pada saya, tolong koreksi saya yah, saya juga masih sangat pemula terhadap Protokol S3 ini, hihi 😁

### Saat Pendaftaran dan Berlangganan
Berbeda daripada Layanan IDCloudHost pada umumnya (seperti Domain, Hosting, VPS, _Dedicated/Colocation Server_, dll), untuk bisa berlangganan Layanan Fleksibel nya (Seperti: _Virtual Machine_/VPS yang Fleksibel, _Network Resources_, dan _Object Storage_) maka Anda perlu mendaftar akun di Konsol IDCloudHost yang beralamat: [https://console.idcloudhost.com](https://console.idcloudhost.com) terlebih dahulu.

Ya, ini bukan layanan pada umumnya yang menggunakan laman [My IDCloudHost](https://my.idcloudhost.com) untuk segala urusan layanan yang ada, dan sayangnya layanan fleksibel tadi tidak menggunakan laman ini. Dengan kata lain, Anda harus buat akun nya di Konsol IDCloudHost itu tadi agar dapat menikmati nya.

Saya daftar akun nya pada akhir Mei yang lalu dan saya melakukan pengisian ulang _(top-up)_ pada tanggal 9 Juni yang lalu, itu semua terjadi saat IDCloudHost memberikan Kredit sebesar Rp. 100.000,00 secara gratis jika saya melakukan _top-up_ yang minimalnya Rp. 50.000,00 dan saya isi ulang sebesar minimalnya saja.

Harga itu tentu saja belum termasuk PPn 10%, jadi saya bayar sebesar Rp. 55.000,00 saja untuk mengisi ulang nya. 

Metode pembayaran nya pun beragam, ada ATM Bersama, Akun Virtual _(Virtual Account)_ dari beberapa Bank, seperti Bank Permata, Mandiri, Maybank, BNI, dan CIMB Niaga (tidak ada _Virtual Account_ BCA), serta mendukung pembayaran lewat Ritel (seperti: Alfamart & Dan-dan), Pegadaian, Kantor Pos, OVO dan QRIS dari Shopee Pay selain Kartu Kredit/Debit.

Karena saya menggunakan LinkAja, maka saya pilih menggunakan Kode QRIS dari Shopee Pay, pembayarannya pun mudah, saya tinggal memindai Kode QR saja yang muncul di layar, nanti akan muncul semua biaya yang tertera. 

Setelah itu saya masukkan nomor PIN nya, dan saya klik bayar, lalu pembayaran akan diselesaikan secara otomatis tanpa harus verifikasi lagi. Sungguh mudah, bukan?

Tentu saja tidak ada biaya tambahan lain nya saat pengisian, selain pajak 10%, yang artinya saya cuma membayar sebesar Rp. 55.000,00 saja kemarin. Setelah mengisi ulang saldo, barulah secara otomatis saya mendapatkan kredit gratis sebesar Rp. 100.000,00 dan saya langsung berlangganan _Object Storage_ nya pada saat itu juga.

### Saat membuat dan 