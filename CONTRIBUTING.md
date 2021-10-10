# Cara Kontribusi
Kontribusi dari Anda sangatlah berharga bagi saya. Jika Anda ingin berkontribusi untuk blog ini, maka Anda bisa melakukannya dengan berbagai cara yang telah saya sediakan.

Caranya sebagai berikut:

## Cara ke-1: Mengubah Kode Sumber
Jika Anda ingin berkontribusi dengan membantu konfigurasi Blog ini atau ikut serta dalam mengubah Kode Sumber nya.

### Struktur Direktori dan Berkas pada Kode Sumber
Tapi sebelum merubah Kode Sumber, maka Anda perlu mengetahui struktur direktori dan berkas yang ada di kode sumber ini, beserta fungsi-fungsi nya.

Berikut di bawah ini adalah Struktur Direktori dan Berkas nya:

```plain
FarrelF-Blog
├── archetypes
│   ├── categories.md
│   ├── default.md
│   └── tags.md
├── config
│   ├── _default
│   ├── development
│   └── production
├── content
│   ├── 404.md
│   ├── categories
│   ├── page
│   ├── post
│   └── tags
├── CONTRIBUTING.md
├── .github
│   └── workflows
├── .gitignore
├── .gitmodules
├── layouts
│   └── shortcodes
├── LICENSE
├── netlify.toml
├── README.md
├── static
│   ├── 0xA47AE59DC94ABF69.asc
│   ├── ads.txt
│   ├── BingSiteAuth.xml
│   ├── CNAME
│   ├── copyrighted-d8d7be3e6f3ee7ab.html
│   ├── google0ec7ff3a4f28b0d2.html
│   ├── google71ef861592f6b855.html
│   ├── keybase.txt
│   ├── _redirects
│   ├── robots_preview
│   └── robots.txt
└── themes
    ├── hugo-theme-stack
    └── stack-modified
```

Setelah melihat struktur direktori dan berkas nya di atas, maka saatnya Anda mengetahui apa berkas dan direktori tersebut.

Berikut adalah Informasi mengenai berkas-berkas nya yang berada di dalam direktori Akar (_Root directory_) nya:
- [`.gitignore`](.gitignore): Adalah berkas yang berisikan berkas-berkas atau direktori yang akan diabaikan oleh Git, sehingga direktori atau berkas di dalam daftar tersebut tidak akan dimasukkan ke dalam Kode Sumber/_Repository_ karena alasan tertentu.
- [`.gitmodules`](.gitmodules): Adalah berkas yang berisikan _Submodule_ yang digunakan oleh _Repository_ Git ini.
- `CONTRIBUTING.md`: Adalah berkas yang Anda akses sekarang.
- [`LICENSE`](LICENSE): Adalah berkas Lisensi untuk Kode Sumber ini,
- [`README.md`](README.md): Sepertinya Anda sangat tahu apa berkas ini, jadi tidak usah saya jelaskan.
- [`netlify.toml`](netlify.toml): Adalah berkas konfigurasi untuk Netlify.

Dan berikut adalah Informasi mengenai direktori-direktori nya:
- [`.github/workflows`](.github/workflows): Adalah direktori yang menyimpan sejumlah berkas yang akan digunakan oleh GitHub Actions untuk membangun blog ini dan menyebarkan hasilnya ke Server Hosting. Untuk hasil penggunaan nya, silahkan Anda [klik di sini](https://github.com/FarrelF/Blog/actions).

    Yap, Anda gak salah mengira, saya Hosting Blog ini di banyak tempat dan Netlify bukanlah tempat Hosting yang utama, melainkan cadangannya saja.

- [`config`](config): Adalah direktori yang menyimpan berkas konfigurasi untuk Hugo.

    Yap, Anda tidak salah baca, saya tidak menggunakan berkas `config.toml`, `config.yaml` atau `config.json` sebagai konfigurasi Hugo di sini, melainkan saya menggunakan direktori agar konfigurasinya jadi lebih mudah dan bisa mengurangi kerepotan, serta membuat kode sumber terlihat lebih rapi.

    Untuk saat ini, di dalam direktori tersebut ada 3 sub-direktori, yakni sub-direktori `_default` yang menyimpan berkas konfigurasi baku, `production` yang menyimpan berkas konfigurasi untuk lingkungan produksi, dan `development` yang menyimpan berkas konfigurasi untuk lingkungan pengembangan (_development_). Untuk lebih lanjut, silahkan masuk ke dalam direktori nya.

    Dokumentasi nya bisa Anda baca [di sini](https://gohugo.io/getting-started/configuration/#configuration-directory)

- [`content`](content): Adalah direktori yang menyimpan konten-konten pada Blog ini, seperti Artikel, Halaman, Kategori, Tag dan bahkan Halaman khusus untuk Galat HTTP dengan kode 404.
- [`layouts/shortcodes`](layouts/shortcodes): Adalah direktori yang menyimpan berkas templat untuk _Shortcodes_ yang akan digunakan untuk memasukkan sebuah skrip atau Tag HTML ke dalam sebuah Konten (Artikel, Halaman, dll) menggunakan kode yang telah dipendekkan, yang merupakan salah satu fitur dari Hugo.

    Dokumentasi nya bisa Anda baca [di sini](https://gohugo.io/templates/shortcode-templates/)

- [`static`](static): Adalah direktori yang menyimpan berkas yang benar-benar statik, sehingga berkas-berkas tersebut tidak mungkin dimodifikasi oleh Hugo saat menghasilkan Blog/Situs Web, melainkan disalin ke dalam Akar Situs (_Site Root_) setelah Blog dihasilkan oleh Hugo, sehingga bisa diakses secara langsung dengan URL `https://<alamat_domain>/<nama_berkas_statik>`.

    Contoh terbaik mengenai kegunaan direktori tersebut adalah menyimpan berkas HTML untuk keperluan verifikasi kepemilikan Situs Web/Blog di Google Search Console, menyimpan berkas `robots.txt`, dll, yang mana semua itu tidak perlu dimodifikasi oleh Hugo saat menghasilkan Blog ini.

    Jika Anda menaruh berkas yang seharusnya dimodifikasi oleh Hugo saat menghasilkan Blog (seperti berkas Gambar, JS, CSS, Fonta, dll) tanpa alasan yang jelas, maka dengan senang hati saya menolak mentah-mentah _Pull Request_ Anda 😊

    Dokumentasi nya bisa Anda baca [di sini](https://gohugo.io/content-management/static-files/)

- [`themes`](themes): Adalah direktori yang menyimpan tema-tema yang digunakan untuk Blog ini, selain tema, di situ juga terdapat sub-direktori untuk menyimpan berkas-berkas tema yang telah dimodifikasi.

    Untuk saat ini, di dalam direktori tersebut ada 2 sub-direktori, yakni `hugo-theme-stack` yang merupakan merupakan _Submodule_ dari [_Repository_ asli nya](https://github.com/CaiJimmy/hugo-theme-stack) dan [`stack-modified`](themes/stack-modified) merupakan sebuah sub-direktori yang hanya menyimpan berkas-berkas tema yang telah dimodifikasi.

    Jika Anda ingin berkontribusi pada penampilan di blog ini, silahkan modifikasi itu di dalam direktori `stack-modified` dan pelajari [dokumentasi nya](https://gohugo.io/hugo-modules/theme-components/). Tapi jika Anda ingin kontribusi terhadap tema aslinya, silahkan kontribusi ke Halaman _Repository_ Tema Aslinya.

    Jangan 'mengotori' dan menggantikan direktori _Submodule_ nya dengan alasan apapun! Jika Anda melakukan nya, maka dengan senang hati saya menolak _Pull Request_ dari Anda.

Jika Anda ingin merubah kode sumber yang berada di dalam direktori, masuklah ke dalam direktori tersebut untuk lebih lanjut dan baca berkas `README.md` yang ada di setiap direktori, tapi gak semua direktori.

### Cara merubah Kode Sumber
Cara nya cukup mudah, Anda tinggal ikuti langkah di bawah ini:

1. Buatlah sebuah _fork_ dari Repo ini

2. Klon Repo GitHub dari Repo yang Anda buat _fork_ nya tadi

3. Penuhi terlebih dahulu semua [Persyaratan nya](https://github.com/FarrelF/Blog#persyaratan). Setelah memenuhi persyaratan, barulah Anda bisa menggunakan nya

4. Navigasikan _Shell_ yang Anda gunakan ke dalam Folder Kode Sumber yang Anda klon tadi dengan perintah `cd`

5. Lalu, buatlah sebuah _Branch_ baru dari Repo yang Anda _fork_ tadi, Anda bisa turunkan _Branch_ tersebut dari `origin/main`. Lalu, namai _branch_ tersebut sesuai dengan apa yang ingin kamu lakukan (cth. `fix-i18n-string` jika Anda ingin memperbaiki terjemahan, dll)

6. Setelah Anda membuat _Branch_ baru, alihkan ke _Branch_ tersebut, lalu ubah Kode Sumber nya dari situ, bisa melalui Editor Teks/Kode favorit kamu

7. Lakukan _Staging_, buatlah sebuah _Commit_ dan isi pesannya dengan pesan yang jelas, lalu lakukan _Push_. Pesan nya sendiri tidak perlu dalam bahasa Inggris, tapi akan lebih bagus jika kamu menggunakan nya

8. Setelah Anda selesai, buatlah sebuah _Pull Request_ jika Anda benar-benar ingin mengubah Kode Sumber ini. Pastikan Anda membuatnya dari _Branch_ yang Anda buat tadi di dalam Repo _fork_ Anda ke tujuan `FarrelF-Blog:main`

Ya udah, cuma gitu aja.

## Cara ke-2: Melakukan Donasi
Anda bisa menyisihkan sedikit uang Anda untuk mendonasikan nya sebagai kontribusi Anda untuk Blog ini. 

Jika Anda ingin mendonasikan nya, Anda bisa melakukan nya melalui [PayPal](https://paypal.me/FarrelF) atau Akun [Trakteer](https://trakteer.id/farrelf) saya.

Rencana nya saya akan membuat artikel yang hanya bisa kalian baca/lihat setelah membayar nya di sana (Trakteer), namun sepertinya hal itu belum bisa terjadi dalam waktu dekat.

Jadi kalau Anda suka atau merasa Informasi nya berguna, maka Anda bisa sekadar berdonasi sekali atau setiap bulan nya di sana.

## Cara ke-3: Memberikan Masukan atau Bertanya
Anda bisa bertanya, memberikan kritik dan saran, serta berkomentar di dalam blog ini dan kode sumber nya.

- Jika Anda mempunyai masalah saat menggunakan kode sumber ini, atau memberikan masukan tentang kode sumber ini, silahkan Anda buat tiket ["Issue"](https://github.com/FarrelF/Blog/issues) di dalam Repo ini.

- Jika Anda mempunyai pertanyaan atau hal lain yang ingin didiskusikan mengenai Blog ini, silahkan Anda membuat Diskusi nya di bagian ["Discussion"](https://github.com/FarrelF/Blog/discussions).

- Jika Anda ingin berkomentar atau kritik dan saran mengenai Artikel di dalam [Blog ini](https://farrel.franqois.id), silahkan berkomentar melalui kolom komentar yang tersedia di akhir Artikel Blog.

- Jika Anda mempunyai pertanyaan lainnya yang mana tidak mungkin Anda sebarkan ke publik, silahkan hubungi saya.

Nah, itulah cara kontribusi nya, jika Anda mempunyai pertanyaan mengenai Berkas ini, silahkan tanyakan itu melalui ["Discussion"](https://github.com/FarrelF/Blog/discussions) di dalam Repo inih.

Terima kasih 😊