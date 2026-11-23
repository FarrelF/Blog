---
Title: Cara Install Hugo Static Site Generator
Slug: cara-install-hugo
Author: Farrel Franqois
Categories: 
    - Tutorial
    - Web dan Blog
Image: hugo-logo-wide.webp
imageCoverMode: contain
imageMode: height
Date: 2021-10-22T13:32:20+07:00
Comments: true
Tags:
    - SSG
    - Static Site Generator
    - Cara Install
    - Windows
    - GNU/Linux
    - macOS
    - Android
readMore: true
DescriptionSEO: Apakah Anda ingin menginstal Hugo, tapi tidak tahu caranya? Jika iya, Anda bisa kunjungi artikel ini
Description: |-
    Artikel ini akan membahas tentang apa itu Hugo dan cara install-nya, baik itu di dalam Windows, GNU/Linux, macOS, Android, dll.

    Namun sebelum itu, mungkin saya akan sedikit berbasa-basi soal apa itu Hugo dan apa saja variannya, setelah itu saya langsung membahas cara install-nya.

    Kalau Anda ingin menginstal Hugo di dalam Komputer, silakan simak lebih lanjut artikel ini, kalau tidak ya lebih baik tidak usah dibaca 🙂
---

## Apa itu Hugo?

Hugo adalah salah satu SSG (_Static-site Generator_) atau Generator Web Statis yang dibuat menggunakan bahasa pemrograman Go, dikembangkan oleh Steve Francia, Bjørn Erik Pedersen, dan kontributor lainnya.

Hugo juga merupakan FLOSS (_Free/Libre Open Source Software_) yang dirilis di bawah [Lisensi Apache 2.0](https://github.com/gohugoio/hugo/blob/master/LICENSE), kode sumbernya bisa Anda akses [di sini](https://github.com/gohugoio/hugo).

Hugo mendukung berbagai _platform_ yang ada, termasuk sistem operasi Windows, macOS, berbasis Linux, dan BSD, untuk arsitektur x64 (disebut sebagai x86-64, x86_64 atau AMD64), ARM, dan ARM64. Hugo tidak lagi menyediakan berkas untuk arsitektur x86 (32-bit).

SSG ini diklaim sebagai SSG tercepat oleh para pengembangnya, salah satunya adalah karena Hugo berjalan di lingkungan yang _Native_, tanpa ketergantungan (_dependencies_) apa pun (kecuali kalau kamu mau dukungan CSS Sass) dan memiliki fitur yang dinamakan _Fast Render Mode_.

Selain itu, Hugo juga memiliki banyak fitur lainnya, seperti i18n untuk dukungan multibahasa, berkas data, berkas statis, pemrosesan gambar, pemrosesan berkas CSS, JS, dll yang dapat menunjang kebutuhan untuk Situs Web/Blog Anda.

## Varian Hugo

Saat ini Hugo memiliki 2 varian, yakni edisi standar tanpa dan dengan fitur **Deploy** (atau ada `withdeploy` di nama berkasnya) yang mana bisa kamu lakukan dengan perintah `hugo deploy` nantinya.

Fitur **Deploy** dari Hugo berguna untuk _men-deploy_ web statis ke layanan _storage_ seperti [AWS S3](https://aws.amazon.com/s3/), [Azure Blob Storage](https://azure.microsoft.com/en-us/products/storage/blobs/) dan [Google Cloud Storage](https://cloud.google.com/storage).

Karena pilihannya terbatas dan platform yang didukung sedikit, sebaiknya gunakan saja [Rclone]({{< relref "post/2022/08/19-cara-memakai-rclone-di-github-actions/index.md" >}}), yang secara fungsi dan fiturnya jauh lebih lengkap. Jadi, ketiadaan fitur Deploy di Hugo tidak masalah.

Sebelum versi `0.170.0`, Hugo juga memiliki dua edisi lain di luar edisi standar, yaitu **Extended** dan **Extended dengan Deploy** (`extended_withdeploy`). Keduanya mendukung CSS berbasis Sass dan diproses dengan [LibSass](https://github.com/sass/libsass).

Sayangnya LibSass tidak dikembangkan lagi, sehingga pengembang Hugo memutuskan untuk berganti ke [Dart Sass](https://github.com/sass/dart-sass) yang lebih baru.

Sebagai akibatnya, di versi `0.170.0` dan setelahnya kedua edisi itu resmi dihapus, walau sepertinya masih bisa dikompilasi.

Selain itu, untuk mengaktifkan dukungan Sass di Hugo edisi standar, Dart Sass harus diinstal sendiri oleh pengguna.

**Tapi kok masih ada Extended di perilisan?** Itu hanya sebagai _alias_ saja, atau dengan kata lain mereka adalah berkas yang sama dengan edisi standar. Tujuan adanya berkas-berkas tersebut adalah untuk menghindari gangguan konfigurasi yang sudah ada, seperti konfigurasi CI/CD, pengelola paket, dll, itu pun yang tersedia cuma berkas yang sering diunduh saja.

## Cara install Hugo

Di bagian ini, saya akan membahas cara instalasinya.

Caranya sendiri akan berbeda-beda untuk setiap sistem operasi ataupun _platform_ yang ada, jadi pastikan Anda mengikutinya sesuai dengan sistem operasi atau _platform_ yang digunakan.

Perlu dicatat bahwa Dart Sass adalah program yang terpisah dari Hugo meskipun Hugo menggunakannya jika diperlukan, sehingga harus diinstal sendiri dan tidak semua cara instalasi Hugo di sini sudah termasuk instalasi Dart Sass.

Dart Sass ikut terpasang hanya jika perintah instalasinya menyebut `sass` atau `dart-sass` secara eksplisit. Dart Sass bersifat opsional, jadi tidak menginstalnya pun tidak masalah selama tema yang dipakai tidak memakai Sass.

Berikut adalah cara instalasinya:

### Windows

#### Pengelola paket Scoop (direkomendasikan)

Anda dapat menginstal Hugo dan Dart Sass melalui [Scoop](https://scoop.sh) sebagai pengelola paket di Windows dengan perintah berikut:

```powershell
scoop install hugo sass
```

Perintah di atas akan menginstal Hugo dan Dart Sass di dalam direktori pengguna (`%USERPROFILE%\scoop\apps`), jika Anda ingin Hugo dan Dart Sass-nya dapat berjalan di semua pengguna, maka Anda perlu menambahkan argumen `-g`.

Perintahnya akan menjadi seperti berikut:

```powershell
scoop install hugo sass -g
```

Namun, Anda perlu membuka Command Prompt, Windows Terminal, PowerShell-nya, atau aplikasi terminal lainnya sebagai Administrator terlebih dahulu sebelum menjalankan perintah di atas.

Jika Anda sudah menginstal `sudo` melalui Scoop, [mengaktifkan `sudo` di Windows 11](https://learn.microsoft.com/en-us/windows/advanced-settings/sudo/) atau menginstal [`gsudo`](https://github.com/gerardog/gsudo) sebelumnya, maka cukup tambahkan saja `sudo` sebelum menjalankan perintah Scoop, tanpa harus menjalankan Terminal sebagai Administrator, menjadi seperti berikut:

```powershell
sudo scoop install hugo sass -g
```

Dengan begitu, Anda tidak perlu lagi membuka Terminal sebagai Administrator.

Untuk memperbarui versinya, silakan ganti opsi `install` di atas menjadi `update`. Kalau tidak butuh Dart Sass, cukup hapus saja `sass`-nya pada barisan perintah di atas.

#### Pengelola paket Chocolatey

Anda dapat menginstal Hugo dan Dart Sass melalui [Chocolatey](https://chocolatey.org/) sebagai pengelola paket di Windows dengan perintah berikut:

```powershell
choco install hugo sass
```

Perlu diketahui, paket `sass` di Chocolatey selalu mengikuti versi Dart Sass terbaru, tetapi ia bergantung pada paket `dart-sdk` sehingga SDK lengkapnya ikut terinstal. Unduhan SDK itu sekitar 210 MB, jauh lebih besar daripada kebutuhan Hugo dan Dart Sass saja.

Situs resmi Sass memang menyarankan `choco install sass`, jadi perintah di atas sah-sah saja. Namun, bila ukuran unduhan menjadi masalah, gunakan Scoop untuk memasang Dart Sass atau instal secara manual. Kalau tidak butuh Dart Sass, cukup hapus `sass` dari perintah di atas.

Untuk memperbarui versinya, silakan ganti opsi `install` di atas menjadi `upgrade`.

{{< info title="**Catatan:**" >}}
Secara baku, Chocolatey akan menginstal paket-paketnya di dalam direktori `%ProgramData%\chocolatey`, sehingga paket yang terinstal dapat diakses oleh semua pengguna di dalam 1 sistem.

Namun, direktori tersebut memerlukan izin Administrator untuk mengisinya. Oleh karena itu, Anda perlu membuka Command Prompt, Windows Terminal, PowerShell, atau aplikasi terminal lainnya sebagai Administrator sebelum menginstal, menghapus, dan memperbarui paket melalui Chocolatey.
{{< /info >}}

#### Pengelola paket WinGet

Anda dapat menginstal Hugo melalui WinGet sebagai pengelola paket di Windows dengan perintah berikut:

```powershell
winget install -e --id Hugo.Hugo
```

Secara baku, perintah di atas akan menginstal Hugo di dalam direktori pengguna, jika Anda ingin Hugo-nya dapat berjalan di semua pengguna, maka Anda perlu menambahkan argumen `--scope machine`, contohnya seperti berikut:

```powershell
winget install -e --id Hugo.Hugo --scope machine
```

Namun, perlu diingat bahwa Anda perlu membuka Windows Terminal, Command Prompt, PowerShell, atau aplikasi terminal lainnya sebagai Administrator agar dapat menjalankan perintah dengan argumen di atas.

Anda tidak dapat menginstal Dart Sass menggunakan pengelola paket ini karena tidak tersedia, sehingga Anda perlu menginstalnya menggunakan pengelola paket lain, seperti Scoop dan Chocolatey, atau diinstal secara manual.

Untuk memperbarui versinya, silakan ganti opsi `install` di atas menjadi `upgrade`.

#### Berkas biner, tanpa pengelola paket (manual)

Hugo telah menyediakan berkas biner yang telah dikompilasi agar dapat digunakan secara langsung dan berkas tersebut diarsipkan dengan format/ekstensi `zip` (untuk Windows), jadi Anda bisa langsung menggunakannya setelah berkas tersebut diunduh dan diekstrak.

Maksud dari "berkas biner" di sini adalah berkas yang tujuannya untuk dieksekusi, kalau di Windows Anda akan mengenal dengan berkas yang berakhiran `.exe`.

Jika tidak ingin menggunakan pengelola paket apa pun untuk menginstalnya, maka berikut adalah langkah-langkahnya:

1. Unduh Berkas Arsip yang berisi berkas biner Hugo di [halaman perilisannya](https://github.com/gohugoio/hugo/releases).

    Di situ tersedia 4 berkas yang bisa Anda unduh salah satunya, semua itu diarsipkan dalam format Zip, sesuaikan dengan Arsitektur Sistem Operasi yang dipakai.

    Namun, jika Anda memakai Hugo sebelum versi `0.170.0` dan ingin menginstal edisi Extended, unduh berkas yang namanya diawali dengan `hugo_extended`

2. Setelah diunduh, ekstrak berkas arsip tersebut ke dalam folder/direktori apa saja.

    Saya asumsikan bahwa Anda mengekstraknya ke dalam Folder `C:\Hugo\bin` dan akan saya gunakan direktori tersebut untuk seterusnya

3. Setelah diekstrak, Anda perlu menambahkan ke dalam variabel `PATH` agar Hugo bisa dieksekusi di mana saja.

    Pertama-tama, klik "Start Menu", lalu manfaatkan fasilitas pencarian yang ada di sana atau Anda juga bisa langsung ke pencarian yang ada di _Taskbar_ jika Anda memasangkannya.

    Saat di pencarian, ketik `env` di situ, nanti akan muncul tulisan **Edit the system environment variables** dan klik tulisan tersebut, seperti cuplikan berikut:

![Hasil pencarian 'env' di Windows 10](Search-Env-in-Windows-10.webp)

4. Nanti akan muncul dialog **System Properties**, di dalam dialog tersebut, klik pada _Button_ **Environment Variables...**, seperti cuplikan berikut:

![Dialog 'System Properties' di Windows 10](System-Properties-in-Windows-10.webp)

5. Setelah itu, Anda akan memasuki dialog yang berjudul **Environment Variables**, di situ nanti ada dua kolom, yakni **User variables** yang terletak di atas dan **System variables** yang terletak di bawah.

    Karena Variabel yang diubah ini lingkupnya ke satu Sistem Operasi, yang artinya semua Akun Pengguna (_User Account_) kena, maka carilah variabel `PATH` di dalam kolom **System variables**.

    Setelah ketemu, pilih variabel tersebut dan klik pada _Button_ **Edit**, seperti cuplikan berikut:

![Environment Variables di Windows 10 (beberapa bagian sengaja saya hitamkan)](Environment-Variables-in-Windows-10.webp)

6. Anda memasuki dialog yang berjudul **Edit environment variables**, di situ Anda akan mengubah nilai dari variabel tersebut. Windows 10 dan Windows 7 mungkin memiliki penampilan yang berbeda, jadi cara mengubahnya akan berbeda-beda, berikut di bawah ini adalah caranya:

    - Di Windows 10 atau di atasnya: Nilai dari variabel `PATH` yang tampil di Windows 10 adalah dalam bentuk daftar. Untuk menambahkannya, cukup klik pada _Button_ **New**, lalu isi nilainya dengan lokasi berkas Hugo itu berada.

        Jika Anda sebelumnya mengekstrak Hugo di `C:\Hugo\bin`, maka isi nilainya dengan `C:\Hugo\bin` juga. Setelah menambahkannya, klik pada _Button_ **OK**, seperti cuplikan berikut:

        ![Mengubah variabel PATH di Windows 10](Edit-Environment-Variables-in-Windows-10.webp)

    - Di Windows 7: Nilai dari Variabel `PATH` yang tampil di Windows 7 adalah dalam bentuk deretan. Untuk menambahkannya, cukup tambahkan `C:\Hugo\bin;` saja di bagian akhir deretan (**JANGAN DIGANTI SEMUA DERETANNYA!!**).

        `C:\Hugo\bin` menunjukkan tempat di mana Hugo diekstrak, jika Anda mengekstraknya di tempat lain, maka ganti `C:\Hugo\bin` menjadi lokasi di mana berkas biner Hugo itu berada.

        Setelah itu, klik pada _Button_ **OK**.

        **Catatan:** Mohon maaf, karena saya tidak lagi memakai Windows 7, jadi cuplikannya belum ada saat ini

7. Jika masih ada sesi Command Prompt, Windows Terminal, PowerShell, dll, maka Anda perlu menutup semuanya terlebih dahulu/mengakhiri semua sesinya, lalu membukanya kembali.

    Perubahan pada variabel `PATH` tidak berlaku di sesi terminal yang sudah terbuka. Jika belum ada terminal yang dibuka, bukalah salah satu (Command Prompt, Windows Terminal, PowerShell, dan sebagainya) sekarang.

8. Setelah Anda membuka Terminal-nya, silakan Anda eksekusikan perintah `hugo version` untuk menampilkan versi Hugo yang Anda gunakan. Jika berhasil, maka akan tampil keluaran seperti berikut:

```plain
{{< hugo-version-long isExtended=false platform="windows/amd64" >}}
```

9. Selamat! Anda telah berhasil menginstal Hugo. Jika Anda ingin memperbarui versi Hugo-nya, cukup unduh lagi berkas binernya, lalu tinggal timpakan berkas lamanya.

Langkah-langkah di atas juga dapat diikuti ketika Anda menginstal Dart Sass, paling berkas-berkas dan letak direktorinya saja yang berbeda, silakan kunjungi [halaman perilisan Dart Sass](https://github.com/sass/dart-sass/releases) jika Anda ingin mengunduhnya.

Nah, untuk Windows-nya saya cukupkan di sini dulu, berikutnya saya bahas cara instal Hugo untuk sistem operasi GNU/Linux.

### GNU/Linux {#gnu-linux}

#### Debian, Ubuntu, dan keluarganya

Jika Anda adalah pengguna Debian, Ubuntu atau keluarganya, sebenarnya Anda dapat menginstalnya dengan perintah berikut:

```shell
sudo sh -c 'apt update; apt install -y hugo'
```

Atau:

```shell
apt update; apt install -y hugo
```

Namun cara di atas tidak saya rekomendasikan, karena versi yang Anda dapatkan nantinya merupakan versi yang lama (kecuali jika Anda menggunakan distribusi dengan rilis bergulir).

Jika Anda ingin versi terbaru dari Hugo, silakan unduh itu di halaman [perilisan resminya](https://github.com/gohugoio/hugo/releases), pastikan unduh berkas `.deb`-nya, setelah itu tinggal Anda instal secara manual.

Atau, jika Anda lebih suka lewat Terminal, maka pertama-tama Anda perlu mengubah hak akses Anda di Terminal menjadi `root` dengan perintah `sudo su`, `sudo -i` atau `sudo -s`.

Setelah itu, tentukan apakah Anda mau menginstal Hugo varian standar atau Extended, beserta arsitektur sistem operasi yang Anda gunakan sekarang.

Jika sudah ditentukan, Anda bisa mengikuti caranya berikut:

Untuk menginstalnya, salinkan skrip berikut di bawah ini dan tempelkan itu ke dalam Terminal, lalu tekan <kbd>&#8629; Enter</kbd>:

```shell {linenos=true}
HUGO_VERSION="$(curl -fsSLIo /dev/null --retry 2 --connect-timeout 15 -w '%{url_effective}' "https://github.com/gohugoio/hugo/releases/latest" | sed -n 's#.*/tag/v*##p')"
case $(uname -m) in x86_64|amd64) HUGO_ARCH=amd64;; aarch64|arm64) HUGO_ARCH=arm64;; *) echo "Arsitektur tidak didukung: $(uname -m)" >&2; exit 1;; esac
HUGO_FILENAME=hugo_${HUGO_VERSION}_linux-${HUGO_ARCH}.deb
cd /tmp; wget -c "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_FILENAME}"
```

Atau, gunakan skrip berikut jika Anda menggunakan fish sebagai _shell_:

```fish {linenos=true}
set HUGO_VERSION (curl -fsSLIo /dev/null --retry 2 --connect-timeout 15 -w '%{url_effective}' https://github.com/gohugoio/hugo/releases/latest | string match -rg '/tag/v*(.+)')
switch (uname -m); case x86_64 amd64; set HUGO_ARCH amd64; case aarch64 arm64; set HUGO_ARCH arm64; case '*'; echo "Arsitektur tidak didukung: "(uname -m) >&2; exit 1; end
set HUGO_FILENAME hugo_{$HUGO_VERSION}_linux-{$HUGO_ARCH}.deb
cd /tmp; wget -c "https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/$HUGO_FILENAME"
```

**Penjelasan:**

- Baris ke-1: Untuk mendapatkan versi terbaru Hugo dari tujuan akhir pengalihan (redirect) halaman `releases/latest` di GitHub, lalu memasukkannya ke dalam variabel `HUGO_VERSION`. Awalan `v` pada tag otomatis dibuang oleh `sed` atau `string match` jika menggunakan fish
- Baris ke-2: Untuk menentukan arsitektur sistem pada berkas Hugo yang ingin Anda unduh secara otomatis ke dalam variabel `HUGO_ARCH` jika arsitektur sistem mendukung, yakni `amd64`/`x86_64` dan `arm64`/`aarch64` saja, jika tidak maka akan muncul galat dan skrip tidak dilanjutkan
- Baris ke-3: Untuk memasukkan nama berkas yang ingin diunduh ke dalam variabel `HUGO_FILENAME`, dengan nilai yang diambil dari nama berkas aslinya, yakni adanya versi (`HUGO_VERSION`) dan arsitektur sistem (`HUGO_ARCH`) di dalam nama berkasnya
- Baris ke-4: Untuk menavigasikan Terminal ke `/tmp`, lalu mengunduh Hugo-nya di sana dengan bantuan GNU Wget

Lalu, instal berkas yang telah Anda unduh dengan perintah berikut:

```shell
dpkg -i "$HUGO_FILENAME" && echo "Instalasi berhasil" || echo "Instalasi Gagal"
rm -f "$HUGO_FILENAME"; cd -
```

**Penjelasan:**
Perintah di atas menginstal Hugo lewat `dpkg` dari berkas `.deb` yang namanya diambil dari variabel `HUGO_FILENAME`, lalu menampilkan pesan berhasil atau gagal. Apa pun hasilnya, berkas penginstal dihapus dan Terminal kembali ke direktori sebelumnya.

Semua cara di bagian ini tidak menyertakan Dart Sass, dan Dart Sass juga tidak tersedia sebagai berkas `.deb`. Gunakan pengelola paket lain seperti Homebrew, Snap, atau Nix, instal secara manual, atau pakai skrip yang telah tersedia.

Jika merasa sudah selesai, silakan alihkan kembali hak akses di dalam Terminal Anda menjadi pengguna biasa dengan perintah `exit`.

Untuk memperbarui versi Hugo-nya, Anda perlu mengulangi semua langkah-langkah di atas.

#### Fedora, CentOS, RHEL, dan keluarganya

Jika Anda adalah pengguna Fedora, CentOS, RHEL atau keluarganya, Anda dapat memasangnya dengan perintah berikut:

```shell {linenos=true}
sudo dnf install hugo
```

Versi yang didapat mungkin bukan yang terbaru, terutama untuk RHEL dan keluarganya. Untuk Fedora versi terbaru, paketnya biasanya sudah mendekati rilis terkini.

Dart Sass juga belum tersedia di repositori resmi Fedora dan keluarganya. Untuk memasangnya, gunakan Homebrew, Snap, atau Nix, instal secara manual, atau pakai skrip yang telah tersedia.

Kalau ingin Hugo versi terbaru sekaligus Dart Sass, gunakan Homebrew, Snap, atau Nix, atau instal secara manual.

#### openSUSE Leap/Tumbleweed dan keluarganya (tidak resmi)

Jika Anda adalah pengguna openSUSE Leap/Tumbleweed atau keluarganya, sebelum menginstalnya, tambahkan dulu repositori dari luar (dari [`home:dirkmueller:Factory`](https://build.opensuse.org/project/show/home:dirkmueller:Factory) untuk Hugo dan [`home:darix:apps`](https://build.opensuse.org/project/show/home:darix:apps) untuk Dart Sass, jadi itu bukan resmi) yang bisa Anda percayakan dengan salah satu perintah berikut:

```shell {linenos=true}
### Untuk pengguna openSUSE Leap 16
# Hugo
sudo zypper ar -f https://download.opensuse.org/repositories/home:dirkmueller:Factory/16.0/home:dirkmueller:Factory.repo

# Dart Sass
sudo zypper ar -f https://download.opensuse.org/repositories/home:darix:apps/16.0/home:darix:apps.repo

### Untuk pengguna openSUSE Tumbleweed
# Hugo
sudo zypper ar -f https://download.opensuse.org/repositories/home:dirkmueller:Factory/standard/home:dirkmueller:Factory.repo

### Catatan: pengguna openSUSE Tumbleweed tidak perlu menambahkan repositori karena Dart Sass sudah tersedia di repositori resmi
```

Setelah itu segarkan repositorinya, lalu install Hugo dan Dart Sass-nya dengan perintah berikut:

```shell {linenos=true}
sudo sh -c 'zypper ref; zypper in hugo dart-sass'
```

Untuk lebih lanjut, silakan kunjungi [halaman unduh repositorinya](https://software.opensuse.org/download.html?project=home%3Adirkmueller%3AFactory&package=hugo).

#### Arch Linux, Manjaro, dan keluarganya

Jika Anda adalah pengguna Arch Linux, Manjaro atau keluarganya, Anda dapat menginstal Hugo dan Dart Sass dengan perintah berikut:

```shell
sudo pacman -S hugo dart-sass
```

#### Solus dan keluarganya

Jika Anda menggunakan Solus atau keluarganya, maka Anda dapat menginstalnya dengan perintah berikut:

```shell
sudo eopkg install hugo
```

Anda tidak dapat menginstal Dart Sass menggunakan repositori resminya, karena memang belum tersedia, silakan gunakan pengelola paket lain seperti Snap, Homebrew atau pengelola paket Nix, atau instal manual, atau bisa juga menggunakan skrip yang tersedia bila tidak mau ribet.

#### Void Linux dan keluarganya

Jika Anda adalah pengguna Void Linux atau keluarganya, Anda dapat menginstal Hugo dengan perintah berikut:

```shell
sudo xbps-install -S hugo
```

Anda tidak perlu khawatir mengenai arsitektur sistem yang Anda gunakan, karena paketnya mendukung itu semua, sehingga bisa diinstal di arsitektur sistem manapun di Void Linux.

Dart Sass juga belum tersedia di repositori resmi Void Linux. Gunakan Homebrew atau Nix, instal secara manual, atau pakai skrip yang telah tersedia.

#### Homebrew (lebih universal) {#homebrew-lebih-universal}

Jika Anda ingin menggunakan [Homebrew (brew)](https://brew.sh/) yang lebih universal, maka Anda bisa menginstal Hugo dan Dart Sass-nya dengan perintah berikut:

```shell
brew install hugo dart-sass
```

Hapus salah satu nama paket dari barisan perintah untuk menginstal salah satunya. Contohnya bila Anda sudah menginstal Hugo dengan metode lain dan hanya ingin menginstal Dart Sass saja, maka cukup hapus saja `hugo` di barisan perintah di atas.

#### Snap (lebih universal)

Jika Anda ingin menggunakan Snap yang lebih universal, maka Anda dapat menginstal Hugo dan Dart Sass-nya dengan perintah berikut:

```shell
sudo snap install hugo dart-sass
```

Untuk memasang salah satunya saja, hapus nama paket yang tidak dibutuhkan dari perintah di atas.

{{< info title="Catatan:" >}}
Kalau dibilang 'Universal' mungkin tidak terlalu, semenjak Snap sendiri memasukkan systemd sebagai ketergantungan, sehingga distribusi yang Anda gunakan harus memakai systemd sebagai init agar Snap bisa digunakan.

Jika Anda menggunakan distribusi yang tidak memakai systemd seperti Void Linux, Devuan, MX Linux (lebih tepatnya ia tidak menggunakannya sebagai "Init baku"), Artix Linux, Guix dan keluarganya dan lainnya, maka kemungkinan besar Anda tidak dapat menggunakan pengelola paket Snap.

Makanya di awal saya bilang "lebih universal", karena bisa untuk distribusi lainnya yang lebih luas ketimbang menggunakan pengelola paket bawaan.
{{< /info >}}

#### Pengelola paket Nix (lebih universal)

Jika Anda ingin menggunakan [Pengelola Paket Nix](https://nixos.org/) yang lebih universal, sebelum benar-benar menginstalnya, Anda bisa mencobanya terlebih dahulu dengan menggunakan perintah berikut:

```shell
nix-shell -p hugo dart-sass
```

Perintah di atas akan tetap menginstal Hugo dan Dart Sass, tapi di dalam `nix-shell` khusus, sehingga setelah masuk ke sana Hugo dan Dart Sass hanya bisa dijalankan dari situ.

Jadi, jika Anda menginstalnya dengan perintah di atas, agar Hugo dapat dijalankan sewaktu-waktu, maka Anda harus masuk ke dalam `nix-shell` terlebih dahulu dengan mengeksekusi perintah di atas.

Cara ini cocok untuk menguji aplikasi sebelum dipasang permanen. Nix sendiri justru menyarankan `nix-shell` ketimbang instalasi permanen, kecuali Anda memakai NixOS yang aplikasinya dipasang lewat berkas konfigurasi sistem.

Namun, jika Anda ingin menginstalnya secara permanen, maka Anda bisa menginstalnya dengan perintah berikut:

```shell
nix-env -iA nixpkgs.hugo nixpkgs.dart-sass
```

Untuk memasang salah satunya saja, hapus nama paket yang tidak dibutuhkan dari perintah di atas.

Aturan ini berlaku bagi pengguna Nix di luar NixOS. Jika Anda pengguna NixOS, ganti `nixpkgs` menjadi `nixos`.

Namun, jika Anda tidak menggunakan NixOS dan menggunakan Nix sebagai pengelola paket, maka versi paket yang Anda dapatkan biasanya akan mengikuti kanal tidak stabil dari NixOS/Nixpkgs.

#### Menggunakan berkas skrip (lebih universal) {#menggunakan-berkas-skrip}

Saya sudah menyediakan skrip penginstal Hugo dan Dart Sass untuk distribusi yang tidak menyediakannya, baik karena versinya ketinggalan maupun paketnya tidak ada sama sekali.

Untuk melihat atau/dan mengunduh skripnya, silakan kunjungi file yang bernama [`install-dart-sass.sh`](https://github.com/FarrelF/Blog/blob/main/scripts/install-dart-sass.sh) dan [`install-hugo.sh`](https://github.com/FarrelF/Blog/blob/main/scripts/install-hugo.sh).

Skrip tersebut tidaklah sepenuhnya dibuat oleh saya, melainkan AI yang membuat skrip tersebut, jadi mohon baca (kalau bisa pahami) terlebih dahulu kodenya sebelum menjalankan skrip tersebut.

Tapi harusnya tidak masalah, karena saya yakin tidak ada kode yang membahayakan di situ dan saya menggunakannya untuk GitHub Actions, Netlify dan Cloudflare Pages juga.

Jika sudah yakin, Anda bisa mengunduh, lalu mengeksekusi skripnya dengan cara berikut:

Di bawah ini untuk menginstal Hugo:

```shell {linenos=true}
curl -fsSLO https://raw.githubusercontent.com/FarrelF/Blog/refs/heads/main/scripts/install-hugo.sh
chmod +x ./install-hugo.sh
./install-hugo.sh [versi]
```

Dan, di bawah ini untuk menginstal Dart Sass:

```shell {linenos=true}
curl -fsSLO https://raw.githubusercontent.com/FarrelF/Blog/refs/heads/main/scripts/install-dart-sass.sh
chmod +x ./install-dart-sass.sh
./install-dart-sass.sh [versi]
```

Kedua skrip tersebut mendukung sistem operasi GNU/Linux (dan berbagai distribusinya), macOS, Windows (Git Bash/MSYS), dan Android melalui [Termux](https://termux.dev).

Hapus `[versi]` di atas untuk menginstal versi terbaru atau ganti `[versi]` dengan versi yang Anda inginkan.

Secara baku, Dart Sass dan Hugo akan terinstal di dalam direktori `/usr/local/bin` jika direktori tersebut bisa ditulis tanpa hak akses `root`, jika tidak maka secara otomatis akan terinstal di dalam direktori `$HOME/.local/bin`. Anda bisa mengganti lokasinya dengan menambahkan opsi `--install-dir`.

Skrip Hugo juga secara baku memasang manpage dan _shell completion_. _Completion_ hanya dipasang untuk _shell_ yang terdeteksi terpasang (Bash, Zsh, Fish, dan PowerShell), sedangkan manpage akan dilewati jika `gzip` tidak tersedia. Gunakan `--no-man` atau `--no-completions` jika tidak ingin keduanya dipasang, atau `--completions bash,fish` untuk memilih _shell_ tertentu.

Jadi, jika Anda ingin menginstalnya untuk semua pengguna di dalam 1 komputer, maka Anda perlu memberikan mereka hak akses `root`, Administrator atau apa pun itu, bisa dengan membuka skrip penginstal tersebut diawali dengan `sudo` (cth. `sudo ./install-dart-sass.sh`).

Tapi kalau Anda adalah pengguna Termux, Anda tidak perlu menggunakan `sudo` untuk menginstal dua-duanya, karena keduanya akan terinstal di dalam `$PREFIX/bin` apa pun hak aksesnya, sehingga itu tidak berguna dan malah bikin repot saja.

Ngomongin soal Android/Termux, instalasi Dart Sass menggunakan skrip di atas memang sepenuhnya mendukung Android melalui Termux, karena mereka menyediakan berkas binernya secara resmi untuk Android.

Namun, berbeda dengan Hugo yang tidak menyediakan berkas biner untuk Android secara _native_, melainkan untuk GNU/Linux. Ya bisa sih berkas biner tersebut dieksekusikan di Android, tapi bakal terjadi rentetan isu kalau dipakai bukan peruntukannya, seperti bakal ada masalah zona waktu yang tidak dikenali/selalu UTC, dll.

Jadi ujung-ujungnya kamu bakal diarahkan buat instal Hugo di Android melalui [pengelola paket di Termux](#termux), terutama jika versi yang dipilih adalah yang terbaru, karena itu adalah pilihan terbaik buat pengguna Android saat ini.

Untuk mempelajarinya lebih lanjut, silakan eksekusikan skrip tersebut dengan menambahkan parameter `--help` (cth. `./install-hugo.sh --help` atau `./install-dart-sass.sh --help`).

#### Berkas biner, tanpa pengelola paket (lebih universal, manual)

Hugo telah menyediakan berkas biner yang telah dikompilasi agar dapat digunakan secara langsung dan berkas tersebut diarsipkan dengan format/ekstensi `.tar.gz` (untuk GNU/Linux), jadi Anda bisa langsung menggunakannya setelah berkas tersebut diunduh dan diekstrak.

Maksud dari "berkas biner" di sini adalah berkas yang tujuannya untuk dieksekusi, kalau di Windows Anda akan mengenal dengan berkas yang berakhiran `.exe`.

Berkas tersebut biasanya akan kompatibel dengan hampir seluruh distribusi GNU/Linux, jadi jika distribusi yang Anda gunakan tidak saya bahas di sini dan tidak mau menggunakan pengelola paket yang universal atau bahkan sama sekali tidak mau menggunakan pengelola paket, maka Anda bisa gunakan berkas binernya.

Cara sederhananya:

1. Unduh salah satu berkas Arsip yang berisikan berkas biner Hugo dari [halaman perilisannya](https://github.com/gohugoio/hugo/releases) (yang berformat `.tar.gz`)
2. Ekstrak berkasnya
3. Izinkan agar berkas yang bernama `hugo` bisa dieksekusi (dengan mengeksekusi perintah `chmod +x hugo`)
4. Pindahkan berkas yang bernama `hugo` ke dalam direktori `/usr/local/bin` (dengan mengeksekusi perintah `sudo mv hugo /usr/local/bin/`)
5. Pastikan bahwa `/usr/local/bin/hugo` itu milik pengguna `root` (dengan mengeksekusi perintah `sudo chown root:root /usr/local/bin/hugo`)
6. Selesai!

Langkah yang kurang lebih sama berlaku untuk Dart Sass; hanya halaman rilis, direktori, dan cara ekstraknya yang berbeda.

Untuk mengunduhnya, silakan kunjungi [halaman perilisannya](https://github.com/sass/dart-sass/releases), unduh dan ekstrak, setelah diekstrak, pindahkan folder `src` dan berkas `sass` di dalam folder `dart-sass` langsung ke direktori `/usr/local/bin`.

Lalu, jalankan `sudo chmod +x /usr/local/bin/sass` dan `sudo chown -R root:root /usr/local/bin/sass /usr/local/bin/src`. Udah deh selesai!

**Catatan:** Bisa saja Anda memindahkan berkas tersebut ke dalam direktori lain yang termasuk dalam variabel `PATH`, seperti `/home/username/.local/bin` misalnya dan tidak perlu melakukan peralihan kepemilikan ke `root`, tapi saya rekomendasikan agar diletakkan ke dalam direktori `/usr/local/bin` supaya Hugo dan Dart Sass bisa dieksekusi oleh seluruh pengguna di satu sistem.

Jika Anda lebih suka melakukannya secara langsung di Terminal (atau cara panjangnya) maka Anda dapat mengikuti langkah-langkah berikut ini:

**Langkah ke-1:** Buka Terminal, lalu Anda perlu mengubah hak akses di Terminal menjadi `root`, bisa dengan eksekusi perintah `sudo su`, `sudo -i`, atau `sudo -s`, kecuali jika Anda ingin menginstalnya di dalam direktori pengguna.

**Langkah ke-2:** Untuk menginstalnya, maka tinggal Anda copas saja skrip berikut ke dalam Terminal yang menggunakan Bash atau Zsh sebagai _shell_, lalu tekan <kbd>&#8629; Enter</kbd>:

```bash {linenos=true}
HUGO_VERSION=$(curl -fsSLIo /dev/null --retry 2 --connect-timeout 15 -w '%{url_effective}' https://github.com/gohugoio/hugo/releases/latest | sed -n 's#.*/tag/v*##p')
DART_SASS_VERSION=$(curl -fsSLIo /dev/null --retry 2 --connect-timeout 15 -w '%{url_effective}' https://github.com/sass/dart-sass/releases/latest | sed -n 's#.*/tag/v*##p')
case $(uname -m) in x86_64|amd64) HUGO_ARCH=amd64 DART_SASS_ARCH=x64;; aarch64|arm64) HUGO_ARCH=arm64 DART_SASS_ARCH=arm64;; armv6*|armv7*|arm) HUGO_ARCH=arm DART_SASS_ARCH=arm;; *) echo "Arsitektur tidak didukung: $(uname -m)" >&2; exit 1;; esac; if ldd --version 2>&1 | grep -qi musl || ls /lib/ld-musl-* >/dev/null 2>&1; then DART_SASS_LIBC=-musl; else DART_SASS_LIBC=; fi
HUGO_FILENAME=hugo_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz DART_SASS_FILENAME=dart-sass-${DART_SASS_VERSION}-linux-${DART_SASS_ARCH}${DART_SASS_LIBC}.tar.gz
INSTALL_TEMPDIR=$(mktemp -d); cd "${INSTALL_TEMPDIR}" && wget -c "https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/$HUGO_FILENAME" "https://github.com/sass/dart-sass/releases/download/$DART_SASS_VERSION/$DART_SASS_FILENAME"
printf '%s\n' *.tar.gz | xargs -n1 -P2 tar -xzf
install -Dm755 hugo /usr/local/bin/; install -Dm644 LICENSE /usr/local/share/licenses/hugo/LICENSE
install -Dm755 dart-sass/sass /usr/local/bin/; rm -rf /usr/local/bin/dart-sass; mv dart-sass/src /usr/local/bin/dart-sass; chown -R root:root /usr/local/bin/dart-sass
sed -i '/^exec /s|/src/|/dart-sass/|g' /usr/local/bin/sass
cd -
rm -rf "${INSTALL_TEMPDIR}"
```

Atau, gunakan skrip berikut jika Anda menggunakan fish sebagai _shell_:

```fish {linenos=true}
set HUGO_VERSION (curl -fsSLIo /dev/null --retry 2 --connect-timeout 15 -w '%{url_effective}' https://github.com/gohugoio/hugo/releases/latest | string match -rg '/tag/v*(.+)')
set DART_SASS_VERSION (curl -fsSLIo /dev/null --retry 2 --connect-timeout 15 -w '%{url_effective}' https://github.com/sass/dart-sass/releases/latest | string match -rg '/tag/v*(.+)')
switch (uname -m); case x86_64 amd64; set HUGO_ARCH amd64; set DART_SASS_ARCH x64; case aarch64 arm64; set HUGO_ARCH arm64; set DART_SASS_ARCH arm64; case 'armv6*' 'armv7*' arm; set HUGO_ARCH arm; set DART_SASS_ARCH arm; case '*'; echo "Arsitektur tidak didukung: "(uname -m) >&2; exit 1; end; if ldd --version 2>&1 | grep -qi musl; or test (count /lib/ld-musl-*) -gt 0; set DART_SASS_LIBC -musl; else; set DART_SASS_LIBC ''; end
set HUGO_FILENAME hugo_{$HUGO_VERSION}_linux-{$HUGO_ARCH}.tar.gz; set DART_SASS_FILENAME dart-sass-{$DART_SASS_VERSION}-linux-{$DART_SASS_ARCH}{$DART_SASS_LIBC}.tar.gz
set INSTALL_TEMPDIR (mktemp -d); cd "$INSTALL_TEMPDIR"; wget -c "https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/$HUGO_FILENAME" "https://github.com/sass/dart-sass/releases/download/$DART_SASS_VERSION/$DART_SASS_FILENAME"
printf '%s\n' *.tar.gz | xargs -n1 -P2 tar -xzf
install -Dm755 hugo /usr/local/bin/; install -Dm644 LICENSE /usr/local/share/licenses/hugo/LICENSE
install -Dm755 dart-sass/sass /usr/local/bin/; rm -rf /usr/local/bin/dart-sass; mv dart-sass/src /usr/local/bin/dart-sass; chown -R root:root /usr/local/bin/dart-sass
sed -i '/^exec /s|/src/|/dart-sass/|g' /usr/local/bin/sass
cd -
rm -rf "$INSTALL_TEMPDIR"
```

**Penjelasan:**

- Baris ke-1: Untuk mendapatkan versi terbaru Hugo dari tujuan akhir pengalihan (redirect) halaman `releases/latest` di GitHub, lalu memasukkannya ke dalam variabel `HUGO_VERSION`. Awalan `v` pada tag otomatis dibuang oleh `sed` atau `string match` jika menggunakan fish
- Baris ke-2: Untuk mendapatkan versi terbaru Dart Sass dengan cara yang sama, lalu memasukkannya ke dalam variabel `DART_SASS_VERSION`
- Baris ke-3: Untuk menentukan arsitektur sistem pada berkas Hugo dan Dart Sass yang ingin Anda unduh secara otomatis ke dalam variabel `HUGO_ARCH` dan `DART_SASS_ARCH` jika arsitektur sistem mendukung, yakni `amd64`/`x86_64`, `arm64`/`aarch64` dan `arm`/`armv6*`/`armv7*` saja, jika tidak maka akan muncul galat dan skrip tidak dilanjutkan
- Baris ke-4: Untuk memasukkan nama berkas yang ingin diunduh ke dalam variabel `HUGO_FILENAME` dan `DART_SASS_FILENAME`, dengan nilai yang diambil dari nama berkas aslinya, yakni adanya versi (`HUGO_VERSION`/`DART_SASS_VERSION`) dan arsitektur sistem (`HUGO_ARCH`/`DART_SASS_ARCH`) di dalam nama berkasnya
- Baris ke-5: Untuk membuat direktori sementara dengan `mktemp -d` dan menyimpan lokasinya di variabel `INSTALL_TEMPDIR`, menavigasikan Terminal ke sana, lalu mengunduh Hugo dan Dart Sass sekaligus dengan bantuan GNU Wget. Opsi `-c` membuat unduhan bisa dilanjutkan bila terputus
- Baris ke-6: Untuk mengekstrak kedua berkas arsip `.tar.gz` secara paralel (dua proses sekaligus) dengan bantuan `xargs`
- Baris ke-7: Untuk menginstal `hugo` di direktori `/usr/local/bin` dengan chmod `755`, lalu menyalin berkas `LICENSE` milik Hugo ke `/usr/local/share/licenses/hugo/LICENSE` dengan chmod `644`
- Baris ke-8: Untuk menginstal `sass` di direktori `/usr/local/bin` dengan chmod `755`, menghapus `/usr/local/bin/dart-sass` bila ada, memindahkan direktori `src` milik Dart Sass ke `/usr/local/bin/dart-sass`, lalu menyetel pemilik direktori tersebut menjadi `root:root`
- Baris ke-9: Untuk mengubah jalur `/src/` menjadi `/dart-sass/` pada baris `exec` di berkas `/usr/local/bin/sass`, agar skrip `sass` menunjuk ke lokasi baru Dart Sass. Opsi `-i` mengubah berkas langsung di tempat
- Baris ke-10: Kembali ke direktori sebelumnya
- Baris ke-11: Menghapus direktori sementara beserta berkas unduhan dan hasil ekstrak yang sudah tak terpakai lagi

Kalau mau menginstalnya di dalam direktori pengguna, silakan ganti `/usr/local` di atas menjadi `${HOME}/.local` dan ganti `chown -R root:root` yang berada di baris ke-8 menjadi `chown -R $USER:$USER`.

**Bagaimana kalau mau _meng-update_ Hugo dan Dart Sass?** Bisa banget, tinggal eksekusikan lagi skrip di atas, otomatis berkas-berkas lama akan ditimpa.

Kamu bisa menyimpan barisan skrip di atas sebagai berkas skrip agar bisa dieksekusikan kapan saja tanpa harus mengunjungi artikel ini. Kalau mau menggunakan semuanya otomatis, tapi memakai berkas biner, silakan memakai [berkas skrip yang disediakan](#menggunakan-berkas-skrip).

**Langkah ke-3:** Setelah itu, pastikan kalau Hugo dan Dart Sass dapat berjalan dengan mengeksekusi perintah berikut untuk melihat versi Hugo dan Dart Sass yang Anda gunakan sekarang:

```shell
hugo version
sass --version
```

Jika berhasil, maka keluarannya akan seperti di bawah ini:

```plain
{{< hugo-version-long isExtended=false >}}
1.108.2
```

**Langkah ke-4 (opsional):** Masih dalam hak akses `root`, kalau mau, Anda juga dapat membuat halaman panduan (manpages) untuk Hugo dengan skrip berikut:

```shell {linenos=true}
hugo gen man --dir '/tmp/hugo_manpages'
cd /tmp/hugo_manpages; gzip -9 *
install -Dm644 * -t /usr/local/share/man/man1
cd -; rm -rf /tmp/hugo_manpages
```

**Penjelasan:**

- Baris ke-1: Untuk membuat Halaman Panduan Hugo dan berkas-berkasnya akan diletakkan di dalam direktori `/tmp/hugo_manpages` (Direktori tersebut akan dibuatkan secara otomatis jika tidak ada, jadi Anda tidak perlu membuatnya terlebih dahulu)
- Baris ke-2: Untuk menavigasikan _shell_ ke dalam direktori `/tmp/hugo_manpages`, lalu mengkompresi semua berkas di dalamnya dengan Gzip dan menghapus semua berkas aslinya
- Baris ke-3: Untuk menyalin semua berkas di dalamnya ke `/usr/local/man/man1` dan menyetel nilai chmod-nya ke `644`
- Baris ke-4: Untuk kembali ke direktori sebelumnya, lalu menghapus direktori `/tmp/hugo_manpages` dan seluruh berkas di dalamnya (atau secara rekursif)

Kalau mau membuat halaman panduan Hugo di direktori pengguna, tanpa hak akses `root`, silakan ganti `/usr/local` di atas menjadi `${HOME}/.local`.

Namun masalahnya, direktori `${HOME}/.local/share/man` tidaklah dianggap sebagai tempat untuk menyimpan halaman panduan, sehingga ketika kamu mengetik `man hugo` pun bakal dianggap tidak ada karena memang tidak dibaca, jadi tambahkan direktori tersebut ke dalam variabel `MANPATH` bersamaan dengan perintah `manpath -g` di awal.

Kalau di Terminal yang menggunakan Bash atau Zsh sebagai _shell_, Anda bisa eksekusi perintah berikut untuk menambahkannya:

```bash
printf "\n%s\n" 'MANPATH="$(manpath -g):$HOME/.local/share/man" && export MANPATH' >> ~/.bashrc
```

Ganti `~/.bashrc` menjadi `~/.zshrc` kalau Anda menggunakan Zsh sebagai _shell_.

Atau, kalau Anda menggunakan fish, perintahnya menjadi sebagai berikut:

```fish
mkdir -p {$HOME}/.config/fish/conf.d
printf '%s\n' 'set -gx MANPATH (manpath -g) {$HOME}/.local/share/man' > {$HOME}/.config/fish/conf.d/manpath.fish
```

Setelah itu Anda bisa mulai/muat ulang _shell_ yang digunakan, bisa dengan cara tutup lalu buka lagi Terminal-nya, atau eksekusi perintah `exec bash`, `exec zsh` atau `exec fish` juga bisa.

Kalau sudah, Anda bisa tes halaman panduannya dengan mengeksekusi perintah `man hugo` di dalam Terminal Anda.

**Langkah ke-5 (opsional):** Jika Anda ingin memasang fitur _completion_ untuk _shell_ yang Anda gunakan di Terminal, maka Anda dapat memasangnya dengan perintah berikut: (Sesuaikan dengan _shell_ yang terinstal di sistem Anda)

```shell {linenos=true}
### Untuk pengguna Bash
hugo completion bash | install -Dm644 /dev/stdin "/usr/share/bash-completion/completions/hugo"

### Untuk pengguna Zsh
hugo completion zsh | install -Dm644 /dev/stdin "/usr/share/zsh/site-functions/_hugo"

### Untuk pengguna fish
hugo completion fish | install -Dm644 /dev/stdin "/usr/share/fish/vendor_completions.d/hugo.fish"
```

Silakan coba fitur _completion-nya_ di dalam Terminal Anda setelah itu.

Tapi, kalau Anda mau memasangnya di dalam direktori pengguna juga bisa, silakan eksekusikan salah satu perintah berikut:

```shell
### Untuk pengguna Bash
hugo completion bash | install -Dm644 /dev/stdin "$HOME/.local/share/bash-completion/completions/hugo"

### Untuk pengguna Oh My Zsh
hugo completion zsh | install -Dm644 /dev/stdin "$HOME/.oh-my-zsh/custom/completions/_hugo"

### Untuk pengguna fish
hugo completion fish | install -Dm644 /dev/stdin "$HOME/.config/fish/completions/hugo.fish"
```

**Loh kok Oh My Zsh? Di mana Zsh biasanya?** Karena secara baku Zsh sendiri sama sekali tidak mempunyai direktori yang menyimpan dan membaca _completions_ di direktori pengguna, sedangkan jika Anda menggunakan Oh My Zsh maka direktori tersebut bisa digunakan untuk menyimpan _completions_.

Sebenarnya mudah mengatasi ini, cukup instal saja [Oh My Zsh](https://ohmyz.sh), lalu pasang _completions-nya_ dengan eksekusi perintah di atas, tapi kalau tidak mau menginstalnya maka kamu harus tambahkan direktori `$HOME/.local/share/zsh/completions` ke dalam variabel `fpath`.

Eksekusikan perintah berikut untuk menambahkan direktori tersebut ke dalam `fpath` di dalam berkas `.zshrc` sekalian memasang _completion-nya_ juga:

```shell
printf "\n%s\n" 'typeset -gaU fpath=($fpath $HOME/.local/share/zsh/completions)' >> ~/.zshrc
hugo completion zsh | install -Dm644 /dev/stdin "$HOME/.local/share/zsh/completions/_hugo"
```

Setelah itu, mulai/muat ulang Zsh-nya, bisa dengan tutup lalu buka lagi Terminal-nya, atau bisa dengan eksekusi perintah `exec zsh` atau `source ~/.zshrc` tanpa harus tutup-buka Terminal.

Silakan coba lagi _completion-nya_ apakah berfungsi dengan benar atau tidak.

**Langkah terakhir:** Jika merasa sudah selesai dan bagi yang masih di hak akses `root`, silakan alihkan kembali hak akses di dalam Terminal Anda menjadi pengguna biasa dengan perintah `exit`.

Untuk memperbarui versi Hugo dan Dart Sass-nya, cukup ulangi semua langkah-langkah di atas, nanti berkas-berkas lama akan ditimpa secara otomatis.

### macOS

#### Berkas penginstal

**Catatan:** Saya tidak memakai sistem operasi macOS, mungkin cara instalasi yang saya lontarkan di sini kurang begitu akurat sehingga bisa saja salah. Jika terjadi kesalahan, mohon berikan masukan/koreksi dari Anda melalui kolom komentar.

Anda dapat menginstal Hugo menggunakan berkas penginstal yang disediakan secara resmi jika Anda menggunakan macOS.

Cukup unduh berkasnya di [halaman perilisannya](https://github.com/gohugoio/hugo/releases) yang biasanya berkas tersebut berekstensi `.pkg`, lalu buka berkasnya.

Setelah dibuka maka penginstal akan muncul, cukup ikuti saja langkahnya, lalu masukkan kata sandi Administrator bila perlu. Hugo pun langsung terinstal setelah itu.

Perlu diingat bahwa ini tidaklah menginstal Dart Sass, Anda dapat menginstalnya menggunakan pengelola paket Homebrew/`brew`.

#### Homebrew

Homebrew tersedia untuk macOS maupun GNU/Linux. Perintah instalasinya sama dengan bagian [Homebrew di GNU/Linux](#homebrew-lebih-universal).

#### MacPorts

**Catatan:** Saya tidak memakai sistem operasi macOS dan MacPorts sebagai pengelola paket, mungkin cara instalasi yang saya lontarkan di sini kurang begitu akurat sehingga bisa saja salah. Jika terjadi kesalahan dan Anda adalah pengguna MacPorts, mohon berikan masukan/koreksi dari Anda melalui kolom komentar.

Jika Anda menggunakan [MacPorts](https://www.macports.org/) sebagai pengelola paket di dalam macOS, maka Anda dapat menginstal Hugo dengan perintah berikut:

```shell
sudo port install hugo
```

Jika Anda tidak ingin menggunakan `sudo`, maka hapus saja `sudo`-nya.

### Android

#### Termux

Jika Anda menggunakan [Termux](https://termux.com/) di dalam Android, maka Anda dapat menginstal Hugo dengan perintah berikut:

```shell
pkg i hugo
```

Saya sarankan agar Anda menggunakan Termux versi terbaru untuk pengalaman yang lebih nyaman, bisa Anda unduh di [F-Droid](https://f-droid.org/en/packages/com.termux/), [GitHub](https://github.com/termux/termux-app/releases) atau [Google Play Store (eksperimental)](https://play.google.com/store/apps/details?id=com.termux). Perlu versi Android minimal 7.0 agar Termux versi terbaru dapat digunakan.

Perintah di atas tidak akan menginstal Dart Sass, silakan memakai [berkas skrip yang disediakan](#menggunakan-berkas-skrip) untuk menginstalnya.

### BSD

#### OpenBSD dan keluarganya

**Catatan:** Saya tidak memakai sistem operasi berbasis BSD, seperti OpenBSD, mungkin cara instalasi yang saya lontarkan di sini kurang begitu akurat sehingga bisa saja salah. Jika terjadi kesalahan dan Anda adalah pengguna OpenBSD, mohon berikan masukan/koreksi dari Anda melalui kolom komentar.

Jika Anda adalah pengguna OpenBSD dan keluarganya, maka Anda dapat menginstal Hugo dengan perintah berikut:

```shell
doas pkg_add hugo
```

#### NetBSD dan keluarganya

**Catatan:** Saya tidak memakai sistem operasi berbasis BSD, seperti NetBSD, mungkin cara instalasi yang saya lontarkan di sini kurang begitu akurat sehingga bisa saja salah. Jika terjadi kesalahan dan Anda adalah pengguna OpenBSD, mohon berikan masukan/koreksi dari Anda melalui kolom komentar.

Jika Anda adalah pengguna NetBSD dan keluarganya, maka Anda dapat menginstal Hugo dengan perintah berikut:

```shell
sudo pkgin install go-hugo
```

#### FreeBSD, DragonFly BSD, dan keluarganya

**Catatan:** Saya tidak memakai sistem operasi berbasis BSD, seperti FreeBSD dan DragonFly BSD, mungkin cara instalasi yang saya lontarkan di sini kurang begitu akurat sehingga bisa saja salah. Jika terjadi kesalahan dan Anda adalah pengguna FreeBSD dan DragonFly BSD, mohon berikan masukan/koreksi dari Anda melalui kolom komentar.

Jika Anda adalah pengguna FreeBSD, DragonFly BSD dan keluarganya, maka Anda dapat menginstal Hugo dengan perintah berikut:

```shell
sudo pkg install gohugo
```

### Docker

Jika Anda menggunakan Docker, mungkin Anda bisa gunakan _Docker Image_ [`hugomods/hugo`](https://hub.docker.com/r/hugomods/hugo) untuk itu. Ini memang bukan dari pengembang resmi, tapi ini yang paling aktif.

Untuk penjelasan lebih lanjut, silakan kunjungi [situs web resminya](https://docker.hugomods.com).

## Pertanyaan dan jawaban

### Pertanyaan ke-1: varian Hugo mana yang harus dipakai? {#pertanyaan-ke1}

**Jawab:** Sebaiknya edisi standar tanpa fitur **Deploy**, karena pilihannya terbatas dan secara fungsi tidak lebih baik daripada memakai Rclone.

Akan lebih baik kalau Dart Sass terinstal, mengingat banyak tema yang menggunakan Sass juga, tapi sayangnya tidak semua cara instalasi di sini bisa menyertakan instalasi Dart Sass.

### Pertanyaan ke-2: kenapa cara instal Hugo di Fedora, Red Hat, dan keluarganya dulu tidak dibahas? {#pertanyaan-ke2}

**Jawab:** ~~Karena versi Hugo yang digunakan oleh Fedora, Red Hat, dan Keluarganya adalah versi lama.~~

~~Hingga saat ini, saya belum menemukan repositori luar yang cocok untuk Fedora, Red Hat, dan Keluarganya.~~

~~Jika Anda sangat ingin menginstal Hugo di dalam Distribusi yang tidak saya bahas, maka saya sarankan agar Anda menginstalnya melalui cara yang lebih "Universal" seperti menggunakan Snap, Homebrew, Nix atau melalui cara manual (mengunduh berkas biner, tanpa pengelola paket).~~

**Pembaruan (7 Juni 2023):** Sekarang cara instal untuk Fedora, CentOS, RHEL, dan keluarganya sudah saya bahas, sehingga pertanyaan ini tidak berlaku lagi.

### Pertanyaan ke-3: apakah cara instal untuk openSUSE bisa diaplikasikan di Fedora, Red Hat, dan keluarganya? {#pertanyaan-ke3}

**Jawab:** Tidak bisa, kalaupun bisa maka sebaiknya jangan, karena pada dasarnya distribusi keluarga SUSE dan Fedora/Red Hat memang berbeda meskipun sama-sama menggunakan RPM sebagai salah satu sistem pengelolaan paketnya dan sama-sama merupakan GNU/Linux.

Letak perbedaannya nanti di paket ketergantungannya, mulai dari nama paketnya sampai versi dari paket-paket tersebut yang didapat akan berbeda satu sama lain.

Jika Anda ingin mencobanya ya silakan saja, tapi segala risiko yang ada atau yang telah terjadi, silakan Anda tanggung sendiri.

## Penutup

Sudah? Iya, sudah, cuma itu saja yang perlu Anda lakukan. Ini merupakan artikel yang membahas tentang 'Cara Install Hugo', bukan 'Cara Install Hugo beserta konfigurasinya', walaupun saya sedikit berbasa-basi tentang apa itu Hugo dan apa saja variannya.

Demi kesederhanaan Artikel ini, maka topik tentang membuat Blog di Hugo beserta konfigurasinya akan saya bahas secara terpisah.

Jika kamu mempunyai pertanyaan, kritik dan saran, komentar atau masukan lainnya, silakan kamu berkomentar melalui kolom komentar yang tersedia atau bisa kamu [Hubungi Saya](/tentang).

Terima kasih atas perhatiannya 😊
