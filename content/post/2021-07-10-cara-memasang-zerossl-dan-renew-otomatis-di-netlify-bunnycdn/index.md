---
Title: Cara memasang ZeroSSL + Renew Otomatis di Netlify dan BunnyCDN
Slug: memasang-zerossl-di-netlify-bunnycdn
Author: Farrel Franqois
Categories: 
    - Web dan Blog
    - Layanan Internet
    - Info Blog
    - Tutorial
Draft: true
Date: 2021-07-10 22:33:00+07:00
Tags:
    - Sertifikat SSL
    - ZeroSSL
    - Netlify
    - BunnyCDN
readMore: true
DescriptionSEO: Apakah Anda ingin memasang ZeroSSL, tapi Anda juga ingin bisa me-renew nya secara otomatis di Netlify dan BunnyCDN? Jika iya, Anda bisa baca artikel ini untuk mengetahuinya.
Description: >
    Blog ini telah menggunakan ZeroSSL sebagai Sertifikat SSL nya, tapi kendalanya adalah bahwa SSL ini tidak didukung oleh Penyedia Web secara luas, artinya SSL tersebut belum bisa di-_renew_ secara otomatis.
    
    
    Tapi akhirnya, kendala tersebut bisa saya atasi berkat bantuan dari referensi-referensi yang ada dan saya ingin membagikan nya pada Anda, terutama untuk pengguna [Netlify](https://www.netlify.com) dan [BunnyCDN](https://afiliasi.farrel.franqois.id).
    
    
    Jika Anda ingin memasang Sertifikat SSL dari ZeroSSL pada Web Statis Anda yang menggunakan Netlify sebagai Hosting atau menggunakan BunnyCDN, serta me-_renew_ nya secara otomatis atau Anda yang sekadar ingin tahu saja, mungkin Anda bisa baca artikel ini.
---
## Daftar Isi
{{< toc >}}

## Pembuka
## Membuat Sertifikat SSL dengan Acme.sh {#membuat-sertifikat-ssl}
## Memasang Sertifikat SSL {#memasang-ssl}
### Di Netlify
### Di BunnyCDN
### Lain nya

## _Renew_ SSL secara Otomatis {#renew-ssl}
## ZeroSSL daripada Let's Encrypt, kenapa? {#zerossl-vs-lets-encrypt}
### Menggunakan Sectigo sebagai Akar nya
### Tidak(/Belum?) menerapkan _Rate Limit_
### Mengelola Sertifikat SSL dengan Antarmuka Pengguna (UI)

## ZeroSSL Gratis?
## Pertanyaan yang (akan) sering ditanya {#pertanyaan-dan-jawaban}
## Kesimpulan dan Penutup