---
Title: Cara memasang ZeroSSL + Renew Otomatis di Netlify dan BunnyCDN
Slug: memasang-zerossl-di-netlify-bunnycdn
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Info Blog
    - Tutorial
Draft: true
Date: 2021-07-10 22:33:00+07:00
Tags:
    - Sertifikat SSL
    - ZeroSSL
    - Netlify
    - BunnyCDN
readMore: true
DescriptionSEO: Apakah Anda ingin memasang ZeroSSL, tapi Anda juga ingin bisa me-renew nya secara otomatis di Netlify dan BunnyCDN? Jika iya, Anda bisa baca artikel ini untuk mengetahuinya.
Description: >
    Blog ini telah menggunakan ZeroSSL sebagai Sertifikat SSL nya, tapi kendalanya adalah bahwa SSL ini tidak didukung oleh Penyedia Web secara luas, artinya SSL tersebut belum bisa di-_renew_ secara otomatis.
    
    
    Tapi akhirnya, kendala tersebut bisa saya atasi berkat bantuan dari referensi-referensi yang ada dan saya ingin membagikan nya pada Anda, terutama untuk pengguna [Netlify](https://www.netlify.com) dan [BunnyCDN](https://afiliasi.farrel.franqois.id).
    
    
    Jika Anda ingin memasang Sertifikat SSL dari ZeroSSL pada Web Statis Anda yang menggunakan Netlify sebagai Hosting atau menggunakan BunnyCDN, serta me-_renew_ nya secara otomatis atau Anda yang sekadar ingin tahu saja, mungkin Anda bisa baca artikel ini.
---
## Daftar Isi
{{< toc >}}

## Pembuka
Artikel kali ini akan membahas tentang Cara memasang ZeroSSL + Renew secara Otomatis di Netlify dan BunnyCDN.

### Persyaratan
Di artikel ini, Anda akan mempelajari membuat Sertifikat SSL dengan menggunakan [acme.sh](https://acme.sh) yang hanya kompatibel dengan Sistem Operasi berbasis *nix/UNIX-like, termasuk tapi tidak terbatas pada GNU/Linux, macOS, BSD dan Android.

Jika Anda menggunakan Windows, terutama Windows 10, maka Anda bisa gunakan fitur [WSL (Windows Subsystem for Linux)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) agar Anda bisa menggunakan Sistem Operasi GNU/Linux di dalam Windows.

Sedangkan jika Anda menggunakan Android, maka Anda bisa gunakan Termux untuk itu, gunakan versi terbaru untuk pengalaman yang lebih nyaman.

Pastikan Termux tidak diunduh melalui [Google Play Store](https://play.google.com/store/apps/details?id=com.termux), melainkan melalui [F-Droid nya](https://f-droid.org/repository/browse/?fdid=com.termux).

Kenapa? Karena Termux sudah tidak lagi diperbarui di Google Play Store sejak 02 November 2020 yang lalu, untuk alasan nya silahkan Anda baca [dari sini](https://wiki.termux.com/wiki/Termux_Google_Play).

Setelah Instal Termux, hal yang perlu Anda lakukan adalah perbarui semua paket-paket yang ada, lalu instal paket-paket yang diperlukan dengan perintah berikut:

```bash
$ pkg update; pkg upgrade
$ pkg install curl wget openssl-tools cronie termux-services
```

Kalau perlu, ganti _Repository_ pada Termux dengan perintah `termux-change-repo` dan gunakan _Repository_ Resmi dari Termux agar mendapatkan versi terbaru, barulah Anda eksekusikan perintah di atas. Setelah itu, mulai ulang Termux Anda agar perubahan nya bisa diterapkan.

## Sebelum membuat Sertifikat SSL
### Membuat Akun ZeroSSL dan mendapatkan Kredensial EAB nya {#membuat-akun-zerossl}
**Catatan:** Jika Anda belum mempunyai Akun nya dan ingin membuatnya tanpa melalui Web, lewati ini jika Anda tidak ingin mendaftar melalui Web nya, [lanjut saja](#install-acme-sh).

Sebelum Anda membuat Sertifikat SSL nya, maka Anda disarankan untuk mendaftar akun ZeroSSL nya terlebih dahulu melalui [Situs Webnya](https://zerossl.com).

Setelah mendaftar, Anda tidak perlu membuat Sertifikatnya di sana, melainkan Anda hanya perlu Kredensial EAB yakni "EAB KID" dan "EAB HMAC Key" nya saja. Langkah-langkahnya sebagai berikut:

0. Daftar Akun ZeroSSL nya [di sana](https://app.zerossl.com/signup) dan Login setelah itu (Atau, Anda hanya perlu [Login](https://app.zerossl.com/login) saja jika Anda sudah pernah mendaftar akun sebelumnya)
1. Pada Dasbor ZeroSSL, klik "Developer"
2. Setelah itu, pada bagian "EAB Credentials for ACME Clients", klik _Button_ "Generate"
3. Simpan "EAB KID" dan "EAB HMAC Key" yang telah dihasilkan itu dengan baik, nanti akan digunakan lagi untuk acme.sh
4. Setelah menyimpan nya, Anda tinggal klik _Button_ "Done" dan Selesai

Jika Anda tidak memahami langkah-langkah di atas, maka Anda dapat melihat Cuplikan Layar berikut yang cukup menyesuaikan dengan langkah-langkah di atas: (Silahkan perbesar gambarnya dengan mengklik nya)

![1](ZeroSSL_EAB_Credential_1.png) ![2](ZeroSSL_EAB_Credential_2.png)

Setelah Kredensial EAB dibuat, ya sudah lanjut saja ke langkah berikutnya, yakni Instal acme.sh, Anda sama sekali tidak perlu membuat Sertifikat SSL nya di sana.

### Instal acme.sh {#install-acme-sh}
Setelah mendaftar akun ZeroSSL, salah satu yang perlu Anda lakukan adalah meng-instal acme.sh terlebih dahulu di dalam Sistem Operasi Anda.

Tidak perlu menggunakan Akun Administrator atau `root` untuk meng-instal nya, atau tidak perlu dieksekusikan dengan perintah `sudo`, cukup gunakan saja akun Anda. (Bahkan, lebih baik gini)

Cara meng-instal nya adalah dengan meng-eksekusikan salah satu perintah berikut:

Dengan cURL:

```bash
$ curl https://get.acme.sh | sh -s email=my@example.com
```

Atau, dengan GNU Wget:

```bash
$ wget -O -  https://get.acme.sh | sh -s email=my@example.com
```

Ganti `my@example.com` dengan Alamat Surel Anda. 

Setelah selesai instal, pastikan bahwa acme.sh dapat dieksekusi dengan baik dengan mengetikkan `acme.sh --version` di dalam Terminal, lalu tekan tombol "<key>Enter</key>".

Jika dapat dieksekusi dengan baik, maka selamat Anda telah bisa menginstal nya. Jika tidak, maka Anda perlu memasukkan direktori acme.sh kedalam variabel `PATH`, dengan salah satu cara berikut:

Untuk pengguna GNU Bash:

```bash
$ cp ${HOME}/.bashrc ${HOME}/.bashrc.1  ## Backup dulu
$ echo 'PATH="${PATH}:${HOME}/.acme.sh" && export PATH' >> ${HOME}/.bashrc
$ source ${HOME}/.bashrc
```

Untuk pengguna Zsh:

```zsh
$ cp ${HOME}/.zshrc ${HOME}/.zshrc.1  ## Backup dulu
$ echo 'PATH="${PATH}:${HOME}/.acme.sh" && export PATH' >> ${HOME}/.zshrc
$ source ${HOME}/.zshrc
```

### Verifikasi DNS di acme.sh
Agar Sertifikat SSL dapat dibuat melalui Protokol ACME, maka pengguna diperlukan melakukan verifikasi. Salah satunya adalah dengan verifikasi DNS.

Verifikasi DNS merupakan metode verifikasi yang paling dianjurkan, selain mudah dan hanya pemilik domain yang bisa melakukan nya, Anda juga dapat membuat Sertifikat SSL untuk semua Subdomain Anda (Wildcard SSL) dengan mudah.

Agar acme.sh dapat melakukan verifikasi DNS secara otomatis saat membuat dan memperbarui Sertifikat SSL, maka acme.sh harus dapat mengakses dan merubah _DNS Record_ pada akun Layanan DNS Otoritatif Anda.

Untuk itu, Anda perlu memberikan acme.sh izin untuk mengaksesnya dengan memberinya sebuah _Token_, Kunci API atau bahkan Nama Pengguna dan Kata Sandi untuk mengakses akun tertentu.

#### Untuk Pengguna DNS Otoritatif Cloudflare
Jika Anda menggunakan Cloudflare sebagai DNS Otoritatif untuk Domain Anda, Anda tinggal buat sebuah "API Token" (`CF_Token`) dan dapatkan "Account ID" (`CF_Account_ID`) nya, jika berkenan, Anda bisa mendapatkan "Zone ID" (`CF_Zone_ID`) nya juga agar acme.sh hanya menargetkan ke 1 Domain saja.

Untuk membuat "API Token" nya, silahkan Anda baca [dokumentasi nya](https://developers.cloudflare.com/api/tokens/create), di sana sudah dijelaskan secara lengkap tentang bagaimana cara membuat "API Token" nya.

Buatlah "API Token" yang diizinkan untuk mengedit DNS nya dengan memilih "Edit zone DNS" sebagai Templat saat ingin membuatnya.

Untuk mendapatkan "Account ID" dan "Zone ID" nya, Anda tinggal ke [Halaman Dasbor Cloudflare](https://dash.cloudflare.com), pilih Domain nya, lalu gulirkan kebawah, nanti akan ketemu Informasi mengenai "Account ID" dan "Zone ID", seperti di bawah ini:

!["Account ID" dan "Zone ID" di Cloudflare](Cloudflare_Zone_and_Account_ID.png)

Nah, setelah semuanya berhasil didapat, maka Anda tinggal masukkan saja semua Informasinya ke dalam berkas `${HOME}/.bashrc` atau `${HOME}/.zshrc`. Dengan cara berikut:

Untuk Pengguna GNU Bash:

```bash
### Di bawah ini adalah perintah untuk melakukan Backup .bashrc
### Agar bisa dikembalikan lagi jika adanya keteledoran
$ cp ${HOME}/.bashrc ${HOME}/.bashrc.1

### Di bawah ini adalah Informasi yang wajib dimasukki
$ echo 'CF_Token="API_TOKEN_KAMU_DI_SINI" && export CF_Token' >> ${HOME}/.bashrc
$ echo 'CF_Account_ID="ACCOUNT_ID_KAMU_DI_SINI" && export CF_Account_ID' >> ${HOME}/.bashrc

### Anda juga dapat memasukkan "Zone ID" jika Anda ingin acme.sh menargetkan hanya
### untuk 1 Domain saja, tapi ini bukanlah hal yang wajib, jadi sebaiknya tidak usah saja
$ echo 'CF_Zone_ID="ZONE_ID_KAMU_DI_SINI" && export CF_Zone_ID' >> ${HOME}/.bashrc

### 'Source' ke .bashrc agar Shell diperbarui
$ source ${HOME}/.bashrc
```

Untuk Pengguna Zsh:

```zsh
### Di bawah ini adalah perintah untuk melakukan Backup .zshrc
### Agar bisa dikembalikan lagi jika adanya keteledoran
$ cp ${HOME}/.zshrc ${HOME}/.zshrc.1

### Di bawah ini adalah Informasi yang wajib dimasukki
$ echo 'CF_Token="API_TOKEN_KAMU_DI_SINI" && export CF_Token' >> ${HOME}/.zshrc
$ echo 'CF_Account_ID="ACCOUNT_ID_KAMU_DI_SINI" && export CF_Account_ID' >> ${HOME}/.zshrc

### Anda juga dapat memasukkan "Zone ID" jika Anda ingin acme.sh menargetkan hanya
### untuk 1 Domain saja, tapi ini bukanlah hal yang wajib, jadi sebaiknya tidak usah saja
$ echo 'CF_Zone_ID="ZONE_ID_KAMU_DI_SINI" && export CF_Zone_ID' >> ${HOME}/.zshrc

### 'Source' ke .zshrc agar Shell diperbarui
$ source ${HOME}/.zshrc
```

Udah itu aja, jika Anda menggunakan Cloudflare dan sudah memasukkan Informasi-informasi di atas, maka Anda hanya perlu langsung melanjutkan ke [langkah berikutnya](#registrasi-akun-acme-sh).

#### Untuk Pengguna DNS Otoritatif lain
Jika Anda menggunakan Layanan DNS Otoritatif selain Cloudflare, seperti Hurricane Electric Free DNS, Constellix, NS1, ClouDNS, Amazon Route53, dll, maka Anda perlu membaca [halaman dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).

Karena setiap Penyedia DNS Otoritatif mempunyai cara yang berbeda-beda untuk akses nya. Jadi, silahkan ikuti yang ada di dokumentasinya.

Jika sudah, silahkan lanjut ke [langkah berikutnya](#registrasi-akun-acme-sh).

### Registrasi Akun melalui acme.sh {#registrasi-akun-acme-sh}
Secara bawaan, acme.sh menggunakan ZeroSSL sebagai CA (Certificate Authority) nya, jadi jika Anda adalah orang yang pertama kali menggunakan acme.sh, silahkan registrasikan akun ZeroSSL Anda terlebih dahulu ke Server ACME nya menggunakan acme.sh dengan perintah berikut:

```bash
$ acme.sh --register-account --eab-kid EAB_KID_KAMU_DI_SINI --eab-hmac-key EAB_HMAC_KEY_KAMU_DI_SINI
```

Ganti `EAB_KID_KAMU_DI_SINI` dan `EAB_HMAC_KEY_KAMU_DI_SINI` dengan "EAB KID" dan "EAB HMAC Key" yang telah kamu simpan sebelumnya.

Atau, jika Anda belum pernah daftar sama sekali dan ingin mendaftarkan akun ZeroSSL, maka Anda dapat eksekusi perintah berikut:

```bash
$ acme.sh  --register-account -m myemail@example.com
```

Ganti `myemail@example.com` dengan Alamat Surel Anda yang valid.

Setelah itu, kamu telah dapat menggunakan acme.sh seperti biasanya untuk membuat dan memperbarui Sertifikat SSL kamu.

## Membuat Sertifikat SSL dengan acme.sh {#membuat-sertifikat-ssl}
Nah, setelah mengikuti beberapa langkah, akhirnya Anda bisa sampai di sini, yakni membuat Sertifikat SSL.

Ada beberapa cara untuk membuat sertifikat SSL Anda menggunakan acme.sh, tidak perlu Anda ikuti semua dan sesuaikan dengan selera Anda. Berikut adalah cara-cara nya:

### Membuat Sertifikat SSL untuk 1 Domain dan 1 Subdomain
Jika Anda ingin membuat Sertifikat SSL hanya untuk 1 Domain, Anda dapat eksekusikan perintah berikut:

```bash
$ acme.sh --issue -d domain.com -d www.domain.com
```

Jika Anda mengeksekusi perintah di atas, maka Anda membuat Sertifikat SSL hanya untuk 1 Domain dan 1 Subdomain saja, yakni `domain.com` dan `www.domain.com`.

Parameter `-d` berfungsi untuk target domain nya dan untuk domain apa Sertifikat SSL itu dibuat, isikan itu dengan Domain Anda.

Parameter `--issue` berfungsi agar acme.sh membuat Sertifikat SSL Anda, itu cuma sebagai opsi awal. Opsi lain nya adalah `--renew` untuk memperbarui Sertifikat SSL yang ada, `--revoke` untuk mencabut Sertifikat SSL, dll.

### Membuat Sertifikat SSL dengan Menggunakan DNS sebagai Verifikasi
Jika Anda ingin membuat Sertifikat SSL yang menggunakan DNS sebagai Verifikasi nya, maka Anda tinggal tambahkan saja parameter `--dns nama_dns`. Contohnya seperti berikut:

```bash
$ acme.sh --issue -d domain.com -d www.domain.com --dns dns_cf
```

Perintah di atas jika dieksekusi maka acme.sh akan membuat Sertifikat SSL untuk `domain.com` dan `www.domain.com` dengan menggunakan DNS dari Cloudflare sebagai Verifikasi.

Jika Anda menggunakan Penyedia DNS Otoritatif selain Cloudflare, ganti saja `dns_cf` nya menjadi nama-nama berkas yang tampil [di sana](https://github.com/acmesh-official/acme.sh/tree/master/dnsapi).

Misalnya: Anda ingin membuat sebuah sertifikat SSL untuk `domain.com` dan ingin menggunakan DNS dari Constellix sebagai Verifikasi nya, karena nama berkas di sana nya adalah `dns_constellix`, maka Anda tinggal tambahkan saja parameter `--dns dns_constellix`. Jadinya seperti berikut:

```bash
$ acme.sh --issue -d domain.com -d www.domain.com --dns dns_constellix
```

Atau, Anda bisa baca halaman [dokumentasinya](https://github.com/acmesh-official/acme.sh/wiki/dnsapi), sebenarnya di sana juga telah disediakan cara membuat Sertifikat SSL dengan menggunakan DNS sebagai Verifikasi nya pada masing-masing Penyedia.

Nah, sekarang paham, kan? Ini juga sangat penting untuk membuat Sertifikat SSL yang _Wildcard_, karena Verifikasi melalui DNS merupakan salah satu syarat yang wajib.

### Membuat Sertifikat SSL untuk Banyak Domain dan Subdomain
Untuk membuat Sertifikat SSL yang menargetkan Banyak Domain dan Subdomain, sebenarnya Anda tinggal parameter `-d` dengan banyak juga untuk masing-masing domain atau subdomain nya. Contohnya seperti berikut:

Untuk 2 Domain dan 4 Subdomain:

```bash
$ acme.sh --issue -d domain1.com -d www.domain1.com -d sub.domain1.com -d domain2.com -d www.domain2.com -d sub.domain2.com
```

Untuk 4 Domain saja:

```bash
$ acme.sh --issue -d domain1.com -d domain2.com -d domain3.com -d domain4.com
```

Dan seterusnya akan seperti itu caranya.

### Membuat Sertifikat SSL yang menjangkau Seluruh Subdomain nya
Jika Anda ingin membuat Sertifikat SSL yang menjangkau seluruh Subdomain (Wildcard), maka Anda tinggal tambahkan parameter `-d "*.domain.com"` saja. Tapi Anda juga harus menambahkan parameter `--dns nama_dns`, karena dibutuhkan verifikasi melalui DNS.

Contohnya seperti berikut:

```bash
$ acme.sh --issue -d domain.com -d "*.domain.com" --dns dns_cf
```

Jika Anda mengeksekusi perintah di atas, maka Anda membuat Sertifikat SSL hanya untuk 1 Domain dan seluruh Subdomain nya, yakni `domain.com` dan `*.domain.com` dengan menggunakan DNS dari Cloudflare sebagai Verifikasi.

Kenapa dikutip _Wildcard_ nya? Karena terkadang _Shell_ lain tidak dapat meng-intepretasi tanda bintang dengan baik jika tidak dikutip, seperti Zsh misalnya.

Apakah itu menjangkau Sub-subdomain seperti `sub.sub.domain.com`? Tentu saja tidak, karena sertifikat SSL cuma dibuat untuk `*.domain.com`, yang mana cuma menjangkau `sub1.domain.com`, `sub2.domain.com`, dst, bukan `sub.sub.domain.com`.

Jika Anda mau seperti itu, tambahkan Subdomain Anda beserta _Wildcard_ nya, jadi parameter yang Anda tambahkan adalah `-d sub.domain.com -d "*.sub.domain.com"`. 

Hasilnya seperti berikut:

```bash
$ acme.sh --issue -d domain.com -d "*.domain.com" -d sub.domain.com -d "*.sub.domain.com" --dns dns_cf
```

Nah, sekarang paham, kan?

### Membuat Sertifikat SSL dengan kunci RSA-3072

## Tunggu, ZeroSSL Gratis? {#zerossl-gratis}
## Memasang Sertifikat SSL {#memasang-ssl}
### Di Netlify
### Di BunnyCDN
### Lain nya

## _Renew_ SSL secara Otomatis {#renew-ssl}
## ZeroSSL daripada Let's Encrypt, kenapa? {#zerossl-vs-lets-encrypt}
### Menggunakan Sectigo sebagai Akar nya
### Tidak(/Belum?) menerapkan _Rate Limit_
### Mengelola Sertifikat SSL dengan Antarmuka Pengguna (UI)

## Pertanyaan yang (akan) sering ditanya, beserta jawaban nya {#pertanyaan-dan-jawaban}
## Kesimpulan dan Penutup