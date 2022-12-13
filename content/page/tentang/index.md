---
title: Tentang
description: Laman ini berisikan Informasi Tentang Saya dan juga blog ini, bagi yang ingin kenalan bisa kunjungi laman ini
license: Laman ini telah saya buat dibawah lisensi <a class="link" href="https://creativecommons.org/licenses/by-nd/4.0/" target="_blank" rel="noopener">CC BY-ND 4.0</a>
slug: tentang
comments: false
aliases: 
  - tentang-saya
  - tentang-blog
  - hubungi-saya
author: Farrel Franqois
menu:
  main:
    identifier: about
    name: Tentang
    weight: -90
    params:
      icon: user
custom:
  css:
    path: custom.css
---

## Tentang Saya
Saya adalah makhluk hidup yang biasa-biasa saja, penuh dengan salah dan yah biasa-biasa aja, gak ada istimewanya. Jika adanya kesalahan teknis pada blog ini, tolong dikoreksi yah, saya juga sedang belajar menggunakan _Static-site Generator_.

## Tentang Blog ini
### Ikhtisar
Blog ini merupakan blog pribadi milik saya, tetapi yang saya bahas ini bukan sekadar tentang pribadi saya saja. Di blog ini, saya membahas apa yang ingin saya bahas.

Bukan apa-apa, namun mungkin blog ini agak _nge-random_ pembahasannya, entah itu bikin tutorial, beropini, bikin catatan biar gak lupa atau sekadar bikin diari kalo niat.

### Penggunaan Blog
Agar blog ini 'hidup' (bukan dalam artian _makhluk hidup_ yah), maka saya perlu beberapa komponen yang membantunya.

Berikut ini adalah apa yang saya pakai untuk blog ini:

- SSG: [Hugo Extended](https://gohugo.io/) (versi [{{< hugo-version >}}](https://github.com/gohugoio/hugo/releases/tag/v{{< hugo-version >}})), saya gak pake CMS/_Platform_ kayak WordPress
- Tema: [Hugo Theme Stack](https://github.com/CaiJimmy/hugo-theme-stack)
- Fon: Keluarga [Lato](https://www.latofonts.com/) (varian: Lato Latin)
- Favicon: Ikon [Papan Klip](https://pixabay.com/images/id-1294565/) oleh [OpenClipart-Vectors](https://pixabay.com/users/openclipart-vectors-30363/) dari Pixabay, dilisensikan di bawah [Lisensi Pixabay](https://pixabay.com/service/license/)
- VCS: [GitHub](https://github.com)
- CI/CD:
  - [GitHub Actions](https://github.com/features/actions) sebagai CI/CD Utama
  - Netlify sebagai CI/CD Cadangan dan untuk pratinjau
- Domain:
  - [PT Cloud Hosting Indonesia (IDCloudHost)](https://afiliasi.farrel.franqois.id/idch/) sebagai Registrar dan Pengelola Domainnya
- DNS Otoritatif: [Cloudflare DNS](https://www.cloudflare.com/dns/)
- Hosting/Tempat Penyimpanan:
  - [Bunny Storage](https://afiliasi.farrel.franqois.id/bunny/storage/) sebagai Tempat Penyimpanan Utama untuk Blog
  - [Storj DCS (Decentralized Cloud Storage)](https://www.storj.io), [Tebi](https://tebi.io/), [Cloudflare Pages](https://pages.cloudflare.com/) dan [Netlify](https://www.netlify.com) sebagai Tempat Penyimpanan dan Hosting Cadangan
- Pewali terbalik (_Reverse Proxy_): [Bunny CDN](https://afiliasi.farrel.franqois.id/bunny/cdn/)
- Sertifikat TLS/SSL: [Google Trust Services (GTS)](https://pki.goog)
- CDN: Bunny CDN (Untuk berkas CSS, Fon dan Gambar)
- Sistem Komentar: [giscus](https://giscus.app)

### Kode Sumber Blog
Jika Anda menginginkan kode sumber untuk blog ini, entah untuk tujuan kontribusi, mempelajari blog ini atau lainnya, silakan kunjungi alamat URL berikut:

```plain
https://github.com/FarrelF/Blog
```

Atau, alamat URL berikut untuk kode sumber cerminnya:

```plain
https://gitlab.com/FarrelF/Blog
```

Kode Sumber tersebut saya lisensikan di bawah [GNU AGPLv3](https://github.com/FarrelF/Blog/blob/main/LICENSE), tetapi artikel di blog ini secara baku saya lisensikan di bawah [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/), kecuali jika ada yang [dinyatakan sebaliknya](/ketentuan-dan-kebijakan-blog/).

Jadi, mungkin ada beberapa materi tertentu yang bisa saja diterbitkan di bawah lisensi yang berbeda (Contoh: Gambar/Media yang bersumber dari luar, dll) dan lisensi untuk materi-materi tersebut akan saya sebutkan di masing-masing Artikel dan Laman sebagai atribusi jika saya diizinkan untuk menggunakannya.

## Informasi Kontak
### Surel
- farrel(at)franqois(dot)id (Surel Pribadi)
- farrelf(at)pm(dot)me atau farrelf(at)protonmail(dot)com (Menggunakan Protonmail, "katanya" lebih aman dan lebih ramah privasi)

### Media sosial/Perpesanan {#medsos}
- Telegram: [@FarrelF](https://t.me/FarrelF)
- Twitter: [@FarrelFranqois](https://twitter.com/FarrelFranqois)
- Facebook: [Farrel Franqois](https://www.facebook.com/FarrelFranqois)
- Keybase: [FarrelF](https://keybase.io/farrelf) (~~Jarang Aktif~~ Mungkin gak akan aktif)

## Kunci Publik
### Kunci PGP/GPG {#kunci-gpg}
Kunci PGP/GPG nantinya akan berguna buat Anda yang ingin mengirimkan pesan ke saya dengan lebih aman, serta dapat mengurangi kemungkinan untuk terbaca oleh orang lain karena memerlukan kunci pribadi saya untuk membukanya.

Berikut adalah informasi mengenai kunci GPG saya:

|<span class="tab-center">Informasi</span>|<span class="tab-center">Isi Data</span>|
|:--------------------|:-------------------------------------------------------------|
| Atas Nama           | Farrel Franqois                                              |
| Jenis Kunci         | ECC (Ed25519 dan Curve25519)                                 |
| Masa Berlaku        | 21 Januari 2026                                              |
| ID Kunci (Pendek)   | `0xA47AE59DC94ABF69` atau `A47AE59DC94ABF69`                 |
| ID Kunci (Panjang)  | `A148 2DE3 7280 1F1A E00F 92E0 A47A E59D C94A BF69`          |

Unduh kunci:
- [Mailvelope](https://keys.mailvelope.com/pks/lookup?op=get&search=0xA47AE59DC94ABF69)
- [OpenPGP\.org](https://keys.openpgp.org/search?q=A1482DE372801F1AE00F92E0A47AE59DC94ABF69)
- [Langsung (melalui CDN)](/0xA47AE59DC94ABF69.asc)

### Kunci Publik SSH
Kunci ini akan berguna buat Anda yang ingin perangkatnya (seperti Komputer PC/Laptop, Server, Ponsel/Tablet, dll) diakses oleh saya melalui SSH atas izin dari Anda untuk keperluan apa pun, seperti menggunakan jasa/layanan dari saya yang memerlukan akses perangkat Anda, dll.

Anda dapat mengunduh/melihat kunci-kunci publik tersebut melalui GitHub saya: [https://github.com/FarrelF.keys](https://github.com/FarrelF.keys)

Atau, selain melalui GitHub, Anda juga dapat mengunduhnya secara manual melalui tautan di bawah ini dengan jenis kunci yang berbeda-beda:

- [Ed25519](/ssh/id_ed25519.pub) (disarankan)
- [ECDSA P-256](/ssh/id_ecdsa.pub)
- [RSA 4096-bit](/ssh/id_rsa.pub)

Kalau bisa, saya sarankan agar Anda menggunakan Ed25519 sebagai jenis kunci publiknya, selain karena paling kecil ukurannya ketimbang jenis kunci lainnya, kunci tersebut lebih cepat dalam memproses autentikasi SSH dan diklaim lebih aman juga.

Lalu, masukkan isi kunci-kunci tersebut ke dalam berkas `.ssh/authorized_keys` di perangkat Anda.

## Memberi Dukungan/Menyawer {#menyawer}
Anda bisa memberikan dukungan terhadap blog ini atau menyawer sejumlah uang Anda melalui beberapa cara berikut di bawah ini:

- [PayPal](https://paypal.me/FarrelF) (Internasional)
- Rekening Bank: (Atas Nama: OK Mohammad Edbert Farrel Franqois)
  - Bank Syariah Indonesia:
    - No. Rekening: `7203370703`
    - Kode Bank: 451
    - Kode Swift: BSMDIDJA
  - Bank Digital BCA/BCA Digital/blu:**\***
    - No. Rekening/bluAccount: `001566549842`
    - Kode Bank: 501
- Kamu bisa [nyawer ke saya](https://saweria.co/FarrelFranqois) melalui Saweria
- Kamu bisa [memberikan tip ke saya](https://arxist.id/farrelf/tip) melalui Arxist
- Mendaftar sebuah layanan memakai tautan afiliasi merupakan salah satu pemberian dukungan dari Anda tanpa harus mengeluarkan biaya tambahan apapun untuk membayar sebuah layanan. Bahkan di halaman ini juga ada tautan afiliasinya, hehe 😁

{{< info title="**\*Keterangan:**" >}}
Jika Anda ingin mentransfernya dari rekening BCA konvensional ke rekening BCA Digital/blu, pastikan pilih "Transfer Antar Bank", bukan "Transfer ke Sesama BCA" atau "Transfer Antar Rekening". Kenapa? Karena ini beda bank, meski termasuk dalam Grup BCA.

Jika ingin bebas biaya transfer, pastikan metode transfer yang Anda pilih adalah "Transfer Online" atau "Realtime Online", bukan "BI-FAST", karena transfer dengan BI-FAST tetap akan dikenakan biaya sebesar Rp2.500,00/transaksi.

**Bagaimana dengan BCA Syariah?** Sayangnya meski dalam satu grup yang sama (Grup BCA), BCA Syariah tetap dikenakan biaya seperti biasanya, baik dari BCA Syariah ke blu/BCA Digital atau sebaliknya, jadi saya sarankan untuk memakai BI-FAST sebagai metode transfernya atau memakai aplikasi transfer antar bank seperti [Flip](https://afiliasi.farrel.franqois.id/flip/) atau sejenisnya agar biayanya menjadi lebih murah.
{{< / info >}}

## Akhir Kata
Ya sudah, itu saja untuk halaman ini. Maaf kalau terlalu singkat, saya sendiri juga tidak terlalu niat-niat amat dalam mengurusi halaman ini sampai-sampai membuat kisah hidup saya di sini.

Halaman ini adalah tentang blog ini dan ringkasan mengenai saya, jadi saya buat secukupnya saja.

Semoga blog ini bermanfaat bagi Anda yang telah membaca artikelnya ^_^
