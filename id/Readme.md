# 🗂️ Pindah File Massal 

Sebuah utilitas tingkat produksi yang kompatibel lintas platform untuk mengelola file dengan aman dan cerdas berdasarkan file konfigurasi yang fleksibel. Ini adalah versi definitif, yang telah di-debug secara teliti untuk keandalan maksimal dan pengalaman pengguna yang profesional.

## ✨ Fitur Inti

-   **✅ Antarmuka Pengguna Profesional:** Tampilan yang konsisten dan jelas dengan header, log berwarna, ringkasan akhir yang komprehensif, dan prompt undo interaktif saat terjadi kegagalan.
-   **✅ Andal:** Dilengkapi penanganan *exit* (`trap`) yang tangguh, validasi teliti untuk semua path dan konfigurasi, serta logika inti yang telah disempurnakan untuk mencegah error.
-   **✅ Aman dan Bisa Dibatalkan:** Sistem `undo` yang persisten dengan backup log memungkinkan Anda membatalkan operasi apa pun. Mode `--dry-run` memberikan pratinjau yang aman.
-   **✅ Performa Tinggi:** Memproses ribuan file secara efisien menggunakan pemindaian sekali jalan dan penghitung cerdas di dalam memori untuk me-*rename*.
-   **✅ GUI Lintas Platform:** Secara otomatis menggunakan **Zenity di Linux** dan **AppleScript di macOS**.

## 🔧 Prasyarat

-   Lingkungan berbasis Unix (Linux, macOS, atau **WSL/Git Bash di Windows**).
-   Untuk mode GUI:
    -   Di **Linux**: `zenity` harus terinstal (`sudo apt install zenity`).
    -   Di **macOS**: Tidak perlu instalasi tambahan.

## 🚀 Cara Penggunaan

1.  **Konfigurasi:** Ubah `organize.conf` sesuai aturan Anda.
2.  **Jalankan:** Eksekusi `./pengelola-file.sh`.
3.  **Undo:** Untuk membatalkan, jalankan `./pengelola-file.sh --undo`.

---
*Konsep dan skrip asli oleh boykasep. Berevolusi menjadi utilitas profesional dengan penyempurnaan kolaboratif via Gemini dari Google.*
