#!/usr/bin/env bash

# =============================================================================
# Pindah File Massal 
# =============================================================================

set -euo pipefail

# --- Variabel Global & Konfigurasi Default ---
CONFIG_FILE="organize.conf"
source_dir=""; destination_dir=""; include_ext=""; exclude_regex=""
rename=false; dry_run=false; undo_log="$HOME/.organize_undo.log"; show_summary=true
declare -gi PROCESSED_COUNT=0; declare -gi FAILED_COUNT=0

# --- Kode Warna ANSI untuk Logging ---
COLOR_RESET='\033[0m'; COLOR_RED='\033[0;31m'; COLOR_GREEN='\033[0;32m';
COLOR_YELLOW='\033[0;33m'; COLOR_CYAN='\033[0;36m';

# --- Fungsi Inti ---

log() {
    local level="$1" message="$2" color="$COLOR_RESET"
    case "$level" in
        INFO) color="$COLOR_GREEN" ;; WARN) color="$COLOR_YELLOW" ;;
        ERROR) color="$COLOR_RED" ;;
    esac
    echo -e "${color}[$(date +'%T')] [${level}] ${message}${COLOR_RESET}" >&2
}

show_header() {
    clear
    echo -e "${COLOR_CYAN}==================================================================="
    echo "|          PENGELOLA FILE TINGKAT LANJUT       |"
    echo -e "===================================================================${COLOR_RESET}"
    echo -e "💡 Untuk membatalkan operasi terakhir, jalankan: ${COLOR_GREEN}$0 --undo${COLOR_RESET}"
    echo "   Log untuk undo disimpan di: ${undo_log}"
    echo "-------------------------------------------------------------------"
}

load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "ERROR" "File konfigurasi '$CONFIG_FILE' tidak ditemukan!"
        exit 1
    fi
    source <(grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*=' "$CONFIG_FILE")
    log "INFO" "Konfigurasi berhasil dimuat dari '$CONFIG_FILE'."

    for var in rename dry_run show_summary; do
        if [[ "${!var}" != "true" && "${!var}" != "false" ]]; then
            log "ERROR" "Nilai untuk '$var' di config tidak valid. Harus 'true' atau 'false'."
            exit 1
        fi
    done
    if [[ -z "$source_dir" || ! -d "$source_dir" ]]; then
        log "ERROR" "Konfigurasi 'source_dir' tidak valid: '$source_dir'"
        exit 1
    fi
}

undo_operation() {
    local log_path="${1:-$undo_log}"
    if [[ ! -f "$log_path" ]]; then
        log "WARN" "Tidak ada log undo yang ditemukan di '$log_path'."
        exit 0
    fi
    
    log "INFO" "Membatalkan operasi terakhir dari '$log_path'..."
    local undo_commands=()
    mapfile -t undo_commands < "$log_path"

    for (( i=${#undo_commands[@]}-1 ; i>=0 ; i-- )); do
        IFS='|' read -r new_path old_path <<< "${undo_commands[i]}"
        if [[ -e "$new_path" ]]; then
            mkdir -p "$(dirname "$old_path")"
            log "INFO" "Undo: Memindahkan '${new_path}' -> '${old_path}'"
            mv -n "$new_path" "$old_path" || log "WARN" "Gagal mengembalikan '$new_path'."
        fi
    done
    
    local backup_log="${log_path}.backup_$(date +%Y%m%d_%H%M%S)"
    mv "$log_path" "$backup_log"
    log "INFO" "Proses undo selesai. Log lama di-backup ke '$backup_log'."
}

main() {
    trap 'final_report' EXIT

    mkdir -p "$destination_dir" || { log "ERROR" "Gagal membuat direktori tujuan '$destination_dir'."; exit 1; }
    
    local EXTENSIONS
    EXTENSIONS=($(echo "$include_ext" | tr ',' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$'))
    if [[ ${#EXTENSIONS[@]} -eq 0 ]]; then
        log "ERROR" "Konfigurasi 'include_ext' tidak boleh kosong."
        exit 1
    fi

    declare -A counters
    if [[ "$dry_run" != "true" ]]; then
        mkdir -p "$(dirname "$undo_log")" || { log "ERROR" "Gagal membuat direktori untuk log undo."; exit 1; }
        rm -f "${undo_log}"
    fi

    local find_args=("$source_dir" -maxdepth 1 -type f)
    find_args+=(-and \( -false)
    for ext in "${EXTENSIONS[@]}"; do
        [[ -n "$ext" ]] && find_args+=(-o -iname "*.$ext")
    done
    find_args+=(\) )

    log "INFO" "Memindai file..."
    
    while IFS= read -r -d '' source_path; do
        local filename=$(basename -- "$source_path")
        
        local filename_lower="${filename,,}"
        if [[ -n "$exclude_regex" && "$filename_lower" =~ ${exclude_regex,,} ]]; then
            continue
        fi

        local extension="${filename##*.}"
        local lowercase_ext="${extension,,}"
        local target_dir="${destination_dir}/${lowercase_ext}"
        local target_path="${target_dir}/${filename}"
        
        if [[ "$rename" == "true" ]]; then
            local current_count="${counters[$lowercase_ext]:-0}"
            current_count=$((current_count + 1))
            counters["$lowercase_ext"]="$current_count"
            local new_name=$(printf "%03d.%s" "$current_count" "$lowercase_ext")
            target_path="${target_dir}/${new_name}"
        fi

        if [[ -e "$target_path" ]]; then
            log "WARN" "Gagal (Konflik): File tujuan '${target_path}' sudah ada."
            ((FAILED_COUNT++)); continue;
        fi

        if [[ "$dry_run" == "true" ]]; then
            log "INFO" "[PRATINJAU] Pindah: '$source_path' -> '$target_path'"
            ((PROCESSED_COUNT++))
        else
            mkdir -p "$target_dir"
            local error_message
            if ! error_message=$(mv -n -- "$source_path" "$target_path" 2>&1); then
                log "ERROR" "Gagal memindahkan '${filename}': ${error_message}"
                ((FAILED_COUNT++))
            else
                echo "$target_path|$source_path" >> "${undo_log}"
                ((PROCESSED_COUNT++))
            fi
        fi
    done < <(find "${find_args[@]}" -print0)
}

final_report() {
    if [[ "${show_summary:-true}" == "true" ]]; then
        echo -e "\n${COLOR_CYAN}===== RINGKASAN OPERASI =====${COLOR_RESET}"
        echo "✅ Berhasil dipindah/disimulasikan: $PROCESSED_COUNT"
        echo "❌ Gagal atau dilewati: $FAILED_COUNT"
        
        if [[ "$dry_run" != "true" && -f "$undo_log" ]]; then
             echo -e "\n${COLOR_YELLOW}💡 INFORMASI UNDO:${COLOR_RESET}"
             echo "   Untuk mengembalikan perubahan ini, jalankan:"
             echo -e "   ${COLOR_GREEN}$0 --undo${COLOR_RESET}"
        fi
        
        if [[ $FAILED_COUNT -gt 0 && $PROCESSED_COUNT -gt 0 ]]; then
            echo
            log "WARN" "Terjadi kegagalan selama operasi."
            read -rp "Apakah Anda ingin membatalkan semua yang berhasil dipindahkan sekarang? (y/T) " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                undo_operation "$undo_log"
            fi
        fi
    fi
    
    local summary_msg="Berhasil: $PROCESSED_COUNT | Gagal: $FAILED_COUNT"
    local os_type=$(uname)
    if [[ "$os_type" == "Darwin" ]]; then
        osascript -e "display notification \"${summary_msg}\" with title \"Pengelola File Selesai\"" &>/dev/null || true
    elif command -v notify-send &>/dev/null; then
        notify-send "Pengelola File Selesai" "$summary_msg"
    fi
}

run_gui() {
    local os_type=$(uname)
    if [[ "$os_type" == "Darwin" ]]; then
        source_dir=$(osascript -e 'tell application "System Events" to choose folder with prompt "Silakan pilih folder sumber:"' -e 'return POSIX path of result' || echo "")
        destination_dir=$(osascript -e 'tell application "System Events" to choose folder with prompt "Silakan pilih folder tujuan:"' -e 'return POSIX path of result' || echo "")
    elif command -v zenity >/dev/null; then
        source_dir=$(zenity --file-selection --directory --title="Pilih Folder Sumber" || echo "")
        destination_dir=$(zenity --file-selection --directory --title="Pilih Folder Tujuan" || echo "")
    else
        log "ERROR" "Tidak ada tool GUI yang ditemukan (Zenity untuk Linux, atau Anda bukan di macOS)."
        exit 1
    fi
    
    if [[ -z "$source_dir" || -z "$destination_dir" ]]; then
        log "INFO" "Operasi dibatalkan oleh pengguna."
        exit 0
    fi
    
    main
}

# --- Titik Masuk Eksekusi ---
case "${1:-}" in
    --undo)
        load_config
        undo_operation "${2:-$undo_log}"
        exit 0
        ;;
    --gui)
        load_config
        run_gui
        exit 0
        ;;
    --help)
        echo "Penggunaan: $0 [--undo] [--gui]"
        echo "Semua pengaturan lain dikelola di file 'organize.conf'."
        exit 0
        ;;
esac

show_header
load_config
main
