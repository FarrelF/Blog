# Cara Kontribusi
Kontribusi dari Anda sangatlah berharga bagi saya. Jika Anda ingin berkontribusi untuk blog ini, maka Anda bisa melakukannya dengan berbagai cara yang telah saya sediakan.

Caranya sebagai berikut:

## Cara ke-1: Mengubah Kode Sumber
Jika Anda ingin berkontribusi dengan membantu konfigurasi blog ini atau ikut serta dalam mengubah kode sumbernya.

### Struktur Direktori dan Berkas pada Kode Sumber
Namun sebelum mengubah kode sumber, maka Anda perlu mengetahui struktur direktori dan berkas yang ada di kode sumber ini, beserta fungsi-fungsinya.

Berikut di bawah ini adalah struktur direktori dan berkas-berkasnya:

```plain
FarrelF-Blog
├── config
│   ├── _default
│   ├── development
│   ├── production
│   └── README.md
├── content
│   ├── 404.md
│   ├── categories
│   ├── page
│   ├── post
│   ├── README.md
│   └── tags
├── CONTRIBUTING.md
├── .github
│   └── workflows
├── .gitignore
├── go.mod
├── go.sum
├── layouts
│   └── shortcodes
├── LICENSE
├── netlify.toml
├── README.md
└── static
    ├── 0xA47AE59DC94ABF69.asc
    ├── ads.txt
    ├── BingSiteAuth.xml
    ├── CNAME
    ├── copyrighted-d8d7be3e6f3ee7ab.html
    ├── google0ec7ff3a4f28b0d2.html
    ├── google71ef861592f6b855.html
    ├── keybase.txt
    └── _headers
```

Setelah melihat struktur direktori dan berkasnya di atas, maka saatnya Anda mengetahui apa berkas dan direktori tersebut.

Berikut adalah Informasi mengenai berkas-berkasnya yang berada di dalam direktori akar (_Root directory_)-nya:
- [`.gitignore`](.gitignore): Adalah berkas yang berisikan berkas-berkas atau direktori yang akan diabaikan oleh Git, sehingga direktori atau berkas di dalam daftar tersebut tidak akan dimasukkan ke dalam kode sumber/repositori karena alasan tertentu
- `CONTRIBUTING.md`: Adalah berkas yang Anda akses sekarang
- [`LICENSE`](LICENSE): Adalah berkas lisensi untuk kode sumber ini
- [`README.md`](README.md): Sepertinya Anda sangat tahu apa berkas ini, jadi tidak perlu saya jelaskan
- [`netlify.toml`](netlify.toml): Adalah berkas konfigurasi untuk Netlify

Dan berikut adalah Informasi mengenai direktori-direktorinya:
- [`.github/workflows`](.github/workflows): Adalah direktori yang menyimpan sejumlah berkas yang akan digunakan oleh GitHub Actions untuk membangun blog ini dan menyebarkan hasilnya ke Server Hosting. Untuk hasil penggunaannya, silakan [klik di sini](https://github.com/FarrelF/Blog/actions).

    Yap, Anda gak salah mengira, saya menghosting blog ini ke banyak tempat dan Netlify bukanlah tempat Hosting yang utama, melainkan cadangannya saja.

- [`config`](config): Adalah direktori yang menyimpan berkas konfigurasi untuk Hugo.

    Yap, Anda tidak salah baca, saya tidak menggunakan berkas `config.toml`, `config.yaml` atau `config.json` sebagai konfigurasi Hugo di sini, melainkan saya menggunakan direktori agar konfigurasinya jadi lebih mudah dan bisa mengurangi kerepotan, serta membuat kode sumber terlihat lebih rapi.

    Untuk saat ini, di dalam direktori tersebut ada 3 sub-direktori, yakni sub-direktori `_default` yang menyimpan berkas konfigurasi baku, `production` yang menyimpan berkas konfigurasi untuk lingkungan produksi, dan `development` yang menyimpan berkas konfigurasi untuk lingkungan pengembangan (_development_). Untuk lebih lanjut, silakan masuk ke dalam direktorinya.

    Dokumentasinya bisa Anda baca [di sini](https://gohugo.io/getting-started/configuration/#configuration-directory)

- [`content`](content): Adalah direktori yang menyimpan konten-konten pada Blog ini, seperti Artikel, Halaman, Kategori, Tag dan bahkan Halaman khusus untuk Galat HTTP dengan kode 404.
- [`layouts/shortcodes`](layouts/shortcodes): Adalah direktori yang menyimpan berkas templat untuk _Shortcodes_ yang akan digunakan untuk memasukkan sebuah skrip atau Tag HTML ke dalam sebuah Konten (Artikel, Halaman, dll) menggunakan kode yang telah dipendekkan, yang merupakan salah satu fitur dari Hugo.

    Dokumentasinya bisa Anda baca [di sini](https://gohugo.io/templates/shortcode-templates/)

- [`static`](static): Adalah direktori yang menyimpan berkas yang benar-benar statik, sehingga berkas-berkas tersebut tidak mungkin dimodifikasi oleh Hugo saat menghasilkan Blog/Situs Web, melainkan disalin ke dalam Akar Situs (_Site Root_) setelah Blog dihasilkan oleh Hugo, sehingga bisa diakses secara langsung dengan URL `https://<alamat_domain>/<nama_berkas_statik>`.

    Contoh terbaik mengenai kegunaan direktori tersebut adalah menyimpan berkas HTML untuk keperluan verifikasi kepemilikan Situs Web/Blog di Google Search Console, ~~menyimpan berkas `robots.txt`~~*, dll, yang mana semua itu tidak perlu dimodifikasi oleh Hugo saat menghasilkan Blog ini.

    **PEMBARUAN Senin, 13 Juni 2022:** Sejak _commit_ [`e9fb143`](https://github.com/FarrelF/Blog/commit/e9fb1439cb3f1cd88d61d014a8d035faf7929f5c), saya memutuskan untuk memakai berkas `robots.txt` yang dihasilkan secara otomatis oleh Hugo, sehingga saya tidak lagi menyimpannya secara manual ke dalam folder tersebut.

    Jika Anda menaruh berkas yang seharusnya dimodifikasi oleh Hugo saat menghasilkan Blog (seperti berkas Gambar, JS, CSS, Fon, dll) tanpa alasan yang jelas, maka dengan senang hati saya akan menolak mentah-mentah _pull request_ dari Anda 😊

    Dokumentasinya bisa Anda baca [di sini](https://gohugo.io/content-management/static-files/)

Jika Anda ingin mengubah kode sumber yang berada di dalam direktori, masuklah ke dalam direktori tersebut untuk lebih lanjut dan baca berkas `README.md` yang ada di setiap direktori, tetapi tidak semua direktori ada berkas tersebut

### Cara mengubah Kode Sumber
Caranya cukup mudah, Anda tinggal ikuti langkah di bawah ini:

1. Buatlah sebuah _fork_ dari Repo ini

2. Klon Repo GitHub dari Repo yang Anda buat _fork_-nya tadi

3. Penuhi terlebih dahulu semua [persyaratannya](https://github.com/FarrelF/Blog#persyaratan). Setelah memenuhi persyaratan, barulah Anda bisa menggunakannya

4. Navigasikan _Shell_ yang Anda gunakan ke dalam folder kode sumber yang Anda klon tadi dengan perintah `cd`

5. Lalu, buatlah sebuah _Branch_ baru dari repositori yang Anda _fork_ tadi, Anda bisa turunkan _branch_ tersebut dari `origin/main`. Lalu, namai _branch_ tersebut sesuai dengan apa yang ingin kamu lakukan (cth. `fix-i18n-string` jika Anda ingin memperbaiki terjemahan, dll)

6. Setelah Anda membuat _bBranch_ baru, alihkan ke _branch_ tersebut, lalu ubah kode sumbernya dari situ, bisa melalui editor teks/kode favorit kamu

7. Lakukan _Staging_, buatlah sebuah _Commit_ dan isi pesannya dengan pesan yang jelas, lalu lakukan _Push_. Pesannya sendiri tidak perlu dalam bahasa Inggris, tetapi akan lebih bagus lagi jika kamu menggunakannya

8. Setelah selesai, buatlah sebuah _Pull Request_ jika Anda benar-benar ingin mengubah kode sumber ini. Pastikan Anda membuatnya dari _branch_ yang Anda buat tadi di dalam repositori _fork_ Anda ke tujuan `FarrelF-Blog:main`

Ya udah, cuma gitu aja.

### Cara memodifikasi tema
Jika Anda ingin memodifikasi tema sebagai bentuk kontribusi Anda, silakan lakukan itu di dalam repositori [`stack-modified`](https://github.com/FarrelF/stack-modified) milik saya.

## Cara ke-2: Menyawer
Kalau Anda suka atau merasa informasi dari blog saya ini berguna, Anda bisa menyawerkan sedikit uang Anda sebagai kontribusi Anda untuk blog ini.

Jika Anda ingin menyawerkannya, Anda bisa melakukannya melalui [PayPal](https://paypal.me/FarrelF), [Ko-fi](https://ko-fi.com/farrelf), [Saweria](https://saweria.co/FarrelFranqois) atau melalui [Trakteer](https://trakteer.id/farrelf/tip) saya.

Untuk lebih lengkapnya, silakan kunjungi halaman ["Tentang"](https://farrel.franqois.id/tentang/) di blog saya.

## Cara ke-3: Memberikan Masukan atau Bertanya
Anda bisa bertanya, memberikan kritik dan saran, serta berkomentar di dalam blog ini dan kode sumbernya.

- Jika Anda mempunyai masalah saat menggunakan kode sumber ini, atau memberikan masukan tentang kode sumber ini, silakan Anda buat tiket ["Issue"](https://github.com/FarrelF/Blog/issues) di dalam repositori ini

- Jika Anda mempunyai pertanyaan atau hal lain yang ingin didiskusikan mengenai blog ini, silakan Anda membuat diskusinya di bagian ["Discussion"](https://github.com/FarrelF/Blog/discussions)

- Jika Anda ingin berkomentar atau kritik dan saran mengenai artikel di dalam [blog ini](https://farrel.franqois.id), silakan berkomentar melalui kolom komentar yang tersedia di akhir artikel blog

- Jika Anda mempunyai pertanyaan lainnya yang tidak mau Anda sebarkan ke publik, silakan hubungi saya

Nah, itulah cara kontribusinya, jika Anda mempunyai pertanyaan mengenai berkas ini, silakan tanyakan itu melalui ["Discussion"](https://github.com/FarrelF/Blog/discussions) di dalam repositori ini.

Terima kasih 😊