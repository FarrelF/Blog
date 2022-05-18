---
Title: Cara mendapatkan Sertifikat SSL Gratis dari Google (memakai acme.sh)
Slug: cara-mendapatkan-sertifikat-ssl-dari-google
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Info Blog
    - Tutorial
Image: Google-Logo.png
Date: 2022-05-15T23:32:00+07:00
Draft: false
Comments: true
Tags:
    - Sertifikat SSL
    - Google
    - Google Trust Services
    - GTS
readMore: true
#_build:
#    list: false
#    render: true
DescriptionSEO: Sebenarnya, saat ini Anda sudah dapat menggunakan SSL dari Google secara gratis tanpa harus memakai layanannya, lho. Mau? Silahkan baca artikel ini
Description: >
    Sudah berapa bulan saya gak posting-posting yah, dari tahun baru kemarin saja saya gak posting, update artikel dan update ini itu mulu, terus artikel yang ingin saya buat malah menumpuk yang semoga saja bisa saya selesaikan segera.


    Selain itu, tidak terasa juga bahwa kita sudah memasukki kuartal kedua dari tahun 2022 ini dan bahkan saat artikel ini diterbitkan saja sudah memasukki bulan Syawal tahun 1443H, Alhamdulillah. Bagi umat muslim, bulan kemarin puasanya bagaimana? Lancar, kan? Selamat Idul Fitri dan Mohon Maaf lahir batin yah buat umat muslim sekalian yang merayakannya.


    Kembali lagi ke topik artikel. Untuk saat ini, blog ini sudah memakai sertifikat SSL/TLS dari Google.


    Yap, Anda gak salah lihat, saya memakai sertifikat SSL dari Google atau lebih tepatnya Google Trust Services yang biasanya hanya dipakai untuk Layanan dari Google beserta Web/Blog Pengguna yang dibuat menggunakan salah satu layanannya (salah satunya adalah Blogger).


    Tapi, saya gak sedang pakai layanan dari Google buat Blognya, lho. Kok bisa? Dan, bagaimana cara mendapatkannya? Kalau kamu penasaran dengan itu semua, silahkan kamu baca lebih lanjut artikel ini, kalau tidak ya tidak usah dibaca, hehe 😁
---

## Pembuka
Pada tanggal 29 Maret 2022 kemarin, pihaknya baru saja mengumumkan bahwa mereka sudah meluncurkan layanan CA mereka dan server ACME-nya secara publik, yakni **Google Public CA**, yang mana bisa digunakan oleh siapa saja, termasuk orang yang tidak menggunakan layanan dari Google sekalipun untuk Aplikasinya.

Pengumumannya bisa Anda baca [di sini](https://cloud.google.com/blog/products/identity-security/automate-public-certificate-lifecycle-management-via--acme-client-api).

Artinya apa? Ini artinya bahwa Anda bisa mendapatkan/menggunakan sertifikat SSL/TLS (selanjutnya saya sebut saja menjadi "Sertifikat SSL") dari Google tanpa harus menggunakan layanan/hosting dari Google terlebih dahulu untuk Web, Blog atau Aplikasinya.

Untuk saat ini, Anda bisa mendapatkan sertifikat SSL tersebut secara gratis, mendukung kunci RSA/ECC dan mendukung _Wildcard_ juga, meski sekarang masih dalam tahap Uji Coba/Pratinjau Beta (_Beta preview_).

_Semoga seterusnya bisa gratis, Amiin_.

Selain itu, sertifikat yang diterbitkan merupakan sertifikat langsung dari [**Google Trust Services (GTS)**](https://pki.goog), yang kompatibilitas perangkatnya tidak perlu diragukan lagi dan menggunakan infrastruktur dari Google untuk menerbitkannya.

## Persiapan
Karena ini sepenuhnya menggunakan protokol ACME dan ini bersifat _Self-managed_, maka tentu saja tidak ada antarmuka pengguna dari Google secara langsung untuk mengelolanya.

Jadi, persiapan yang perlu Anda lakukan adalah sebagai berikut:
1. Punya Akun Google (Kalau kamu pengguna Android, ya gak usah ditanya lah yaa)
2. Punya Koneksi Internet (Kalau Internet aja gak punya, gimana kamu bisa baca artikel ini?)
3. Terinstalnya perkakas klien ACME di dalam perangkat kamu, entah itu di dalam Komputer PC, Laptop, Server/VPS, Ponsel Pintar, atau lainnya.

Di instruksi kali ini, saya akan memakai [acme.sh](https://acme.sh) sebagai perkakas klien ACME yang merupakan perkakas favorit saya. Jadi, maaf yah buat pengguna Certbot, Lego, atau lainnya, saya belum bisa menjelaskannya, karena belum saya pakai.

Tapi, kalau kamu sebelumnya pernah memasang sertifikat SSL dari ZeroSSL dengan membaca artikel saya sebelumnya yang Panjang kali Lebar itu, pasti perkakas tersebut sangatlah familiar bagi Anda.

Jika Anda menggunakan acme.sh sebagai perkakasnya, silahkan perbarui terlebih dahulu versinya dengan perintah berikut:

```shell
acme.sh --upgrade --auto-upgrade
```

Kalau mau, Anda juga dapat membaca [artikel saya sebelumnya](/cara-memasang-zerossl-di-netlify-bunnycdn/), siapa tahu mau nambah ilmu (terutama tentang pemasangan sertifikat SSL ke Netlify dan Bunny CDN, serta _Renew_ secara otomatis), tapi kalau gak dibaca juga gak apa-apa.

{{< info text="**PERINGATAN!!!**" >}}
Server Google Public CA masih dalam tahap uji coba (_Beta preview_).

Jika Anda menerbitkan sertifikat SSL dari Google melalui Google Public CA, maka segala resiko seperti perubahan server, perubahan kebijakan, pencabutan sertifikat yang dilakukan secara mendadak, dan resiko lainnya, silahkan Anda tanggung sendiri.

Dengan mengikuti petunjuk/instruksi dari artikel ini, maka artinya Anda telah memahami dan siap menerima segala resiko yang ada setelah Anda melakukannya.
{{< / info >}}

Setelah semuanya sudah siap, gak usah banyak _cing-cong_, mari kita langsung eksekusi!

## Membuat Proyek di Google Cloud Console
Pertama-tama, Anda perlu membuat sebuah Proyek (bahasa Inggrisnya: **Project**) di [**Google Cloud Console**](https://console.cloud.google.com/) (Sebelumnya **Google Developer Console**). Ini nantinya diperlukan karena kita akan mengakses API-nya.

Sebagai catatan, Anda tidak perlu memasukkan kartu kredit/debit hanya untuk menambahkan proyek di sana, jadi Anda bisa melakukan semuanya secara gratis. Tapi, kuotanya terbatas untuk 10 proyek saja per Akun.

Jadi, jika Anda sebelumnya telah membuat proyek di sana, maka saya sarankan Anda lewati ini dan pakai proyek yang ada saja, cukup simpan saja **Project ID** pada Proyek yang telah Anda buat sebelumnya, karena itu akan dipakai.

Jika belum, Anda bisa membuatnya melalui **Cloud Shell** yang ada di **Google Cloud Console**-nya, caranya berikut ini:

**Langkah ke-1:** Masuk ke [**Google Cloud Console**-nya](https://console.cloud.google.com/)

**Langkah ke-2:** Setelah masuk, silahkan aktifkan **Cloud Shell**-nya dengan klik pada ikon Terminal di pojok kanan atas, seperti pada cuplikan berikut:

![Cara aktivasi Google Cloud Shell](Activate_Cloud_Shell.png)

**Langkah ke-3:** Di **Cloud Shell**-nya, silahkan Anda buat proyeknya dengan perintah berikut:

```shell
gcloud projects create <PROJECT_ID>
```

Tentukan sendiri ID Proyeknya (_Project ID_) dengan menggantikan `<PROJECT_ID>`-nya. ID Proyek haruslah unik, boleh terdiri dari tanda strip, angka dan huruf kecil, tidak boleh selain itu.

Contoh:

```shell
gcloud projects create test-project-3049113
```

`test-project-3049113` adalah contoh ID Proyek yang saya buat.

**Langkah ke-4:** Setelah menentukan ID Proyeknya, silahkan tekan "Enter", nanti secara otomatis akan dibuatkan Proyeknya. Jika ini berhasil, maka keluarannya akan seperti berikut:

```shell
$ gcloud projects create test-project-3049113
Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/test-project-3049113].
Waiting for [operations/cp.5266221063755867120] to finish...done.    
Enabling service [cloudapis.googleapis.com] on project [test-project-3049113]...
Operation "operations/acat.p2-566660100705-de51fa1a-3c95-49b1-907a-7e26627da3e4" finished successfully.
```

Kira-kira akan seperti di atas.

**Langkah ke-5:** Jika berhasil, maka sebaiknya kamu simpan ID Proyek tersebut dengan baik di dalam perangkat kamu.

Jika semua sudah selesai, Anda tinggal langsung daftarkan proyeknya saja.

## Mendaftarkan Proyek
Berikutnya adalah daftarkan proyek yang Anda buat tadi terlebih dahulu dengan mengisi formulir permintaan akses yang tersedia.

**Kenapa?** Karena Anda perlu mengaktifkan API **Public Certificate Authority** yang mana itu dinonaktifkan secara baku dan itu wajar karena sebenarnya server tersebut masih dalam tahap Uji Coba (_Beta preview_).

**Biar apa?** Biar supaya Anda bisa meminta Kredensial EAB (_External Account Binding_) melalui panggilan API-nya, lalu Anda pakai kredensial tersebut untuk menerbitkan sertifikat SSL-nya melalui perkakas klien ACME (seperti acme.sh) nantinya.

Silahkan [klik di sini](https://docs.google.com/forms/d/e/1FAIpQLSd8zUIww_ztyT9a56OPq9NXISiyw6Y9g8S7LBtRQjxPhsHz5A/viewform?ts=620a6854) untuk mengakses formulirnya.

Formulirnya akan seperti cuplikan layar berikut:

![Formulir Permintaan Akses terhadap API](Google_Request_Form.png)

Akun Google-nya bisa bebas, tapi lebih baik gunakan akun Google yang Anda gunakan ketika membuat proyek di **Google Cloud Console**. Jika Anda ingin menggantikan akunnya, silahkan klik pada tautan **Ganti akun**.

Setelah itu, isikan formulirnya dengan benar, berikut adalah penjelasan mengenai formulir yang Anda isikan nantinya

- **Email:** Isikan Alamat Surel Anda, alamat ini nantinya digunakan untuk mengirimkan sebuah pemberitahuan bahwa Proyek tersebut telah diterima oleh Google
- **Google Cloud Project ID:** Isikan itu dengan ID dari Proyek (bahasa Inggrisnya: **Project ID**) yang telah Anda buat sebelumnya di **Google Cloud Console**
- **Estimated usage:** Perkirakan berapa sertifikat SSL yang Anda terbitkan/perbarui setiap 3 bulan sekali, sebaiknya kalau bisa isi itu dengan benar dan jujur, serta isi itu sesuai dengan kebutuhan Anda, ini kemungkinan bisa jadi penentu persiapan yang dilakukan oleh pihak mereka nantinya.

    Tips: Untuk meminimalkan jumlah sertifikat SSL per 3 bulan, saran saya pikirkanlah untuk memakai sertifikat SSL dalam bentuk _Wildcard_ dan manfaatkan _Multi-domain_ dalam 1 sertifikat jika perlu

- **Optional feedback:** Anda bisa mengisi masukkan untuk Google Public CA nanti, ini tidak wajib diisi, jika Anda tidak mempunyai masukkan apapun, ya tidak usah diisi

Nah, setelah semua sudah diisi, silahkan klik pada _Button_ **Kirim** (atau, bahasa Inggrisnya adalah **Submit**), lalu tinggal Anda tunggu saja hasilnya, biasanya hanya dalam beberapa jam.

Pastikan untuk selalu periksa pesan surel Anda baik di dalam kotak masuk ataupun di dalam folder Spam, karena jika sudah diterima, maka akan muncul pesan surel dari `public-ca-preview-access@google.com` dengan nama `Public CA Preview Access`, bersubjek `Welcome to Google Cloud Certificate Manager, Public CA`, yang isinya kira-kira seperti cuplikan berikut:

![Isi Pesan Surel dari Google Public CA](Google_Public_CA_Email_Message.png)

Jika Anda menerima pesan di atas, maka sudah dipastikan bahwa Anda bisa mengaktifkan Akses API untuk **Public Certificate Authority** milik Google melalui **Google Cloud Console**.

## Mengaktifkan Akses API-nya dan membuat kredensial EAB
Setelah diterima, Anda perlu mengaktifkan Akses API-nya terlebih dahulu dan berikan izin akses untuk membuat kredensial EAB-nya.

Caranya seperti berikut:

**Langkah ke-1:** Masuk ke [**Google Cloud Console**-nya](https://console.cloud.google.com/)

**Langkah ke-2:** Setelah masuk, silahkan aktifkan **Cloud Shell**-nya dengan klik pada ikon Terminal di pojok kanan atas.

**Langkah ke-3:** Di **Cloud Shell**-nya, pastikan Anda memilih proyek mana yang ingin diaktifkan Akses API-nya:

```shell
gcloud config set project <PROJECT_ID>
```

Ganti `<PROJECT_ID>` dengan ID Proyek Anda.

**Langkah ke-4:** Berikan izin untuk membuat kredensial EAB dengan perintah berikut di dalam **Cloud Shell**-nya:

```shell
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=user:<USER> \
  --role=roles/publicca.externalAccountKeyCreator
```

Ganti `<PROJECT_ID>` dengan ID Proyek Anda.
Ganti `<USER>` dengan Alamat Surel untuk akun Google Anda atau Alamat Surel lain yang ingin Anda tambahkan izinnya.

**Langkah ke-5:** Aktifkan Akses API-nya dengan perintah berikut:

```shell
gcloud services enable publicca.googleapis.com
```

**Langkah ke-6:** Setelah diaktifkan, buatlah kredensial EAB-nya dengan perintah berikut:

```shell
gcloud beta publicca external-account-keys create
```

Jika berhasil, nanti keluarannya akan seperti berikut:

```shell
[b64MacKey: Qxxx_dxxxxxxxxxxxxxxxxxxxxx_cxxx-2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
keyId: bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx]
```

Hal yang perlu diperhatikan/dicatat adalah bahwa:
- Nilai dari `b64MacKey` adalah **EAB HMAC Key**-nya
- Nilai dari `keyId` adalah **EAB Key ID/EAB KID**-nya

Jangan lupa simpan hasil keluaran tersebut itu baik-baik karena akan dipakai nantinya oleh perkakas klien ACME dan pastikan bahwa tidak ada seorangpun yang mengetahui itu, kecuali Anda sendiri.

Kredensial EAB yang tidak digunakan akan bertahan 7 hari, tapi akun untuk server ACME yang telah Anda daftarkan menggunakan kredensial tersebut tidak memiliki masa berlaku.

Jadi, buruan dipakai kredensial EAB-nya setelah ini.

## Mengkaitkan Kredensial EAB dengan Perkakas Klien ACME
Setelah membuat kredensial EAB-nya, sekarang waktunya Anda gunakan kredensial tersebut ke dalam perkakas klien ACME dalam rangka mendaftarkan sebuah "akun" untuk server ACME-nya, dalam instruksi kali ini saya memakai acme.sh sebagai perkakas klien untuk protokol ACME-nya.

Untuk mendaftarkan sebuah akun dengan menggunakan Kredensial EAB-nya, Anda dapat menggunakan perintah berikut:

```shell
acme.sh  --register-account -m <ALAMAT_SUREL_KAMU> --server google \
    --eab-kid <EAB_KID_KAMU> \
    --eab-hmac-key <EAB_HMAC_KEY_KAMU>
```

Ganti:
- `<ALAMAT_SUREL_KAMU>` menjadi alamat surel kamu
- `<EAB_KID_KAMU>` menjadi **EAB KID** yang telah kamu simpan sebelumnya
- `<EAB_HMAC_KEY_KAMU>` menjadi **EAB HMAC Key** yang telah kamu simpan sebelumnya

Jika registrasi berhasil, maka Anda sudah mulai bisa menerbitkan sertifikat SSL dengan menggunakan **Google Public CA**, lalu bisa Anda kelola sesuka hati melalui perkakas acme.sh.

## Menerbitkan sertifikat SSL dari Google
Untuk menerbitkan sertifikat SSL dari Google melalui acme.sh, maka Anda hanya perlu pelajari contoh perintah berikut:

```shell
acme.sh --issue --server google \
   -d '*.contoh.com' -d contoh.com --dns dns_cf
```

Perintah di atas akan menerbitkan sertifikat SSL dengan menggunakan **Google Public CA** sebagai CA-nya, sertifikat tersebut mencakup hanya untuk domain `*.contoh.com` dan `contoh.com` saja dengan menggunakan Layanan DNS dari Cloudflare sebagai Metode Verifikasinya.

Jika Anda sudah lama menggunakan acme.sh sebelumnya, maka harusnya Anda sudah familiar dengan perintah di atas yang sebenarnya cuma nambahin parameter `--server google` saja. Tapi, kalau Anda belum pernah sama sekali menggunakannya, saran saya kamu pelajari itu di [artikel saya sebelumnya](/cara-memasang-zerossl-di-netlify-bunnycdn/#menerbitkan-sertifikat-ssl).

Perkakas acme.sh menggunakan ZeroSSL sebagai CA baku, sehingga Anda tetap diharuskan untuk menggunakan parameter `--server google` setiap kali menerbitkan sertifikat SSL yang baru dari Google.

Jika Anda ingin menggantikan CA bakunya, Anda bisa memakai perintah berikut:

```shell
acme.sh --set-default-ca --server google
```

Dengan begini, maka kedepannya Anda tidak perlu lagi memakai parameter `--server google` hanya sekadar untuk menerbitkan sertifikat SSL dari Google.

Nah, artikelnya saya cukupkan sampai sini saja. Jika Anda mempunyai pertanyaan lain, silahkan tanyakan itu di kolom komentar yang tersedia, tapi sebelum bertanya, ada baiknya bila Anda membaca dan memahami pertanyaan yang (akan) sering ditanya beserta jawabannya agar bisa menjadi referensi buat Anda.

## Pertanyaan yang (akan) sering ditanya {#pertanyaan-dan-jawaban}
### Pertanyaan ke-1: Apakah saya perlu memasukkan kartu kredit/debit terlebih dahulu agar dapat menggunakan Google Cloud Console? {#pertanyaan-ke1}
**Jawab:** Seharusnya tidak perlu kamu masukkan dan semua itu bisa Anda lakukan secara gratis tanpa membayar biaya sepeserpun.

Hanya saja, maksimum proyek yang bisa Anda buat adalah sebanyak 10 proyek per Akun. Jadi, jika Anda pernah memiliki/membuat proyek sebelumnya di **Google Cloud Console** atau **Google Developer Console**, maka saya sangat menyarankan agar memakai proyek yang ada saja.

### Pertanyaan ke-2: Apakah semua sertifikat SSL yang diterbitkan oleh Google Public CA ini gratis? {#pertanyaan-ke2}
**Jawab:** Untuk saat ini, jawabannya adalah **Iya**. Anda bisa menerbitkan sertifikat SSL tersebut secara gratis melalui protokol ACME-nya.

Baik sertifikat SSL dalam bentuk biasa, _Multi-domain_ atau bahkan _Wildcard_ sekalipun bisa Anda terbitkan secara gratis dengan RSA atau ECC sebagai Algoritma Kunci Publiknya.

Hanya saja sifatnya ini adalah _Self-managed_, sehingga semuanya Anda kelola secara mandiri tanpa bantuan ataupun dukungan dari pihak Google secara langsung.

### Pertanyaan ke-3: Berapa lama masa aktif sertifikat SSL dari Google Public CA ini? {#pertanyaan-ke3}
**Jawab:** Secara baku, semua sertifikat yang diterbitkan oleh Google Trust Services memiliki masa aktif selama 90 hari per sertifikat dan itu merupakan nilai maksimalnya.

Namun, protokol ACME telah mengizinkan klien untuk meminta dengan masa aktif yang berbeda-beda yang tentunya kurang dari masa aktif maksimal.

Oleh karena itu, Google sendiri mengizinkan Anda untuk menerbitkan sertifikat SSL-nya dengan masa aktif yang seminimal-minimalnya selama 1 hari.

Tapi, mereka sendiri menyarankan Anda untuk menerbitkan sertifikatnya minimal dengan masa aktif 3 hari atau lebih untuk mencegah [ketidaktepatan pada jam](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/46359.pdf) dan validitas sertifikat yang tumpang tindih, yang mengakibatkan Web, Blog atau Aplikasi menjadi tidak bisa diakses oleh karenanya.

### Pertanyaan ke-4: Bagaimana caranya agar saya bisa menerbitkan sertifikat SSL dengan masa aktif kurang dari 90 hari? {#pertanyaan-ke4}
**Jawab:** Di acme.sh, Anda bisa tambahkan parameter `--valid-to <tanggal waktu>` saat ingin menerbitkan sebuah sertifikat.

Contoh:

```shell
acme.sh --issue -d '*.contoh.com' -d contoh.com --dns dns_cf --valid-to "+30d"
```

Perintah di atas akan menerbitkan sertifikat SSL untuk domain `*.contoh.com` dan `contoh.com` dengan masa berlaku selama 30 hari.

Contoh lainnya:

```shell
acme.sh --issue -d '*.contoh.com' -d contoh.com --dns dns_cf --valid-to "+30h"
```

Sama seperti perintah sebelumnya, bedanya hanya masa aktifnya selama 30 jam saja.

Format yang diterima oleh parameter di atas adalah `+*d` dan `+*h` saja, selain itu akan ditolak.

Selain menggunakan format yang relatif, Anda juga bisa menggunakan format yang absolut dengan menentukan tanggal dan waktunya secara lengkap. Penulisan tanggal dan waktunya harus memenuhi standar ISO 8601 dan harus ditulis dalam format UTC, sehingga ditulis seperti ini: `2022-04-01T08:10:33Z`

Contoh:

```shell
acme.sh --issue -d '*.contoh.com' -d contoh.com --dns dns_cf --valid-to "2022-04-01T08:10:33Z"
```

Perintah di atas akan menerbitkan sertifikat SSL untuk domain `*.contoh.com` dan `contoh.com` dengan masa berlaku pada tanggal 01 April 2022 dengan pukul 08:10:33 dalam waktu UTC.

Menggunakan Format Absolut membuat acme.sh tidak sanggup memperbarui sertifikatnya secara otomatis, jadi saran saya pakai saja format yang relatif, sehingga bisa diperbarui secara otomatis.

### Pertanyaan ke-5: Apakah sertifikat SSL yang diterbitkan itu merupakan sertifikat langsung dari Google Trust Services? {#pertanyaan-ke5}
**Jawab:** Iya, betul.

Semua sertifikat SSL yang telah Anda terbitkan melalui **Google Public CA** itu adalah sertifikat langsung dari **Google Trust Services (GTS)**, yang di mana sertifkatnya digunakan oleh seluruh layanan Google, sehingga kompatibilitas perangkatnya tidak perlu Anda ragukan lagi.

### Pertanyaan ke-6: Kalau saya menerbitkan sertifikat SSL dengan memakai ECC sebagai Algoritma Kunci Publiknya, apakah rantai yang dipakai itu murni ECC juga? {#pertanyaan-ke6}
**Jawab:** Sayangnya, tidak. Alasannya kurang tahu dan kapan menggunakan rantai murni ECC yang sepenuhnya juga saya kurang tahu, yang jelas bukan sekarang ini menurut klaim mereka.

### Pertanyaan ke-7: Saya memakai perkakas ACME selain acme.sh, seperti Certbot, apa Alamat URL untuk server ACME-nya? {#pertanyaan-ke7}
**Jawab:** Alamat URL-nya sebagai berikut:

Server Produksi (baku): `https://dv.acme-v02.api.pki.goog/directory`

Server Uji coba: `https://dv.acme-v02.test-api.pki.goog/directory`

### Pertanyaan ke-8: Kenapa kamu memakai acme.sh? {#pertanyaan-ke8}
**Jawab:** Karena lebih simpel dan lebih mudah dipelajari, serta fiturnya juga lumayan lengkap, seperti dukungan layanan penyedia DNS-nya yang lengkap, pilihan CA yang cukup banyak, eksekusi skrip setelah pembaruan sertifikat, opsi penginangan sertifikat, mengatur masa berlaku sertifikat saat penerbitan, dll.

Perkakas tersebut juga tidak memerlukan hak akses `root` ataupun menggunakan `sudo`, sehingga kamu bisa bebas menggunakannya tanpa terkendala perizinan dan juga pastinya lebih aman ketimbang menggunakan hak akses `root`.

Perkakas acme.sh juga berbasis _Shell_ dan diklaim memenuhi standar POSIX juga, jadi selain menjadi lebih ringan dan fleksibel, perkakas tersebut juga dapat dijalankan di hampir semua Sistem Operasi berbasis \*nix.

Selain itu, karena sifat perkakas tersebut yang diinstal di dalam direktori pengguna dan secara baku semua konfigurasinya diletakkan ke dalam 1 folder, yakni `~/.acme.sh`, maka semua salinannya juga bisa dipindahkan ke perangkat lain dengan lebih mudah tanpa harus melakukan langkah yang lebih sulit.

Alasan-alasan tersebutlah yang membuat saya secara pribadi lebih menyukai acme.sh ketimbang perkakas klien ACME lain, seperti Certbot misalnya.

Ini sebenarnya adalah sebuah alasan yang sama seperti artikel sebelumnya, sehingga kalau kamu pernah membaca artikel sebelumnya, mungkin kamu akan berpikir bahwa jawaban ini sangat familiar bagi Anda, karena pada dasarnya ya sama saja, cuma beda kasusnya.

### Pertanyaan ke-9: Apa kelebihan dan kekurangan dari Google Public CA menurut kamu? {#pertanyaan-ke9}
**Jawab:** Mungkin lebih baik bila disebutkan "Hal yang menarik" dan "Hal yang perlu diperhatikan" daripada "kelebihan" dan "kekurangan", karena kelebihan bagi saya belum tentu itu merupakan kelebihan bagi Anda dan kekurangan bagi saya belum tentu itu merupakan kekurangan bagi Anda, atau justru malah sebaliknya.

Jadi saya langsung saja bahas hal yang menarik dan yang perlu diperhatikan soal **Google Public CA** ini.

Hal yang menarik:
- Penerbitan/pembaruan sertifikat yang cepat. Hal ini dikarenakan ia menggunakan infrastruktur jaringan dari Google untuk server ACME-nya dan kita penggunanya akan diarahkan ke Server terdekat saat memakainya, sehingga proses penerbitan/pembaruan sertifikat akan menjadi jauh lebih cepat
- Lebih minim gangguan saat proses penerbitan/pembaruan, sehingga kamu lebih jarang menemukan galat 5xx saat penerbitan/pembaruan sertifikat, karena infrastruktur jaringan dari Google itu tadi
- Kamu bisa menerbitkan sertifikat dalam bentuk biasa, _Multi-domain_, dan bahkan _Wildcard_ baik menggunakan RSA ataupun ECC sebagai Algoritma Kunci Publiknya
- Sertifikat yang diterbitkannya bisa digunakan oleh hampir semua perangkat. Hal ini dikarenakan ia menggunakan [GlobalSign Root CA - R1](https://crt.sh/?id=88) (Halaman demonya [di sini](https://valid.r1.roots.globalsign.com/)) sebagai sertifikat akar, yang merupakan sertifikat akar tertua dari GlobalSign yang berlaku dari tahun 1998 sampai 2028 dan digunakan secara luas pada tahun 1999. Selain itu, sertifikatnya digunakan oleh hampir semua layanan Google, sehingga kompatibilitasnya tidak perlu diragukan lagi
- Yang paling penting adalah semuanya bisa digunakan secara gratis, setidaknya untuk saat ini

Hal yang perlu diperhatikan:
- Masih dalam tahap uji coba, sehingga bisa saja nantinya terjadi hal-hal yang tidak kamu inginkan dan keputusan bisa saja berubah dengan cepat
- Karena masih dalam tahap uji coba, maka partisipasinya jadi jauh lebih sulit dan diharuskan untuk mengisi sebuah formulir agar Akses API-nya bisa diaktifkan
- Algoritma Kunci Publik pada rantai sertifikat di atasnya masih menggunakan RSA, meski sertifikat SSL-nya diterbitkan menggunakan ECC, tapi rantainya tidak benar-benar murni ECC, tidak seperti ZeroSSL dan Let's Encrypt
- Tidak mendukung nama domain Unicode yang disandikan atau _di-encode_ menggunakan Punycode
- Jika Anda ingin Situs Web/Blog-nya diakses oleh pengguna di Tiongkok Daratan, mungkin sebaiknya jangan gunakan sertifikat SSL ini karena seluruh layanannya diblokir oleh GFW (_Great Firewall_)-nya yang berimbas pada pemuatan Situs Web/Blog Anda karena masalah pada pemuatan sertifikatnya/jabat tangan TLS-nya. Saya tidak terkejut dengan hal seperti ini karena hampir seluruh layanan Google diblokir oleh pemerintah Republik Rakyat Tiongkok

Ada satu hal lagi yang ingin saya bahas, hanya saja saya tidak tahu apakah hal ini merupakan hal yang menarik atau justru merupakan hal yang perlu diperhatikan.

Hal ini adalah bahwa sertifikat tersebut memiliki CRL (_Certificate Revocation List_) dan juga OCSP (_Online Certificate Status Protocol_) untuk pencabutannya di saat sertifikat SSL gratisan yang berbasis ACME lainnya yang pernah saya coba hanya memiliki OCSP saja, namun tidak dengan CRL.

Saya tidak bisa memasukkannya sebagai hal yang "menarik" adalah karena yang pertama saya kurang mempelajari lebih dalam mengenai CRL dan OCSP ini, dan yang kedua karena menurut beberapa referensi, CRL itu termasuk _outdated_ dan OCSP diklaim lebih cepat daripada CRL karena ia tidak perlu mengunduh semua list sertifikat yang telah dicabut.

Untuk mempercepatnya lagi, kita hanya perlu mengaktifkan fitur **OCSP Stapling** saja pada Server Web/Blog agar pengunjung tidak lagi mengakses Server (atau, Responder) OCSP-nya saat mengunjungi sebuah Web/Blog.

Namun menariknya, setiap sertifikat yang diterbitkan dari Google Trust Services memiliki alamat URL-nya sendiri untuk CRL dan OCSP-nya, mungkin saja dengan strategi seperti ini akan meminimalkan untuk mengunduh semua daftar sertifikat yang telah dicabut, sehingga pemuatan sertifikatnya/jabat tangannya akan jauh lebih cepat, ya saya kurang tahu juga sih selebihnya.

Mungkin hal di atas bisa saja ada yang salah, jika ada koreksi, silahkan Anda berikan masukkannya melalui kolom komentar.

### Pertanyaan ke-10: Apa pengalamanmu saat menggunakan Google Public CA? Apakah ada masalah sejauh ini? {#pertanyaan-ke10}
**Jawab:** Sejauh ini belum ada masalah apapun, baik saat penerbitan sampai pemakaiannya. Penerbitannya bisa dibilang cepat, jauh lebih cepat ketimbang saat saya memakai ZeroSSL dan saya belum pernah menemukan galat 5xx saat penerbitan ataupun galat yang membuat perkakas acme.sh mengulangi proses penerbitan sertifikat.

Jika ada masalah saat pemakaian ataupun pembaruan sertifikat (semoga jangan), mungkin akan saya perbarui juga di sini. 

Untuk pencabutannya belum saya coba, karena saya belum sempat dan belum ada urgensi juga untuk mencabut sertifikatnya, mungkin kedepannya akan saya coba.

### Pertanyaan ke-11: Saya memasang CAA Record di dalam pengaturan DNS pada Domain saya, apa CAA Record yang harus saya isi? {#pertanyaan-ke11}
**Jawab**: Jika Anda memasang **CAA Record**, pastikan Anda menambahkan `pki.goog` di dalamnya. Dengan ini, Anda akan mengizinkan Google Trust Services untuk menerbitkan sertifikat SSL-nya untuk domain Anda.

Untuk referensinya/selebihnya, bisa Anda kunjungi server ACME-nya secara langsung melalui Peramban Web-mu, Alamat URL-nya sudah saya sebutkan di jawaban pada [pertanyaan ke-7](#pertanyaan-ke7) lalu lihat pada bagian `caaIdentities` dan di situ akan ada `pki.goog` sebagai isi dari `caaIdentities` yang merupakan **CAA Record** yang bisa Anda isi untuk mengizinkan Google Trust Services.

Hal di atas bukan hanya berlaku untuk Google Trust Services saja, tapi berlaku juga untuk server ACME lainnya seperti Let's Encrypt, ZeroSSL, Buypass, SSL.com, dll yang bisa Anda coba sendiri.

## Penutup
Yap, sekian saja artikelnya untuk kali ini, bagaimana? Mudah, bukan? Dengan begini, Anda bisa memakai sertifikat SSL dari Google secara gratis tanpa perlu memakai layanan dari mereka untuk Web/Blog-nya.

Itu aja? Yah, tidaklah, selanjutnya ya pasang sertifikat SSL-nya ke dalam Situs Web/Blog kamu agar bisa digunakan, jika Anda memakai Netlify, Bunny CDN, atau/dan cPanel, saya sarankan Anda baca [artikel saya sebelumnya](/cara-memasang-zerossl-di-netlify-bunnycdn/#memasang-ssl) dan mulai bacanya dari bagian **Memasang Sertifikat SSL**.

Maaf yah buat pengguna Certbot dan Klien ACME lainnya, baris perintahnya tidak saya bahas di sini, karena saya sendiri belum pernah menggunakannya, saya sendiri memakai acme.sh sebagai perkakas klien ACME.

Terima kasih bagi Anda yang telah membaca serta mempelajari yang ada di artikel ini, mohon maaf jika artikel ini memiliki beberapa kekeliruan dan kesalahan, seperti salah ketik, kurang jelas, salah informasi, dll, karena artikel ini jauh dari sempurna.

Saya akan berusaha untuk terus-terusan memperbarui artikel ini seiring berkembangnya Informasi yang ada, karena yang saya pos ini adalah tutorial, sehingga perlu adanya penyesuaian.

Jika adanya kesalahan dan kekeliruan, atau kalau Anda memiliki pertanyaan lainnya, bisa Anda berikan masukkan melalui kolom komentar yang tersedia. Masukkan dari Anda akan sangat berarti bagi saya dan artikel ini untuk kedepannya nanti.

## Penggunaan Gambar dan Atribusi
Berkas-berkas Gambar (seperti Cuplikan layar dan Gambar lainnya) yang di gunakan di dalam artikel ini, disediakan di dalam [_Repository_ Blog ini](https://github.com/FarrelF/Blog).

Jika Anda ingin menjelajahinya, silahkan kunjungi Alamat URL berikut:

```plaintext
https://github.com/FarrelF/Blog/tree/main/content/post/2022-05-15-cara-mendapatkan-sertifikat-ssl-dari-google
```

Google dan logonya merupakan Merek Dagang, Merek Dagang Terdaftar, atau/dan Pakaian Dagang dari "Google LLC", sehingga nama merek dan logo tersebut bukanlah milik saya pribadi.
