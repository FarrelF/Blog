---
Title: Nyobain Object Storage dari IDCloudHost (IS3)
Slug: nyobain-object-storage-dari-idcloudhost
Aliases:
    - /is3/
    - /idcloudhost-s3/
    - /idcloudhost-object-storage/
    - /nyobain-idcloudhost-object-storage/
    - /nyobain-idcloudhost-object-storage-is3/
    - /nyobain-penyimpanan-s3-dari-idcloudhost/
    - /nyobain-penyimpanan-s3-dari-idcloudhost-is3/
    - /nyobain-s3-dari-idcloudhost/
    - /nyobain-object-storage-s3-dari-idcloudhost/
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Opini
    - Info Blog
Date: 2021-06-25 20:18:00+07:00
Tags: 
    - Preview
    - IDCloudHost
    - IS3
    - Penyimpanan S3
    - Penyimpanan berbasis Objek
readMore: true
Image: IDCloudHost_Logo.jpg
DescriptionSEO: Blog ini pernah menggunakan IDCloudHost Object Storage, bagaimana pengalamannya? Silakan baca artikel ini!
Description: |-
    Beberapa bulan kemarin, saya sudah berencana kalau saya akan menggunakan penyimpanan yang menggunakan protokol S3 ini sebagai tempat penyimpanan untuk blog statis ini.

    Karena sampai sekarang Bunny\.net belum juga membuat layanan penyimpanan yang menggunakan protokol S3-nya, maka saya pun menggunakan layanan dari IDCloudHost ini.

    Bagaimana pengalamannya? Silakan baca lebih lanjut artikel ini jika Anda ingin mengetahuinya 🙂
---

## Pembuka
Setelah berbulan-bulan saya menggunakan FTP sebagai protokolnya untuk blog ini, kini saatnya saya beralih ke protokol S3 sebagai protokol penyimpanannya. Sehingga jika saya ingin menggunakannya, tentunya saya harus pindah penyedia penyimpanan.

Karena sampai artikel ini ditulis, Bunny CDN masih belum menyediakan layanan penyimpanan yang menggunakan protokol S3, masih menggunakan FTP hingga sekarang, hingga akhirnya saya pindah ke IDCloudHost.

Tentu saja saya tidak berlangganan hostingnya di sana, melainkan saya hanya berlangganan layanan _Object Storage_-nya saja.

Di Artikel ini, saya akan bahas pengalaman saya saat menggunakan menggunakan layanan ini sekaligus penggunaannya sebagai seorang yang pertama kali menyicipi Penyimpanan yang berbasis Objek ini.

Ya Anda benar, saya sendiri baru pertama kali menggunakan layanan penyimpanan dengan protokol S3 ini. Jadi, kalau ada kesalahan pada saya, tolong koreksi saya yah, saya juga masih sangat pemula terhadap protokol ini, hihi 😁

Oh iya, semua cuplikan layar yang ditampilkan itu merupakan cuplikan layar yang terbaru, bukan pada saat saya melakukan semuanya, karena saya tidak sempat mengambil cuplikan layar pada saat itu, jadi harap maklum yah 😊

## Pengalaman _Object Storage_ di IDCloudHost

### Saat pertama kali mengetahuinya
Saya mengetahui layanan ini dari Tweet Bapak Achmad Zaky berikut, yang merupakan Pendiri sekaligus mantan CEO Bukalapak (yang sekarang merupakan Pendiri dari "Init 6")

{{< x user="achmadzaky" id="1394999284722933762" >}}

{{< x user="achmadzaky" id="1394990971990036487" >}}

Entahlah Tweet yang mana, tetapi yang jelas saya tahu ini dari Tweet-nya beliau yang dikutip oleh Bapak Teguh Aprianto.

Sontak hal itu membuat saya langsung mengunjungi situs web resminya IDCloudHost dan melihat-lihat apa saja produk-produk atau layanannya dan ternyata di sana ada produk/layanan penyimpanan berbasis objek yang bernama IS3 (IDCloudHost S3).

Harga yang ditawarkan sangat murah, yakni cuma sebesar Rp507,00 per GB per Bulan saja, bahkan lebih murah daripada layanan _object storage_ dari Indonesia lainnya yang pernah saya temui, seperti: [Biznet NEO Object Storage](https://www.biznetgio.com/product/neo-object-storage) dan [Kilat Storage](https://www.cloudkilat.com/layanan/kilat-storage).

Tentu saja biaya tersebut tidak termasuk biaya per _Request_ yang dilakukan, _Bandwidth_ keluar/masuk, dan biaya-biaya lainnya, karena biaya-biaya tersebut memang tidak ada di sana.

Karena harga yang murah serta bonus saldo sebesar Rp100.000,00 setelah melakukan isi ulang, hal itu membuat saya ingin mencoba layanan Penyimpanan berbasis Objek beberapa hari setelah saya mengunjunginya.

### Saat Pendaftaran dan Berlangganan
Berbeda daripada Layanan IDCloudHost pada umumnya (seperti Domain, Hosting, VPS, _Dedicated/Colocation Server_, dll), untuk bisa berlangganan layanan fleksibelnya (Seperti: _Virtual Machine_/VPS yang fleksibel, _Network Resources_, dan _Object Storage_) maka Anda perlu mendaftar akun di Konsol IDCloudHost yang beralamat: [https://console.idcloudhost.com](https://console.idcloudhost.com) terlebih dahulu.

Ya, ini bukan seperti biasanya yang menggunakan laman [My IDCloudHost](https://my.idcloudhost.com) untuk segala urusan layanan yang ada dan layanan fleksibel tadi tidak menggunakan laman ini. Dengan kata lain, Anda harus buat akunnya di Konsol IDCloudHost itu tadi agar dapat menikmatinya.

![Penampilan Halaman Login Konsol IDCloudHost. Abaikan Ikon Kunci yang tampil di kotak "Email", karena itu dari Pengelola Kata Sandi yang saya gunakan, yakni "KeePassXC"](Penampilan_Login_IDCloudHost_Console.jpg) ![Penampilan Konsol IDCloudHost setelah Login](Penampilan_IDCloudHost_Console.jpg)

Saya daftar akunnya pada akhir Mei yang lalu dan saya melakukan pengisian ulang (top-up) pada tanggal 9 Juni yang lalu, itu semua terjadi saat IDCloudHost memberikan Kredit sebesar Rp100.000,00 secara gratis jika saya melakukan _top-up_ yang minimalnya Rp50.000,00 dan saya isi ulang sebesar minimalnya saja.

Harga itu tentu saja belum termasuk PPn 10%, jadi saya bayar sebesar Rp55.000,00 saja untuk mengisi ulangnya.

Metode pembayarannya pun beragam, selain Kartu Kredit (Visa/Mastercard), ada ATM Bersama, Akun Virtual (Virtual Account) dari beberapa Bank, seperti Bank Permata, Mandiri, Maybank, BNI, dan CIMB Niaga (tidak ada _Virtual Account_ BCA), serta mendukung pembayaran lewat Ritel (seperti: Alfamart & Dan-dan), Pegadaian, Kantor Pos, OVO dan QRIS dari Shopee Pay saat artikel ini saya tulis.

Karena saya menggunakan LinkAja, maka saya pilih menggunakan Kode QRIS dari "Shopee Pay", pembayarannya pun mudah, saya tinggal memindai Kode QR yang muncul di layar saja, nanti akan muncul semua biaya yang tertera di LinkAja.

Setelah itu saya klik bayar dan masukkan nomor PIN-nya, lalu pembayaran akan diproses dan diselesaikan secara otomatis tanpa harus verifikasi lagi setelah saya memasukkan kode PIN-nya tadi. Sungguh mudah, bukan?

![Bukti Pembayaran Isi Ulang di IDCloudHost](Bukti_Pembayaran.jpg) ![Bukti Pembayaran di LinkAja](Bukti_Pembayaran_LinkAja.jpg)

Tentu saja tidak ada biaya tambahan lainnya saat pengisian selain PPn 10%, yang artinya saya cuma membayar sebesar Rp55.000,00 saja kemarin. Setelah mengisi ulang saldo, barulah secara otomatis saya mendapatkan kredit gratis sebesar Rp100.000,00 dan saya langsung berlangganan _Object Storage_-nya pada saat itu juga.

### Saat pertama kali membuat Bucket untuk _Object Storage_
Agar dapat menggunakan layanan penyimpanan dengan Protokol S3 atau _Object Storage_, maka Anda perlu membuat sebuah "wadah" yang disebut dengan "Bucket".

Wadah tersebut sudah jelas fungsinya, yakni untuk menyimpan berkas dan folder di dalamnya, namanya aja "Bucket", kalau kamu pernah ke KFC atau ke restoran ayam cepat saji lainnya, pastinya kamu tahu apa itu "Bucket" dan perbedaannya.

Untuk membuat bucket-nya sendiri cukup mudah, Anda tinggal klik pada "Storage" lalu klik "Create New Storage", isikan nama bucket-nya, karakter nama bucket yang diizinkan yaitu: Mengandung angka, huruf kecil atau/dan tanda hubung (-). Kalau selesai, tinggal klik "Create" saja di bagian paling kanan.

Pembuatan yang mudah dan tanpa halangan, itulah yang saya alami saat membuat Bucket S3 di IDCloudHost, bucket S3 pertama yang saya buat bernama `farrelf` pada saat itu. Cuplikan di bawah ini hanyalah gambaran penampilannya saja, karena pada saat itu tampilannya benar-benar kosong dan belum ada satupun bucket S3-nya saat itu.

![Penampilan saat Bucket S3 dibuat dan disebelah kiri adalah Daftar Bucket S3 yang sudah dibuat](Penampilan_saat_Bucket_S3_ingin_dibuat.jpg)

Setelah dibuat dan bucket tersebut dipilih, maka akan tampil sebuah informasi untuk Bucket S3 yang cukup minim, seperti pada cuplikan berikut:

![Informasi mengenai Bucket S3 yang dipilih](Penampilan_Bucket_S3_yang_dipilih.jpg)

Kenapa minim? Karena di situ tidak ada informasi tentang _Endpoint_, Alamat URL Alternatif, _Region_, dan informasi yang diperlukan lainnya, saya baru menyadari semua itu saat menggunakannya yang saya bahas lebih lanjut lagi.

Mungkin karena "Object Storage" ini baru banget kali yah sehingga minim gitu informasinya, semoga semakin lengkap lagi informasinya 😊

Awalnya saya mengira kalau **Access Key ID** dan **Secret Key Access** itu cuma berlaku di satu Bucket S3 saja, tetapi saat saya membuat bucket-nya lagi, saya menyadari bahwa 2 informasi penting itu berlaku untuk semua Bucket S3 yang saya buat.

Sehingga, ketika saya mengklik Bucket yang berbeda, maka **Access Key ID** dan **Secret Key Access** akan tampil dengan nilai yang sama. Mungkin maksudnya agar dapat memudahkan penggunanya, sehingga menampilkan informasi dengan cara seperti itu? Siapa tahu juga alasannya begitu, karena saya merasa dimudahkan daripada dipisah gitu 🤷‍♂️

### Saat pertama kali menggunakan _Object Storage_
Karena di IDCloudHost belum ada fitur yang berguna untuk mengelola sekaligus menjelajah Berkas dan Folder di dalam Bucket, maka saya harus meng-install Aplikasi tambahan agar dapat mengelolanya.

Kalau di Windows itu ada sebuah Perangkat Lunak yang bernama ["Cyberduck"](https://cyberduck.io/), berfungsi sebagai pengelola berkas dari jarak jauh dan mendukung protokol S3 juga, serta merupakan FLOSS (Free/Libre Open Source Software). Saya tahu ini dari [halaman dokumentasinya](https://idcloudhost.com/panduan/cara-akses-object-storage-idcloudhost-menggunakan-cyberduck/).

![Penampilan Cyberduck di Windows 10](Penampilan_Cyberduck.jpg)

Pada saat menggunakan Cyberduck dan saya klik kanan pada salah satu objek/berkas, lalu saya arahkan kursornya ke "Copy URL", di situlah saya langsung menyadari kalau Bucket S3 itu bisa diakses melalui URL Alternatif, yaitu `https://nama-bucket.is3.cloudhost.id` dan sayangnya di panel/konsolnya belum ada informasi seperti itu, padahal menurut saya lebih enak cara mengakses seperti ini, lebih bersih aja daripada `https://is3.cloudhost.id/nama-bucket`.

Lalu, bagaimana dengan GNU/Linux atau Android? Hmmm, di GNU/Linux saya harus _me-mounting_ Bucket S3-nya secara manual menggunakan `s3fs` agar bisa mengelola Berkas-berkas di dalamnya (itu pun sampai sekarang belum bisa).

Kalau di Android saya kurang tahu, ada sebuah Aplikasi yang tersebar di Play Store untuk ini, tetapi rasanya saya kurang percaya aja mengingat perangkat lunak tersebut tak terurus sejak lama dan itu bukanlah termasuk FLOSS.

Jadi, untuk sekarang saya belum bisa mengelola Berkas dan Folder yang di dalam Bucket S3 itu di Sistem Operasi selain Windows.

Karena rencananya saya gunakan Bucket S3 itu sebagai tempat untuk menyimpan Berkas-berkas Blog Statis, maka saya membutuhkan cuma membutuhkan fitur sinkronisasi dan itu semua bisa dilakukan dengan [Rclone](https://rclone.org/). 

Saat menggunakan Rclone, disitu saya langsung menyadari pengaturan perizinan pada Bucket S3 (Permissions) dan ada fitur ACL (Access control list) disitu, karena saya ingin menggunakan nya sebagai Hosting Web Statis, maka saya atur ACL nya menjadi `Public-Read` di Rclone.

Oh iya, seiring penggunaan, saya baru menyadari kalau ternyata IDCloudHost itu menggunakan _Platform_ dari [Warren.io](https://warren.io/id) untuk Layanan Fleksibelnya. Yah tidak masalah sih, yang penting kedepan nya bisa lebih berkembang lagi daripada lainnya yang menggunakan _Platform_ yang sama.

### Saat mencoba fitur Hosting Web Statis di S3
Saya gunakan _Object Storage_ dari IDCloudHost sebagai Hosting untuk Blog Statis ini, sedangkan saya gunakan Bunny CDN sebagai _Reverse-proxy_, _TLS termination proxy_ (atau bisa disebut dengan "SSL offloading" atau "SSL termination") dan juga CDN (kependekan dari _Content Delivery Network_).

Dengan alasan itu, saya mencoba fitur Hosting Web Statis yang seharusnya itu merupakan fitur [AWS S3](https://aws.amazon.com/id/s3/) di IDCloudHost S3, karena di [Scaleway Object Storage](https://www.scaleway.com/en/object-storage/) ada fitur seperti ini juga.

Pada dasarnya, fungsinya agar supaya _Object Storage_ ini dapat membaca berkas indeks seperti `index.html` saja ketika diakses tanpa harus menuliskan `index.html` lagi di alamat URL pada peramban web dan tentunya ini akan sangat berguna untuk Hosting Web Statis.

Nah, saya butuh fitur ini agar supaya mempermudah saya untuk mengatur _Reverse-proxy_ CDN ini tanpa perlu melakukan penyetelan/pengaturan yang tidak perlu, seperti mengatur "Edge Rules" agar berkas indeks dapat terbaca.

Karena secara bawaan _(default)_ fitur tersebut tidak diaktifkan, maka saya berinisiatif untuk mengaktifkannya. Akhirnya saya gunakanlah [referensi dari Scaleway](https://www.scaleway.com/en/docs/s3-bucket-website/) dan di sana saya diperkenalkan serta disarankan untuk menggunakan AWS CLI, ya saya pakailah perangkat lunak tersebut.

Setelah saya membuat berkas `bucket-website.json` (sesuai Referensi) dan mengeksekusi perintah berikut:

```bash
$ aws s3api put-bucket-website --bucket <NAMA_BUCKET> --website-configuration file://bucket-website.json
```

Malah muncul kesalahan (error) dengan pesan berikut:

```plain
An error occurred (MethodNotAllowed) when calling the PutBucketWebsite operation: Unknown
```

Ya langsung bingung dong, masa gak boleh sih cuma pake fitur ini doang biar bisa saya bisa menyetel CDN-nya dengan mudah. Akhirnya saya coba cara lain, seperti mengubah nama berkas, menggunakan `s3cmd`, bahkan sampai menggunakan Cyberduck pun juga sama aja hasilnya.

Akhirnya, ketika saya ingin menggunakan Bunny CDN sebagai _Reverse-proxy_ untuk Blog ini seperti sekarang, saya malah harus menyetel "Edge Rule"-nya terlebih dahulu agar berkas `index.html` bisa terbaca dengan baik.

Setelah itu, saya sinkronkan secara manual dengan menggunakan Rclone. Seperti yang saya bilang diawal, bahwa blog ini saya hosting di _Object Storage_-nya dan saya gunakan Bunny CDN sebagai _Reverse-proxy_, _TLS termination proxy_ dan juga CDN, sehingga pengunjung tidak mengakses Bucket S3-nya, melainkan CDNnya.

Saat saya menghubungi dan membuat tiket dukungannya (Support Ticket), mereka bilang kalau saat ini belum ada fitur Hosting Web Statis di Bucket S3, sedang dalam pengembangan katanya.

Jadi, harus sabar menunggu kalau kamu butuh banget sama fiturnya, tetapi kalo kamu bisa menyiasatinya (kayak saya), ya gas ajalah kalo pengen, hehe 😀

**PEMBARUAN Rabu, 07 Juli 2021:** Sekarang saya tidak lagi menggunakan IDCloudHost sebagai Hosting, melainkan [Storj DCS (Decentralized Cloud Storage)](https://www.storj.io), jadi saya tidak mengalami hal di atas lagi sejak saat itu.

### Saat menghapus Bucket S3
Karena suatu alasan, maka saya berinisiatif mencoba untuk menghapus sebuah Bucket S3 dari laman Panelnya. Bucket S3 tersebut bernama `farrelf`.

Ada konfirmasi yang muncul sebelum menghapusnya, setelah itu, bucket S3 tersebut hilang dari panel. Namun, saat saya buat lagi dengan nama yang sama, malah muncul kalau Bucket tersebut sudah ada, padahal sudah saya hapus dan di panel sudah tidak ada bucket tersebut.

![Kira-kira, pesan kesalahannya seperti ini](Penampilan_Error_saat_membuat_Bucket_S3_farrelf.jpg)

Setelah saya akses bucket-nya melalui peramban web, masih bisa diakses dong, dengan menampilkan pesan `AccessDenied`, lalu saya tambahkan salah satu nama file yang ingin diakses pada URL nya, seperti `index.html` dan benar saja bahwa file tersebut masih bisa diakses, itu tandanya kalau Bucket tersebut benar-benar masih ada.

Kalau sudah terhapus, seharusnya cuma nampil `NoSuchBucket` saat diakses lewat peramban web dan bucket sudah tidak bisa diakses sama sekali dengan cara apa pun, sehingga sudah seharusnya dapat dibuat lagi dengan nama yang sama, ini tidak.

Namun pas saya coba mengaksesnya lewat AWS CLI untuk mencoba menghapus Bucket S3-nya, saya malah tidak dapat mengaksesnya.

Karena Bucket tersebut tidak benar-benar terhapus, maka saya buat bucket S3 lagi yang bernama `farrelfstaticblog` untuk menyimpan blog statis dan saya gunakan sebelum artikel ini terbit.

Setelah menghubungi dan membuat tiket dukungannya (Support Ticket), kata mereka kalau penghapusan bucket S3 lewat panel itu tidak dilakukan secara _realtime_, melainkan secara terjadwal, sehingga saya harus menunggu beberapa hari agar bucket S3 tersebut benar-benar terhapus.

Setelah beberapa hari (kira-kira selama 4-5 hari), bucket tersebut akhirnya terhapus juga dan saya bisa membuat bucket itu lagi dengan nama `farrelf`. Lho, kok bisa sampe 4-5 harian? Nanti akan saya bahas lebih lanjut.

Selang beberapa waktu setelahnya, saya mencoba menghapus Bucket S3 melalui AWS CLI dan `s3cmd`, malah bucket tersebut bisa terhapus secara _realtime_ dan di panel pun juga bucket tersebut hilang, bahkan saya hapus bucket S3 melalui Cyberduck juga bisa.

Untuk buktinya, Anda bisa lihat/tonton video berikut:

{{< bunny-stream id="a917f4c0-a553-4e77-8154-257881fb1418" lazyload=true allowfullscreen=true >}}

Hal ini lantas membuat saya berpikir:

> Lha kalo tahu gitu, ngapain 4-5 hari kemarin saya hapus melalui panelnya yah?

Mungkin karena saat itu saya masih baru banget terhadap Penyimpanan yang menggunakan protokol S3 ini, jadi ya saya belum tahu banyak.

Jadi jika Anda kebetulan berlangganan S3 dari IDCloudHost dan Anda ingin menghapus salah satu bucket dengan alasan apa pun, saran saya jangan hapus bucket S3 dari halaman panelnya jika Anda ingin membuatnya lagi.

### Saat menghubungi dukungan layanan
Alasan saya menghubungi dukungan layanan adalah karena masalah fitur Hosting Web Statis di S3, Penghapusan Bucket S3 dan fitur CNAME. Inti dari dukungan layanan (salah satunya melalui Tiket Dukungan/_Support Ticket_) selain fitur Hosting Web Statis adalah tentang penghapusan Bucket S3 yang gak _realtime_ itu.

Fitur CNAME belum saya butuhkan, karena pada dasarnya saya tidak mungkin Hosting langsung di sana.

Namun sebelum saya menghubungi Dukungan Layanan, seperti biasa, saya baca-baca terlebih dahulu [Dokumentasi nya](https://idcloudhost.com/panduan-kategori/object-storage/), siapa tahu kalo ada Informasi yang menjawab pertanyaan-pertanyaan saya di sana.

Namun ternyata, dokumentasi nya belumlah lengkap, hingga artikel ini diterbitkan, dokumentasi di sana cuma membahas kasus yang sebatas cara membuat Bucket S3, mengakses Bucket S3, _Mounting_ Bucket S3 dan integrasi ke WordPress saja.

Pada akhirnya, saya gunakanlah fasilitas "Live Chat" nya terlebih dahulu, karena di panel gak ada halaman untuk menggunakan tiket dukungan dan di sana saya hanya disarankan untuk menggunakan fasilitas "Live Chat"-nya, maka saya gunakanlah itu terlebih dahulu.

Namun, Live Chat tidak memberikan jawaban yang berarti selama seharian dan bahkan saya disuruh untuk membuat tiket dukungan, karena hal itu, maka dengan terpaksa saya membuat Tiket Dukungan di laman ["My IDCloudHost"](https://my.idcloudhost.com)nya.

Jika Anda ingin melihat percakapan nya seperti apa di tiket dukungan, silakan Anda lihat cuplikan layar mengenai transkrip percapakan berikut:

**Catatan:** Saya sarankan untuk perbesar cuplikan nya dengan mengklik gambarnya dan gambar yang saya sisipkan bersifat urut berdasarkan angka yang tampil di keterangan gambar/_caption_.

![1](Ticket_1.jpg) ![2](Ticket_2.jpg) ![3](Ticket_3.jpg) ![4](Ticket_4.jpg) ![5](Ticket_5.jpg) ![6](Ticket_6.jpg)

Jika Anda ingin melihat Cuplikan Transkrip nya secara utuh, silakan {{< a-file path="Transkrip_Obrolan_lewat_Tiket_Dukungan.jpg" >}}klik di sini{{< / a-file >}} (Ukuran berkasnya sebesar 380 KB dan resolusinya sebesar 842x5254).

Bagaimana menurutmu mengenai tiket dukungan ini? Kalau menurut saya, respon mereka terlalu lambat dan mereka terlalu sering "melempar" pesan ke "tim terkait", mungkin saja mereka ini adalah beda tim divisi atau apalah saya juga gak tahu.

Atau, mungkin karena saya diawal tidak memberikan cuplikan layar sebagai lampiran diawal, jadi mereka seperti gak paham detailnya seperti apa.

Namun yang jelas, respon mereka sangatlah lambat, kadang seringkali seharian baru bales tiket/pertanyaan saya, untungnya saat itu saya bersabar untuk menunggu dan terus mantengin tiketnya, serta saya saat itu tidak terlalu ada urgensi agar permasalahan nya cepat selesai.

Selama 4-5 harian, barulah kasusnya terselesaikan dan akhirnya bucket nya benar-benar terhapus, sehingga saya bisa lagi membuat bucket S3 dengan nama yang sama seperti sebelumnya.

### PEMBARUAN 12/02/2022: Saat mengalami gangguan {#saat-mengalami-gangguan}
Sebetulnya gangguan itu sendiri sudah sangat lama, sekitar 7 bulanan kurang lebih, hanya saja saya baru memperbaruinya sekarang.

Saat menggunakannya, saya pernah mengalami gangguan yang membuat blog saya menjadi tidak bisa diakses, yakni mengalami galat "503 Service Unavailable".

Saat saya sadar bahwa blognya mengalami galat seperti itu, awalnya saya mengira bahwa CDN-lah yang menjadi penyebabnya, tetapi setelah saya akses bucket S3-nya, ternyata terkena galat 503 juga.

Ini artinya, penyebab dari masalah tersebut adalah dari bucket S3-nya yang mengalami gangguan, bukan layanan CDN-nya (entah pada jaringan mereka atau server mereka, saya gak ngerti).

Di bawah ini adalah penampakannya:

![Penampakan Galat pada Bucket S3 saya](Penampilan_Error_503_Service_Unavailable.png)

Saya sudah mengecek blog dan bucket S3 saya ke beberapa situs web yang menguji ketersediaan dari sebuah situs web (seperti [Uptrends](https://www.uptrends.com/tools/uptime)), dan ternyata mengalami galat yang sama juga, jadi ini jelas bukan dari ISP yang saya gunakan.

Maaf apabila saya tidak bisa memberikan cuplikan layarnya di sini, sehingga buktinya kurang lengkap, karena pada saat itu saya tidak sempat mengambil cuplikannya.

Sejak saat itu, saya langsung membuat tiket dukungan, tetapi balasnya lama sekali. Saya memulai itu dari sekitar pukul 18:06 WIB dan setengah jam kemudian gak ada jawaban.

Karena gak ada jawaban apa pun, maka saya menanyakan kenapa tiketnya tidak dibalas. Setengah jam lagi kemudian setelah saya menanyakannya, akhirnya tiket tersebut baru dijawab, tetapi sayangnya masalah tersebut masih belum selesai, "sedang dilakukan pengecekan oleh team kami" katanya.

Jika Anda ingin melihat percakapannya, silakan lihat cuplikan berikut dan klik pada cuplikannya untuk memperbesar:

![Transkrip Percakapan lewat Tiket Dukungan saat mengalami gangguan](Transkrip_Obrolan_lewat_Tiket_Dukungan_saat_Gangguan.png)

Karena penyelesaian masalahnya yang lambat, maka saya pindahkan dulu Hosting-nya untuk sementara memakai Netlify, untung saja saya memiliki cadangannya.

Setelah itu saya langsung mencari layanan penyimpanan S3 atau _Object Storage_ yang lain, tentunya kalau bisa yang gratis dan gak perlu kartu kredit buat verifikasi. Saat mencari, ketemulah [Storj DCS](https://www.storj.io) yang selain gratis dan memiliki S3-compatible pada layanan penyimpanannya, ia juga tidak memerlukan kartu kredit atau debit untuk bisa digunakan.

Meskipun penyetelannya sulit (atau bisa Anda bilang "sangat sulit"), tetapi saya tetap memindahkan blog statis saya dari IS3 ke Storj DCS. Jadi, saya langsung pindah dari IDCloudHost S3 pada saat itu juga.

Beberapa jam kemudian, sampai jam 9 malam, saya melihat bahwa masalah tersebut sebenarnya sudah selesai setelah saya mengakses bucket S3-nya, hanya saja si CS belum memberitahukan apa pun kepada saya, saya pikir itu belum selesai sepenuhnya, jadi saya tunggu besok saja.

Keesokkan harinya, si CS belum juga membalas ataupun merespon tiketnya sama sekali dan masalah sepertinya sudah teratasi sepenuhnya, jadi saya tutup saja tiketnya secara manual.

## Kesimpulan
Apakah Layanan ini disarankan? Jika Anda adalah orang yang pemula banget sama Protokol S3 ini dan sangat ingin belajar, maka untuk saat ini saya belum terlalu bisa menyarankan ini.

Kenapa? Karena dokumentasinya sangat belum lengkap dan belum tentu juga semua API Penyimpanan S3 dari AWS akan didukung oleh Penyimpanan S3 dari IDCloudHost, yah namanya juga "S3-compatible".

Belum lagi masalah penghapusan Bucket S3 melalui Panel yang tidak dilakukan secara _realtime_, melainkan secara terjadwal, kecuali jika Anda tahu bagaimana cara menghapus bucket S3-nya secara _realtime_.

Saya lebih menyarankan Anda untuk belajar menggunakan S3 dari AWS-nya secara langsung untuk saat ini, di sana dokumentasinya sangatlah lengkap dan komprehensif, sehingga apa yang Anda eksekusikan di sana maka akan sesuai dengan apa yang Anda pelajari di sana.

Namun jika Anda ingin belajar dengan menggunakan S3 dari IDCloudHost, ya silakan dicoba sendiri.

### Untuk Hosting Web Statis
Untuk Hosting Web Statis, saya belum terlalu sarankan juga karena fiturnya memang belum ada hingga saat ini, sehingga berkas `index.html` tidak terbaca dengan baik, kecuali jika kamu sanggup mengakali nya saat menggunakan CDN (seperti yang saya lakukan) atau kamu rela kalau ada `index.html` di URL setiap mengakses Blog/Web kamu, ya bolehlah dicoba.

Selain itu, di sana tidak ada fitur CNAME, jadi jika Anda ingin meng-hosting web statis Anda ke dalam bucket S3, maka Anda harus mempunyai/menyewa sebuah layanan CDN terlebih dahulu, paling murah bisa gunakan [Bunny CDN*](https://afiliasi.farrelf.blog/bunny/cdn/).

**NB:** Pada praktik terbaiknya, Anda tetap harus menggunakan layanan CDN sih, karena pada dasarnya penyimpanan berbasis objek memang tidak didesain untuk digunakan sebagai hosting sekaligus pengantaran konten. Namun, jika Anda hanya ingin mengantarkan konten ke sesama orang Indonesia, mungkin ini bisa dicoba.

{{< spoiler title="**\*Catatan mengenai tautan diatas**" >}}
Tautan diatas merupakan tautan afiliasi, jika Anda mendaftar dan membayar sebuah layanan melalui tautan tersebut, maka Anda telah memberikan dukungan terhadap saya agar saya lebih bersemangat dalam menulis artikel, karena menulis itu menguras tenaga, pikiran dan waktu.

Tenang saja, Anda tidak akan terkena biaya tambahan apa pun karena afiliasi ini, saya jamin 100%.
{{< / spoiler >}}

Menggunakan Cloudflare Gratisan? Mungkin bisa Anda coba, tetapi yang jelas itu perlu mengkaitkan terlebih dahulu domainnya dengan CNAME ke Bucket S3-nya dan mungkin perlu mengaktifkan proksinya (dengan mengubahnya menjadi awan oranye).

### Untuk kebutuhan lain
Bagaimana jika saya butuhnya cuma integrasi ke WordPress, Backup Data, atau simpan data saja atau lainnya?

Yah, jika Anda tidak terlalu butuh _Support_/dukungan layanan atau jika Anda tidak masalah dengan Penghapusan Bucket S3-nya, saya bisa menyarankan Anda untuk menggunakan nya, terlepas dari kekurangan yang telah saya sampaikan sebelumnya.

Kenapa? Karena mereka menggunakan Server Indonesia (yang pasti sangat cepat jika diakses dari Indonesia), biaya yang fleksibel, harga yang sangat murah untuk per GB nya, pembayaran yang mudah dan beragam, serta tidak terkendala Bahasa saat berkomunikasi dengan dukungan layanannya.

~~Jika Anda mengisi ulang saldo Anda dari sekarang (minimal sebesar Rp50.000,00), maka Anda akan mendapatkan bonus saldo sebesar Rp100.000,00, promo tersebut ada sampai tanggal 30 Juni 2021. (Kalau tidak salah)~~

**PEMBARUAN Sabtu, 15 April 2023:** Setelah 30 Juni 2021 kemarin, promo tersebut sudah tidak ada, tetapi sebagai gantinya Anda dapat gunakan kode `m9z6qf` untuk mendapatkan bonus saldo sebesar Rp25.000,00 setelah pertama kalinya Anda mengisi saldo di Console IDCloudHost atau silakan [klik di sini](https://console.idcloudhost.com/referral/m9z6qf) jika Anda belum pernah mendaftar Console IDCloudHost sama sekali

Jadi, jika Anda ingin menggunakan _Object Storage_ dari IDCloudHost ini, saya sarankan mulai saja dari sekarang.

## Pertanyaan yang (mungkin) sering ditanyakan
### Pertanyaan ke-1: Dimanakah Server _Object Storage_ IDCloudHost? {#pertanyaan-ke1}
**Jawab:** Ada di DKI Jakarta, Indonesia. Saya tidak tahu di mana persisnya, jika Anda sangat ingin tahu letak servernya, mungkin bisa Anda tanyakan sendiri ke pihak IDCloudHostnya.

### Pertanyaan ke-2: Jika saya cuma mengunggah berkas/file kurang dari 1 GB, apakah saya akan dikenakan Rp507/Bulan juga? {#pertanyaan-ke2}
**Jawab:** Mungkin tidak, Anda hanya dikenakan sesuai dengan besaran ukuran berkas yang Anda unggah dan biayanya tidak langsung dibulatkan ke Rp507/Bulan saat Anda mengunggah berkas-berkas dengan ukuran kurang dari 1 GB.

Contohnya Blog Statis ini, saya unggah semuanya ke dalam bucket S3 `farrelfstaticblog` yang tidak mencapai 1 GB, tetapi saya cuma perlu membayar sekitar Rp13,00/bulan saja.

Saldo saya berkurang cukup banyak karena saya seringkali melakukan mengunggah banyak berkas dan menghapusnya lagi dengan tujuan mempelajari protokol S3 ini.

### Pertanyaan ke-3: Apa alasan kamu untuk menggunakan Layanan ini? {#pertanyaan-ke3}
**Jawab:** Alasannya yakni cuma karena kemudahan sinkronisasi dan biayanya fleksibel untuk kebutuhan saya.

Kebutuhannya apa? Kebutuhannya cuma menyimpan blog statis ini. Kenapa "kemudahan sinkronisasi"? Karena blog ini statis, agar bisa terus diperbarui, maka diperlukan untuk melakukan sinkronisasi.

Saat masih menggunakan FTP, saya bisa melakukan sinkronisasi melalui Rclone, tetapi perubahan pada berkas itu dikenali bukan berdasarkan pada _Hash_, melainkan cuma berdasarkan ukuran dari sebuah berkas dengan menggunakan satuan _Byte_/Bita, karena server tidak mendukungnya.

Sedangkan, ukuran pada suatu berkas itu akan berubah jika ada pengurangan atau penambahan jumlah karakter (terutama untuk berkas yang isinya karakter latin seperti berkas HTML, CSS dan JS ini).

Sehingga jika saya melakukan perubahan pada berkas CSS, lalu saya hasilkan blognya, maka berkas baru pun tidak akan disinkronisasikan karena ukurannya sama.

Meskipun saya menggunakan teknik _Fingerprinting_, memang saya bisa menyinkronisasikan berkas-berkas statiknya, tetapi saya tidak bisa menyinkronkan perubahan pada berkas-berkas HTML karena ukuran nya memang sama seperti berkas sebelumnya dan jumlah karakternya pun juga sama, kecuali jika saya melakukan perubahan pada HTML-nya.

Jadi, jika saya melakukan perubahan pada berkas-berkas statik, seperti CSS dan JS maka saya perlu meng-install Perangkat Lunak `lftp` agar menghapus berkas-berkas HTML, lalu saya upload lagi berkas-berkasnya.

Kenapa gak pake `lftp` aja semuanya? Karena `lftp` yang saya dan CI "GitHub Actions" (di Ubuntu 20.04) gunakan itu belum bisa menghapus berkas-berkas dari server yang memiliki nama yang berbeda dari berkas yang ingin diunggah, karena berkas nya dianggap tidak ada oleh `lftp`.

Misalnya, berkas yang diunggah itu adalah `style.min.9rcxxxx.css` untuk menggantikan `style.min.8bcxxxx.css` di server, tetapi berkas di server tidak bisa terhapus melalui `lftp` karena suatu kesalahan yang entah penyebabnya. Pesan kesalahan nya seperti berikut:

```plain
rm: Access failed: 550 File Not Found (./style.min.8bcxxxx.css)
```

Aneh banget, padahal berkas tersebut jelas-jelas ada di server setelah saya melakukan pemeriksaan ulang.

Karena kesalahan seperti itu, makanya di GitHub Actions saya jalankan dulu Rclone-nya, barulah saya jalankan juga `lftp`-nya untuk sinkronisasi berkas-berkas HTML jika berkas CSS atau/dan JS mengalami perubahan. Ribet banget, kan?

Nah, karena menggunakan protokol S3, jadi perubahan pada berkas itu dikenali berdasarkan _Hash_, jika berkas mengalami perubahan, bahkan tanpa mengurangi/menambah jumlah karakter sekali pun, berkas tersebut akan dianggap berbeda.

Sehingga ini akan mempermudah saya untuk melakukan sinkronisasi blog statis ini tanpa perlu membuat langkah yang banyak seperti sebelumnya pada GitHub Actions. Jadi, berkat ini, saya hanya perlu Rclone saja untuk sinkronisasi.

### Pertanyaan ke-4: Kenapa Anda malah memilih IDCloudHost daripada Layanan serupa dari Scaleway dan Wasabi misalnya? {#pertanyaan-ke4}
**Jawab:** Untuk Scaleway itu karena saya belum punya kartu kredit, meskipun gratis penyimpanan sebesar 75 GB dan Kuota _Bandwidth_ keluar sebesar 75 GB/Bulan, tetapi untuk mendaftarnya saya harus menggunakan kartu kredit untuk keperluan verifikasi.

Sedangkan untuk Wasabi, di sana tidak ada tingkat Gratis nya, melainkan cuma masa percobaan selama 30 hari saja dan pembayarannya pun cuma bisa dilakukan dengan menggunakan [kartu kredit saja](https://wasabi-support.zendesk.com/hc/en-us/articles/115001407112-Does-Wasabi-accept-payment-via-methods-other-than-a-credit-card-).

Selain itu, saya lihat kalau Wasabi sendiri tidak memiliki fitur Hosting Web Statis, sehingga buat saya yang menyimpan blog statis ini akan merasa sama saja.

Saya pilih IDCloudHost hanya karena pembayaran yang mudah dan beragam dan layanan dukungan nya yang berbahasa Indonesia, itu saja sih.

Saya juga berencana ingin migrasi ke penyedia lainnya, bahkan mungkin saja saya akan migrasi ke AWS S3 untuk mempelajari protokol S3 ini dengan mencoba [Tingkat Gratis (Free Tier) nya](https://aws.amazon.com/id/free/).

Mungkin saya akan mempertimbangkan opsi Kartu Kredit Virtual untuk ini, tetapi jika Anda memiliki cara lain, Anda bisa komentar di kolom komentar atau Anda bisa [japri ke saya](/tentang/#informasi-kontak).

### Pertanyaan ke-5: Server Penyimpanan nya ada di Indonesia, tetapi PoP Bunny CDN belum ada di Indonesia, sedangkan targetnya Indonesia. Bukankah ini akan memperlambat Blog nya sendiri karena 'bolak-balik' seperti itu? {#pertanyaan-ke5}
**Jawab:** Blog ini merupakan blog statis yang konten nya 'pasti', sehingga tidak perlu proses dinamis di 'belakang layar' untuk menampilkan sebuah konten yang mempengaruhi sebuah kecepatan.

Jadi, seharusnya secara kecepatan juga tidak ada perbedaan yang berarti. Untuk berkas-berkas statiknya sendiri, seperti berkas-berkas CSS, JS dan gambar, itu sudah dibantu oleh fitur ["Perma-Cache" dari Bunny CDN](https://bunny.net/cdn/perma-cache) agar berkas tersebut tidak lagi ditarik oleh Server CDN dari Penyimpanan S3-nya setelah dikunjungi balik.

Apalagi jika berkas tersebut disimpan ke dalam "Edge Storage" yang telah direplikasi, sehingga akses ke berkas-berkas statik akan menjadi jauh lebih cepat, tanpa menyentuh server aslinya sama sekali.

**PEMBARUAN Rabu, 07 Juli 2021:** Karena saya Hosting di [Storj DCS](https://www.storj.io) dan bukan di IDCloudHost lagi, jadi 'masalah' di pertanyaan ini sudah terselesaikan.

### Pertanyaan ke-6: Apakah semua API S3 yang saya pelajari dari Dokumentasi AWS bisa saya gunakan di IDCloudHost? {#pertanyaan-ke6}
**Jawab:** Belum tentu, sejak ini merupakan "S3-compatible" belum tentu semua fitur dari AWS S3 bisa diaplikasikan ke dalam S3-nya IDCloudHost.

Namun jika Anda sudah berkecimpung cukup lama dengan protokol S3 ini dan ingin mempelajari API S3 pada IDCloudHost yang bisa digunakan, ya silakan Anda coba saja sendiri.

## Penutup
Ya sudah, itu aja dulu pembahasan pada artikel kali ini. Saat ini saya belum bisa mengulas API dari S3 mana aja yang bisa digunakan pada IDCloudHost ini, karena saya sendiri baru pertama kali belajar mengenai protokol S3 ini.

Jadi, mohon maaf jika artikel ini dirasa kurang lengkap bagi kebutuhan Anda. Mohon maaf juga jika apa yang saya bahas di artikel ini kesannya seperti menjelekkan layanan _Object Storage_ dari IDCloudHost, saya tidak bermaksud demikian, saya cuma membahas pengalaman saya selama menggunakan penyimpanan S3 dari IDCloudHost ini.

Selama menggunakannya, saya menemukan cukup banyak kekurangan yang harusnya diperbarui. Mungkin semua kekurangan yang terjadi dikarenakan layanan _Object Storage_ ini masih sangatlah baru, belum lama ada juga, tetapi semoga saja layanan ini bisa terus berkembang maju, salah satu nya dengan mampu menerima banyak masukkan dari pengguna nya dari waktu ke waktu.

Mengingat IDCloudHost telah mendapatkan [suntikkan dana sebesar US$ 5 juta](https://industri.kontan.co.id/news/raih-pendanaan-us-5-juta-idcloudhost-siap-sasar-pasar-asia) dari Init 6 (yang CEO nya adalah Bapak Achmad Zaky, salah satu pendiri dan mantan CEO Bukalapak) belum lama ini, maka sudah seharusnya bahwa layanan ini merupakan layanan yang serius, termasuk tetapi tidak terbatas pada layanan fleksibel (Layanan _Cloud_) lainnya, seperti _Cloud VPS_ dan _Network Resources_, setidaknya untuk pasar Asia.

Kalau adanya kesalahan pada penulisan artikel ini, silakan berikan masukkan terbaik Anda dengan berkomentar melalui kolom komentar yang telah disediakan. Atau, Anda juga bisa [kirimi pesan kepada saya secara pribadi](/tentang/#informasi-kontak) jika Anda lebih suka melalui 'jalur pribadi'.

Semoga layanan ini bisa lebih berkembang lagi dengan baik ke depannya dan terima kasih bagi Anda yang telah membaca artikel ini sampai habis 😊

## Penggunaan Gambar dan Atribusi
Berkas-berkas gambar (seperti cuplikan layar dan gambar lainnya) yang saya gunakan di dalam artikel ini, disediakan di dalam [repositori blog ini](https://github.com/FarrelF/Blog).

Jika Anda ingin menjelajahinya, silakan kunjungi alamat URL berikut:

```plain
https://github.com/FarrelF/Blog/tree/main/content/post/2021/06/25-nyobain-idcloudhost-object-storage
```

IDCloudHost dan logonya merupakan Merek Dagang, Merek Dagang Terdaftar, atau/dan Pakaian Dagang dari "PT Cloud Hosting Indonesia", sehingga nama merek dan logo tersebut bukanlah milik saya pribadi.

Saya hanya memberikan latar warna putih pada logo IDCloudHost agar logo tersebut bisa dilihat dalam mode tampilan apa pun (baik dalam mode gelap ataupun terang).
