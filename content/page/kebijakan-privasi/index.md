---
Title: Kebijakan Privasi
Slug: kebijakan-privasi
Authors: Farrel Franqois
comments: false
license: Halaman ini telah saya buat di bawah lisensi <a class="link" href="https://creativecommons.org/licenses/by-nd/4.0/" target="_blank" rel="noopener">CC BY-ND 4.0</a>
menu:
  main:
    identifier: privacy-policy
    weight: -75
    params:
      icon: eye
---

## Pembuka

Setelah kamu mengunjungi blog ini, maka akan ada data yang dikumpulkan oleh saya dan berbagai pihak. Maka dari itu, di halaman ini saya akan jelaskan informasi apa saja yang dikumpulkan dan cara saya menggunakannya secara transparan.

## Data yang saya kumpulkan, untuk apa, berapa lama dan cara saya mengumpulkannya

### Data-data teknis

Ketika kamu mengunjungi blog ini, maka data yang saya kumpulkan adalah sebagai berikut:

- Alamat IP kamu dan negara asalnya
- Peramban atau _User-Agent_ yang kamu gunakan
- URL Pengarah (_Referrer URL_)
- URL Permintaan (_Request URL_)
- Ukuran Permintaan (_Request Size_)

Saya menggunakan [Bunny Storage](https://bunny.net/storage/) sebagai tempat penyimpanan utama untuk berkas-berkas blog statis, serta [Bunny CDN](https://bunny.net/cdn/) sebagai CDN dan _reverse-proxy_ utama yang menghubungkan penyimpanan tersebut.

Sehingga data-data teknis di atas secara otomatis dikumpulkan oleh Bunny CDN dan saya simpan ke dalam Bunny Storage khusus agar disimpan secara permanen untuk keperluan pengarsipan. Saya mengumpulkan data-data tersebut untuk keperluan statistik akses blog, mengoptimalkan blog, melakukan _troubleshooting_ serta mengamankannya dari serangan yang mana mengakibatkan akses blog yang berlebihan.

Saya juga menggunakan [Bunny Stream](https://bunny.net/stream/) untuk video-video yang ada di dalam artikel blog ini, yang juga memerlukan Bunny CDN untuk menyebarkan/mendistribusikan video-nya, sehingga data-data yang dikumpulkan hampir sama seperti Bunny CDN.

Selain itu, blog ini juga menggunakan [Bunny DNS](https://bunny.net/dns/) sebagai Penyedia DNS, yang artinya saya juga dapat mengumpulkan data-data seperti berikut:

- Tanggal dan Waktu Kueri
- Tipe Kueri
- Nama Hos (_Hostname_)
- Alamat IP Remot atau Alamat IP _Resolver DNS_ dan negara asalnya
- Alamat IP EDNS dan negara asalnya (jika _Resolver DNS-mu_ mendukung ekstensi EDNS)
- Jawaban dari server DNS

Data-data di atas dikumpulkan oleh Bunny DNS dan saya mengumpulkannya dengan tujuan yang hampir sama, yakni untuk mengoptimalkan blog dan melakukan _troubleshooting_ waktu ada masalah ketika menggunakan penyedia DNS tersebut. Hanya saja, data-data tersebut tidak disimpan secara permanen, melainkan hanya sampai 3 hari saja.

Semua data yang saya kumpulkan TIDAK AKAN saya bagikan ke mana pun kecuali ke dukungan layanan yang saya pakai untuk keperluan penyelesaian masalah yang berkaitan dengan blog ini dan juga TIDAK ADA data pribadi yang dikumpulkan maupun dibagikan saat Anda mengunjungi blog ini.

### Analitik, Pengukuran dan Iklan

Saya tidak memasang analitik dan iklan apa pun di blog ini, jadi saya maupun pihak lain jelas tidak dapat melacak pengunjung blog ini dengan lebih akurat dan tidak dapat mengumpulkan hasilnya.

Kecuali pengukuran RUM (_Real user monitoring_) terbatas yang dilakukan oleh Bunny Stream untuk mengukur pengalaman pengunjung dalam memutar video, mengoptimalkannya, dan membantu membuat _heatmap_ pada video, pengukuran tersebut hanya aktif kalau artikel dan halaman terdapat sebuah video dari Bunny Stream dan memuatnya.

Pengukuran tersebut tidak dimaksudkan untuk melacak pengunjung blog secara keseluruhan, baik kebiasaan pribadi maupun preferensi pengguna, serta tidak ada data pribadi dikumpulkan maupun dibagikan, Anda dapat memblokirnya menggunakan pemblokir iklan sebelum mengakses sebuah artikel tertentu kalau mau.

Untuk lebih lanjut, silakan kunjungi [halaman GDPR-nya](https://bunny.net/gdpr/).

### Hal yang perlu diperhatikan

Saya mengerti kekhawatiran Anda mengenai pengumpulan data-data di atas, terutama Alamat IP Anda, tapi ada hal yang harus Anda perhatikan terlebih dahulu, yakni sebagai berikut:

- Alamat IP apa pun yang dikumpulkan itu tidak ditampilkan sepenuhnya, melainkan alamat IP dengan satu _octet_ yang terhapus dan diganti dengan angka nol (cth. `114.114.114.0`).

  Ini juga berlaku untuk alamat IPv6 yang juga tidak ditampilkan sepenuhnya, melainkan alamat IPv6 dengan 4 _octet_ yang terhapus dan diganti dengan angka nol

- Kebanyakan Alamat IP yang digunakan, terutama untuk rumahan, itu bersifat dinamis atau/dan banyak orang yang menggunakan 1 alamat IP secara bersamaan, serta lokasinya tidak begitu akurat.

  Sehingga alamat IP tidak bisa dengan relevan untuk melacak atau menemukan lokasi seseorang dan perangkat

- Data-data yang dikumpulkan tidak memungkinkan bagi saya untuk melacak pengunjung blog dan tidak dimaksudkan demikian

Itulah hal lain yang harus Anda perhatikan, jadi tidak perlu khawatir akan data-data seperti apa yang dikumpulkan.

## Pihak lain yang saya gunakan

Di bawah ini merupakan pihak lain yang saya gunakan untuk blog ini:

### giscus

Saya menggunakan giscus sebagai sistem komentar di blog ini, ia merupakan sebuah sistem komentar pihak ke-3 yang diberdayakan oleh [GitHub Discussion](https://docs.github.com/en/discussions). Sehingga untuk menggunakannya dan berkomentar, Anda harus masuk menggunakan akun GitHub terlebih dahulu.

Dengan masuk menggunakan akun GitHub dan berkomentar di blog ini, maka Anda telah tunduk, patuh dan setuju terhadap [kebijakan privasi GitHub](https://docs.github.com/en/github/site-policy/github-privacy-statement).

## Kuki dan penyimpanan lokal

Anda tidak memerlukan kuki apa pun untuk mengakses blog ini, tapi Anda perlu fitur penyimpanan lokal (_Local Storage_) pada peramban web Anda yang biasanya secara otomatis aktif di peramban web mayoritas tanpa perlu melakukan apa pun di sisi Anda.

Penyimpanan lokal ini diperlukan untuk menyimpan data skema warna (mode gelap dan terang) untuk mengingat preferensi skema warna tema dan sesi giscus jika melakukan login menggunakan akun GitHub di dalam peramban Anda.

Tidak ada data pribadi apa pun di dalamnya, semua data yang disimpan tidak akan disebar ke mana pun dan juga tidak dimaksudkan untuk melacak pengunjung. Semua yang berada di dalam penyimpanan lokal ditujukan untuk fungsionalitas blog ini.

## Keamanan Data

Blog ini menggunakan protokol TLS untuk mengenkripsi transmisi data dan diakses menggunakan protokol HTTPS, serta semua aset dan skrip yang ada di blog ini dimuat sepenuhnya menggunakan HTTPS, tidak ada satu pun pemuatan yang bercampur dengan protokol HTTP.

Selain itu, blog ini juga menerapkan _HSTS Preloading_ agar blog ini selalu diakses menggunakan protokol HTTPS di peramban web dengan memaksanya mengalihkan ke HTTPS langsung melalui peramban web, tanpa bantuan dari _web server_ karena domain yang dimasukkan ke dalam _HSTS Preload List_ yang berada di dalam peramban.

Otoritas sertifikat/CA (_Certificate Authority_) yang saya gunakan untuk menerbitkan sertifikat TLS blog ini adalah [Google Trust Services](https://pki.goog) sebagai CA utama dan [ZeroSSL](https://zerossl.com) sebagai CA cadangan.

Sehingga jika sertifikat TLS yang ditampilkan itu berbeda, kemungkinan ada suatu perangkat lunak yang dapat mencegat dan memodifikasi permintaan HTTPS, entah itu dengan tujuan keamanan, pemblokiran iklan, sampai melacak pengguna. Jika itu terjadi, maka hal itu sudah berada di luar kendali saya.

Untuk keamanan data yang tersimpan di dalam layanan Bunny\.net yang saya gunakan (seperti Bunny CDN, Bunny Storage, dll), silakan kunjungi [kebijakan privasinya](https://bunny.net/privacy/).

## Kontak

Jika Anda memiliki pertanyaan seputar kebijakan privasi ini, silakan [hubungi saya](/tentang#hubungi-saya) untuk lebih lanjut.

## Persetujuan dan Perubahan Kebijakan

Kebijakan ini akan berlaku selama Anda mengunjungi, menjelajahi dan menggunakan blog ini untuk keperluan apa pun.

Jadi dengan tetap mengunjungi blog ini, maka Anda telah menyetujui segala ketentuan dalam kebijakan privasi di blog ini.

Selain itu, saya berhak untuk mengubah kebijakan ini kapan pun dan di mana pun, tanpa perlu pemberitahuan terlebih dahulu, dengan alasan apa pun.

Mengenai halaman kebijakan privasi di blog ini:

- Diperbarui/diubah pada Hari/Tanggal: **Senin, 04 Agustus 2025**
- Diberlakukan pada Hari/Tanggal: **Senin, 04 Agustus 2025**

## Penutup

Baiklah, sekian untuk halaman kebijakan privasi blog kali ini. Semoga Anda memahami dan memaklumi adanya ketentuan seperti ini.

Terima kasih atas perhatiannya dari kalian semua 😊
