# 🗂️ Pengelola File Massal (GUI & CLI)

Sebuah skrip Bash yang kuat dan ramah pengguna untuk mengelola file secara otomatis ke dalam folder berdasarkan nama filenya. Kini dilengkapi dengan antarmuka grafis (GUI) dan antarmuka baris perintah (CLI).

🛠️ Awalnya dibuat untuk menyortir ratusan dokumen mahasiswa — kini telah berevolusi menjadi sebuah utilitas lengkap untuk penggunaan umum.

## ✨ Fitur-fitur

-   **✅ Antarmuka Ganda:** Jalankan dengan GUI yang simpel dan mudah, atau gunakan baris perintah yang andal untuk otomatisasi.
-   **✅ Mode Dry-Run yang Aman:** Lihat perubahan apa yang akan terjadi *sebelum* ada file yang benar-benar dipindahkan. Sebuah fitur keamanan penting!
-   **✅ Pembuatan Folder Otomatis:** Membuat folder khusus untuk setiap nama file yang unik.
-   **✅ Pengelompokan Cerdas:** Memindahkan semua file terkait (misalnya, `dokumen.pdf`, `dokumen.jpg`) ke dalam folder yang benar.
-   **✅ Penanganan Akhiran Cerdas:** Mampu mengenali akhiran (seperti `_t`) untuk mengelompokkan file terkait (misalnya, `ijazah.pdf` dan `ijazah_t.pdf`) menjadi satu.

## 🔧 Prasyarat

-   Lingkungan berbasis Unix (Linux, macOS, WSL).
-   Untuk mode GUI: `zenity` harus terinstal.
    -   Di Debian/Ubuntu, instal dengan: `sudo apt install zenity`

## 📦 Instalasi

Tidak perlu instalasi. Cukup buat skrip agar bisa dieksekusi:
```bash
chmod +x pengelola-file.sh
```

## 🚀 Cara Penggunaan

### Menggunakan Antarmuka Grafis (Disarankan untuk Pemula)

Cukup jalankan skrip dengan opsi `--gui`. Sebuah jendela akan muncul meminta Anda memilih folder.

```bash
./pengelola-file.sh --gui
```

### Menggunakan Baris Perintah (CLI)

Arahkan skrip ke direktori target.

```bash
# Untuk langsung mengeksekusi
./pengelola-file.sh /path/ke/folder/anda

# Untuk melihat pratinjau perubahan tanpa memindahkan file apa pun
./pengelola-file.sh /path/ke/folder/anda --dry-run
```

---
*Silakan berkontribusi atau melaporkan jika ada masalah.*

*Konsep dan skrip oleh Hendra. Berevolusi dan didokumentasikan dengan bantuan Gemini dari Google.*
