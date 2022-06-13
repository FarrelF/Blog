# Folder Konfigurasi
Folder/Direktori ini merupakan tempat penyimpanan konfigurasi untuk Hugo.

Yap, Anda tidak salah baca, saya tidak menggunakan berkas `config.toml`, `config.yaml` atau `config.json` sebagai konfigurasi, melainkan melalui Folder ini.

Untuk lebih lanjut mengenai folder ini, silahkan Anda baca [dokumentasinya](https://gohugo.io/getting-started/configuration/#configuration-directory) (terutama di bagian "Configuration Directory").

## Struktur Direktori dan Berkas
Struktur direktori dan berkas nya sebagai berikut:

```plain
config
├── _default
│   ├── config.yaml
│   ├── menu.yaml
│   ├── module.yaml
│   └── params.yaml
├── development
│   ├── module.yaml
│   └── server.yaml
├── production
│   ├── config.yaml
│   └── params.yaml
└── README.md
```

Seperti yang Anda lihat di atas, di sini ada 3 folder/direktori yang masing-masing mewakili lingkungan kerja Hugo, antara lain:

- [`_default`](_default): Merupakan direktori yang menyimpan berkas konfigurasi baku untuk Hugo.

    Karena merupakan konfigurasi baku, jadi berkas-berkas di dalamnya akan digunakan oleh Hugo ketika menghasilkan Blog dalam lingkungan apapun, termasuk lingkungan produksi atau pengembangan.

    Di dalam direktori tersebut, ada 4 berkas konfigurasi, yakni: 
    - [`_default/config.yaml`](_default/config.yaml): Merupakan berkas konfigurasi utama
    - [`_default/menu.yaml`](_default/menu.yaml): Merupakan berkas konfigurasi yang mempresentasikan [`menu`](https://gohugo.io/content-management/menus/) atau `[Menu]` pada Konfigurasi Hugo
    - [`_default/module.yaml`](_default/module.yaml): Merupakan berkas konfigurasi yang mempresentasikan [`module`](https://gohugo.io/hugo-modules/configuration/) atau `[Module]` pada Konfigurasi Hugo
    - [`_default/params.yaml`](_default/params.yaml): Merupakan berkas konfigurasi yang mempresentasikan [`params`](https://gohugo.io/variables/site/#the-siteparams-variable) atau `[Params]` pada Konfigurasi Hugo

- [`development`](development): Merupakan direktori yang menyimpan berkas-berkas konfigurasi untuk lingkungan pengembangan pada Hugo.

    Berkas-berkas di dalamnya akan digunakan oleh Hugo ketika menghasilkan Blog dalam lingkungan pengembangan. Di dalam direktori tersebut, ada 2 berkas konfigurasi, yakni:
    - [`development/module.yaml`](development/module.yaml): Merupakan berkas konfigurasi yang mempresentasikan [`module`](https://gohugo.io/hugo-modules/configuration/) atau `[Module]` pada Konfigurasi Hugo
    - [`development/server.yaml`](development/server.yaml): Merupakan berkas konfigurasi yang mempresentasikan [`server`](https://gohugo.io/getting-started/configuration/#configure-server) atau `[Server]` pada Konfigurasi Hugo

    Sekadar info saja, `development` sendiri adalah lingkungan (_environment_) baku untuk Hugo yang digunakan saat menjalankan perintah `hugo server`.

    Jadi, ketika Anda menjalankan `hugo server` atau menambahkan argumen `-e development` saat ingin menjalankan Aplikasi Hugo, maka folder tersebut secara otomatis akan digunakan sebagai konfigurasi dan isinya akan digabungkan dengan konfigurasi `_default`

- [`production`](production): Merupakan direktori yang menyimpan berkas-berkas konfigurasi untuk lingkungan produksi pada Hugo.

    Berkas-berkas di dalamnya akan digunakan oleh Hugo ketika menghasilkan Blog dalam lingkungan produksi. Di dalam direktori tersebut, ada 2 berkas konfigurasi, yakni: 
    - [`production/config.yaml`](production/config.yaml): Merupakan berkas konfigurasi utama
    - [`production/params.yaml`](production/params.yaml): Merupakan berkas konfigurasi yang mempresentasikan [`params`](https://gohugo.io/variables/site/#the-siteparams-variable) atau `[Params]` pada Konfigurasi Hugo

    Sekadar info saja, `production` sendiri adalah lingkungan (_environment_) baku untuk Hugo yang digunakan saat menjalankan perintah `hugo` ataupun menghasilkan sebuah Blog/Situs Web yang kemudian disebar (_deploy_) ke tempat yang disebut dengan _Hosting_.

    Jadi, ketika Anda menggunakan perintah `hugo` untuk menghasilkan Web/Blog atau menambahkan argumen `-e production` saat ingin menjalankan Aplikasi Hugo, maka secara otomatis folder tersebut akan digunakan sebagai konfigurasi dan isinya akan digabungkan dengan konfigurasi `_default`

## Cara Kontribusi
Jika Anda ingin mengubah konfigurasi pada Blog ini, Anda harus mengetahui bagaimana mengkonfigurasi Web/Blog yang menggunakan Hugo.

Setelah itu, pastikan konfigurasi yang telah Anda lakukan sesuai dengan peruntukkan yang seharusnya dan sesuai pada tempatnya, jika tidak (cth. membuat berkas yang mempresentasikan konfigurasi `Server` di lingkungan produksi, dll), maka _Pull Request_ Anda akan saya tolak.

Harap maklumi 😊