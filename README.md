# Shopping Cart — Tugas Take Home 1

Aplikasi keranjang belanja sederhana menggunakan Flutter (Mobile Programming).

## Fitur
- 3 produk (Wireless Headphone, Laptop ASUS Vivobook, Wireless Mouse) dengan nama, gambar, dan harga.
- Informasi jumlah barang dan total harga yang ter-update otomatis.
- Menggunakan `StatefulWidget` dan `setState()`.
- Menggunakan `GestureDetector` untuk menangani gesture.

## Interaksi Pengguna
| Gesture | Perubahan tampilan |
|---|---|
| **Tap** pada produk | Produk dipilih: border kartu dan warna latar berubah biru |
| **Double Tap** pada produk | Jumlah like bertambah, ikon hati berubah merah |
| **Long Press** pada produk | Muncul pesan informasi "Produk dipilih!" di bagian atas |
| Tombol **+ / −** | Jumlah barang dan total harga berubah |

## Cara Menjalankan
```
flutter pub get
flutter run
```
Kode utama ada di `lib/main.dart`.
