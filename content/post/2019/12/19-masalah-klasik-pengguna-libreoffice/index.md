---
Title: Masalah Klasik (Calon) Pengguna LibreOffice dan Cara mengatasi nya
Categories: 
    - Tutorial
    - Opini
Author: Farrel Franqois
Tags: 
    - Cara mengatasi
    - Kompatibilitas
    - LibreOffice
    - Windows
    - GNU/Linux
Date: 2019-12-19 21:42:00+07:00
Slug: masalah-klasik-pengguna-libreoffice
image: LibreOffice-External-Logo.png
readMore: true
descriptionSEO: Apakah Anda merasa kesulitan saat menggunakan LibreOffice pertama kali dan ingin mengatasi nya? Silahkan baca Artikel ini!
description: |-
    Banyak sekali pengguna LibreOffice yang merasa kesulitan dalam menggunakan nya, seperti dokumen nya yang berantakan saat di buka dengan Microsoft Office, masalah kompatibilitas dan masalah lain nya. 

    Artikel ini akan membahas hal-hal dasar yang harus di lakukan ketika Anda menggunakan LibreOffice dengan "Benar", dan saya bahas pada bagian yang paling "dasar" nya saja, yang mana ini tidak banyak di ketahui oleh banyak orang. 

    Penasaran? Silahkan baca artikel ini, kalau tidak, yah tidak apa-apa 🙂
---

## Pembuka
LibreOffice merupakan sebuah Perangkat Lunak Paket Perkantoran yang merupakan Perangkat Lunak Bebas/FLOSS (Free/Libre Open Source Software) dan juga bisa di peroleh secara gratis. Biasanya Perangkat Lunak ini bisa menjadi alternatif, bahkan menggantikan Microsoft Office itu sendiri. Perangkat Lunak ini di kembangkan oleh sebuah organisasi nirlaba, yakni: [The Document Foundation (TDF)](https://www.documentfoundation.org/) dan sejumlah kontributor lain nya.

Perangkat Lunak ini cukup populer, terutama di kalangan pengguna GNU/Linux. Salah satu alasannya adalah karena Distribusi GNU/Linux yang mereka gunakan itu biasanya sudah ter-install LibreOffice secara bawaan (_default_). Ubuntu, Varian (Seperti: Xubuntu, Lubuntu, Kubuntu, Ubuntu MATE, dll) dan Turunan nya (seperti Mint, Pop_OS!, dll) merupakan salah satu contoh nya.

Namun sayangnya, banyak sekali dari mereka yang mengeluhkan sebuah masalah yang klasik, yang mana itu seharusnya tidak perlu di keluhkan/di permasalahkan, apa saja masalah nya? Mungkin bisa Anda lanjut simak artikel ini.

## Sanggahan
Tapi sebelum itu, ada yang ingin saya sampaikan bahwa Artikel ini akan membahas hal-hal yang sangatlah mendasar untuk menggunakan LibreOffice. Jadi, artikel ini tidak akan membahas penggunaan LibreOffice lebih lanjut.

Perlu saya ingatkan juga, bahwa kemungkinan Artikel ini akan menyinggung salah satu Produk dari Microsoft dan format nya, saya tidak bermaksud dan tidak ada perasaan untuk membenci terhadap Microsoft dan segala produk-produk nya, serta saya juga bukanlah seorang yang meng-Anti kan nya. 

Tapi yang saya bahas ini merupakan penjelasan dan kenyataan nya saja, yang berdasarkan dari pengalaman seseorang/saya, dan referensi-referensi yang telah saya ambil dari beberapa situs web, baik dari luar Situs Web Microsoft, bahkan dari Situs Microsoft itu sendiri.

## I. Masalah Kompatibilitas saat di buka dengan Microsoft Office (begitupun juga sebaliknya)
Ini adalah masalah paling klasik yang paling sering di bicarakan oleh kebanyakan pengguna GNU/Linux di Indonesia, berdasarkan dari banyaknya komunitas GNU/Linux di dunia maya (terutama di Indonesia). 

Hal ini terjadi ketika pengguna menyelesaikan pembuatan Dokumen (entah itu sekedar Dokumen hasil Pengolah Kata (_Word Processor_), Lembar Kerja (_Spreadsheet_), Presentasi (_Presentation_), dll), setelah itu ia simpan dokumen nya menggunakan Format OOXML (Office Open XML Format), ini artinya mereka menyimpan nya dengan ekstensi DOCX atau DOC, XLSX atau XLS, PPTX atau PPT, dan Ekstensi dengan format OOXML lain nya.

Ketika mereka ingin membuka Dokumen nya dengan Microsoft Office, tentunya dengan ekspektasi bahwa dokumen tersebut harusnya bisa di 'render' dengan baik, yang artinya, dokumen tersebut harusnya tampil dengan tampilan yang 'seharusnya'. Tapi ternyata, dokumen yang di tampilkan malah berantakan, dan tentu saja itu jauh (bahkan 'sangat jauh') dari ekspektasi si pengguna tersebut.

Masalah di atas merupakan salah satu contoh dari Masalah Kompatibilitas saat dokumen di buka dengan Microsoft Office, dan ini bisa terjadi sebaliknya (Dokumen di buat dengan Microsoft Office, dan di buka dengan LibreOffice). Masih ada sebenarnya yang mirip dengan ini, cuma lebih baik saya bahas satu ini saja.

> ### Kenapa hal itu bisa terjadi?

Alasan nya sederhana, karena LibreOffice sendiri memfokuskan penggunaan format ODF (OpenDocument Format) daripada OOXML (Office Open XML) sebagai format Dokumen bawaan dan format asli (_native_) nya.

Jadi, masalah seperti ini sebenarnya tidak perlu di keluhkan/di permasalahkan, bahkan sama sekali.

> ### Kenapa mereka memfokuskan format ODF sebagai format bawaan nya? Dan, kenapa mereka tidak memfokuskan format OOXML saja? Bukan nya OOXML ini termasuk "Open Format"?

Karena Format OOXML itu bersifat [tidak konsisten](https://joinup.ec.europa.eu/collection/open-source-observatory-osor/document/complex-singularity-versus-openness), hal ini terjadi karena spesifikasi dari OOXML itu sendiri dan juga Implementasi nya di Microsoft Office itu seringkali [berbeda](https://brattahlid.wordpress.com/2012/05/08/is-docx-really-an-open-standard/). 

Perlu Anda ketahui, bahwa di dalam Format OOXML itu di pecah menjadi 3 versi (atau sub-standar), diantara nya adalah: 

- ECMA-376 (atau di sebut versi/sub-standar "ECMA")
- ISO/IEC 29500 Transitional (atau di sebut versi/sub-standar "Transitional")
- ISO/IEC 29500 Strict (atau di sebut versi/sub-standar "Strict")

{{< spoiler title="Catatan bagi yang ingin melihat/membaca Spesifikasi nya" >}}
Jika Anda ingin melihat/membaca spesifikasi Format OOXML versi ECMA nya, silahkan kunjungi [halaman web resmi nya](https://www.ecma-international.org/publications/standards/Ecma-376.htm)

Sedangkan, jika Anda ingin melihat/membaca Spesifikasi dari Format OOXML versi 'Transitional' dan'Strict' nya, silahkan kunjungi halaman web dari situs web Pemerintah Amerika Serikat, yakni ["Library of Congress"](https://www.loc.gov/preservation/digital/formats/fdd/fdd000395.shtml#specs) yang menyediakanspesifikasi OOXML nya disana. Mungkin disana kurang lengkap dan belum ada edisi terbaru, dan ini mungkin saja ada spesifikasi yang belum di publikasi kan disana.
{{< / spoiler >}}

Berdasarkan dari Laman [Wikipedia nya](https://wn.wikipedia.org/wiki/Office_Open_XML), bahwa Microsoft Office hanya mendukung baca/tulis untuk dokumen yang di buat dengan Versi 'Transitional' saja, dan dokumen yang di buat dengan Versi 'Strict' hanya bisa di baca pada Microsoft Office 2010, serta bisa baca/tulis pada Microsoft Office 2013 dan di atasnya, itupun bukan sebagai ['bawaan'](https://technet.microsoft.com/en-us/library/cc179191%28v=office.15%29.aspx).

Selain itu, dokumen dengan versi ECMA hanya bisa di baca saja di Microsoft Office 2010, entah apa yang terjadi dengan versi di atas nya. 

Namun, yang menjadi masalahnya adalah, sejak Microsoft Office itu adalah Perangkat Lunak Berpemilik (Proprietary Software), apakah format di dalam Microsoft Office itu 'sepenuhnya' benar-benar mematuhi/mengikuti 3 versi dari standar di atas yang beredar di Internet untuk Implementasi nya? Atau, justru Microsoft Office membuat "Standar nya sendiri" di dalam Implementasi nya?

Jadi, mungkin saja ketika Anda menyimpan dokumen dari Microsoft Office (terutama dengan ekstensi yang berformat OOXML), maka Anda menyimpan dokumen nya bukan sebagai "Office Open XML" yang selama ini "di iklankan" sebagai "Format Terbuka".

Selain itu, format ini memiliki beberapa masalah ketika di implementasikan oleh Perangkat Lunak Perkantoran selain Microsoft Office.

Sehingga, ini akan membuat Pengembang Perangkat Lunak Bebas/FLOSS seperti LibreOffice, bahkan Perangkat Lunak lain nya seperti WPS Office, Softmaker FreeOffice, dan lain nya akan mengalami kesulitan untuk memenuhi standar dari Format OOXML itu sendiri. 

Masalah-masalah nya seperti:

- Memerlukan pengaitan ke teknologi atau fitur khusus yang di kendalikan atau/dan hanya bisa di gunakan secara eksklusif oleh Vendor tertentu.

- Jumlah Halaman dari Dokumen Spesifikasi nya sendiri nya mencapai [&pm;6000 halaman](https://www.ecma-international.org/publications/standards/Ecma-376.htm), yang bahkan itu melebihi POSIX/SUSv3 yang (katanya) cuma sampai [&pm;3700 halaman saja](https://en.wikipedia.org/wiki/Single_UNIX_Specification). Dan, itupun untuk versi ECMA nya, belum 'Transitional' dan 'Strict' nya. Sehingga, hal itu akan menyulitkan Pengembang Perangkat Lunak lain nya untuk meng-implementasikan format tersebut.

- Ada beberapa bagian di dalam Format OOXML itu sendiri telah terbebani oleh [Paten](http://noooxml.wikidot.com/patents) [Perangkat Lunak](http://en.swpat.org/wiki/OOXML), sehingga hal itu akan membuat Pengembang Perangkat Lunak perkantoran lain nya menjadi tidak mungkin untuk menyempurnakan dukungan/implementasi format OOXML nya.

- Dan, masalah lain nya.

Masalah-masalah di atas bukan hanya mempengaruhi pengembang Perangkat Lunak saja, tapi itu akan mempengaruhi pengguna nya secara keseluruhan, terutama jika pengguna tersebut membuka atau membuat dokumen ber-format OOXML dengan Perangkat Lunak Perkantoran selain Microsoft Office.

Sehingga Perangkat Lunak Perkantoran yang paling bisa meng-implementasikan nya dan yang paling mengikuti/memenuhi standar dalam Format OOXML adalah Microsoft Office itu sendiri.

Selain alasan di atas, Alasan mereka hanya fokus (bahkan [mempromosikan](https://wiki.documentfoundation.org/LibreOffice_OOXML#Does_The_Document_Foundation_support_OOXML_.3F)) format ODF adalah karena mereka percaya bahwa tidak ada standar/format dokumen lain yang menawarkan tingkat netralitas terhadap vendor dengan tepat. Dan, mereka juga percaya bahwa format tersebut akan bermanfaat untuk semua orang kedepan nya.

Ini artinya, mereka percaya bahwa ODF merupakan format yang paling 'netral' saat ini, bila di bandingkan dengan format OOXML.

Lagian di Indonesia, Format ODF ini sudah memasuki ketentuan Standar Nasional Indonesia (SNI) pada tahun 2010 dengan Nomor [**SNI ISO/IEC 26300:2011**](http://sispk.bsn.go.id/SNI/DetailSNI/8541)* melalui surat keputusan dengan Nomor [**41/KEP/BSN/4/2011**](http://akses-sispk.bsn.go.id/Upload/Dokumen/SK_SNI/7476_SK%20SNI%2041-04-2011.PDF)* dari Kepala BSN (Badan Standardisasi Nasional) pada waktu itu. Sampai sekarang, Standar ini masih berlaku di Indonesia.

**\*Catatan**: Akses tautan tersebut melalui protokol HTTP bukan HTTPS, dan nonaktifkan terlebih dahulu Ekstensi "HTTPS Everywhere" pada Peramban Web kamu, kalo ada. Jika kamu mengakses nya dengan protokol HTTPS, maka yang kamu dapatkan hanyalah laman Login nya saja/User Portal. Aneh memang situs web pemerintah satu ini.

Bahkan format ini telah di akui oleh Pemerintah kita melalui [Kemenkominfo (Kementerian Komunikasi dan Informatika)](https://jdih.kominfo.go.id/produk_hukum/unduh/id/75/t/peraturan+menteri+komunikasi+dan+informatika++nomor+7+tahun+2013+tanggal+5+maret+2013) (Atau, Anda bisa unduh [versi lain nya](https://web.kominfo.go.id/sites/default/files/RPM%20Pedoman%20Penerapan%20Interoperabilitas%20Dokumen%20Perkantoran%20Bagi%20Penyelenggara%20Sistem%20Elektronik%20Untuk%20Pelayanan%20Publik.docx)) dan [Kemenkumham (Kementerian Hukum dan Hak Asasi Manusia)](https://peraturan.go.id/common/dokumen/bn/2013/bn474-2013lamp.pdf) pada Tahun 2013 yang lalu.

Selain itu, menurut [artikelnya](https://kominfo.go.id/index.php/content/detail/3434/open+source+di+kominfo+/0/program_prioritas), pihak Kemenkominfo telah menggunakan Perangkat-Perangkat Lunak tersebut di dalam lingkungan nya untuk menunjang keperluan mereka, termasuk LibreOffice dan Format ODF nya. (Ngomong-ngomong, Artikel itu di terbitkan sejak tahun 2014 yang lalu. Entah apa yang terjadi sekarang, apakah mereka masih menggunakan nya? Semoga saja masih menggunakan nya)

Jadi, jika OOXML di nyatakan sebagai "Open Format", apakah artinya OOXML ini termasuk Standar yang bebas? Seperti nya belum tentu juga. 

Apakah itu merupakan suatu hal yang wajar jika tampilan atau bahkan dokumen nya menjadi kacau saat dokumen OOXML di buat atau/dan di buka dengan Perangkat Lunak selain Microsoft Office? Wajar, bahkan normal jika itu terjadi, kecuali jika Anda cuma tahu Microsoft Office atau/dan Ekstensi berformat OOXML nya saja. 

Dan, apakah masalah seperti ini perlu di keluhkan? Kalau menurut saya, tidak perlu, bahkan sama sekali. Lagian juga, LibreOffice ini di buat untuk membantu Anda bekerja dengan dokumen di dalam komputer Anda tanpa harus mengorbankan [4 kebebasan utama dalam perangkat lunak](https://www.gnu.org/philosophy/free-sw.html), bukan cuma untuk memenuhi Standar dari Microsoft Office saja*.

**\*Catatan**: "bukan untuk memenuhi Standar dari Microsoft Office" bukan berarti bahwa mereka sama sekali tidak mendukung/meng-implementasikan Format OOXML, yah 🙂 

Bagaimana kalau dokumen nya tidak menjadi kacau, atau tampilan nya sangat baik, bahkan "sempurna"? Yah, itu artinya kamu sedang "beruntung" atau mungkin saja ada faktor lain nya yang membuat dokumen tidak tampil berantakan, seperti dokumen nya tidak terlalu kompleks misalnya 🙂

Mau Referensi lain nya? Silahkan klik salah satu tautan berikut:

- Salah satu artikel yang di tulis oleh Kang Ade Malsasa Akbar (dalam Bahasa Inggris): ["Support Open Document Format | Dreambox"](https://linuxdreambox.wordpress.com/2016/01/10/support-open-document-format/)

- [MS-OOXML - Overview | Free Software Foundation Europe (FSFE)](https://fsfe.org/activities/os/msooxml.html)

- [What's in a label? ODF vs. OOXML and Open Standards | Open Source Initiative](https://opensource.org/node/266)

- [We Can Put an End to Word Attachments - GNU Project](https://www.gnu.org/philosophy/no-word-attachments.html)

- [Reject proprietary formats! Pledge to use OpenDocument! — Free Software Foundation](https://www.fsf.org/campaigns/opendocument/reject)

- [Why you should not use Microsoft Office! | TLFR.io](https://www.tfir.io/never-use-microsofts-ooxml-pseudo-standard-format/)

> ### Lalu, apa solusi nya?

Solusinya mudah, tinggalkan dan jangan pernah gunakan format OOXML untuk membuat dokumen Anda, apalagi jika Anda sedang menggunakan LibreOffice. 

Lalu bagaimana caranya? Caranya adalah, ketika Anda sudah selesai membuat Dokumen nya, simpanlah dokumen tersebut sebagai Ekstensi yang berformat ODF (OpenDocument Format), seperti .ODT (untuk LibreOffice Writer), .ODS untuk (LibreOffice Calc), dan .ODP (untuk LibreOffice Impress), daripada ekstensi yang berformat OOXML seperti .DOC, .DOCX, .XLS, .XLSX, .PPT, .PPTX dan ekstensi dengan format OOXML lain nya.

Terakhir, jangan pernah mengharapkan/meng-ekspektasikan kalau LibreOffice bisa membuka dokumen dengan format OOXML sebaik Microsoft Office.

Karena pada dasarnya LibreOffice dan Microsoft Office adalah dua Perangkat Lunak yang berbeda, meski sama-sama Perangkat Lunak Perkantoran.

> ### Bagaimana jika saya berada di Rental Komputer/Warung Internet, atau di komputer lain yang rata-rata menggunakan Windows suatu saat nanti?

LibreOffice mendukung Sistem Operasi Windows, jadi ia bisa di install di dalam Sistem Operasi Windows. Jika tidak mungkin bisa di install (Entah itu karena terkendala izin Administrator sampai tidak ada waktu atau terlalu repot), LibreOffice juga telah menyediakan versi Portabel nya agar LibreOffice bisa di jalankan secara langsung di dalam USB tanpa izin terlebih dahulu ke Administrator. 

Ini akan sangat membantu Anda yang sedang menggunakan Komputer lain, yang mana Anda tidak dapat menggunakan Izin Administrator atau bagi Anda yang tidak ingin repot-repot atau membuang-buang waktu serta tenaga untuk meng-install LibreOffice di Komputer lain, seperti di Warnet, Rental Komputer, Komputer Lab Sekolah/Kampus, Komputer Kantor, dll nya.

Untuk meng-unduh nya, silahkan Anda kunjungi [Halaman Web Resmi nya](https://www.libreoffice.org/download/portable-versions/), meng-ingat ini sangat penting bagi Anda yang sering menggunakan komputer lain nya.

> ### Bagaimana jika saya membuka berkas OOXML di LibreOffice?

Seperti yang sudah saya bilang sebelumnya, bahwa lebih baik Anda tidak terlalu berharap untuk bisa membuka berkas yang berformat OOXML di LibreOffice sebaik Microsoft Office. Namun Anda bisa saja membuka nya, hanya saja hasilnya nanti tidak sebaik Microsoft Office, karena fitur-fitur yang ada/digunakan pada dokumen tersebut belum tentu dapat di 'render' dengan baik oleh LibreOffice, karena masalah format OOXML itu sendiri.

Meskipun artikel ini menyinggung Microsoft Office dan Format OOXML nya, bukan berarti saya melarang Anda untuk menggunakan kedua nya. 

Anda bisa menggunakan Microsoft Office untuk membuka berkas berformat OOXML, atau jika Anda tidak mempunyai Microsoft Office nya (Entah itu sengaja gak di install atau gak bisa di Install karena sebab lain), Anda bisa menggunakan Perangkat Lunak Perkantoran lain nya selain Microsoft Office yang di tujukan untuk memenuhi standar Microsoft Office, seperti WPS Office, Softmaker FreeOffice, dll.

Atau jika hal tersebut tidak memungkinkan, maka sebaiknya Anda minta saja kepada pengirimnya untuk mengirimkan ulang berkas sebagai Format PDF jika Anda hanya ingin membacanya saja, atau dengan Format Teks Polos/ODF (Sesuai kebutuhan) jika Anda ingin mengubah nya juga. Jadi, sesuaikan saja dengan kebutuhan.

> ### Bagaimana jika saya mengirimkan berkas kepada orang lain, entah itu teman, dosen, HRD, dll nya suatu saat nanti?

Tergantung, apakah mereka hanya ingin membaca dokumenmu saja atau ingin mengubah nya juga atau cuma sekedar mengulas/meninjau ulang (_review_) dokumen mu saja? Biasanya (apalagi dosen atau HRD), mereka akan butuh dokumen kamu hanya untuk di baca saja, karena pada dasar nya, mereka tidak terlalu perlu untuk mengubah dokumen kamu. (Contoh kasus: Jika kamu mengirimkan CV atau _Resume_ kepada HRD untuk melamar pekerjaan, Tugas Kuliah ke Dosen berupa dokumen, dll).

Kalau mereka hanya ingin membacanya saja, ekspor berkas tersebut ketika Anda sudah selesai mengetik/membuat dokumen nya sebagai Format PDF dan kirimkan saja hasil nya.

Tapi kalau mereka ingin mengubah dokumen mu, maka kalau bisa, kirimkan berkas tersebut kepada mereka dan sarankan kepada mereka dengan baik-baik untuk meng-install LibreOffice jika kamu merasa dekat dengan mereka.

Atau kalau mereka menginginkan format selain PDF hanya karena ia tidak bisa membuka nya dengan baik, jika kamu dekat dengan mereka, coba kamu bantu untuk memperbaiki nya atau sarankan kepada mereka untuk menggunakan Peramban Web (_Web Browser_) untuk membuka PDF.

Sedangkan jika kebutuhan nya hanya mengulas/meninjau ulang dokumen nya saja (entah itu dengan menyoroti teks nya, memberikan komentar, dll), kamu hanya perlu mengirimkan berkas PDF saja, biasanya Aplikasi Peninjau PDF (Kecuali Peramban Web) bisa melakukan nya jika hanya menyoroti teks atau mengulas dokumen saja.

## II. Tampilan nya membuat LibreOffice sulit untuk di gunakan
Tidak bisa di pungkiri lagi, bahwa secara bawaan, LibreOffice memiliki penampilan yang agak kurang familiar dan penggunaan nya yang memang rumit. Sehingga orang-orang merasa 'pusing' dan sulit untuk menggunakan Perangkat Lunak satu ini.

Salah satu penyebabnya adalah bahwa kebanyakan orang telah terbiasa dengan Penampilan "Ribbon" yang ada di Microsoft Office sejak versi 2007, begitupun juga versi di atasnya, sampai sekarang.

Tampilan LibreOffice standar kira-kira seperti ini (saya menggunakan Windows 10):

![Cuplikan Layar LibreOffice 6.3 di Windows 10](LibreOffice_Screenshot_in_Windows_10.png)

Mungkin saja tampilan seperti itu memang terasa familiar bagi Anda yang sudah pernah menggunakan Microsoft Office 2003 sebelumnya. Tapi yang menjadi masalah nya adalah bahwa kebanyakan orang sudah duluan familiar dengan penampilan "Ribbon" dan mengingatnya, kalaupun sebelumnya ada yang sudah pernah menggunakan Microsoft Office 2003, bukan berarti mereka familiar akan tampilan nya, serta tidak semua orang menggunakan nya.

Namun sejak LibreOffice versi 6.2 dirilis, Anda dapat menikmati penampilan "Ribbon" di LibreOffice dengan mengubah Setelan tampilan nya. Dulu sebelum versi 6.2, memang sempat ada fitur seperti ini, hanya saja itu masih beta/eksperimental dan masih memerlukan Berkas JAR Eksternal (dari luar).

Sekarang Anda sudah bisa menikmati nya tanpa harus memuat Berkas JAR Eksternal lagi.

> ### Lalu, bagaimana caranya?

Caranya mudah, yaitu:

1. Pastikan LibreOffice versi 6.2 atau di atasnya sudah terinstall di dalam Komputer Anda.

2. Pastikan juga kalau Aplikasi LibreOffice dan salah satu varian nya sudah di buka (Untuk varian nya bisa apa saja, seperti: LibreOffice Writer, Spreadsheet, Impress atau lain nya)

3. Klik pada Menu "View" -> Lalu, klik pada "User interface" -> Terakhir, kamu klik "Tabbed" untuk mengaktifkan fitur "Ribbon"

Dibawah ini merupakan satu Cuplikan Layar yang akan mempermudah kamu atau memperjelas cara di atas:

![Cara mengaktifkan Tabbed UI di LibreOffice](Activate_Tabbed_UI_in_LibreOffice.png)

Mudah, bukan?

Kira-kira, untuk tampilan nya akan seperti di bawah ini jika sudah di aktifkan "Tabbed UI" nya:

![LibreOffice Tabbed UI di Windows 10](LibreOffice_Tabbed_Screenshot_in_Windows_10.png)

> ### Saya masih kesulitan untuk menggunakan nya, bagaimana caranya agar saya tidak merasa kesulitan?

Solusi nya yah belajarlah untuk menggunakan LibreOffice secara mandiri sampai terbiasa.

Lalu, bagaimana cara nya agar kita bisa mempelajari nya? Banyak sekali cara mempelajari penggunaan LibreOffice, tapi hal yang terpenting dalam belajar adalah pelan-pelan dan tidak usah terlalu terburu-buru, dan usahakan untuk bersikap tenang. 

Salah satu cara yang bisa Anda lakukan untuk mempelajari nya adalah dengan berikut ini:

#### Cara 1: Buatlah Dokumen yang sama dengan Dokumen yang di kerjakan dengan Microsoft Office

{{< spoiler title="tl;dr" >}}
Buatlah 'versi ODF' dari Dokumen yang pernah Anda buat sebelumnya dengan Microsoft Office itu dengan Perangkat Lunak Perkantoran FLOSS seperti LibreOffice.
{{< /spoiler >}}

Pernahkah Anda membuat dokumen dengan Microsoft Office? Pernahkah Anda membuatnya dengan format yang kompleks, minimal seperti dalam bentuk Proposal, Laporan, Dokumentasi, Makalah, Jurnal atau bahkan sampai Skripsi misal nya?

Kalau pernah, mungkin saat nya Anda membuat dokumen yang sama dengan dokumen yang Anda buat menggunakan Microsoft Office sebelumnya itu dengan LibreOffice, agar supaya Anda bisa mempelajari nya. Lalu, bagaimana caranya?

Bukalah dokumen yang pernah Anda buat dengan Microsoft Office itu dengan Microsoft Office, lalu buatlah dokumen baru dengan LibreOffice. Ya, ini artinya Microsoft Office dan LibreOffice akan di buka secara bersamaan, cuma beda peran nya.

Setelah Anda membuka LibreOffice nya, buatlah dokumen baru itu menjadi sama persis dengan yang ada di Microsoft Office.

Jadi, yang jelas nya adalah, Dokumen yang di buka dengan Microsoft Office itu peran nya cuma di baca/di lihat saja, sedangkan LibreOffice itu membuat dokumen nya yang sama persis dengan Dokumen yang di buat dengan Microsoft Office. 

Atau, yang lebih jelas nya adalah, Anda buat "versi ODF" dari dokumen yang Anda buat dengan Microsoft Office itu.

Hal ini akan melatih Anda untuk mempelajari bagaimana cara menggunakan LibreOffice, dan fitur-fitur yang ada serta menguasai nya, dan ini juga akan melatih kemandirian Anda. Lakukanlah itu sampai kamu terbiasa untuk menggunakan nya, sesering mungkin. 

Jika Anda sudah selesai membuatnya, jangan lupa, simpanlah dokumen tersebut dengan format ODF, bukan format OOXML.

#### Cara 2: Sering-sering Googling untuk menguasai Fitur-fitur pada LibreOffice
Ini mungkin berhubungan dengan cara pertama. Meskipun begitu, mungkin saja Anda masih bingung dalam menggunakan fitur-fitur pada LibreOffice saat membuat dokumen nya, yah setidak nya anggap saja begitu. 

Jika Anda merasa bingung, hal yang pertama kali yang harus Anda lakukan adalah sering-seringlah Googling terlebih dahulu untuk menguasai Fitur-fitur LibreOffice beserta cara menggunakan nya. Kalau bisa, gunakan Bahasa Inggris untuk kata kunci nya supaya hasilnya lebih lengkap, atau bisa dengan Bahasa Indonesia kalau kamu ingin hasilnya lebih "akurat".

Hal ini harus di lakukan terutama sebelum Anda bertanya kepada seseorang melalui apapun juga di Internet, termasuk melalui Forum/Grup yang ada di Internet.

Jadi, sebelum bertanya kepada seseorang di Internet, ada baiknya untuk Googling terlebih dahulu untuk penguasaan Fitur nya.

#### Cara 3: Baca, Pelajari dan Pahami Panduan nya
Anda bisa mempelajari Panduan yang tersedia jika suatu saat Anda bingung bagaimana caranya menggunakan sebuah fitur yang ada.

Cukup Anda tekan tombol <kbd>F1</kbd> untuk membaca panduan nya, nanti setelah Anda menekan nya, maka secara otomatis LibreOffice akan mengeksekusi Peramban Web (_Web Browser_) bawaan di Sistem Operasi yang Anda gunakan.

Panduan tersebut memang berbahasa Inggris, namun Anda bisa menggunakan Bahasa Indonesia nya, jika Anda mengunduh "Helppack" nya. 

Anda bisa mencari materi-materi yang ada di situ kalau mau. Tapi, panduan disitu kurang lengkap untuk menjelaskan nya, panduan tersebut hanyalah sebatas menjelaskan penggunaan fitur-fitur nya saja.

Namun Alhamdulillah, bapak Sokibi telah membuat sebuah buku dengan judul "Menulis Buku dengan LibreOffice" yang tentu nya di buat dengan Bahasa Indonesia, yang dapat membantu Anda untuk menguasai fitur-fitur yang ada pada LibreOffice (terutama LibreOffice Writer). Buku Digital tersebut bisa Anda unduh secara gratis dengan mengunjungi salah satu artikel [di blog nya](https://imgos-belajarlinux.blogspot.com/2019/10/unduh-buku-digital-gratis.html).

Sayangnya, buku tersebut hanya membahas LibreOffice Writer saja, tidak membahas lain nya. 

Atau, mungkin Anda dapat mengunduh salah satu Buku Digital dari Komunitas "Belajar LibreOffice Indonesia" yang tersedia dari [Halaman Web Resmi nya](https://belajarlibreofficeid.web.id/buku-digital/)atau [membeli buku fisik nya](https://belajarlibreofficeid.web.id/buku-fisik-cetak/). Tapi, sayangnya juga, kedua buku tersebut hanya membahas tentang penggunaan LibreOffice Writer dan Calc saja, tidak membahas lain nya.

Walaupun begitu, setidaknya ini lumayan membantu Anda untuk mempelajari LibreOffice, daripada tidak sama sekali.

#### Cara 4: Bertanya kepada seseorang/orang lain
Jika Anda sudah mempelajari cara menggunakan LibreOffice dan fitur-fitur nya dengan cara di atas, namun Anda mengalami kesulitan saat menggunakan nya (Contoh: Masalah yang di alami itu tidak di temukan solusi nya di Internet, dll)

Anda bisa bertanya kepada seseorang atau orang lain, baik itu melalui Forum, Grup atau Komunitas yang berada di dunia maya atau dunia nyata. Di Indonesia, ada salah satu komunitas (yang juga mempunyai Grup Telegram), yang mana itu di tujukan untuk mempelajari LibreOffice, sesuai dengan namanya, yakni "[Belajar LibreOffice Indonesia](https://t.me/BelajarLibreOfficeIndonesia)" (atau di singkat dengan "BLOI")

Sebelum bertanya (apalagi di dunia maya), tolong pahami bahwa tidak semua orang dapat membantu Anda/menjawab pertanyaan Anda, karena waktu yang mereka miliki, situasi dan kondisi dari setiap orang itu sangatlah berbeda daripada Anda. Atau, mungkin saja ada yang tidak mampu untuk menjawab pertanyaan Anda/mengatasi masalah yang Anda alami.

Terlebih lagi, mereka membantu Anda itu secara gratis/tanpa bayaran, yang artinya, mereka lakukan itu secara sukarela.

Jadi, tolonglah untuk berempati pada orang lain dan hargailah situasi dan kondisi mereka dengan bersabar, dan jangan memaksakan orang lain untuk menjawab/mengatasi masalah kamu mentang-mentang komunikasi yang kamu lakukan itu tanpa tatap muka. 

Serta, jangan merasa paling 'berhak' untuk mendapatkan jawaban, kecuali kalau kamu membayarnya.

Untuk lebih lanjut, Anda juga dapat membaca tulisan yang bagus sekali, dan cocok untuk Anda yang ingin bertanya. Tulisan tersebut membahas tentang "[Cara bertanya yang baik](https://www.dropbox.com/s/csnoh0cpp9xz2sl/cara%20bertanya%20yang%20baik.txt)" yang di tulis oleh Bapak [Harry Sufehmi](https://harry.sufehmi.com/).

> ### Apakah masalah seperti ini pantas untuk di keluhkan?

Anda yang membaca artikel ini, terutama dari awal artikel juga pasti hafal bukan jawaban nya? Yap, menurut saya, itu masih tidak perlu di keluhkan.

Tapi mungkin saja Anda berpikir bahwa mempelajari LibreOffice itu seperti 2 kali kerja, karena Anda telah mempelajari Microsoft Office sebelumnya (yang mungkin) sejak lama, tapi sekarang malah di tambah dengan mempelajari LibreOffice yang akan membuang waktu dan tenaga mu. Apa benar begitu, bukan?

Iya, memang seperti itu, dan itu merupakan suatu hal yang wajar, karena seperti yang saya bilang sebelumnya, bahwa LibreOffice itu di buat untuk membantu kalian membuat dokumen tanpa harus mengorbankan 4 kebebasan utama dalam perangkat lunak, bukan untuk memenuhi Standar dari Microsoft Office. 

Walaupun itu semua cukup berat bagi Anda, bukan berarti menjadi tidak mungkin, kan? Tapi setidak nya, LibreOffice ini termasuk Perangkat Lunak Bebas, yang mana Anda bisa bebas untuk mendistribusikan, memodifikasi, mempelajari dan menggunakan nya untuk keperluan apapun, termasuk komersial sekalipun, tidak seperti Microsoft Office yang bukan Perangkat Lunak Bebas.

Jadi, jika Anda menggunakan LibreOffice, maka Anda juga harus mempelajari nya, mau-tidak mau 🙂

## Penutup
Jika Anda ingin menggunakan LibreOffice, maka Anda harus bisa menggunakan nya dengan "Benar". Jangan pernah berharap untuk menggunakan Format OOXML di dalam LibreOffice.

Jadi, mau-tidak mau, Anda harus belajar lagi untuk menggunakan LibreOffice. Namun, keputusan mengenai kamu mau belajar atau tidak nya, itu semua kembali pada diri Anda, saya tidak bisa memaksa kamu untuk melakukan nya, tidak seperti salah satu anggota di salah satu Grup Facebook yang menjadi "sales" dadakan dengan embel-embel "Share Ilmu" yang jawaban nya seringkali gak nyambung saat di tanya.

Tapi setidak nya, LibreOffice dan Format Asli nya, yakni ODF (OpenDocument Format) itu merupakan Perangkat Lunak dan Format Bebas, tidak seperti Microsoft Office dan Format OOXML nya.

Saya membuat artikel seperti ini karena saya sendiri melihat kalau kebanyakan anggota Komunitas/Grup, terutama di Grup Pengguna GNU/Linux, menganggap LibreOffice itu bermasalah, sehingga tidak di sarankan oleh mereka. Tapi kenyataan nya, kebanyakan dari mereka yang menganggap seperti itu karena Masalah Kompatibilitas terhadap Format OOXML itu sendiri yang seharusnya tidak perlu di permasalahkan.

Jadi, mereka berpikir bahwa Format OOXML adalah satu-satu nya format berbasis XML yang mempresentasikan berbagai dokumen perkantoran di dunia ini (seperti Dokumen Lembar Kerja, Pengolah Kata, Presentasi, dan lain nya), tidak ada format yang lain selain dia.

Sehingga, orang lain (terutama "Pemula") menjadi seperti tidak ada harapan untuk mengurusi dokumen tersebut (seperti membuat/mengubah/memodifikasi nya), apalagi di dalam Sistem Operasi yang berbeda, seperti GNU/Linux misalnya.

Saya kira, pembahasan nya sudah cukup sampai disini saja. Mohon maaf jika adanya kesalahan pada artikel ini, atau jika kamu mempunyai pertanyaan, kritik dan saran, komentar, pendapat/opini kamu atau masukkan lain nya, silahkan kamu berkomentar atau kamu bisa berdiskusi dengan saya melalui kolom komentar yang tersedia atau bisa kamu [Hubungi Saya](/tentang) jika kamu lebih suka lewat "Jalur Pribadi".

Terima kasih atas perhatian nya 😊

## Penggunaan Gambar dan Atribusi
Berkas-berkas Gambar (seperti Cuplikan layar dan Gambar lain nya) yang di gunakan di dalam artikel ini, disediakan di dalam [_Repository_ Blog ini](https://github.com/FarrelF/Blog). 

Jika Anda ingin menjelajahi nya, silahkan kunjungi Alamat URL berikut:

```plaintext
https://github.com/FarrelF/Blog/tree/main/content/post/2019/12/19-masalah-klasik-pengguna-libreoffice
```

Logo LibreOffice (yang saya gunakan sebagai sampul artikel ini) di buat oleh ['The Document Foundation'](https://www.documentfoundation.org/) dan (mungkin) kontributor nya, serta di lisensikan dengan sebagai berikut: 

- [Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)](https://creativecommons.org/licenses/by-sa/3.0/).

- [GNU Lesser General Public License versi 3 atau lebih baru (LGPL 3+)](http://www.gnu.org/licenses/lgpl.html).

- [Mozilla Public License versi 1.1 (MPL 1.1)](http://www.mozilla.org/MPL/MPL-1.1.html).

Logo tersebut juga merupakan Merek Dagang/Pakaian Dagang terdaftar dari 'The Document Foundation'. Jadi, logo-logo tersebut tetap milik mereka yang memiliki merek/pakaian dagang. Jika Anda ingin menggunakan logo-logo tersebut, silahkan kunjungi [Panduan mengenai Penggunaan Logo/Branding LibreOffice](https://wiki.documentfoundation.org/Marketing/Branding).

Jika Anda ingin meng-unduh lebih banyak, silahkan Anda kunjungi [halaman web resmi nya](https://wiki.documentfoundation.org/Gallery_Logos).
