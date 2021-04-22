---
title: "Cara Install LAMP Stack (Apache2, MariaDB, PHP 7) + phpMyAdmin di Ubuntu dan Turunan nya"
categories: "Tutorial"
tags: 
- Cara Install 
- LAMP Stack 
- Apache2 
- MariaDB 
- PHP 7
- Ubuntu
- GNU/Linux
date: 2019-10-31 17:04:17+07:00
image: Cover.png
slug: "cara-install-lamp-stack-di-ubuntu"
suthor: "Farrel Franqois"
readMore: true
descriptionSEO: Apakah Anda ingin meng-install Git di dalam Komputer Anda? Kalau iya, silahkan Anda baca artikel ini!
description: >
    Artikel ini akan membahas tentang bagaimana caranya meng-install LAMP Stack di dalam Sistem Operasi GNU/Linux, khususnya untuk pengguna Distribusi Ubuntu dan Turunan nya (seperti [Mint](https://linuxmint.com), [KDE neon](https://neon.kde.org), [Pop!_OS](https://pop.system76.com), dll) dengan 'benar'.


    Penasaran? Silahkan baca artikel ini, kalau tidak, ya tidak apa-apa 🙂
---
## Daftar Isi
{{< toc >}}

## Pembuka
Banyak sekali pengguna GNU/Linux yang ingin menguji Aplikasi Web yang telah di buatnya, seperti seseorang yang ingin menguji Aplikasi Web yang di buat nya dengan bahasa pemrograman PHP dengan meng-install Webserver seperti Apache2 serta Bahasa Pemrograman Web seperti PHP juga turut di Install, agar Aplikasi Web tersebut bisa di uji.

Namun, masih ada yang bingung tentang bagaimana cara meng-install Aplikasi yang di perlukan tersebut. 

Dan, sayangnya, banyak sekali praktik yang salah mengenai ini, contoh nya, masih ada pengguna yang meng-install nya dengan XAMPP, yang akan mengakibatkan Apache2, PHP dan MariaDB/MySQL tidak terinstall sama sekali ke dalam Sistem Operasi.

Atau, bahkan yang lebih parahnya adalah ada yang menggunakan 'chmod 777' pada “Document Root” nya (seperti `/var/www/html/`) yang akan menimbulkan celah keamanan yang fatal, salah kepemilikan _Document Root_ yang mengakibatkan tidak bisa membuat/mengedit atau menghapus berkas/folder di dalam _Document Root_, menginstall phpMyAdmin melalui Repo, dsb. 

Lalu, bagaimana caranya agar kita bisa meng-install _Web Stack_ ke dalam sistem operasi dengan "benar"? Anda bisa baca tutorial nya di dalam artikel ini, tapi sebelumnya Anda harus membaca Sanggahan Tambahan nya terlebih dahulu agar Anda bisa paham.

## Sanggahan
Cara ini bukanlah cara cepat untuk meng-install _LAMP Stack_ ke dalam Sistem Anda, ini adalah cara yang ‘fleksibel’ untuk meng-install _LAMP Stack_. Jadi, tutorial ini tidaklah cocok bagi Anda yang ingin serba instan. Jadi, Artikel ini akan membahasnya dengan “Panjang x Lebar”, dan saya harap Anda kuat baca dan pemahamnya, hehe :grinning:

Dengan “Panjang x Lebar” nya pembahasan ini, saya harapkan bahwa Anda bisa mempelajari apa yang kamu lakukan nanti nya, baik itu sebelum melakukan nya sampai sesudah melakukan nya.
Artikel ini tidak pernah saya tujukan untuk pengguna Server (meski bisa), melainkan untuk Web Developer/Programmer yang ingin menggunakan/meng-install _LAMP Stack_.

Karena di tujukan untuk Web Developer/Programmer, maka bahasan tentang Keamanan dan Optimasi disini harusnya akan sangat berbeda jika di bandingkan dengan pengguna Server. Jadi, bagi Web Developer/Programmer, Anggap saja pembahasan keamanan dan optimasi disini sebagai bonus, dan di harapkan agar Anda bisa mengatur keamanan dan optimasi nya sendiri untuk kedepan nya.

Artikel ini memang membahas tentang “cara install yang benar”, bukan berarti Artikel ini sepenuhnya benar. “Benar” disini maksudnya adalah melakukan sesuatu dengan praktek yang lebih baik atau/dan "lebih benar" daripada yang Anda praktekkan sebelumnya, bukan bermaksud pada “sepenuhnya benar”. 

Jadi, mohon perhatian dan pengertian nya dari pembaca sekalian :slightly_smiling_face:

Terima kasih atas perhatian dan pengertian nya :blush:

## I. Sebelum Install
Sebelum Anda meng-install _LAMP Stack_, sebaiknya Anda Perbarui (_Update_) terlebih dahulu Repo Anda dan semua Perangkat Lunak yang terpasang terlebih dahulu, dengan menggunakan perintah berikut:

```bash
$ sudo -- sh -c 'apt update; apt full-upgrade'
```

Bisa kamu gunakan Aplikasi yang berbasis GUI kalau kamu lebih suka GUI di bandingkan dengan menggunakan Terminal yang berbasis CLI. Sedangkan, kalau kamu menggunakan Mint, maka kamu bisa gunakan “Update Manager”.

## II. Install Apache2
### Cara Install
Instalasi nya memang sangat mudah, buka _Terminal Emulator_ pada sistem Ubuntu (dan Turunan nya) Anda, lalu eksekusi perintah berikut ini untuk meng-install 'Apache2':

```bash
$ sudo apt install -y apache2 apache2-utils
```

### Setelah Instalasi
#### **1. Memeriksa Status Apache2, dan mengaktifkan nya setelah Sistem Operasi selesai Booting**
Setelah instalasi Apache2, sebaiknya Anda periksa/pastikan terlebih dahulu jika Apache2 ini sudah berjalan dengan baik ke dalam Sistem menggunakan perintah berikut:

```bash
$ systemctl status apache2
```

Jika Apache2 berjalan dengan baik, harus nya ada `Active: active (running)` dan `Loaded: loaded` seperti berikut di bawah ini:

```plaintext
● apache2.service - The Apache HTTP Server
   Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
  Drop-In: /lib/systemd/system/apache2.service.d
           └─apache2-systemd.conf
   Active: active (running) since Thu 2019-10-17 22:21:30 WIB; 1h 0min ago
  Process: 1535 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
 Main PID: 1741 (apache2)
    Tasks: 6 (limit: 4447)
   CGroup: /system.slice/apache2.service
           ├─1741 /usr/sbin/apache2 -k start
           ├─1742 /usr/sbin/apache2 -k start
           ├─1743 /usr/sbin/apache2 -k start
           ├─1744 /usr/sbin/apache2 -k start
           ├─1745 /usr/sbin/apache2 -k start
           └─1746 /usr/sbin/apache2 -k start
```

Atau, seperti pada cuplikan layar berikut ini:

![Setelah Instalasi Apache2](After_Install_Apache2_1.png)

Jika status Apache2 tidak seperti di atas, maka bisa di pastikan bahwa Apache2 tidak berjalan dengan baik. Untuk menjalankan nya, eksekusi perintah berikut:

```bash
$ sudo systemctl start apache2
```

Kalau Anda ingin Apache2 nya dapat di jalankan saat Startup atau Sistem setelah Booting nanti, maka Anda perlu eksekusi perintah berikut:

```bash
$ sudo systemctl enable apache2
```

#### **2. Mengecek versi Apache2**
Coba kamu cek versi Apache2 yang kamu gunakan, dengan perintah berikut:

```bash
$ apache2 -v
```

Dan, outputnya (di saya) sebagai berikut:

```plaintext
Server version: Apache/2.4.29 (Ubuntu)
Server built:   2019-04-03T13:22:37
```

#### **3. Mengubah Pemilik “Document Root”**
Secara default, “Document Root” (atau bisa kamu sebut “Web Root”) dimiliki oleh user `root`.

Jadi, kamu sebagai pengguna biasa tidak akan bisa melakukan aktivitas ‘penulisan’ (seperti membuat, mengubah dan menghapus berkas/folder) di dalam nya, kecuali jika menggunakan `sudo` atau kamu membuka Aplikasi Manipulasi Berkas/Folder (Seperti Pengelola Berkas, Editor Teks, dll) sebagai `root`. 

Kalo kamu mau bisa melakukan nya, maka kamu harus mengubah kepemilikan nya terlebih dahulu menjadi milik kamu, dengan perintah berikut:

```bash
$ sudo chown nama_pengguna_kamu:www-data /var/www/html/ -R
```

Silahkan ganti `nama_pengguna_kamu` dengan Nama Pengguna (_Username_) yang kamu gunakan pada Sistem Ubuntu (dan Turunan nya) yang Anda gunakan saat ini.

Atau, kalo mau cepet, bisa gunakan perintah berikut:

```bash
$ sudo chown ${USER}:www-data /var/www/html/ -R
```

#### **4. (Opsional) Merubah perizinan pada “Document Root”**
Bagi Anda yang terlanjur menggunakan chmod 777. Untuk keamanan dan kalo perlu, Anda harus ganti Perizinan pada "Document Root" menjadi 755 untuk Folder atau 644 untuk berkas-berkas di dalam nya, dengan meng-eksekusi perintah berikut:

```bash
$ sudo chmod 755 /var/www/html
```

Perintah di atas di eksekusi hanya untuk satu Folder saja, jika Anda ingin semua Folder dan Sub-folder di dalam nya (bukan berkas-berkas nya), Anda bisa eksekusi perintah berikut:

```bash
$ sudo find /var/www/html -type d -exec chmod 755 {} \;
```

Kedua perintah di atas (seperti: `chmod 755`) memang sebaik nya di eksekusi untuk Folder saja, sedangkan untuk berkas-berkas nya bisa Anda ketik perintah berikut:

```bash
$ sudo chmod -R 644 /var/www/html/*.php
```

Perintah di atas merupakan contoh untuk mengubah perizinan untuk semua berkas yang berekstensi .php di dalam nya. Jika Anda ingin mengubah perizinan untuk ekstensi berkas lain nya, silahkan ganti `*.php` diatas dengan ekstensi lain, seperti `*.jpg` jika Anda ingin mengubah perizinan untuk semua berkas dengan Ekstensi .jpg.

Sedangkan, jika Anda ingin mengubah perizinan untuk semua Berkas (bukan Folder) dengan semua Ekstensi nya yang berada di dalam Folder/Lokasi `/var/www/html` menjadi 644, Anda bisa eksekusi perintah berikut:

```bash
$ sudo find /var/www/html -type f -exec chmod 644 {} \;
```

(Opsional) Jika Aplikasi Web Anda memiliki fitur 'Unggah' (_Upload_), dan ingin Aplikasi Web tersebut bisa menggunakan fitur itu dengan baik. Ubahlah Perizinan pada Folder Lokasi yang akan di jadikan tempat penyimpanan berkas yang telah di unggah melalui Aplikasi Web menjadi 775 untuk Folder atau 664 untuk berkas-berkas nya, dengan perintah berikut:

```bash
$ sudo find /path/to/uploaded/file -type d -exec chmod 775 {} \; 
$ sudo find /path/to/uploaded/file -type f -exec chmod 665 {} \;
```

Ganti `/path/to/uploaded/file` menjadi lokasi tempat menyimpan berkas yang telah di Unggah.

#### **5. Menguji _Web Server_ dengan membukanya lewat Web Browser**
Setelah itu, buka Peramban Web (_Web Browser_) Anda, lalu masukkan Alamat URL nya dengan `localhost` atau `127.0.0.1`. Lalu, harusnya tampilan akan seperti di bawah ini jika bekerja dengan baik:

![Contoh halaman Index Default yang menandakan Apache2 berjalan dengan baik](After_Install_Apache2_2.png)

Jika tampilan nya muncul “It works!” seperti di atas, maka seharusnya Apache2 sudah siap di gunakan!

#### **6. Menambahkan User ke dalam Grup `www-data`**
Oh, iya, jika user lain atau Anda ingin di masukkan ke dalam grup `www-data`, maka eksekusi perintah berikut:

```bash
$ sudo adduser nama_pengguna_kamu www-data
```

Silakan ganti `nama_pengguna_kamu` dengan Nama Pengguna (_Username_) yang kamu gunakan pada Sistem Ubuntu (dan Turunan nya) yang Anda gunakan saat ini. Atau, Nama Pengguna lain nya yang ada di dalam sistem kamu. Setelah itu, coba kamu log out, lalu login lagi.

Atau, kalo mau cepet, gunakan perintah berikut:

```bash
$ sudo adduser ${USER} www-data
```

#### **7. Mengaktifkan .htaccess di dalam Apache2**
_Web Server_ Apache2 secara bawaan tidak memproses berkas `.htaccess`. Sehingga, berkas tersebut tidak akan bisa di gunakan pada "Web Server", sampai Anda bisa mengaktifkan nya.

Agar _Web Server_ Apache2 dapat memproses berkas `.htaccess`, maka ubahlah berkas `/etc/apache2/apache2.conf` dengan editor teks/kode favorit kamu sebagai `root`. Mungkin, bisa kamu ikuti caranya berikut:

Kalo kamu mau menggunakan `nano` yang berbasis CLI, bisa kamu gunakan perintah berikut:

```bash
$ sudo nano /etc/apache2/apache2.conf
```

Tapi, kalo kamu mau menggunakan editor teks yang berbasis GUI, bisa kamu buka editor teks tersebut sebagai `root` dengan perintah berikut:

Untuk pengguna DE Cinnamon atau Pengguna Mint dengan DE apapun (X-Apps \[Text\] Editor):

```bash
$ xed admin:///etc/apache2/apache2.conf
```

Untuk Pengguna DE GNOME (gedit):

```bash
$ gedit admin:///etc/apache2/apache2.conf
```

Untuk Pengguna KDE Plasma 5 (dengan editor teks ‘KWrite’):

```bash
$ pkexec env DISPLAY=${DISPLAY} XAUTHORITY=${XAUTHORITY} KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true kwrite /etc/apache2/apache2.conf
```

Untuk Pengguna KDE Plasma 5 (dengan editor teks ‘Kate’):

```bash
$ pkexec env DISPLAY=${DISPLAY} XAUTHORITY=${XAUTHORITY} KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true kate /etc/apache2/apache2.conf
```

Untuk Pengguna DE LXDE (Leafpad)*:

    $ sudo su
    # leafpad /etc/apache2/apache2.conf

Untuk Pengguna DE XFCE (Mousepad)*:

    $ sudo su
    # mousepad /etc/apache2/apache2.conf

**\*Catatan**: Kedua DE tersebut belum pernah saya gunakan, jadi apabila perintah di atas salah, maka mohon beri saran dari Anda agar bisa saya ubah perintah di atas. Tapi, khusus DE XFCE memang saya sedang menggunakan nya, yang distronya adalah Mint (di dalam VirtualBox), itupun menggunakan 'X-Apps \[Text\] Editor' (xed) sebagai editor bawaan nya. Jika kamu mau menambahkan, yah, silahkan saja.

Setelah itu, kamu carikan sebuah teks `<Directory /var/www/>` yang ada di dalam berkas tersebut dengan memanfaatkan fitur dari Editor Teks/Kode yang Anda gunakan sekarang. Untuk mencari nya, tekan <kbd>CTRL</kbd> + <kbd>F</kbd>, atau <kbd>CTRL</kbd> + <kbd>W</kbd> jika Anda menggunakan `nano` sebagai editor nya, lalu masukkan teks.

Kemudian, kalo ketemu, akan ada barisan kode seperti di bawah ini:

```plaintext
<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>
```

Ada yang salah dengan kode di atas? Ya, Direktif `AllowOverride` nya bernilai `None`. Kalo Anda ingin mengaktifkan `.htaccess`, maka Anda harus merubah nilai dari Direktif `AllowOverride` ini menjadi `All`.

Jika sudah di rubah, maka akan menjadi seperti berikut:

```plaintext
<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>
```

Kalau kamu sudah selesai, simpan berkas nya. Jika Anda menggunakan Teks Editor berbasis GUI, Anda bisa simpan berkas tersebut dengan menekan <kbd>CTRL</kbd> + <kbd>S</kbd>. Sedangkan, kalau Anda menggunakan `nano`, maka Anda perlu tekan <kbd>CTRL</kbd> + <kbd>O</kbd> terlebih dahulu, lalu tekan <kbd>Enter</kbd>.

Setelah di simpan, restart Apache2 nya dengan perintah berikut:

```bash
$ sudo systemctl restart apache2
```

Sekarang, tinggal kita install MariaDB nya terlebih dahulu, sebelum install PHP.

## III. Install MariaDB
### Menambahkan Repo (Opsional)
Anda memang bisa saja meng-install nya secara langsung, dan melewati langkah ini. Namun, versi MariaDB yang Anda dapatkan nanti adalah versi lama nya. 

Jika Anda ingin menggunakan MariaDB dengan versi terbaru, maka Anda wajib menambahkan Repo nya. Cara menambahkan Repo nya terbilang cukup mudah, Anda tinggal klik [disini](https://downloads.mariadb.org/mariadb/repositories/) untuk menuju langsung ke cara konfigurasi nya. Anda tinggal pilih Distribusi mana yang Anda gunakan saat ini, setelah itu Anda pilih versi MariaDB nya dan _Mirror_ nya. 

#### **1. Menambahkan Repositori MariaDB**
Setelah Anda memilih _Mirror_ nya, maka Anda akan diberi petunjuk cara menambahkan Repositori nya dari Pihak ke-3. Atau, kalau kamu gak mau repot-repot ke sana, mungkin kamu bisa ikuti cara di bawah ini:

Untuk Pengguna Distribusi Ubuntu 18.04 dan Turunan nya (termasuk Mint 19, dan tidak mendukung arsitektur i386):

```bash
$ sudo apt install software-properties-common # Untuk pengguna Mint 19 atau di atasnya sepertinya sudah tidak perlu meng-install ini lagi, karena sudah di gantikan dengan 'mintinstall'.
$ sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
$ sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirror.b-cdn.net/pub/mirror/mariadb/repo/10.4/ubuntu bionic main'
```

**Catatan:** Cara di atas sudah tidak berlaku untuk pengguna Ubuntu 18.04 dan Semua Turunan nya dengan Arsitektur 32-bit, jadi hanya berlaku untuk 64-bit saja. Mungkin, MariaDB sendiri telah menghapus dukungan nya untuk Arsitektur i386 sejak Ubuntu sendiri sudah tidak lagi menyediakan berkas ISO untuk Arsitektur i386 atau x86 (32-bit).

Untuk Pengguna Distribusi Ubuntu 16.04 dan Turunan nya (termasuk Mint 18):

```bash
$ sudo apt install software-properties-common
$ sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
$ sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] https://mirror.b-cdn.net/pub/mirror/mariadb/repo/10.4/ubuntu xenial main'
```

#### **2. Memperbarui Repositori setelah menambahkan nya**
Setelah kamu menambahkan Repo tersebut, pastikan Repo sudah ter-update dengan perintah berikut:

```bash
$ sudo apt update
```

Nah, setelah kita menambahkan Repo nya, sekarang kita menginstall nya.

### Cara Install
Cara meng-install MariaDB memang mudah, Anda cukup eksekusi perintah berikut ini untuk meng-install nya:

```bash
$ sudo apt install mariadb-client mariadb-server
```

### Setelah Instalasi
#### **1. Memeriksa Status MariaDB, dan mengaktifkan nya setelah Sistem Operasi selesai Booting**
Setelah instalasi MariaDB, sebaiknya Anda periksa/pastikan terlebih dahulu jika MariaDB ini sudah berjalan dengan baik ke dalam Sistem menggunakan perintah berikut:

```bash
$ systemctl status mariadb
```

Jika MariaDB berjalan dengan baik, maka hasil output nya nanti harusnya ada `Active: active (running)` dan `Loaded: loaded` seperti berikut di bawah ini:

```plaintext
● mariadb.service - MariaDB 10.3.18 database server
   Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/mariadb.service.d
           └─migrated-from-my.cnf-settings.conf
   Active: active (running) since Sat 2019-10-19 09:19:53 WIB; 1h 16min ago
     Docs: man:mysqld(8)
           https://mariadb.com/kb/en/library/systemd/
 Main PID: 1699 (mysqld)
   Status: "Taking your SQL requests now..."
    Tasks: 30 (limit: 4448)
   CGroup: /system.slice/mariadb.service
           └─1699 /usr/sbin/mysqld
```

Atau, seperti pada cuplikan layar berikut:

![Status MariaDB di dalam Terminal](After_Install_MariaDB.png)

Jika status MariaDB tidak seperti di atas, maka bisa di pastikan bahwa MariaDB tidak berjalan dengan baik. Untuk menjalankan nya, eksekusi perintah berikut:

```bash
$ sudo systemctl start mariadb
```

Kalau Anda ingin MariaDB nya dapat di jalankan saat Startup atau setelah booting Sistem selesai, maka Anda perlu eksekusi perintah berikut:

```bash
$ sudo systemctl enable mariadb
```

#### **2. Konfigurasi MariaDB dan akun `root` nya**
Sekarang, kita konfigurasi kan MariaDB nya supaya aman.

Ketik perintah `sudo mysql_secure_installation` untuk melakukan konfigurasi. Lalu, jika di tanya “Enter current password for root” kamu tekan <kbd>Enter</kbd> saja, setelah itu, masukkan Kata Sandi untuk Akun Root MariaDB yang ingin di buat, seperti cuplikan layar berikut:

![Konfigurasi MariaDB di dalam Terminal](Configuring_MariaDB_1.png)

**Catatan:** Jika Anda menginstall MariaDB 10.4 atau di atasnya, dan Anda di tanya “Switch to `unix_socket` authentication \[Y/n\]”, Anda tinggal ketik atau jawab saja “n” (tanpa kutip). Lalu, tekan <kbd>Enter</kbd>. Hal ini agar Anda tidak mengaktifkan `unix_socket` sebagai metode autentikasi pada akun `root` di MariaDB.

Setelah Anda menentukan Kata Sandi baru untuk Akun root pada MariaDB, Anda tinggal tekan Tombol <kbd>Enter</kbd> saja, sampai selesai dan muncul tulisan “Thanks for using MariaDB!”. Berikut Cuplikan nya:

![Konfigurasi MariaDB di dalam Terminal](Configuring_MariaDB_2.png)

#### **3. Metode Autentikasi di MariaDB**

Secara bawaan, Akun `root` di dalam MariaDB pada pemaketan Ubuntu (dan Turunan nya) menggunakan metode `unix_socket`. Sehingga, hal ini mengakibatkan Anda harus menggunakan perintah `sudo` jika Anda ingin login sebagai akun `root` di dalam MariaDB, dan tentu hal ini tidak bisa di lakukan oleh Pengguna dengan Hak Akses biasa.

Jadi, untuk mengakses MariaDB dengan tujuan mengontrol Basis Data (_Database_) SQL yang ada di dalam nya melalui Terminal dan menggunakan akun `root` dengan mode `unix_socket`, bisa Anda gunakan perintah berikut:

```bash
$ sudo mysql -u root
```

Atau:

```bash
$ sudo mariadb -u root
```

**Catatan:** Jika Anda eksekusi perintah di atas, maka berarti Anda tidak perlu untuk memasukkan Kata Sandi untuk Akun `root` pada MariaDB lagi. Ini bukan berarti akun `root` tidak ada Kata Sandi nya, yah. Tapi, Anda masih perlu memasukkan kata sandi ketika Anda telah eksekusi perintah `sudo`, seperti biasanya, kecuali jika Anda sudah pernah menggunakan perintah `sudo` sebelumnya.

Tapi, `unix_socket` juga bisa di non-aktifkan secara bawaan jika Anda menggunakan MariaDB 10.4 atau di atasnya, saat Anda jawab “n” tadi. Sehingga, perintah di atas seharusnya tidak di gunakan.

Keuntungan menggunakan metode tersebut adalah bahwa Anda bisa saja tidak perlu memasukkan Kata Sandi lagi untuk login ke MariaDB sebagai `root` ketika Anda sudah mengeksekusi nya dengan perintah di atas, karena metode tersebut langsung terhubung dengan Sistem Anda. 

Tapi, kekurangan nya adalah untuk mengaksesnya harus menggunakan `sudo` terlebih dahulu untuk memasukki ke MariaDB, terutama jika login menggunakan akun `root`. 

Biasanya, sebagian orang login ke MySQL/MariaDB tanpa harus menggunakan perintah `sudo`, tapi ini kenapa malah harus? Terlebih, kita tidak bisa login dengan akun `root` dengan menggunakan phpMyAdmin. Lha, kenapa? Karena phpMyAdmin pada dasarnya kan merupakan Aplikasi Web, dan tidak selalu terhubung dengan sistem.

#### **4. Menggantikan metode Autentikasi dari `unix_socket` menjadi `mysql_native_password`**
Karena kita nanti meng-install phpMyAdmin secara manual, atau jika kita terlanjur mengaktifkan `unix_socket`, maka kita harus/wajib merubah metode dari `unix_socket` menjadi `mysql_native_password` terlebih dahulu, dengan cara: Login ke MariaDB sebagai `root` dengan menggunakan cara di atas -> Lalu, eksekusi perintah di bawah ini:

```sql
> UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND plugin = 'unix_socket';
> FLUSH PRIVILEGES;
> exit
```

Adakah solusi lain nya? Ada, bisa kamu klik pada salah satu tautan (_link_) berikut:

- [Connect to mysql server without sudo - Stackoverflow](https://stackoverflow.com/questions/37239970/connect-to-mysql-server-without-sudo)

- [can't login as mysql user root from normal user account in ubuntu 16.04 - Ask Ubuntu](https://askubuntu.com/questions/766334/cant-login-as-mysql-user-root-from-normal-user-account-in-ubuntu-16-04)

Mau lebih banyak lagi? Silahkan kamu [Googling](https://www.google.com/search?q=Running+mysql+command+without+sudo) saja sendiri, banyak di sana juga.

Nah, instalasi MariaDB ini telah sepenuhnya selesai, sekarang kita meng-install PHP versi 7.3 di dalam Sistem Ubuntu (dan Turunan nya, seperti Mint) Anda.


## IV. Install PHP7
### Cara Install
Sekarang Anda akan meng-install PHP 7.3, namun pertama-tama tambahkan terlebih dahulu Repositori PPA dari [Ondřej Surý](https://launchpad.net/~ondrej) agar dapat meng-install PHP versi terbaru di dalam Sistem Ubuntu dan Turunan nya, dengan perintah berikut:

```bash
$ sudo -- sh -c 'LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php; apt update'
```

Lalu, eksekusi perintah berikut jika Anda ingin meng-install PHP 7.3 dengan hampir semua ekstensi: (Ini yang saya gunakan)

```bash
$ sudo apt install php7.3 libapache2-mod-php7.3 php7.3-fpm php7.3-common php7.3-dom php7.3-fileinfo php7.3-gd php7.3-geoip php7.3-gmagick php7.3-gnupg php7.3-http php7.3-igbinary php7.3-igbinary php7.3-json php7.3-mbstring php7.3-memcached php7.3-mysqli php7.3-mysqlnd php7.3-oauth php7.3-odbc php7.3-opcache php7.3-pdo php7.3-phar php7.3-propro php7.3-raphf php7.3-redis php7.3-ssh2 php7.3-tidy php7.3-uuid php7.3-xdebug php7.3-xmlreader php7.3-xmlrpc php7.3-xmlwriter php7.3-xsl php7.3-yaml php7.3-curl php7.3-zip
```

Atau, di bawah ini akan meng-install PHP 7.3 dengan Ekstensi yang seperlu nya saja:

```bash
$ sudo apt install php7.3 libapache2-mod-php7.3 libpcre2-8-0 php-common php-yaml php7.3 php7.3-cli php7.3-common php7.3-curl php7.3-fpm php7.3-gd php7.3-json php7.3-mbstring php7.3-mysql php7.3-opcache php7.3-readline
```

### Setelah Instalasi
#### **1. Mengaktifkan PHP 7.3 pada Apache2**
Setelah meng-installnya, uji terlebih dahulu PHP nya ke dalam Webserver. Sebelum itu, aktifkan terlebih dahulu mod PHP 7.3 nya lewat Apache2, lalu mulai ulang (_restart_) Apache2 mu, dengan perintah berikut:

```bash
$ sudo a2enmod php7.3
$ sudo systemctl restart apache2
```

Setelah itu, cek terlebih dahulu versi PHP nya sekaligus memastikan bahwa PHP sudah benar-benar terinstall ke dalam sistem, dengan perintah berikut:

```bash
$ php --version
```

Jika bisa di eksekusi dan jika PHP sudah benar-benar ter-install ke dalam Sistem, maka seharusnya hasil outputnya seperti ini:

```bash
$ php --version
PHP 7.3.6-1+ubuntu18.04.1+deb.sury.org+1 (cli) (built: May 31 2019 11:06:48) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.3.6, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.3.6-1+ubuntu18.04.1+deb.sury.org+1, Copyright (c) 1999-2018, by Zend Technologies
```

#### **2. Menguji PHP dengan membuat PHP Info**
Nah, untuk mengetes nya ke dalam _Web Server_, buatlah sebuah berkas bernama `info.php` di dalam "Document Root". Tapi, di tutorial ini, saya akan membuatnya lewat `nano` ketimbang menggunakan berbasis GUI, kalau Anda ingin lewat GUI, yah itu tidak masalah.

Buatlah berkas tersebut via nano dengan perintah:

```bash
$ nano /var/www/html/info.php
```

Ingat, perintah tersebut di lakukan tanpa menggunakan `sudo`!

Salin dan tempelkan (_Copy_ dan _Paste_ kan) barisan kode berikut ini ke dalam berkas `info.php` melalui `nano` atau editor teks favorit Anda:

```php
<?php phpinfo(); ?>
```

Lalu, simpan berkas tersebut, kalau Anda menggunakan nano, maka Anda perlu tekan <kbd>CTRL</kbd> + <kbd>O</kbd> terlebih dahulu, lalu tekan <kbd>Enter</kbd>.

Setelah itu, coba buka web browser Anda, lalu masukkan URL nya. Karena berkas yang kita buat tadi lokasi nya di `/var/www/html`, maka artinya masukkan URL `localhost/info.php` atau `127.0.0.1/info.php` kedalam Peramban (_Browser_) mu, lalu tekan <kbd>Enter</kbd>. Hasilnya akan menjadi seperti ini:

![Ini yang di hasilkan dari berkas 'info.php' jika di buka lewat Peramban Web.](PHP7_with_Apache2_Handler.png)

Lihatlah pada Server API nya, yang masih menggunakan `Apache2 Handler`. Tidak masalah sebenarnya, cuma kita tadi sudah meng-install `php7.3-fpm` nya, yang seharusnya itu bukan Apache2 Handler lagi. Selain itu, mungkin ada beberapa alasan (seperti Kinerja dari PHP nya, dll) agar kita harus mengaktifkan PHP-FPM ini.

#### **3. (Opsional) Mengaktifkan dan Menggunakan Intepreter FPM pada PHP 7.3 daripada Apache2 Handler**
Maka dari itu, kita bisa menggantikan nya menjadi PHP-FPM, dengan perintah berikut:

```bash
$ sudo -- sh -c 'a2dismod php7.3; a2enmod proxy_fcgi setenvif; a2enconf php7.3-fpm; systemctl restart apache2'
```

Setelah itu, coba kamu segarkan (_refresh_) berkas `info.php` yang telah kamu akses lewat Peramban Web tadi, dan harusnya akan menjadi seperti ini:

![Hasil berkas 'info.php' setelah PHP-FPM di aktifkan.](PHP7_with_FPM.png)

#### **4. (Opsional) Menguji Galat Sintaks PHP (_PHP Syntax Error_)**
Sekarang, coba kamu buat sebuah berkas PHP, apapun itu, yang menimbulkan galat/kesalahan (_error_) (bebas kode nya apa saja, asal menimbulkan kesalahan sintaks), lalu bukalah berkas PHP tersebut melalui peramban web, harusnya muncul galat/peringatan di layar.

Kira-kira apa yang terjadi? Ya, galat nya tidak tampil di layar sama sekali, padahal pada XAMPP, biasanya tampil galat nya kalau ada kesalahan sintaks pada PHP. 

#### **5. (Opsional) Melakukan Konfigurasi agar PHP bisa menampilkan pesan Galat (_Error_) secara langsung**
Selanjutnya, kita akan melakukan konfigurasi pada PHP nya, agar Galat (_Error_) tersebut bisa tampil di layar. Maka dari itu, kita perlu membuka terlebih dahulu berkas konfigurasi nya, kira-kira kamu paham dimana letaknya? Ya, kalo Anda melihat `Loaded Configuration file` tadi, itulah letak berkas konfigurasi nya, yakni: `/etc/php/7.3/fpm/php.ini`

Nah, kita buka berkas tersebut dengan editor teks favorit kamu, tapi pastikan kamu membuka nya sebagai `root`, agar berkas tersebut bisa di edit. Berikut caranya:

Kalo kamu mau menggunakan `nano` yang berbasis CLI, bisa kamu gunakan perintah berikut:

```bash
$ sudo nano /etc/php/7.3/fpm/php.ini
```

Tapi, kalo kamu mau menggunakan editor teks yang berbasis GUI, bisa kamu buka editor teks tersebut sebagai `root` dengan perintah berikut:

**Untuk pengguna DE Cinnamon atau Pengguna Mint dengan DE apapun (X-Apps \[Text\] Editor)**:

```bash
$ xed admin:///etc/php/7.3/fpm/php.ini
```

**Untuk Pengguna DE GNOME (gedit)**:

```bash
$ gedit admin:///etc/php/7.3/fpm/php.ini
```

**Untuk Pengguna KDE Plasma 5 (dengan editor teks ‘KWrite’)**:

```bash
$ pkexec env DISPLAY=${DISPLAY} XAUTHORITY=${XAUTHORITY} KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true kwrite /etc/php/7.3/fpm/php.ini
```

**Untuk Pengguna KDE Plasma 5 (dengan editor teks ‘Kate’)**:

```bash
$ pkexec env DISPLAY=${DISPLAY} XAUTHORITY=${XAUTHORITY} KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true kate /etc/php/7.3/fpm/php.ini
```

**Untuk Pengguna DE LXDE (Leafpad)\***:

    $ sudo su
    # leafpad /etc/php/7.3/fpm/php.ini

**Untuk Pengguna DE XFCE (Mousepad)\***:

    $ sudo su
    # mousepad /etc/php/7.3/fpm/php.ini

**\*Catatan:** Kedua DE tersebut belum pernah saya gunakan, jadi apabila perintah di atas salah, maka mohon beri saran dari Anda agar bisa saya ubah perintah di atas. Tapi, khusus DE XFCE memang saya sedang menggunakan nya, namun distronya adalah Mint (di dalam VirtualBox), yang mana ia menggunakan "X-Apps \[Text\] Editor" (xed) sebagai editor bawaan nya untuk semua DE nya. Jika kamu mau menambahkan, yah, silahkan saja.

Setelah Anda membuka editor teks nya, coba Anda cari baris yang memiliki opsi `display_errors` dan `display_startup_errors`. Biasanya, kedua opsi tersebut terdapat di baris ke-479 dan baris ke-490.

Kalo kamu menggunakan editor yang berbasis GUI, kamu bisa menggunakan fitur seperti “Jump to Line”, “Go to Line”, atau apalah, yang penting bisa melompat ke baris tujuan.

Sedangkan, jika kamu menggunakan `nano`, editor teks berbasis CLI, kamu bisa menekan tombol <kbd>CTRL</kbd> + <kbd>_</kbd> (_Underscore_/Garis Bawah) di `nano`, bukan <kbd>CTRL</kbd> + <kbd>-</kbd> (Strip). Bagaimana cara menekan nya? Mudah saja, sembari Anda sedang menekan <kbd>CTRL</kbd>, Anda harus tahu bagaimana caranya kamu memasukkan tanda garis bawah ke dalam layar dari Keyboard. 

Kalo saya perlu menekan tombol <kbd>Shift</kbd> + <kbd>-</kbd> untuk menghasilkan Tanda Garis Bawah. Jadi, untuk mencari/melompat ke baris tujuan di `nano`, maka saya harus menekan <kbd>CTRL</kbd> + <kbd>Shift</kbd> + <kbd>-</kbd> untuk menghasilkan <kbd>CTRL</kbd> + <kbd>_</kbd>, sampai sini paham?

Setelah Anda lompat ke baris tujuan, dan benar bahwa kedua opsi tersebut berada di baris itu, maka ubahlah nilai nya yang semula nya `Off` menjadi `On`. Seperti pada Cuplikan Layar berikut:

![Setelah merubah opsi pada php.ini](Activating_PHP_Display_Error.png)

Setelah itu, simpan berkas nya. Jika Anda menggunakan Teks Editor berbasis GUI, Anda bisa simpan berkas tersebut dengan menekan <kbd>CTRL</kbd> + <kbd>S</kbd>. Sedangkan, kalau Anda menggunakan `nano`, maka Anda perlu tekan <kbd>CTRL</kbd> + <kbd>O</kbd> terlebih dahulu, lalu tekan <kbd>Enter</kbd>.

Setelah Anda menyimpan nya, coba mulai ulang terlebih dahulu Apache2 dan PHP 7.3 nya dengan perintah berikut:

```bash
$ sudo systemctl restart apache2 "php7.3*"
```

Sekarang, coba Anda buka berkas (dengan kode yang bebas) yang telah Anda buat tadi, coba apa yang terjadi? Tampilkan galat nya? Yah, pesan galat nya kira-kira tampil seperti pada Cuplikan di bawah ini:

[Error pada PHP yang tampil di Browser>](After_Activating_PHP_Display_Error.png)

Jika Anda telah selesai sepenuhnya berurusan dengan PHP Info, atau berkas `info.php` tidak terpakai lagi, maka untuk keamanan, sebaiknya berkas `info.php` itu di hapus. Untuk menghapus nya, bisa Anda gunakan perintah berikut:

```bash
$ rm /var/www/html/info.php
```

Sekalian, jangan lupa hapus berkas yang Anda buat tadi kalo mau. Nah, sekarang instalasi PHP sudah selesai, terakhir, kita akan meng-install phpMyAdmin.

## V. Install phpMyAdmin
### Cara Install
Terakhir, kita meng-install phpMyAdmin untuk mengelola Database SQL kita. Tapi, perlu yang Anda ketahui, bahwa phpMyAdmin ini sebenarnya adalah sebuah Aplikasi Web, yang harusnya tidak perlu kamu meng-install nya dengan Repositori.

> Lalu, kenapa kita tidak meng-install nya lewat Repositori saja?

Alasan saya mengapa lebih memilih metode manual daripada menggunakan Repository, yaitu sebagai berikut:

1. Mendukung hampir semua Sistem Operasi, selama bisa meng-install Web Server dan PHP.

2. Konfigurasi lebih mudah, karena struktur/alur konfigurasi nya yang tidak berubah daripada kita meng-installnya dari Repo. Jadi, cara konfigurasi nya akan menyesuaikan dengan [Dokumentasi phpMyAdmin](https://docs.phpmyadmin.net/en/latest/) nya, sehingga hal itu akan mempermudah kamu untuk melakukan konfigurasi pada phpMyAdmin nantinya.

3. Langsung menggunakan versi terbaru dari phpMyAdmin nya saat di install nanti. Anda juga bisa meng-upgrade (update versi) atau men-downgrade nya kalo mau :slightly_smiling_face:

4. Sangat Fleksibel, bila di bandingkan dengan meng-install nya dengan Repo.

Lalu, bagaimana cara kita meng-installnya? Mudah saja, kamu tinggal ikuti perintah berikut: (Copas nya satu-per-satu, yah)

```bash
$ PHPMYADMIN_VERSION=$(curl -s https://api.github.com/repos/phpmyadmin/phpmyadmin/releases/latest | grep "\"name\"" | head -1 | cut -d \" -f 4); export PHPMYADMIN_VERSION; echo "${PHPMYADMIN_VERSION}"
$ wget "https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.xz"
$ tar -xvJf "phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.xz" -C /var/www/html/; cd "$_" || return
$ mv "phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages"/ phpmyadmin/; sudo chown ${USER}:www-data -R phpmyadmin/; cd "$_" || return
$ mv config.sample.inc.php config.inc.php; mkdir tmp; sudo chown www-data:www-data tmp; sudo chmod 700 tmp
```

### Setelah Instalasi
#### **1. Menguji phpMyAdmin**
Setelah instalasi phpMyAdmin, memang nanti kita akan meng-konfigurasikan phpMyAdmin nya. Tapi, sebelum itu, kita harus memastikan terlebih dahulu kalau phpMyAdmin bisa di buka dengan baik lewat Peramban Web (_Web Browser_).

Untuk melakukan nya, buka Web Browser Anda, lalu masukkan URL: `http://localhost/phpmyadmin` pada Peramban Web Anda, lalu tekan <kbd>Enter</kbd>.

Jika Anda sudah berhasil membuka nya, maka harusnya tampilan nya menjadi seperti Cuplikan berikut:

![Ketika phpMyAdmin berhasil di buka dengan Web Browser](After_Install_phpMyAdmin.png)


#### **2. Menyisipkan nilai dari opsi `blowfish_secret` di dalam berkas Konfigurasi phpMyAdmin**
Setelah itu, kita akan melakukan konfigurasi terhadap phpMyAdmin. Untuk melakukan konfigurasi, bukalah berkas `config.inc.php` pada phpMyAdmin dengan editor teks/kode favorit Anda.

Di dalam konfigurasi nya nanti, maka kita akan menyisipkan nilai dari Opsi [`blowfish_secret`](https://docs.phpmyadmin.net/en/latest/config.html?highlight=blowfish_secret#cfg_blowfish_secret). Kenapa opsi tersebut wajib di isi? Dengan mengisi opsi tersebut, ini artinya Anda telah mengamankan Akun MariaDB Anda dengan meng-enkripsi Cookie menggunakan Algoritma AES, agar tidak di intip oleh orang luar.

**Catatan :** Alasan kenapa di sebut “Blowfish”, padahal sekarang tidak menggunakan nya, karena phpMyAdmin sendiri pernah dulunya menggunakan “Blowfish” sebagai Algoritma Enkripsi nya.

Jadi artinya, opsi `blowfish_secret` ini hanya berperan sebagai Kunci (_Key_) nya saja dalam Enkripsi, yang tidak boleh di beritahukan ke siapapun, kecuali kamu sendiri. Sedangkan kalo kamu tidak mengisinya, maka sama saja dengan tidak mengamankan akun MariaDB kamu dengan meng-enkripsi Kuki (_Cookie_) nya.

Bagaimana cara menyisipkan nya? Coba kamu cari barisan kode atau teks `$cfg['blowfish_secret']` dengan menggunakan fitur “Find” atau menekan tombol <kbd>CTRL</kbd> + <kbd>F</kbd>. 

Dan, Anda akan menemukan nya dengan seperti berikut:

```php
$cfg['blowfish_secret'] = ''; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
```

Yah, terlihat kosong kan? Kalo gitu, maka Anda harus mengisinya terlebih dahulu. Anda bisa mengisinya dengan karakter apapun. Ya, **Apapun**, selama tidak lebih dari 32 karakter.

Kalo kamu mau karakter yang acak, bisa Anda dapatkan dengan memanfaatkan Penghasil Kata Sandi (_Password Generator_) atau Penghasil Karakter Acak (_Random Character Generator_), baik yang beredar di Internet ataupun di dalam Aplikasi Pengelola Kata Sandi yang Anda install. Kalo mau, [Googling](https://www.google.com/search?q=password+generator) aja sendiri deh, banyak disana juga :)

Atau, kalo kamu mau nya langsung hasilnya, bisa kamu klik [disini](https://phpsolved.com/phpmyadmin-blowfish-secret-generator/).

Lalu, contohnya akan menjadi seperti ini:

```php
$cfg['blowfish_secret'] = '^uz&5vD+F-CNjafr@@x4M3CMAB^v+LL$'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
```

Setelah itu, simpan berkasnya terlebih dahulu, dan jangan di tutup (di _close_).

#### **3. Login phpMyAdmin**
Lalu, buka phpMyAdmin nya lewat Browser, dan lakukan login dengan menggunakan akun MariaDB Anda, kali ini, saya gunakan akun `root`. 

![Login phpMyAdmin dengan menggunakan akun 'root'.](Logging_in_phpMyAdmin.png)

Kalau sudah selesai mengisi Username dan Password nya, maka Anda perlu klik pada _Button_ “Go”.

Jika Anda berhasil login, harusnya Anda akan di arahkan ke Halaman "_Database Management_" nya atau ke halaman utamanya.

Di halaman utamanya, coba Anda gulirkan (_scroll_) Mouse Anda ke bawah. Harusnya tidak muncul Pesan Galat (_Error_), palingan cuma pesan peringatan. Jika Anda tidak menemukan nya, maka berarti phpMyAdmin mu aman, dan kamu tinggal langsung membuat Basis Data (_Database_) ‘phpmyadmin’ nya saja (Baca pembahasan: "[**5. Membuat Basis Data (Database) bernama ‘phpmyadmin’**](#5-membuat-basis-data-database-bernama-phpmyadmin)").

Sedangkan, jika Anda menemukan nya, maka Pesan Galat nya kurang lebih seperti berikut di bawah ini:

![Error Cache pada phpMyAdmin](Error_TempDir_phpMyAdmin.png)

#### **4. (Opsional) Melakukan Konfigurasi pada phpMyAdmin tambahan (terutama untuk mengatasi masalah tersebut)**
Maka dari itu, kita lakukan lagi konfigurasi nya, pastikan berkas config.inc.php tadi masih/sudah di buka menggunakan editor teks/kode favorit Anda. Setelah itu, cari teks `/* Server parameters */` di dalam Editor, bisa kamu tekan tombol <kbd>CTRL</kbd> + <kbd>F</kbd> untuk mencari teks nya.

Nah, kode di bawah `/* Server parameters */` beberapanya ada yang harus di ubah dan di tambahkan, yang semula nya berikut di bawah ini:

```php
/* Server parameters */
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
```

Menjadi seperti di bawah ini:

```php
/* Server parameters */
$cfg['Servers'][$i]['host'] = 'localhost'; # 'Host' untuk mengakses phpMyAdmin
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = true; # Meng-izinkan phpMyAdmin untuk login SQL tanpa menggunakan Kata Sandi (Password)
$cfg['TempDir'] = '/tmp'; # Mengubah Lokasi untuk menampun berkas Sementara dari phpMyAdmin
```

Apa saja yang di ubah? Saya mengubah nilai dari opsi [`AllowNoPassword`](https://docs.phpmyadmin.net/en/latest/config.html?highlight=AllowNoPassword#cfg_Servers_AllowNoPassword) menjadi `true`, hal ini agar kamu dapat menggunakan akun MariaDB yang kata sandi nya kosong, alias tanpa kata sandi sama sekali.

Dan, saya menambahkan [`$cfg['TempDir'] = '/tmp';`](https://docs.phpmyadmin.net/en/latest/config.html?highlight=TempDir#cfg_TempDir), variabel tersebut berguna untuk menentukan lokasi dari Folder yang menyimpan berkas dan Folder dengan Sementara (_Temporary Folder_). 

**Catatan :** Jika Anda tidak mengalami Galat (_Error_) pada phpMyAdmin karena Tembolok (_Cache_), maka Anda bisa menonaktifkan Opsi `TempDir` tersebut dengan menjadikan nya sebagai komentar.

Karena variabel nya di set dengan `/tmp`, maka phpMyAdmin akan menyimpan berkas tembolok nya di dalam folder `/tmp`, harusnya Anda sangat mengenali folder tersebut jika Anda menggunakan Sistem Operasi GNU/Linux. Hal ini dilakukan agar phpMyAdmin dapat menyimpan berkas tembolok nya dan mengatasi Galat tersebut.

Simpan berkas tersebut, lalu coba kamu buka dan login lagi phpMyAdmin nya, kali ini, Anda harus menggunakan akun `root`, karena Anda akan melakukan suatu hal lagi. 

Setelah Anda berhasil login dan di alihkan ke halaman utama. Harusnya, galat tersebut sudah hilang/tidak muncul lagi.

#### **5. Membuat Basis Data (_Database_) bernama ‘phpmyadmin’**
Kenapa harus membuat Basis Data 'phpmyadmin' dan apa gunanya? Gunanya agar phpMyAdmin dapat menyimpan semua Informasi yang di hasilkan dari phpMyAdmin itu sendiri, seperti: Setelan nya (Bahasa pada phpMyAdmin, dll), Riwayat Kueri yang pernah kamu lakukan nya, Markah (Bookmark), dll ke dalam basis data tersebut, yang nanti nya akan di gunakan oleh phpMyAdmin itu sendiri.

Karena itu, kita wajib membuat nya, agar phpMyAdmin dapat di gunakan dengan sangat baik. Lalu, bagaimana caranya?

Caranya, kamu harus login ke phpMyAdmin dengan menggunakan akun `root` kamu terlebih dahulu, setelah nya nanti akan di alihkan ke Halaman Utama, lalu saat kamu di Halaman Utama nya, kamu _Scroll_ lagi ke bawah. 

Setelah kamu _scroll_ ke bawah, nanti akan ada pesan:

> The phpMyAdmin configuration storage is not completely configured, some extended features have been deactivated.

Dan, kamu klik pada tautan (_link_) yang berteks “Find out why”.

Seperti pada cuplikan berikut:

![Langkah 1: Klik pada Tautan &ldquo;Find out why&ldquo;>](Configuring_phpMyAdmin_Storage_1.png)

Lalu, klik pada tautan “Create”, untuk membuat Database ‘phpmyadmin’ seperti pada Cuplikan Layar berikut:

![Langkah 2: Klik pada Tautan &ldquo;Create&ldquo;](Configuring_phpMyAdmin_Storage_2.png)

Jika Anda sudah berhasil membuat basis data nya, maka harusnya status nya dalam “OK” semua, seperti Cuplikan Layar berikut:

![Langkah 3: Pastikan Status nya &ldquo;OK&ldquo; semua>](Configuring_phpMyAdmin_Storage_3.png)

Selain itu, di sebelah kiri nanti, akan ada basis data yang bernama `phpmyadmin` yang barusan di buat tadi. Ketika Anda ke halaman utamanya, dan Anda _scroll_ ke bawah lagi, harusnya sudah tidak muncul Pesan Peringatan ataupun Pesan Galat lagi, karena sudah kita konfigurasikan sebelumnya.

Setelah itu, ada satu hal lagi yang harus di selesaikan. Lha, apa lagi itu? Yaitu......

#### **6. (Opsional) Mengamankan phpMyAdmin**
Lha, apa lagi ini? Tenang, ini opsional, kok, kalo gak mau di lakuin, yah, tidak apa-apa. Tapi, mengamankan phpMyAdmin ini sangatlah penting.

Memang nya kenapa? Lha, phpMyAdmin ini kan Aplikasi untuk mengelola Basis Data (_Database_) MySQL/MariaDB kamu, yang suatu saat akan di gunakan untuk menghubungkan Web ke Basis Data.

Kalo sampai-sampai di akses oleh orang lain (di dalam jaringan yang sama), maka orang tersebut kemungkinan akan berusaha untuk membobol data Anda dengan melakukan serangan, seperti _Brute-force_, dll.

Nah, serangan tersebut akan sangat berbahaya jika Kata Sandi untuk akun root yang kamu gunakan itu sangat mudah di tebak, apalagi kalo sampe gak ada Kata Sandi nya. 

Kalopun Kata Sandi yang kamu gunakan itu rumit atau ‘kuat’, tapi tidak ada salahnya juga kan untuk meminimalisir serangan dari luar?

Cara mengamankan phpMyAdmin ini ada dua, yang satu adalah Memblokir segala akses dari luar dan satunya adalah memberikan Autentikasi. Berikut di bawah ini adalah cara-cara nya (Pilih salah satu).

##### A. Memblokir segala akses dari ‘luar’ atau dari komputer/perangkat lain nya
Metode ini akan memblokir segala akses dari komputer/perangkat lain, jadi perangkat lain tidak akan bisa mengakses phpMyAdmin Anda, kecuali jika berada di akses dengan `localhost` atau `127.0.0.1`.

Cara nya cukup sederhana, Anda tinggal membuat berkas .htaccess di dalam folder phpMyAdmin nya. Tapi, sebelum itu, Anda harus mengaktifkan .htaccess nya terlebih dahulu (Baca juga pembahasan: “[**7. Mengaktifkan .htaccess di dalam Apache2**](#7-mengaktifkan-htaccess-di-dalam-apache2)” untuk mengaktifkan .htaccess).

Setelah Anda mengaktifkan nya, Anda bisa membuat dan meng-edit berkas .htaccess dengan `nano`, berikut perintah nya:

```bash
$ nano /var/www/html/phpmyadmin/.htaccess
```

Setelah Anda berhasil membuka nya, tambahkan dengan menyalinkan (_copy_) barisan kode, kemudian menempelkan nya (_paste_) (Alias, copas) dengan menekan tombol <kbd>CTRL</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> pada Keyboard, berikut di bawah ini ke dalam editor `nano`:

```plaintext
order deny,allow
deny from all
allow from 127.0.0.1
```

Saya akan jelaskan Direktif nya satu-per-satu di bawah ini:

- [`order`](https://httpd.apache.org/docs/2.4/mod/mod_access_compat.html#order) - Direktif ini menentukan direktif mana yang akan di evaluasi/eksekusi, `Deny` atau `Allow`. Saya mengisinya dengan `deny,allow` agar Direktif `Deny` di eksekusi terlebih dahulu. Tapi, jika ada kondisi yang “tidak cocok”, maka Direktif `Allow` yang akan di eksekusi.

- [`deny`](https://httpd.apache.org/docs/2.4/mod/mod_access_compat.html#deny) - Direktif ini berguna untuk memblokir pengunjung yang berasal dari IP, Domain dan Host tertentu. Karena saya mengisi nya dengan `deny from all`, maka ini akan memblokir semua pengunjung (harusnya ini termasuk dari kita sendiri).
  
- [`allow`](https://httpd.apache.org/docs/2.4/mod/mod_access_compat.html#allow) - Direktif ini berguna untuk mengizinkan pengunjung yang berasal dari IP, Domain dan Host tertentu. Bisa di bilang, kalo DIrektif ini merupakan pengecualian setelah Direktif `deny from all` di eksekusi. Saya mengaturnya dengan `allow from 127.0.0.1` agar bisa di akses lewat `localhost`.

Jika Anda sudah selesai, simpan berkas tersebut. Setelah itu, cobalah untuk mengakses phpMyAdmin di Perangkat Lain, dan pastikan juga perangkat tersebut berada di dalam Jaringan yang sama dengan Komputer/Laptop yang terinstall phpMyAdmin. Kalo berhasil, harusnya muncul galat/kesalahan seperti “Forbidden” saat di akses.

Kalo masih bisa di akses, maka mungkin Apache2 nya perlu di restart dengan perintah berikut:

```bash
$ sudo systemctl restart apache2
```

##### B. Memberikan Autentikasi HTTP pada phpMyAdmin
Tadi saya telah membahas tentang cara mengamankan phpMyAdmin dengan memblokir segala akses dari luar. Sekarang, saya membahas mengamankan phpMyAdmin dengan memberikan Autentikasi.

Autentikasi yang saya maksud disini tentu saja Autentikasi HTTP (_HTTP Authentication_), yang mana sebelum di akses oleh Peramban Web, ia akan meminta pengakses nya itu memasukkan Nama Pengguna (_Username_) dan Kata Sandi (_Password_). Jika kita salah memasukkan nya beberapa kali, atau kita membatalkan nya, maka secara otomatis akan menimbulkan kesalahan/galat seperti “Authorization Required” atau “Unauthorized”.

Contohnya? [Googling](https://www.google.com/search?tbm=isch&q=HTTP+Auth) aja sendiri, ah, cape gue.

Jika Anda ingin membuat Autentikasi HTTP pada Webserver Apache2, maka Anda perlu membuatkan berkas `.htpasswd` nya terlebih dahulu.

Bagaimana caranya? Mudah, kamu tinggal gunakan perintah berikut untuk membuat .htpasswd:

```bash
$ htpasswd -c /path/to/.htpasswd nama_pengguna_kamu
```

Ganti `/path/to/.htapasswd` dengan lokasi berkas itu di buat nantinya dan di namakan sebagai apa berkasnya. Oh, iya, untuk membuat berkas `htpasswd` nya itu gak harus menggunakan nama berkas `.htpasswd`, bisa apa saja/bebas.

Dan, kamu bisa ganti `nama_pengguna_kamu` dengan Nama Pengguna (_Username_) yang kamu inginkan.

Kalo kamu mau meletakannya di dalam folder `phpMyAdmin` nya, dan berkas tersebut mau kamu namakan dengan `.htpasswd`, serta ingin menggunakan Nama Pengguna `test123`, maka akan menjadi seperti ini perintah nya:

```bash
$ htpasswd -c /var/www/html/phpmyadmin/.htpasswd test123
```

Untuk praktik keamanan yang lebih baik, harusnya `.htpasswd` di buat di dalam lokasi yang berbeda dan tidak di dalam folder Aplikasi Web nya.

Setelah itu, isikan Kata Sandi baru kamu yang nantinya akan di gunakan untuk membuka Aplikasi Web tersebut nantinya.

Nah, berkas .htpasswd sudah di buat. Setelah di buat, edit/buat berkas .htaccess nya terlebih dahulu. Kali ini, lokasi nya harus berada di dalam folder phpMyAdmin nya, dengan perintah berikut:

```bash
$ nano /var/www/html/phpmyadmin/.htaccess
```

Setelah Anda berhasil membuka nya, tambahkan dengan menyalinkan (_copy_) barisan kode, kemudian menempelkan nya (_paste_) (Alias, copas) dengan menekan tombol <kbd>CTRL</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> pada Keyboard, berikut di bawah ini ke dalam editor `nano`:

```plaintext
AuthUserFile /path/to/.htpasswd
AuthName "Ini adalah Area Terlarang!"
AuthType Basic
require valid-user
```

Ganti `/path/to/.htpasswd` dengan lokasi .htpasswd yang tadi Anda buat. Misal, kalo Anda buat nya di dalam `/var/www/html/phpmyadmin`, maka Anda bisa mengganti nya dengan `/var/www/html/phpmyadmin/.htpasswd`. Menjadi seperti berikut:

```plaintext
AuthUserFile /var/www/html/phpmyadmin/.htpasswd
AuthName "Ini adalah Area Terlarang!"
AuthType Basic
require valid-user
```

Saya akan jelaskan Direktif nya satu-per-satu di bawah ini:

- [`AuthUserFile`](https://httpd.apache.org/docs/2.4/mod/mod_authn_file.html#authuserfile) - Untuk menentukan di mana letak berkas `.htpasswd` itu berada. Berkas nya sendiri gak harus bernama `.htpasswd` sebenarnya, bisa kamu gunakan nama berkas lain, hanya saja yang menyimpan Nama Pengguna dan Kata Sandi yang sudah di-_hash_ (atau, yang di buat menggunakan perintah `htpasswd` tadi), yang akan di gunakan untuk Autentikasi nanti.

- [`AuthName`](https://httpd.apache.org/docs/2.4/mod/mod_authn_core.html#authname) - Direktif ini berfungsi untuk menentukan Pesan saat Autentikasi nanti. Pada kode diatas, saya isikan dengan "Ini adalah Area Terlarang!".

- [`AuthType`](https://httpd.apache.org/docs/2.4/mod/mod_authn_core.html#authtype) - Direktif ini yang menentukan metode Autentikasi nya nanti, ada beberapa metode Autentikasi yang bisa Anda gunakan, seperti `Basic`, [`Digest`](https://httpd.apache.org/docs/2.4/mod/mod_auth_digest.html), dan [`Form`](https://httpd.apache.org/docs/2.4/mod/mod_auth_form.html). Saya gak bahas lebih lanjut disini, tapi kali ini saya gunakan `Basic` saja agar lebih mudah.

- [`require`](https://httpd.apache.org/docs/2.4/mod/mod_authz_core.html#require) - Direktif ini menentukan Pengguna mana yang dapat mengakses Aplikasi Web tersebut. Karena saya mengisinya dengan `valid-user`, maka berarti Aplikasi Web tersebut hanya dapat di akses oleh pengguna yang valid atau pengguna yang tercantum di dalam berkas `.htpasswd` saja.

Jika Anda sudah selesai, simpan berkas tersebut. Setelah itu, cobalah untuk mengakses phpMyAdmin di dalam Perangkat Anda/di Perangkat Lain. Kalo berhasil, harusnya muncul autentikasi yang mengharuskan untuk memasukkan Nama Pengguna dan Kata Sandi nya terlebih dahulu.

Jika tidak di masukkan dengan benar, maka akan muncul pesan kesalahan/galat seperti “Authorization Required” atau “Unauthorized”.

Nah, dengan ini, maka phpMyAdmin sudah siap Anda gunakan sepenuhnya untuk mengelola Basis Data (_Database_) MariaDB Anda.

## Penutup
Instalasi LAMP Stack pun akhirnya selesai, dan Anda sudah bisa mengetes/menguji Aplikasi Web Anda, kapanpun yang Anda mau. 

Terima kasih yang telah membaca artikel ini dan mengikuti tutorial nya. Pada dasarnya, tutorial ini di tujukan bagi yang ingin mempelajari bagaimana cara meng-install LAMP Stack dengan praktik yang lebih baik dan benar serta melakukan konfigurasi pada Perangkat Lunak tertentu.

Meski begitu, bukan berarti artikel ini tidak ada kesalahan dan kekeliruan sama sekali, seperti yang saya bilang di bagian “Sanggahan”.

Mohon maaf, jika artikel ini memiliki kekeliruan dan kesalahan, baik dari ada yang salah ngetik, terlalu panjang, bertele-tele, dll. Dan, saya juga tidak bermaksud untuk menyinggung siapapun disini, saya cuma mau membagikan tutorial ini saja. Serta, saya harap juga pembaca sekalian dapat memahami dan mempelajari Tutorial yang saya sampaikan disini.

Jika adanya kesalahan dan kekeliruan, atau kalo Anda memiliki pertanyaan lain nya, bisa Anda berikan masukkan melalui kolom komentar yang tersedia. Masukkan dari Anda akan sangat berarti bagi saya dan artikel ini untuk kedepan nya nanti.

Terima kasih atas perhatian nya :blush:

## Penggunaan Gambar dan Atribusi
Berkas-berkas Gambar (seperti Cuplikan layar dan Gambar lain nya) yang di gunakan di dalam artikel ini, disediakan di dalam [_Repository_ Blog ini](https://github.com/FarrelF/Blog). 

Jika Anda ingin menjelajahi nya, silahkan kunjungi Alamat URL berikut:

```plaintext
https://github.com/FarrelF/Blog/tree/main/content/post/2019-10-31-cara-install-lamp-stack-di-ubuntu
```

Semua Gambar yang berada di situ di lisensi kan dengan [Creative Commons Attribution-ShareAlike 4.0 (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).
