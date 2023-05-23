# Folder Konfigurasi

Folder/Direktori ini merupakan tempat penyimpanan konfigurasi untuk Hugo.

Yap, Anda tidak salah baca, saya tidak menggunakan berkas `config.toml`, `config.yaml` atau `config.json` sebagai konfigurasi, melainkan melalui Folder ini.

Untuk lebih lanjut mengenai folder ini, silakan baca halaman [dokumentasinya](https://gohugo.io/getting-started/configuration/#configuration-directory) (terutama di bagian "Configuration Directory").

## Struktur Direktori dan Berkas

Struktur direktori dan berkasnya sebagai berikut:

```plain
config
├── _default
│   ├── config.toml
│   ├── menu.toml
│   ├── module.toml
│   └── params.toml
├── development
│   ├── module.toml
│   └── server.toml
├── production
│   ├── config.toml
│   └── params.toml
└── README.md
```

Seperti yang Anda lihat di atas, di sini ada 3 folder/direktori yang masing-masing mewakili lingkungan kerja Hugo, antara lain:

- [`_default`](_default): Merupakan direktori yang menyimpan berkas konfigurasi baku untuk Hugo.

    Karena merupakan konfigurasi baku, jadi berkas-berkas di dalamnya akan digunakan oleh Hugo ketika menghasilkan Blog dalam lingkungan apa pun, termasuk lingkungan produksi atau pengembangan.

    Di dalam direktori tersebut, ada 4 berkas konfigurasi, yakni:

  - [`_default/config.toml`](_default/config.toml): Merupakan berkas konfigurasi utama
  - [`_default/menu.toml`](_default/menu.toml): Merupakan berkas konfigurasi yang mempresentasikan [`[Server]`](https://gohugo.io/content-management/menus/) pada Konfigurasi Hugo
  - [`_default/module.toml`](_default/module.toml): Merupakan berkas konfigurasi yang mempresentasikan [`[Module]`](https://gohugo.io/hugo-modules/configuration/) pada Konfigurasi Hugo
  - [`_default/params.toml`](_default/params.toml): Merupakan berkas konfigurasi yang mempresentasikan [`[Params]`](https://gohugo.io/variables/site/#the-siteparams-variable) pada Konfigurasi Hugo

- [`development`](development): Merupakan direktori yang menyimpan berkas-berkas konfigurasi untuk lingkungan pengembangan pada Hugo.

    Berkas-berkas di dalamnya akan digunakan oleh Hugo ketika menghasilkan Blog dalam lingkungan pengembangan. Di dalam direktori tersebut, ada 2 berkas konfigurasi, yakni:
  - [`development/module.toml`](development/module.toml): Merupakan berkas konfigurasi yang mempresentasikan [`[Module]`](https://gohugo.io/hugo-modules/configuration/) pada Konfigurasi Hugo
  - [`development/server.toml`](development/server.toml): Merupakan berkas konfigurasi yang mempresentasikan [`[Server]`](https://gohugo.io/getting-started/configuration/#configure-server) pada Konfigurasi Hugo

    Sekadar info saja, `development` sendiri adalah lingkungan (_environment_) baku untuk Hugo yang digunakan saat menjalankan perintah `hugo server`.

    Jadi, ketika Anda menjalankan `hugo server` atau menambahkan argumen `-e development` saat menjalankan Aplikasi Hugo, maka folder tersebut secara otomatis akan digunakan sebagai konfigurasi dan isinya akan digabungkan dengan konfigurasi `_default`

- [`production`](production): Merupakan direktori yang menyimpan berkas-berkas konfigurasi untuk lingkungan produksi pada Hugo.

    Berkas-berkas di dalamnya akan digunakan oleh Hugo ketika menghasilkan Blog dalam lingkungan produksi. Di dalam direktori tersebut, ada 2 berkas konfigurasi, yakni:
  - [`production/config.toml`](production/config.toml): Merupakan berkas konfigurasi utama
  - [`production/params.toml`](production/params.toml): Merupakan berkas konfigurasi yang mempresentasikan [`[Params]`](https://gohugo.io/variables/site/#the-siteparams-variable) pada Konfigurasi Hugo

    Sekadar info saja, `production` sendiri adalah lingkungan (_environment_) baku untuk Hugo yang digunakan saat menjalankan perintah `hugo` ataupun menghasilkan sebuah Blog/Situs Web yang kemudian disebar (_deploy_) ke tempat yang disebut dengan _Hosting_.

    Jadi, ketika Anda menggunakan perintah `hugo` untuk menghasilkan Web/Blog atau menambahkan argumen `-e production` saat menjalankan Aplikasi Hugo, maka secara otomatis folder tersebut akan digunakan sebagai konfigurasi dan isinya akan digabungkan dengan konfigurasi `_default`

## Cara Kontribusi

Jika Anda ingin mengubah konfigurasi pada Blog ini, Anda harus mengetahui bagaimana mengkonfigurasi Web/Blog yang menggunakan Hugo.

Setelah itu, pastikan konfigurasi yang telah Anda lakukan sesuai dengan peruntukkan yang seharusnya dan sesuai pada tempatnya, jika tidak (cth. membuat berkas yang mempresentasikan konfigurasi `Server` di lingkungan produksi, dll), maka _pull request_ Anda akan saya tolak.

Harap maklumi 😊
