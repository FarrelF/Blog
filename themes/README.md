# Folder Tema
Folder/Direktori ini merupakan tempat yang menyimpan Tema untuk Hugo. Selain tema, di sini juga menyimpan berkas-berkas tema yang telah dimodifikasi.

## Struktur Direktori dan Berkas
Struktur direktori dan berkas nya sebagai berikut:

```plain
themes
├── hugo-theme-stack
│   ├── archetypes
│   ├── assets
│   ├── data
│   ├── exampleSite
│   ├── .github
│   ├── i18n
│   ├── images
│   ├── layouts
│   ├── LICENSE
│   ├── netlify.toml
│   ├── README.md
│   └── theme.toml
├── README.md
└── stack-modified
    ├── assets
    ├── data
    ├── i18n
    └── layouts
```

Seperti yang Anda lihat di atas, di sini ada 2 folder untuk saat ini, yakni:
- [`hugo-stack-theme`](hugo-stack-theme): Merupakan folder tema utama, tema yang saya gunakan sekarang dan itu merupakan _Submodule_ dari [_Repository_ Aslinya](https://github.com/CaiJimmy/hugo-theme-stack)
- [`stack-modified`](stack-modified): Merupakan folder yang menyimpan berkas-berkas tema yang telah dimodifikasi dan merupakan tema 'turunan' dari folder [`hugo-stack-theme`](hugo-stack-theme), sehingga struktur direktori nya menurun dari yang aslinya.

## Cara Kontribusi
Saya menggunakan salah satu Modul Hugo, yakni Komponen Tema (bahasa Inggris: _Theme Components_) atau konsep "Tema Turunan" untuk memodifikasi temanya, mungkin cara modifikasi nya tidak seperti yang Anda lakukan biasanya.

Namun, jika Anda sudah pernah menggunakan ["Child Themes" pada WordPress](https://developer.wordpress.org/themes/advanced-topics/child-themes/) sebelumnya, saya cukup yakin bahwa Anda pasti familiar dengan konsep seperti ini.

Jadi, jika Anda ingin memodifikasi tema yang saya gunakan di Blog ini, pertama-tama Anda harus baca [dokumentasi nya](https://gohugo.io/hugo-modules/theme-components/) mengenai hal itu terlebih dahulu.

Intinya yang perlu Anda lakukan adalah menyalinkan berkas yang ingin Anda rubah dari [tema aslinya](hugo-theme-stack), lalu salinkan berkas tersebut ke dalam [tema turunan nya](stack-modified) dengan lokasi folder yang sama, setelah itu Anda rubah berkas yang Anda salinkan itu.

**Contoh:** Jika Anda ingin memodifikasi berkas `pagination.html` yang terletak di [`hugo-theme-stack/layouts/partials/pagination.html`](hugo-theme-stack/layouts/partials/pagination.html), maka Anda perlu salinkan berkas tersebut ke dalam folder `stack-modified/layouts/partials`, lalu berkas yang perlu Anda rubah adalah `stack-modified/layouts/partials/pagination.html`.

Serta, jika ada berkas yang ingin Anda tambahkan sendiri, silahkan tambahkan itu ke dalam folder tema turunan.

Jangan mengotori dan menggantikan folder _Submodule_ tersebut dengan alasan apapun, jika Anda melakukan nya, maka dengan senang hati saya menolak _Pull Request_ dari Anda. Harap maklum 😊