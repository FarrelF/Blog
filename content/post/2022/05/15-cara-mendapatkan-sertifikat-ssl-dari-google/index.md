---
Title: Cara mendapatkan Sertifikat SSL Gratis dari Google (memakai acme.sh)
Slug: cara-mendapatkan-sertifikat-ssl-dari-google
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Info Blog
    - Tutorial
Image: Google-Trust-Services-Logo.webp
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
DescriptionSEO: Sebenarnya, saat ini Anda sudah dapat menggunakan SSL dari Google secara gratis tanpa harus memakai layanannya, lho. Mau? Silakan baca artikel ini
Description: |-
    Untuk saat ini, blog ini sudah memakai sertifikat SSL/TLS dari Google.

    Yap, Anda gak salah lihat, saya memakai sertifikat SSL/TLS dari Google atau lebih tepatnya Google Trust Services yang biasanya hanya dipakai untuk Layanan dari Google seperti Penelusuran Google, YouTube, Google Drive, Situs Google, Blogger beserta Web/Blog Pengguna yang dibuat menggunakan salah satu layanannya.

    Namun, saya gak sedang pakai layanan dari Google buat blognya, lho. Kok bisa? Dan, bagaimana cara mendapatkannya? Kalau kamu penasaran dengan itu semua, silakan kamu baca lebih lanjut artikel ini, kalau tidak ya tidak usah dibaca, hehe 😁
---

## Pembuka

Pada tanggal 29 Maret 2022 kemarin, pihaknya baru saja mengumumkan bahwa mereka sudah meluncurkan layanan CA mereka dan server ACME-nya secara publik, yakni **"Google Public CA"**, yang mana dapat digunakan oleh siapa saja, termasuk orang yang tidak menggunakan layanan dari Google sekali pun untuk aplikasinya, tapi saat itu masih dalam uji coba terbatas dan itu tidak publik.

Pengumumannya dapat Anda baca [di sini](https://cloud.google.com/blog/products/identity-security/automate-public-certificate-lifecycle-management-via--acme-client-api).

Tapi sejak tanggal 25 Mei 2023 berdasarkan [halaman ini](https://security.googleblog.com/2023/05/google-trust-services-acme-api_0503894189.html), layanan tersebut mulai dapat dinikmati oleh semua pengguna umum, baik yang menggunakan layanan dari Google atau pun yang tidak sama sekali.

Artinya apa? Ini artinya bahwa Anda bisa mendapatkan/menggunakan sertifikat SSL/TLS dari Google tanpa harus menggunakan layanan/hosting dari Google terlebih dahulu untuk web, blog atau aplikasinya.

Untuk saat ini, Anda bisa mendapatkan sertifikat tersebut secara gratis, mendukung RSA/ECC sebagai algoritma kunci publik dan mendukung penerbitan dalam bentuk _Wildcard_ juga.

Selain itu, sertifikat yang diterbitkan merupakan sertifikat langsung dari [**"Google Trust Services (GTS)"**](https://pki.goog), yang kompatibilitas perangkatnya tidak perlu diragukan lagi dan menggunakan infrastruktur dari Google untuk menerbitkannya.

## Persiapan

Karena ini sepenuhnya menggunakan protokol ACME dan ini bersifat _Self-managed_, maka tentu saja tidak ada antarmuka pengguna dari Google secara langsung untuk mengelolanya.

Jadi, persiapan yang perlu Anda lakukan adalah sebagai berikut:

1. Punya Akun Google (Kalau kamu pengguna Android, ya gak usah ditanya lah yaa)
2. Punya koneksi Internet (Kalau Internet aja gak punya, gimana kamu bisa baca artikel ini?)
3. Terinstalnya perkakas klien ACME di dalam perangkat kamu, entah itu di dalam Komputer PC, Laptop, Server/VPS, Ponsel Pintar, atau lainnya.

Di instruksi kali ini, saya akan memakai [acme.sh](https://acme.sh) sebagai perkakas klien ACME yang merupakan perkakas favorit saya. Untuk pengguna Certbot, Anda dapat membaca tutorial resminya [di sini](https://cloud.google.com/certificate-manager/docs/public-ca-tutorial), di tutorialnya memakai perkakas Certbot juga.

Jadi, maaf yah buat pengguna Lego dan lainnya, saya belum bisa menjelaskannya, karena saya belum pernah pakai.

Namun, kalau kamu sebelumnya pernah memasang sertifikat SSL/TLS dari ZeroSSL dengan membaca artikel saya sebelumnya yang panjang kali lebar itu, pasti perkakas tersebut sangatlah familiar bagi Anda.

Jika Anda menggunakan acme.sh sebagai perkakasnya, silakan perbarui terlebih dahulu versinya dengan perintah berikut:

```shell
acme.sh --upgrade --auto-upgrade
```

Kalau mau, Anda juga dapat membaca [artikel saya sebelumnya](/cara-memasang-zerossl-di-netlify-bunnycdn/), siapa tahu mau nambah ilmu (terutama tentang pemasangan sertifikat SSL/TLS ke Netlify, Bunny CDN, cPanel dan DirectAdmin, serta _me-renew_ secara otomatis), tapi kalau gak dibaca juga gak apa-apa.

Setelah semuanya sudah siap, gak usah banyak _cing-cong_, mari langsung eksekusi!

## Membuat Proyek di Google Cloud Console

Pertama-tama, Anda perlu membuat sebuah Proyek (bahasa Inggrisnya: **Project**) di [**"Google Cloud Console"**](https://console.cloud.google.com/) (Sebelumnya bernama **"Google Developer Console"**). Ini nantinya diperlukan karena kamu akan mengakses API-nya.

Sebagai catatan, Anda tidak perlu memasukkan kartu kredit/debit hanya untuk menambahkan proyek di sana, jadi Anda bisa melakukan semuanya secara gratis. Namun, kuotanya terbatas untuk 10 proyek saja per akun.

Jadi, jika kamu sebelumnya telah membuat proyek di sana, maka saya sarankan kamu [lewati ini](#mengaktifkan-akses-api-nya-dan-membuat-kredensial-eab) dan pakai proyek yang ada saja, cukup simpan saja **"Project ID"** pada proyek yang telah Anda buat sebelumnya, karena itu akan dipakai.

Jika belum, Anda bisa membuatnya melalui **"Cloud Shell"** yang ada di **"Google Cloud Console"**-nya, caranya berikut ini:

**Langkah ke-1:** Masuk ke [**"Google Cloud Console"**-nya](https://console.cloud.google.com/)

**Langkah ke-2:** Setelah masuk, aktifkan **"Cloud Shell"**-nya dengan klik pada ikon Terminal di pojok kanan atas, seperti pada cuplikan berikut:

![Cara aktivasi Google Cloud Shell](Activate_Cloud_Shell.webp)

Kalau ada konfirmasi **"Authorize Cloud Shell"**, klik **"Authorize"** dan gunakan akun Anda jika disuruh memilih.

**Catatan:** Sebenarnya kamu dapat menggunakan [**Google Cloud CLI**](https://cloud.google.com/sdk/docs/install) sebagai gantinya, cuma ya artikel ini juga menyasar kalangan yang belum pernah pake layanan **Google Cloud Console** atau kalangan yang tidak ingin menginstalnya (termasuk saya sendiri), jadi ya saya cuma bahas pakai **Cloud Shell**-nya aja.

**Langkah ke-3:** Di **"Cloud Shell"**-nya, silakan buat proyeknya dengan perintah berikut:

```shell
gcloud projects create <PROJECT_ID>
```

Tentukan sendiri ID Proyeknya (_Project ID_) dengan menggantikan `<PROJECT_ID>`-nya. ID Proyek haruslah unik, boleh terdiri dari tanda strip, angka dan huruf kecil, tidak boleh selain itu.

Contoh:

```shell
gcloud projects create test-project-3049113
```

`test-project-3049113` adalah contoh ID Proyek yang saya buat, silakan ganti ID tersebut dan tentukan sendiri ID Proyeknya dengan unik.

**Langkah ke-4:** Setelah menentukan ID Proyeknya, silakan tekan **"Enter"**, nanti secara otomatis akan dibuatkan proyeknya. Jika ini berhasil, maka keluarannya akan seperti berikut:

```shell {linenos=true}
$ gcloud projects create test-project-3049113
Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/test-project-3049113].
Waiting for [operations/cp.5266221063755867120] to finish...done.    
Enabling service [cloudapis.googleapis.com] on project [test-project-3049113]...
Operation "operations/acat.p2-566660100705-de51fa1a-3c95-49b1-907a-7e26627da3e4" finished successfully.
```

Kira-kira akan seperti di atas.

**Langkah ke-5:** Jika berhasil, maka sebaiknya kamu simpan ID dari proyek tersebut dengan baik di dalam perangkat kamu.

Jika semua sudah selesai, tinggal langsung aktifkan saja.

## Mengaktifkan Akses API-nya dan membuat kredensial EAB

Setelah dibuat, Anda perlu mengaktifkan Akses API-nya terlebih dahulu dan berikan izin akses untuk membuat kredensial EAB-nya.

Caranya seperti berikut:

**Langkah ke-1:** Masuk ke [**"Google Cloud Console"**-nya](https://console.cloud.google.com/)

**Langkah ke-2:** Setelah masuk, silakan aktifkan **"Cloud Shell"**-nya dengan klik pada ikon Terminal di pojok kanan atas. Kalau ada konfirmasi **"Authorize Cloud Shell"**, klik **"Authorize"** dan gunakan akun Anda jika disuruh memilih.

**Catatan:** Sebenarnya kamu dapat menggunakan [**Google Cloud CLI**](https://cloud.google.com/sdk/docs/install) sebagai gantinya, cuma ya artikel ini juga menyasar kalangan yang belum pernah pake layanan **Google Cloud Console** atau kalangan yang tidak ingin menginstalnya (termasuk saya sendiri), jadi ya saya cuma bahas pakai **Cloud Shell**-nya aja.

**Langkah ke-3:** Di **"Cloud Shell"**-nya, pastikan Anda memilih proyek mana yang ingin diaktifkan Akses API-nya:

```shell
gcloud config set project <PROJECT_ID>
```

Ganti `<PROJECT_ID>` dengan ID Proyek Anda.

**Langkah ke-4:** Berikan izin untuk membuat kredensial EAB dengan perintah berikut di dalam **"Cloud Shell"**-nya:

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
gcloud publicca external-account-keys create
```

Jika berhasil, nanti keluarannya akan seperti berikut:

```plain
[b64MacKey: Qxxx_dxxxxxxxxxxxxxxxxxxxxx_cxxx-2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
keyId: bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx]
```

Hal yang perlu diperhatikan/dicatat adalah bahwa:

- Nilai dari `b64MacKey` adalah **"EAB HMAC Key"**-nya
- Nilai dari `keyId` adalah **"EAB Key ID"** atau **"EAB KID"**-nya

Jangan lupa simpan hasil keluaran tersebut itu baik-baik karena akan dipakai nantinya oleh perkakas klien ACME dan pastikan bahwa tidak ada seorang pun yang mengetahui itu, kecuali Anda sendiri.

Kredensial EAB yang tidak digunakan hanya bertahan selama 7 hari dan hanya bisa dipakai sekali saja, tapi akun untuk server ACME yang telah Anda daftarkan menggunakan kredensial tersebut tidak memiliki masa berlaku.

Jadi, buruan dipakai kredensial EAB-nya setelah ini.

### Membuat Kredensial EAB untuk Mode Pementasan/Uji coba

Yap, Anda tidak salah lihat, server ACME dari Google Public CA itu sendiri memiliki fasilitas yang memungkinkan penggunanya untuk menguji penerbitan sertifikat dalam mode pementasan (_Staging Mode_).

Ini sangat berguna bagi Anda yang ingin menguji coba proses penerbitan sertifikat berlangsung ataupun bagi yang sedang mempelajari klien ACME yang sedang digunakan, entah itu sekadar mengecek kredensial DNS yang dipakai, menguji coba konfigurasi yang telah ditetapkan, dll, tanpa mempengaruhi _rate limit_ aslinya.

Jika ingin menguji cobanya, Anda bisa ikuti caranya berikut:

**Langkah ke-1:** Masuk ke **"Google Cloud Console"** dan aktifkan **"Cloud shell"**-nya seperti biasa. Sebelum itu, pastikan bahwa Anda telah mengaktifkan Akses API-nya terlebih dahulu di Proyek yang Anda buat tadi

**Langkah ke-2:** Pastikan Anda telah memilih proyek sebelumnya dengan ciri bahwa ID Proyeknya tertera di dalam Terminalnya. Jika belum/tidak yakin, Anda bisa menyetelnya dengan perintah berikut:

```shell
gcloud config set project <PROJECT_ID>
```

Ganti `<PROJECT_ID>` dengan ID Proyek Anda.

**Langkah ke-3:** Anda perlu menggantikan Alamat URL _Endpoint_ untuk Google Public CA-nya dengan perintah berikut, lalu tekan "Enter":

```shell
gcloud config set api_endpoint_overrides/publicca https://preprod-publicca.googleapis.com/
```

**Langkah ke-4:** Setelah menggantikan Alamat URL _Endpoint-nya_, Anda perlu membuat kredensial EAB dengan perintah yang sama seperti di bagian sebelumnya. Kalau belum yakin, lupa atau merasa malas, Anda bisa _copy-paste_ perintah berikut:

```shell
gcloud publicca external-account-keys create
```

Sama seperti sebelumnya, keluarannya akan seperti berikut jika berhasil:

```plain
[b64MacKey: Qxxx_dxxxxxxxxxxxxxxxxxxxxx_cxxx-2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
keyId: bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx]
```

Hal yang perlu diperhatikan/dicatat adalah bahwa:

- Nilai dari `b64MacKey` adalah **"EAB HMAC Key"**-nya
- Nilai dari `keyId` adalah **"EAB Key ID"** atau **"EAB KID"**-nya

Selain hal di atas, hal yang perlu Anda catat adalah bahwa kredensial EAB yang Anda buat barusan adalah kredensial EAB untuk Mode Pementasan, jadi pastikan Anda memisahkan kredensial EAB untuk produksi dan mode pementasan jika Anda pernah membuat kredensial EAB sebelumnya.

Simpanlah kredensial tersebut dengan baik.

**Langkah ke-5:** Setelah selesai mencatat, Anda perlu mengembalikan Alamat URL _Endpoint-nya_ seperti semula dengan perintah berikut:

```shell
gcloud config unset api_endpoint_overrides/publicca
```

Setelah ini semua, pakai kredensialnya secepat mungkin, karena kredensial tersebut cuma bertahan selama 7 hari setelah pembuatan jika tidak dipakai dan hanya bisa dipakai sekali saja.

Meski begitu, akun untuk server ACME yang telah Anda daftarkan menggunakan kredensial tersebut tidak memiliki masa berlaku.

## Mengkaitkan Kredensial EAB dengan Perkakas Klien ACME

Setelah membuat kredensial EAB-nya, sekarang waktunya Anda gunakan kredensial tersebut ke dalam perkakas klien ACME dalam rangka mendaftarkan sebuah "akun" untuk server ACME-nya, dalam instruksi kali ini saya memakai acme.sh sebagai perkakas klien untuk protokol ACME-nya.

Untuk mendaftarkan sebuah akun dengan menggunakan Kredensial EAB yang telah dibuat sebelumnya, Anda dapat menggunakan perintah berikut:

```shell
acme.sh --register-account -m <ALAMAT_SUREL_KAMU> \
        --eab-kid <EAB_KID_KAMU> \
        --eab-hmac-key <EAB_HMAC_KEY_KAMU> \
        --server google
```

Ganti:

- `<ALAMAT_SUREL_KAMU>` menjadi alamat surel kamu
- `<EAB_KID_KAMU>` menjadi **"EAB KID"** yang telah kamu simpan sebelumnya
- `<EAB_HMAC_KEY_KAMU>` menjadi **"EAB HMAC Key"** yang telah kamu simpan sebelumnya

Jika ingin mendaftarkan sebuah akun untuk mode uji coba atau pementasannya, Anda bisa mengganti `google` pada argumen `--server` menjadi `googletest` dan pastikan bahwa Anda menggunakan kredensial EAB yang tepat untuk itu.

Jika registrasi berhasil, maka Anda sudah mulai bisa menerbitkan sertifikat SSL/TLS dengan menggunakan **"Google Public CA"**, lalu bisa Anda kelola sesuka hati melalui perkakas acme.sh.

## Menerbitkan sertifikat SSL/TLS dari Google

Untuk menerbitkan sertifikat SSL/TLS dari Google melalui acme.sh, maka Anda hanya perlu pelajari contoh perintah berikut:

```shell
acme.sh --issue \
        -d '*.contoh.com' \
        -d contoh.com \
        --dns dns_cf --server google
```

Perintah di atas akan menerbitkan sertifikat SSL/TLS dengan menggunakan **"Google Public CA"** sebagai CA-nya, sertifikat tersebut mencakup hanya untuk domain `*.contoh.com` dan `contoh.com` saja dengan menggunakan layanan DNS dari Cloudflare sebagai metode verifikasinya.

Jika Anda sudah lama menggunakan acme.sh sebelumnya, maka harusnya sudah familiar dengan perintah di atas yang sebenarnya cuma nambahin parameter `--server google` saja. Kalau belum pernah sama sekali menggunakannya, saran saya kamu pelajari itu di [artikel saya sebelumnya](/cara-memasang-zerossl-di-netlify-bunnycdn/#menerbitkan-sertifikat-ssl).

Anda juga bisa menggantikan `google` pada parameter `--server` menjadi `googletest` jika Anda ingin menguji coba proses penerbitan sertifikat tanpa harus mempengaruhi _rate limit_ aslinya.

Perkakas acme.sh menggunakan ZeroSSL sebagai CA baku, sehingga Anda tetap diharuskan untuk menggunakan parameter `--server google` setiap kali menerbitkan sertifikat SSL/TLS baru dari Google.

Jika Anda ingin menggantikan CA bakunya, Anda bisa memakai perintah berikut:

```shell
acme.sh --set-default-ca --server google
```

Dengan begini, Anda tidak perlu lagi memakai parameter `--server google` hanya sekadar menerbitkan sertifikat SSL/TLS dari Google saja.

Nah, artikelnya saya cukupkan sampai sini saja. Jika Anda mempunyai pertanyaan lain, silakan tanyakan itu di kolom komentar yang tersedia, tapi sebelum bertanya, ada baiknya bila Anda membaca dan memahami pertanyaan yang (akan) sering ditanya beserta jawabannya agar bisa menjadi referensi buat Anda.

## Pertanyaan yang (akan) sering ditanya {#pertanyaan-dan-jawaban}

### Pertanyaan ke-1: Apakah saya perlu memasukkan kartu kredit/debit terlebih dahulu agar dapat menggunakan Google Cloud Console? {#pertanyaan-ke1}

Seharusnya tidak perlu kamu masukkan dan semua itu bisa Anda lakukan secara gratis tanpa membayar biaya sepeser pun.

Hanya saja, maksimum proyek yang bisa Anda buat adalah sebanyak 10 proyek per Akun. Jadi, jika Anda pernah memiliki/membuat proyek sebelumnya di **"Google Cloud Console"** atau **Google Developer Console**, maka saya sangat menyarankan agar memakai proyek yang ada saja.

### Pertanyaan ke-2: Apakah semua sertifikat SSL/TLS yang diterbitkan oleh Google Public CA ini gratis? {#pertanyaan-ke2}

**Ya, sepenuhnya gratis**. Semua jenis sertifikat TLS (Standar, _Multi-domain_, dan _Wildcard_) dengan algoritma RSA atau ECC dapat diterbitkan secara gratis via protokol ACME. Namun, ini bersifat _self-managed_, artinya Anda bertanggung jawab penuh atas pengelolaannya tanpa dukungan langsung dari Google.

### Pertanyaan ke-3: Berapa lama masa aktif sertifikat SSL/TLS dari Google Public CA ini? {#pertanyaan-ke3}

Sertifikat Google Trust Services berdurasi maksimum 90 hari. Standar ACME memungkinkan permintaan masa aktif lebih singkat, bahkan hingga 1 hari dan Google mampu mengikutinya.

Namun, Google menyarankan minimum 3 hari untuk menghindari [masalah ketidaksesuaian waktu sistem](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/46359.pdf) atau tumpang tindih validitas yang dapat mengakibatkan gangguan akses.

### Pertanyaan ke-4: Bagaimana caranya agar saya bisa menerbitkan sertifikat SSL/TLS dengan masa aktif kurang dari 90 hari? {#pertanyaan-ke4}

Di acme.sh, Anda bisa tambahkan parameter `--valid-to <tanggal waktu>` saat ingin menerbitkan sebuah sertifikat.

Contoh:

```shell
acme.sh --issue \
        -d '*.contoh.com' \
        -d contoh.com \
        --dns dns_cf --valid-to "+30d"
```

Perintah di atas akan menerbitkan sertifikat SSL/TLS untuk domain `*.contoh.com` dan `contoh.com` dengan masa berlaku selama 30 hari.

Contoh lainnya:

```shell
acme.sh --issue \
        -d '*.contoh.com' \
        -d contoh.com \
        --dns dns_cf --valid-to "+30h"
```

Sama seperti perintah sebelumnya, bedanya hanya masa aktifnya selama 30 jam saja.

Format yang diterima oleh parameter di atas adalah `+*d` dan `+*h` saja, selain itu akan ditolak.

Selain menggunakan format relatif, Anda juga dapat menggunakan format absolut dengan menentukan tanggal dan waktunya secara lengkap. Penulisan tanggal dan waktunya harus memenuhi standar ISO 8601 atau sesuai dengan format [RFC3339](https://www.rfc-editor.org/rfc/rfc3339), sehingga ditulis seperti ini: `2022-04-01T08:10:33Z`

Contoh:

```shell
acme.sh --issue \
        -d '*.contoh.com' \
        -d contoh.com \
        --dns dns_cf --valid-to "2022-04-01T08:10:33Z"
```

Perintah di atas akan menerbitkan sertifikat SSL/TLS untuk domain `*.contoh.com` dan `contoh.com` dengan masa berlaku pada tanggal 01 April 2022 dengan pukul 08:10:33 dalam waktu UTC.

Menggunakan format absolut membuat acme.sh tidak sanggup memperbarui sertifikatnya secara otomatis, jadi disarankan pakai format relatif. Untuk lebih lanjut, silakan kunjungi [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/Validity).

### Pertanyaan ke-5: Apakah sertifikat SSL/TLS Google Public CA merupakan sertifikat langsung Google Trust Services (GTS)? Bagaimana kompatibilitasnya? {#pertanyaan-ke5}

**Ya, langsung dari GTS**. Kompatibilitas bisa dijamin melalui karena dua hal berikut:

1. _Cross-sign_ dengan [GlobalSign Root CA - R1](https://crt.sh/?id=88) (Halaman demonya [di sini](https://valid.r1.roots.globalsign.com/)) yang telah tersedia secara luas sejak 1999 dan berlaku dari tahun 1998.
2. Penggunaan aktif di seluruh layanan Google termasuk Penelusuran, YouTube, dan Google Drive — membuktikan kompatibilitas perangkat yang sangat baik.

Sehingga Anda tidak perlu khawatir tentang masalah kompatibilitas, ada halaman demo yang dapat Anda coba juga.

### Pertanyaan ke-6: Kalau saya menerbitkan sertifikat SSL/TLS dengan memakai ECC sebagai Algoritma Kunci Publiknya, apakah rantai yang dipakai itu murni ECC juga? {#pertanyaan-ke6}

Sayangnya, tidak. Alasannya kurang tahu dan kapan menggunakan rantai murni ECC yang sepenuhnya juga saya kurang tahu, yang jelas bukan sekarang ini menurut klaim mereka.

### Pertanyaan ke-7: Saya memakai perkakas ACME selain acme.sh, seperti Certbot, apa Alamat URL untuk Direktori ACME-nya? {#pertanyaan-ke7}

Alamat URL-nya sebagai berikut:

Server Produksi (baku):

```plain
https://dv.acme-v02.api.pki.goog/directory
```

Server Uji coba:

```plain
https://dv.acme-v02.test-api.pki.goog/directory
```

### Pertanyaan ke-8: Kenapa kamu memakai acme.sh? {#pertanyaan-ke8}

Perkakas acme.sh dipilih karena alasan berikut:

- Simpel dan mudah dipelajari
- Fiturnya lengkap, seperti:
  - Dukungan penyedia DNS yang banyak (termasuk Cloudflare DNS, Netlify DNS, Bunny DNS, dll)
  - Pilihan CA yang cukup banyak (Let's Encrypt, ZeroSSL, SSL\.com, Buypass Go SSL dan Google Trust Services)
  - Bisa menggunakan CA kustom
  - Pengelolaan sertifikat (meliputi penerbitan, pencabutan, penghapusan, konfigurasi, penginangan, dan pembaruan sertifikat)
  - Menggunakan _Cron job_ untuk memperbarui sertifikat secara otomatis
  - Dan lain-lain
- Tidak memerlukan akses _root_ sehingga lebih aman
- Berbasis _Shell_ yang portabel dan kompatibel di hampir semua sistem operasi
- Semuanya (termasuk konfigurasinya) terpusat di satu folder, yakni `~/.acme.sh` sehingga mudah dipindahkan

Alasan-alasan tersebutlah yang membuat saya secara pribadi lebih menyukai ini ketimbang perkakas klien ACME lain, seperti Certbot misalnya.

### Pertanyaan ke-9: Apa kelebihan dan kekurangan dari Google Public CA menurut kamu? {#pertanyaan-ke9}

Kelebihan:

- Penerbitan/pembaruan sertifikat yang cepat. Hal ini dikarenakan ia menggunakan infrastruktur jaringan dari Google untuk server ACME-nya dan kita penggunanya akan diarahkan ke Server terdekat saat memakainya, sehingga proses penerbitan/pembaruan akan menjadi jauh lebih cepat
- Lebih minim gangguan, sehingga kamu lebih jarang menemukan galat 5xx karena infrastruktur jaringan dari Google itu tadi
- Alamat URL OCSP dan CRL yang berbeda di setiap sertifikat (Entah ini merupakan sesuatu kelebihan atau bukan, mungkin lebih ke "keunikan")
- Kamu bisa menerbitkan sertifikat dalam bentuk standar, _Multi-domain_, dan bahkan _Wildcard_ baik menggunakan RSA ataupun ECC sebagai algoritma kunci publiknya
- Masa berlaku sertifikat bervariasi, bisa dimulai dari 1 hari sampai 90 hari ke depan, walaupun disarankan minimum 3 hari
- Sertifikat yang diterbitkannya dapat digunakan oleh hampir semua perangkat. Untuk alasannya, silakan lihat jawaban untuk [pertanyaan ke-5](#pertanyaan-ke5)
- Yang paling penting adalah semuanya bisa digunakan secara cuma-cuma alias gratis

Kekurangan:

- Algoritma Kunci Publik pada rantai sertifikat di atasnya masih menggunakan RSA, meski sertifikat TLS-nya diterbitkan menggunakan ECC, tapi rantainya tidak benar-benar murni ECC, tidak seperti ZeroSSL dan Let's Encrypt. Tapi, Cloudflare sepenuhnya menggunakan rantai murni ECC, entah bagaimana caranya silakan tulis di komentar jika ada
- ~~Tidak mendukung nama domain Unicode yang disandikan atau _di-encode_ menggunakan Punycode.~~

    ~~Sehingga kemungkinan besar tidak ada dukungan nama domain terinternasionalisasikan (bahasa Inggris: **Internationalized Domain Names** atau disingkat menjadi **IDN**) dan huruf lain selain alfabet, termasuk emoji~~

    **PEMBARUAN Senin, 14 Juli 2025:** Sepertinya CA ini sudah bisa menerbitkan sertifikat untuk nama domain/subdomain terinternasionalisasikan, termasuk emoji, berdasarkan [halaman web ini](https://acmeprotocol.dev/getting-started/) entah benar tapi tidak terdokumentasikan atau tidak. Silakan kunjungi [演示测试.farrelf.my.id](https://演示测试.farrelf.my.id) untuk mengujinya

- Jika Anda ingin situs web atau blog-nya diakses oleh pengguna di Tiongkok Daratan (bukan Hong Kong, Makau dan Taiwan, tentunya), tidak saya sarankan untuk memakai sertifikat TLS ini karena seluruh layanan Google, termasuk untuk OCSP, CRL dan ekstensi AIA-nya diblokir oleh GFW (_Great Firewall_) yang berimbas pada pemuatan situs web Anda karena masalah pada pemuatan sertifikatnya/jabat tangan TLS-nya.

    Tapi, kebanyakan peramban web secara baku tidak lagi mengecek pencabutan sertifikat lebih lanjut jika server-nya tidak bisa diakses, sehingga web/aplikasi dengan sertifikat TLS tersebut tetap dapat dimuat seperti biasanya dan sertifikat tetap dianggap masih valid setelah dicabut, atau bahkan bisa jadi mereka tidak mengeceknya sama sekali.

    Jadi selama sertifikat dan _private key-nya_ dipasang dengan lengkap dan benar, mungkin poin ini harusnya sudah tidak lagi berlaku. Mungkin saja saya bisa salah mengenai ini, jadi mohon beri masukkannya melalui kolom komentar.

Untuk perbandingan antar CA ACME lebih lanjut, silakan kunjungi salah satu halaman dokumentasi Posh-ACME dengan [klik di sini](https://poshac.me/docs/v4/Guides/ACME-CA-Comparison/).

Mungkin hal di atas bisa saja ada yang salah, jika ada koreksi, silakan berikan masukkannya melalui kolom komentar.

### Pertanyaan ke-10: Apa pengalamanmu saat menggunakan Google Public CA? Apakah ada masalah sejauh ini? {#pertanyaan-ke10}

Sejauh ini belum ada masalah apa pun, baik saat penerbitan sampai pemakaiannya. Penerbitannya bisa dibilang cepat, jauh lebih cepat ketimbang saat saya memakai ZeroSSL dan saya belum pernah menemukan galat 5xx yang membuat perkakas acme.sh mengulangi proses penerbitan sertifikat.

Jika ada masalah saat pemakaian ataupun pembaruan sertifikat (semoga jangan), mungkin akan saya perbarui juga di sini.

Untuk pencabutannya belum saya coba, karena saya belum sempat dan belum ada urgensi juga untuk mencabut sertifikatnya, mungkin ke depannya akan saya coba.

### Pertanyaan ke-11: Saya memasang CAA Record di dalam pengaturan DNS pada Domain saya, apa CAA Record yang harus saya isi? {#pertanyaan-ke11}

Pastikan Anda menambahkan `pki.goog` di dalamnya. Dengan ini, Anda akan mengizinkan GTS untuk menerbitkan sertifikat SSL/TLS-nya untuk domain Anda.

Untuk referensinya/selebihnya, bisa kunjungi URL direktori ACME-nya secara langsung melalui peramban web-mu, alamat URL-nya sudah saya sebutkan di jawaban pada [pertanyaan ke-7](#pertanyaan-ke7) lalu lihat pada bagian `caaIdentities` dan di situ akan ada `pki.goog` sebagai isi dari `caaIdentities` yang merupakan **CAA Record** yang bisa Anda isi untuk mengizinkannya.

Hal di atas bukan hanya berlaku untuk GTS saja, tapi berlaku juga untuk URL direktori ACME lainnya seperti Let's Encrypt, ZeroSSL, Buypass, SSL.com, dll yang bisa Anda coba sendiri.

Namun untuk GTS ini, ketika alamat URL-nya dibuka, maka keluarannya berupa teks JSON yang sudah diminimalkan (_minified_), sehingga tampilannya tidak enak dilihat dan dibaca oleh kebanyakan orang pada umumnya.

Untuk mempercantik tampilan/keluaran JSON, silakan gunakan ekstensi berikut di peramban web Anda:

- Google Chrome, Chromium dan keluarga: [JSON Lite](https://chromewebstore.google.com/detail/json-lite/acacmjcicejlmjcheoklfdchempahoag), [JSON Formatter](https://chromewebstore.google.com/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa), [JSON Formatter oleh Arnav Kumar](https://chromewebstore.google.com/detail/json-formatter/gpmodmeblccallcadopbcoeoejepgpnb) atau [JSON-handle](https://chromewebstore.google.com/detail/json-handle/iahnhfdhidomcpggpaimmmahffihkfnj)
- Mozilla Firefox, Zen Browser dan keluarga: [JSON Lite](https://addons.mozilla.org/firefox/addon/json-lite/) atau [JSON Formatter oleh Arnav Kumar](https://addons.mozilla.org/firefox/addon/json_formatter/)

## Penutup

Yap, sekian saja artikelnya untuk kali ini, bagaimana? Mudah, bukan? Dengan begini, Anda bisa memakai sertifikat SSL/TLS dari Google secara gratis tanpa perlu memakai layanan dari mereka untuk Web/Blog-nya.

Itu aja? Yah, tidaklah, selanjutnya ya pasang sertifikat SSL/TLS-nya ke dalam Situs Web/Blog kamu agar bisa digunakan, jika Anda memakai Netlify, Bunny CDN, atau/dan cPanel, saya sarankan Anda baca [artikel saya sebelumnya](/cara-memasang-zerossl-di-netlify-bunnycdn/#memasang-ssl) dan mulai bacanya dari bagian **Memasang Sertifikat SSL**.

Maaf yah buat pengguna Certbot dan Klien ACME lainnya, baris perintahnya tidak saya bahas di sini, karena saya sendiri belum pernah menggunakannya, saya sendiri memakai acme.sh sebagai perkakas klien ACME.

Terima kasih bagi Anda yang telah membaca serta mempelajari yang ada di artikel ini, mohon maaf jika artikel ini memiliki beberapa kekeliruan dan kesalahan, seperti salah ketik, kurang jelas, salah informasi, dll, karena artikel ini jauh dari sempurna.

Saya akan berusaha untuk terus-terusan memperbarui artikel ini seiring berkembangnya Informasi yang ada, karena yang saya pos ini adalah tutorial, sehingga perlu adanya penyesuaian.

Jika adanya kesalahan dan kekeliruan, atau kalau Anda memiliki pertanyaan lainnya, bisa Anda berikan masukkan melalui kolom komentar yang tersedia. Masukkan dari Anda akan sangat berarti bagi saya dan artikel ini untuk kedepannya nanti.

## Penggunaan Gambar dan Atribusi

Berkas-berkas Gambar (seperti Cuplikan layar dan Gambar lainnya) yang di gunakan di dalam artikel ini, disediakan di dalam [repositori blog ini](https://github.com/FarrelF/Blog).

Jika Anda ingin menjelajahinya, silakan kunjungi Alamat URL berikut:

```plaintext
https://github.com/FarrelF/Blog/tree/main/content/post/2022/05/15-cara-mendapatkan-sertifikat-ssl-dari-google
```

Google dan logonya merupakan Merek Dagang, Merek Dagang Terdaftar, atau/dan Pakaian Dagang dari "Google LLC", sehingga nama merek dan logo tersebut bukanlah milik saya pribadi.
