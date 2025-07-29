# 🗂️ Pengelola File Massal (Batch File Organizer)

Sebuah skrip Bash yang sederhana namun kuat untuk mengelola banyak file secara otomatis ke dalam folder masing-masing berdasarkan nama filenya. Sangat cocok untuk merapikan dokumen, gambar, atau koleksi file apa pun yang memiliki pola penamaan yang konsisten.

🛠️ Awalnya dibuat untuk menyortir ratusan dokumen mahasiswa (seperti ijazah dan transkrip nilai) — kini tersedia untuk penggunaan umum.

## ✨ Fitur-fitur

-   **✅ Pembuatan Folder Otomatis:** Membuat folder khusus untuk setiap nama dasar file yang unik.
-   **✅ Pengelompokan Cerdas:** Memindahkan semua file terkait (misalnya, `dokumen.pdf`, `dokumen.jpg`) ke dalam folder yang benar.
-   **✅ Penanganan Akhiran (Suffix):** Mampu mengenali akhiran nama file seperti `_transkrip`, `_t`, dll., dan mengelompokkan file-file terkait menjadi satu.
-   **✅ Minimalis & Fleksibel:** Dapat bekerja dengan atau tanpa akhiran, menangani pemrosesan massal dengan bersih.

## 🔧 Prasyarat

-   Lingkungan berbasis Unix (Linux, macOS, atau WSL di Windows).
-   Pengetahuan dasar tentang penggunaan terminal.

## 📦 Instalasi

Tidak perlu instalasi. Cukup unduh skrip `pengelola-file.sh` dan buat agar bisa dieksekusi:
```bash
chmod +x pengelola-file.sh
```

## 🚀 Cara Penggunaan

Jalankan skrip dari terminal Anda, dan arahkan ke direktori yang berisi file-file yang ingin Anda rapikan.

#### Penggunaan Dasar (Satu File per Folder)

Gunakan cara ini jika Anda memiliki file seperti `file1.pdf`, `file2.pdf`, dll., dan Anda ingin memindahkan masing-masing file ke dalam foldernya sendiri (`/file1/`, `/file2/`).
```bash
./pengelola-file.sh /path/ke/folder/file_anda
```

#### Penggunaan Lanjutan (Mengelompokkan File dengan Akhiran)

Gunakan cara ini jika Anda memiliki file terkait yang nama dasarnya sama tetapi memiliki akhiran tertentu (contoh: `john_doe.pdf` dan `john_doe_transkrip.pdf`).
```bash
./pengelola-file.sh -s _transkrip /path/ke/folder/file_anda
```
Opsi `-s` mendefinisikan akhiran yang harus dicari. Skrip akan membuat folder berdasarkan nama file *tanpa* akhiran tersebut dan memindahkan kedua file ke dalamnya.

## 💡 Kustomisasi & Contoh Lanjutan

Skrip ini sengaja dibuat sederhana, namun Anda dapat dengan mudah memodifikasinya untuk kebutuhan yang lebih kompleks. Berikut beberapa contoh.

#### Contoh 1: Memindahkan Folder ke Tujuan Tertentu

Secara default, folder baru dibuat di dalam direktori target. Jika Anda ingin membuatnya di lokasi lain (misalnya, `~/Dokumen/Hasil_Rapih`), Anda bisa membuat sedikit perubahan.

Temukan baris ini di dalam skrip:
```bash
mkdir -p "${nama_folder}"
```
Dan ubah untuk menentukan alamat tujuan Anda:
```bash
ALAMAT_TUJUAN="/home/user/Dokumen/Hasil_Rapih"
mkdir -p "${ALAMAT_TUJUAN}/${nama_folder}"
```
Anda juga perlu memperbarui perintah `mv` setelahnya agar menggunakan alamat baru:
```bash
mv "${nama_folder}"* "${ALAMAT_TUJUAN}/${nama_folder}/"
```

#### Contoh 2: Menambahkan Awalan (Prefix) pada Nama Folder

Jika Anda ingin setiap folder baru memiliki awalan (misalnya, `Arsip_file1`, `Arsip_file2`), Anda bisa memodifikasi skrip.

Temukan baris ini:
```bash
nama_folder=$(basename "$file" ".pdf") # Atau baris basename yang relevan
```
Lalu modifikasi perintah `mkdir` dan `mv` untuk menyertakan awalan yang Anda inginkan:
```bash
AWALAN="Arsip"
mkdir -p "${AWALAN}_${nama_folder}"
mv "${nama_folder}".* "${AWALAN}_${nama_folder}/"
```

---
*Silakan berkontribusi atau melaporkan jika ada masalah.*

*Konsep dan skrip asli oleh Hendra. Disempurnakan untuk penggunaan publik dan didokumentasikan dengan bantuan Gemini dari Google.*
