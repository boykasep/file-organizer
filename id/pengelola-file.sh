#!/bin/bash

# Skrip handal untuk merapikan file ke dalam subdirektori.
# Versi 2.0 - Dibuat generik untuk penggunaan publik.

# Segera hentikan skrip jika ada perintah yang gagal.
# Hentikan jika ada variabel yang belum di-set digunakan.
# Pipeline mengembalikan status exit dari perintah terakhir yang gagal.
set -euo pipefail

# --- Fungsi untuk menampilkan cara penggunaan ---
tampilkan_cara_pakai() {
    echo "Penggunaan: $0 [-s AKHIRAN] <direktori>"
    echo "Merapikan file-file di dalam <direktori> ke dalam subfolder masing-masing."
    echo ""
    echo "Argumen:"
    echo "  <direktori>         Direktori target yang berisi file untuk dirapikan."
    echo ""
    echo "Opsi:"
    echo "  -s AKHIRAN          Tentukan sebuah akhiran (suffix). File yang berakhiran"
    echo "                      AKHIRAN.pdf akan dikelompokkan bersama nama file dasarnya."
    echo "                      Contoh: '-s _transkrip' untuk 'file_transkrip.pdf'"
    echo ""
    echo "  -h                  Tampilkan bantuan ini dan keluar."
    echo ""
    echo "Contoh:"
    echo "  # Penggunaan dasar untuk file seperti 'file1.pdf', 'file2.pdf'"
    echo "  $0 /path/ke/folder/file"
    echo ""
    echo "  # Penggunaan lanjutan untuk 'file_transkrip.pdf' dan 'file.pdf'"
    echo "  $0 -s _transkrip /path/ke/folder/file"
}

# --- Logika Utama ---

# Nilai default
AKHIRAN=""

# Membaca opsi dari baris perintah
while getopts 's:h' flag; do
  case "${flag}" in
    s) AKHIRAN="${OPTARG}" ;;
    h) tampilkan_cara_pakai
       exit 0 ;;
    *) tampilkan_cara_pakai
       exit 1 ;;
  esac
done

# Hapus opsi dari daftar argumen
shift "$((OPTIND - 1))"

# Cek apakah argumen utama (direktori) sudah diberikan
if [ "$#" -ne 1 ]; then
    echo "Error: Direktori target belum ditentukan." >&2
    tampilkan_cara_pakai
    exit 1
fi

DIREKTORI_TARGET="${1}"

# Cek apakah direktori target ada
if [ ! -d "${DIREKTORI_TARGET}" ]; then
    echo "Error: Direktori '${DIREKTORI_TARGET}' tidak ditemukan." >&2
    exit 1
fi

# Pindah ke direktori target; hentikan jika gagal
cd "${DIREKTORI_TARGET}" || exit

echo "Merapikan file di dalam: $(pwd)"

# --- Logika Pemrosesan File ---

if [ -n "${AKHIRAN}" ]; then
    # MODE LANJUTAN: Akhiran ditentukan
    echo "Mode: Pengelompokan dengan akhiran. Mencari akhiran '${AKHIRAN}'..."
    # Loop semua file yang memiliki akhiran
    for file in *"${AKHIRAN}".pdf; do
        # Cek jika ada file yang cocok dengan pola untuk menghindari error
        [ -e "$file" ] || continue

        # Dapatkan nama folder dasar dengan menghapus akhiran dan ekstensi
        # contoh: "file_transkrip.pdf" -> "file"
        nama_folder=$(basename "$file" "${AKHIRAN}.pdf")

        echo "Memproses: ${nama_folder}"
        # Buat folder jika belum ada
        mkdir -p "${nama_folder}"

        # Pindahkan semua file yang dimulai dengan nama dasar ke folder baru
        # contoh: memindahkan "file.pdf", "file_transkrip.pdf", "file.jpg", dll.
        echo "  -> Memindahkan file ke '${nama_folder}/'"
        mv "${nama_folder}"* "${nama_folder}/"
    done
else
    # MODE DASAR: Tanpa akhiran
    echo "Mode: Pengelompokan dasar..."
    # Loop semua file .pdf
    for file in *.pdf; do
        # Cek jika ada file yang cocok dengan pola
        [ -e "$file" ] || continue

        # Dapatkan nama folder dengan menghapus ekstensi .pdf
        nama_folder=$(basename "$file" ".pdf")

        echo "Memproses: ${nama_folder}"
        # Buat folder jika belum ada
        mkdir -p "${nama_folder}"

        # Pindahkan semua file yang dimulai dengan nama itu ke folder baru
        echo "  -> Memindahkan file ke '${nama_folder}/'"
        mv "${nama_folder}".* "${nama_folder}/"
    done
fi

echo "Proses merapikan selesai."
