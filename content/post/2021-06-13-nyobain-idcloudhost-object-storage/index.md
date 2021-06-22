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

Oh iya, semua Cuplikan Layar yang ditampilkan itu merupakan cuplikan layar yang terbaru, bukan pada saat saya melakukan semua nya, karena saya tidak sempat mengambil cuplikan layar pada saat itu, jadi harap maklum yah 😊

### Saat Pendaftaran dan Berlangganan
Berbeda daripada Layanan IDCloudHost pada umumnya (seperti Domain, Hosting, VPS, _Dedicated/Colocation Server_, dll), untuk bisa berlangganan Layanan Fleksibel nya (Seperti: _Virtual Machine_/VPS yang Fleksibel, _Network Resources_, dan _Object Storage_) maka Anda perlu mendaftar akun di Konsol IDCloudHost yang beralamat: [https://console.idcloudhost.com](https://console.idcloudhost.com) terlebih dahulu.

Ya, ini bukan seperti biasanya yang menggunakan laman [My IDCloudHost](https://my.idcloudhost.com) untuk segala urusan layanan yang ada dan layanan fleksibel tadi tidak menggunakan laman ini. Dengan kata lain, Anda harus buat akun nya di Konsol IDCloudHost itu tadi agar dapat menikmati nya.

![Penampilan Halaman Login Konsol IDCloudHost. Abaikan Ikon Kunci yang tampil di kotak "Email", karena itu dari Pengelola Kata Sandi yang saya gunakan, yakni "KeePassXC"](Penampilan_Login_IDCloudHost_Console.png) ![Penampilan Konsol IDCloudHost setelah Login](Penampilan_IDCloudHost_Console.png)

Saya daftar akun nya pada akhir Mei yang lalu dan saya melakukan pengisian ulang (top-up) pada tanggal 9 Juni yang lalu, itu semua terjadi saat IDCloudHost memberikan Kredit sebesar Rp. 100.000,00 secara gratis jika saya melakukan _top-up_ yang minimalnya Rp. 50.000,00 dan saya isi ulang sebesar minimalnya saja.

Harga itu tentu saja belum termasuk PPn 10%, jadi saya bayar sebesar Rp. 55.000,00 saja untuk mengisi ulang nya. 

Metode pembayaran nya pun beragam, selain Kartu Kredit (Visa/Mastercard), ada ATM Bersama, Akun Virtual (Virtual Account) dari beberapa Bank, seperti Bank Permata, Mandiri, Maybank, BNI, dan CIMB Niaga (tidak ada _Virtual Account_ BCA), serta mendukung pembayaran lewat Ritel (seperti: Alfamart & Dan-dan), Pegadaian, Kantor Pos, OVO dan QRIS dari Shopee Pay saat artikel ini saya tulis.

Karena saya menggunakan LinkAja, maka saya pilih menggunakan Kode QRIS dari Shopee Pay, pembayarannya pun mudah, saya tinggal memindai Kode QR yang muncul di layar saja, nanti akan muncul semua biaya yang tertera di LinkAja. 

Setelah itu saya klik bayar dan masukkan nomor PIN nya, lalu pembayaran akan diproses dan diselesaikan secara otomatis tanpa harus verifikasi lagi setelah saya memasukkan kode PIN nya tadi. Sungguh mudah, bukan?

![Bukti Pembayaran Isi Ulang di IDCloudHost](Bukti_Pembayaran.png) ![Bukti Pembayaran di LinkAja](Bukti_Pembayaran_LinkAja.jpg)

Tentu saja tidak ada biaya tambahan lain nya saat pengisian selain PPn 10%, yang artinya saya cuma membayar sebesar Rp. 55.000,00 saja kemarin. Setelah mengisi ulang saldo, barulah secara otomatis saya mendapatkan kredit gratis sebesar Rp. 100.000,00 dan saya langsung berlangganan _Object Storage_ nya pada saat itu juga.

### Saat pertama kali membuat Penyimpanan S3
Agar dapat menggunakan layanan penyimpanan dengan Protokol S3, maka Anda perlu membuat sebuah "wadah" yang disebut dengan "Bucket", wadah tersebut sudah jelas fungsinya, yakni untuk menyimpan Berkas dan Folder di dalam nya, namanya aja "Bucket", kalau kamu pernah ke KFC pastinya tahu apa itu "Bucket" dan perbedaan nya. 

Untuk membuat bucket nya sendiri cukup mudah, Anda tinggal klik pada "Storage" lalu klik "Create New Storage", isikan nama bucket nya, karakter nama bucket yang diizinkan yaitu: Mengandung angka, huruf kecil atau/dan tanda hubung (-). Kalau selesai, tinggal klik "Create" saja di bagian paling kanan.

Pembuatan yang mudah dan tanpa halangan, itulah yang saya alami saat membuat Bucket S3 di IDCloudHost, bucket S3 pertama yang saya buat bernama `farrelf` pada saat itu. Cuplikan di bawah ini hanyalah gambaran penampilan nya saja, karena pada saat itu tampilan nya benar-benar kosong dan belum ada satupun Bucket S3 nya saat itu.

![Penampilan saat Bucket S3 dibuat dan disebelah kiri adalah Daftar Bucket S3 yang sudah dibuat](Penampilan_saat_Bucket_S3_ingin_dibuat.png)

Setelah dibuat dan bucket tersebut dipilih, maka akan tampil sebuah informasi untuk Bucket S3 yang cukup minim, seperti pada cuplikan berikut:

![Informasi mengenai Bucket S3 yang dipilih](Penampilan_Bucket_S3_yang_dipilih.png)

Kenapa minim? Karena disitu tidak ada Informasi tentang _Endpoint_, Alamat URL Alternatif, Informasi mengenai _Region_, dan Informasi yang diperlukan lainnya, saya baru menyadari semua itu saat menggunakan nya yang saya bahas lebih lanjut lagi.

Mungkin karena "Object Storage" ini baru banget kali yah sehingga minim gitu Informasinya, semoga semakin lengkap lagi Informasi nya 😊

Awalnya saya mengira kalau "Access Key ID" dan "Secret Key Access" itu cuma berlaku di satu Bucket S3 saja, tapi saat saya membuat bucket nya lagi, saya menyadari bahwa 2 Informasi penting itu berlaku untuk semua Bucket S3 yang saya buat.

Sehingga, ketika saya mengklik Bucket yang berbeda, maka "Access Key ID" dan "Secret Key Access" akan tampil dengan nilai yang sama. Mungkin maksudnya agar dapat memudahkan pengguna nya, sehingga menampilkan Informasi dengan cara seperti itu? Siapa tahu juga alasan nya begitu, karena saya merasa dimudahkan daripada dipisah gitu 🤷‍♂️

### Saat pertama kali menggunakan Penyimpanan S3
Karena di IDCloudHost belum ada fitur yang berguna untuk mengelola sekaligus menjelajah Berkas dan Folder di dalam Bucket, maka saya harus meng-install Aplikasi tambahan agar dapat mengelola nya.

Kalau di Windows itu ada sebuah Perangkat Lunak yang bernama ["Cyberduck"](https://cyberduck.io/), berfungsi sebagai pengelola berkas dari jarak jauh dan mendukung protokol S3 juga, serta merupakan FLOSS (Free/Libre Open Source Software).

![Penampilan Cyberduck di Windows 10](Penampilan_Cyberduck.png)

Pada saat menggunakan Cyberduck dan saya klik kanan pada salah satu objek/berkas, lalu saya arahkan kursor nya ke "Copy URL", di situlah saya langsung menyadari kalau Bucket S3 itu bisa diakses melalui URL Alternatif, yaitu `https://nama-bucket.is3.cloudhost.id` dan sayangnya di Panel/Konsol nya belum ada Informasi seperti itu, padahal menurut saya lebih enak cara mengakses seperti ini, lebih bersih aja daripada `https://is3.cloudhost.id/nama-bucket`.

Lalu, bagaimana dengan GNU/Linux atau Android? Hmmm, di GNU/Linux saya harus me-_mounting_ Bucket S3 nya secara manual menggunakan `s3fs` agar bisa mengelola Berkas-berkas didalam nya (itupun sampai sekarang belum bisa), kalau di Android saya kurang tahu, ada sebuah Aplikasi yang tersebar di Play Store untuk ini, tapi rasanya saya kurang percaya aja mengingat perangkat lunak tersebut tak terurus sejak lama dan itu bukanlah termasuk FLOSS.

Jadi, untuk sekarang saya belum bisa mengelola Berkas dan Folder yang di dalam Bucket S3 itu di Sistem Operasi selain Windows.

Karena rencananya saya gunakan Bucket S3 itu sebagai tempat untuk menyimpan Berkas-berkas Blog Statis, maka saya membutuhkan fitur sinkronisasi dan itu bisa dilakukan dengan [Rclone](https://rclone.org/). 

Saat menggunakan Rclone, disitu saya langsung menyadari pengaturan perizinan pada Bucket S3 (Permissions) dan ada fitur ACL (Access control list) disitu, karena saya ingin menggunakan nya sebagai Hosting Web Statis, maka saya atur ACL nya menjadi `Public-Read` di Rclone.

### Saat mencoba fitur Hosting Web Statis di S3
Tentu saja saya tidak jadikan ini sebagai Hosting Utama, melainkan sebagai tempat penyimpanan untuk Blog ini dan akan disebar melalui CDN yang saya gunakan (Bunny\.net).

Saya cuma mencoba fitur Hosting Web Statis di IDCloudHost S3 saja, karena di [AWS S3](https://aws.amazon.com/id/s3/) dan [Scaleway Object Storage](https://www.scaleway.com/en/object-storage/) ada fitur seperti ini. 

Pada dasarnya, fungsinya cuma agar supaya Penyimpanan S3 ini bisa membaca berkas Indeks seperti `index.html` saja ketika diakses dan tentunya ini sangat berguna untuk Hosting Web Statis.

Nah, saya butuh fitur ini agar supaya mempermudah saya untuk meng-hostingkan Blog ini dengan CDN tanpa perlu melakukan penyetelan/pengaturan yang tidak perlu, seperti mengatur "Edge Rules" agar berkas Indeks bisa terbaca.

Karena secara bawaan _(default)_ fitur tersebut tidak diaktifkan, maka saya berinisiatif untuk mengaktifkan nya. Akhirnya saya gunakanlah [referensi dari Scaleway](https://www.scaleway.com/en/docs/s3-bucket-website/) dan disana saya diperkenalkan serta disarankan untuk menggunakan AWS CLI, ya saya pakelah Perangkat Lunak tersebut.

Setelah saya membuat `bucket-website.json` (sesuai Referensi) dan mengeksekusi perintah berikut 

```
$ aws s3api put-bucket-website --bucket <NAMA_BUCKET> --website-configuration file://bucket-website.json
```

Malah muncul kesalahan (error) dengan pesan berikut:
```
An error occurred (MethodNotAllowed) when calling the PutBucketWebsite operation: Unknown
```

Ya langsung bingung dong, masa gak boleh sih cuma Hosting Web Statis doang biar bisa disebar melalui CDN dengan mudah. Akhirnya saya coba cara lain, seperti merubah nama berkas, menggunakan `s3cmd`. bahkan sampai menggunakan Cyberduck pun juga sama aja.

Akhirnya, ketika ingin meng-hosting Blog ini dan disebar melalui CDN seperti sekarang, saya malah perlu menyetel "Edge Rule" nya terlebih dahulu agar berkas `index.html` bisa terbaca sampai sekarang.

Setelah itu, saya sinkronkan secara manual dengan menggunakan Rclone. Iya, saat ini, blog ini saya hosting di Penyimpanan S3 nya, kemudian disebar dengan CDN, sehingga pengunjung tidak mengakses Bucket S3 nya, melainkan CDN nya.
