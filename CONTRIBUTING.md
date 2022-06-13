# Cara Kontribusi
Kontribusi dari Anda sangatlah berharga bagi saya. Jika Anda ingin berkontribusi untuk blog ini, maka Anda bisa melakukannya dengan berbagai cara yang telah saya sediakan.

Caranya sebagai berikut:

## Cara ke-1: Mengubah Kode Sumber
Jika Anda ingin berkontribusi dengan membantu konfigurasi Blog ini atau ikut serta dalam mengubah Kode Sumbernya.

### Struktur Direktori dan Berkas pada Kode Sumber
Tapi sebelum merubah Kode Sumber, maka Anda perlu mengetahui struktur direktori dan berkas yang ada di kode sumber ini, beserta fungsi-fungsinya.

Berikut di bawah ini adalah Struktur Direktori dan Berkasnya:

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

Berikut adalah Informasi mengenai berkas-berkasnya yang berada di dalam direktori Akar (_Root directory_)-nya:
- [`.gitignore`](.gitignore): Adalah berkas yang berisikan berkas-berkas atau direktori yang akan diabaikan oleh Git, sehingga direktori atau berkas di dalam daftar tersebut tidak akan dimasukkan ke dalam Kode Sumber/_Repository_ karena alasan tertentu.
- `CONTRIBUTING.md`: Adalah berkas yang Anda akses sekarang.
- [`LICENSE`](LICENSE): Adalah berkas Lisensi untuk Kode Sumber ini,
- [`README.md`](README.md): Sepertinya Anda sangat tahu apa berkas ini, jadi tidak usah saya jelaskan.
- [`netlify.toml`](netlify.toml): Adalah berkas konfigurasi untuk Netlify.

Dan berikut adalah Informasi mengenai direktori-direktorinya:
- [`.github/workflows`](.github/workflows): Adalah direktori yang menyimpan sejumlah berkas yang akan digunakan oleh GitHub Actions untuk membangun blog ini dan menyebarkan hasilnya ke Server Hosting. Untuk hasil penggunaannya, silahkan Anda [klik di sini](https://github.com/FarrelF/Blog/actions).

    Yap, Anda gak salah mengira, saya Hosting Blog ini di banyak tempat dan Netlify bukanlah tempat Hosting yang utama, melainkan cadangannya saja.

- [`config`](config): Adalah direktori yang menyimpan berkas konfigurasi untuk Hugo.

    Yap, Anda tidak salah baca, saya tidak menggunakan berkas `config.toml`, `config.yaml` atau `config.json` sebagai konfigurasi Hugo di sini, melainkan saya menggunakan direktori agar konfigurasinya jadi lebih mudah dan bisa mengurangi kerepotan, serta membuat kode sumber terlihat lebih rapi.

    Untuk saat ini, di dalam direktori tersebut ada 3 sub-direktori, yakni sub-direktori `_default` yang menyimpan berkas konfigurasi baku, `production` yang menyimpan berkas konfigurasi untuk lingkungan produksi, dan `development` yang menyimpan berkas konfigurasi untuk lingkungan pengembangan (_development_). Untuk lebih lanjut, silahkan masuk ke dalam direktorinya.

    Dokumentasinya bisa Anda baca [di sini](https://gohugo.io/getting-started/configuration/#configuration-directory)

- [`content`](content): Adalah direktori yang menyimpan konten-konten pada Blog ini, seperti Artikel, Halaman, Kategori, Tag dan bahkan Halaman khusus untuk Galat HTTP dengan kode 404.
- [`layouts/shortcodes`](layouts/shortcodes): Adalah direktori yang menyimpan berkas templat untuk _Shortcodes_ yang akan digunakan untuk memasukkan sebuah skrip atau Tag HTML ke dalam sebuah Konten (Artikel, Halaman, dll) menggunakan kode yang telah dipendekkan, yang merupakan salah satu fitur dari Hugo.

    Dokumentasinya bisa Anda baca [di sini](https://gohugo.io/templates/shortcode-templates/)

- [`static`](static): Adalah direktori yang menyimpan berkas yang benar-benar statik, sehingga berkas-berkas tersebut tidak mungkin dimodifikasi oleh Hugo saat menghasilkan Blog/Situs Web, melainkan disalin ke dalam Akar Situs (_Site Root_) setelah Blog dihasilkan oleh Hugo, sehingga bisa diakses secara langsung dengan URL `https://<alamat_domain>/<nama_berkas_statik>`.

    Contoh terbaik mengenai kegunaan direktori tersebut adalah menyimpan berkas HTML untuk keperluan verifikasi kepemilikan Situs Web/Blog di Google Search Console, ~~menyimpan berkas `robots.txt`~~*, dll, yang mana semua itu tidak perlu dimodifikasi oleh Hugo saat menghasilkan Blog ini.

    **PEMBARUAN Senin, 13 Juni 2022:** Sejak _commit_ [`e9fb143`](https://github.com/FarrelF/Blog/commit/e9fb1439cb3f1cd88d61d014a8d035faf7929f5c), saya memutuskan untuk memakai berkas `robots.txt` yang dihasilkan secara otomatis oleh Hugo, sehingga saya tidak lagi menyimpannya secara manual ke dalam folder tersebut.

    Jika Anda menaruh berkas yang seharusnya dimodifikasi oleh Hugo saat menghasilkan Blog (seperti berkas Gambar, JS, CSS, Fon, dll) tanpa alasan yang jelas, maka dengan senang hati saya menolak mentah-mentah _Pull Request_ Anda 😊

    Dokumentasinya bisa Anda baca [di sini](https://gohugo.io/content-management/static-files/)

Jika Anda ingin merubah kode sumber yang berada di dalam direktori, masuklah ke dalam direktori tersebut untuk lebih lanjut dan baca berkas `README.md` yang ada di setiap direktori, tapi gak semua direktori.

### Cara merubah Kode Sumber
Caranya cukup mudah, Anda tinggal ikuti langkah di bawah ini:

1. Buatlah sebuah _fork_ dari Repo ini

2. Klon Repo GitHub dari Repo yang Anda buat _fork_-nya tadi

3. Penuhi terlebih dahulu semua [Persyaratannya](https://github.com/FarrelF/Blog#persyaratan). Setelah memenuhi persyaratan, barulah Anda bisa menggunakannya

4. Navigasikan _Shell_ yang Anda gunakan ke dalam Folder Kode Sumber yang Anda klon tadi dengan perintah `cd`

5. Lalu, buatlah sebuah _Branch_ baru dari Repo yang Anda _fork_ tadi, Anda bisa turunkan _Branch_ tersebut dari `origin/main`. Lalu, namai _branch_ tersebut sesuai dengan apa yang ingin kamu lakukan (cth. `fix-i18n-string` jika Anda ingin memperbaiki terjemahan, dll)

6. Setelah Anda membuat _Branch_ baru, alihkan ke _Branch_ tersebut, lalu ubah Kode Sumbernya dari situ, bisa melalui Editor Teks/Kode favorit kamu

7. Lakukan _Staging_, buatlah sebuah _Commit_ dan isi pesannya dengan pesan yang jelas, lalu lakukan _Push_. Pesannya sendiri tidak perlu dalam bahasa Inggris, tapi akan lebih bagus jika kamu menggunakannya

8. Setelah Anda selesai, buatlah sebuah _Pull Request_ jika Anda benar-benar ingin mengubah Kode Sumber ini. Pastikan Anda membuatnya dari _Branch_ yang Anda buat tadi di dalam Repo _fork_ Anda ke tujuan `FarrelF-Blog:main`

Ya udah, cuma gitu aja.

### Cara memodifikasi tema
Jika Anda ingin memodifikasi tema sebagai bentuk kontribusi Anda, silahkan lakukan itu di dalam _Repository_ [`stack-modified`](https://github.com/FarrelF/stack-modified) milik saya.

## Cara ke-2: Melakukan Donasi
Jadi kalau Anda suka atau merasa informasi dari blog saya ini berguna, Anda bisa menyisihkan sedikit uang Anda untuk mendonasikannya sebagai kontribusi Anda untuk Blog ini. 

Jika Anda ingin mendonasikannya, Anda bisa melakukannya melalui [PayPal](https://paypal.me/FarrelF) atau melalui Akun [Saweria](https://saweria.co/FarrelFranqois) saya.

Selain itu, Anda juga dapat mentransfer sejumlah uang dari rekening bank Anda melalui BI-FAST ke alamat proksi saya, yakni `farrel(at)franqois(dot)id` dan bank yang saya pakai adalah blu/BCA Digital (PT Bank Digital BCA).

## Cara ke-3: Memberikan Masukan atau Bertanya
Anda bisa bertanya, memberikan kritik dan saran, serta berkomentar di dalam blog ini dan kode sumbernya.

- Jika Anda mempunyai masalah saat menggunakan kode sumber ini, atau memberikan masukan tentang kode sumber ini, silahkan Anda buat tiket ["Issue"](https://github.com/FarrelF/Blog/issues) di dalam Repo ini.

- Jika Anda mempunyai pertanyaan atau hal lain yang ingin didiskusikan mengenai Blog ini, silahkan Anda membuat Diskusinya di bagian ["Discussion"](https://github.com/FarrelF/Blog/discussions).

- Jika Anda ingin berkomentar atau kritik dan saran mengenai Artikel di dalam [Blog ini](https://farrel.franqois.id), silahkan berkomentar melalui kolom komentar yang tersedia di akhir Artikel Blog.

- Jika Anda mempunyai pertanyaan lainnya yang mana tidak mungkin Anda sebarkan ke publik, silahkan hubungi saya.

Nah, itulah cara kontribusinya, jika Anda mempunyai pertanyaan mengenai Berkas ini, silahkan tanyakan itu melalui ["Discussion"](https://github.com/FarrelF/Blog/discussions) di dalam Repo inih.

Terima kasih 😊