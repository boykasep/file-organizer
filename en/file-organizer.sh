#!/usr/bin/env bash

# =============================================================================
# Batch File Organizer
# =============================================================================

set -euo pipefail

# --- Variabel Global & Konfigurasi Default ---
CONFIG_FILE="organize.conf"
source_dir=""; destination_dir=""; include_ext=""; exclude_regex=""
rename=false; dry_run=false; undo_log="$HOME/.organize_undo.log"; show_summary=true
declare -gi PROCESSED_COUNT=0; declare -gi FAILED_COUNT=0

# --- Kode Warna ANSI ---
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
    echo "|             ADVANCED FILE ORGANIZER - FINAL EDITION             |"
    echo -e "===================================================================${COLOR_RESET}"
    echo -e "💡 To undo the last operation, run: ${COLOR_GREEN}$0 --undo${COLOR_RESET}"
    echo "   The undo log is stored at: ${undo_log}"
    echo "-------------------------------------------------------------------"
}

load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "ERROR" "Config file '$CONFIG_FILE' not found!"
        exit 1
    fi
    source <(grep -E '^\s*[a-zA-Z_][a-zA-Z0-9_]*=' "$CONFIG_FILE")
    log "INFO" "Configuration loaded from '$CONFIG_FILE'."

    for var in rename dry_run show_summary; do
        if [[ "${!var}" != "true" && "${!var}" != "false" ]]; then
            log "ERROR" "Invalid value for '$var' in config. Must be 'true' or 'false'."
            exit 1
        fi
    done
    if [[ -z "$source_dir" || ! -d "$source_dir" ]]; then
        log "ERROR" "Config 'source_dir' is not a valid directory: '$source_dir'"
        exit 1
    fi
}

undo_operation() {
    local log_path="${1:-$undo_log}"
    if [[ ! -f "$log_path" ]]; then
        log "WARN" "No undo log found at '$log_path'."
        exit 0
    fi
    
    log "INFO" "Reverting last operation from '$log_path'..."
    local undo_commands=()
    mapfile -t undo_commands < "$log_path"

    for (( i=${#undo_commands[@]}-1 ; i>=0 ; i-- )); do
        IFS='|' read -r new_path old_path <<< "${undo_commands[i]}"
        if [[ -e "$new_path" ]]; then
            mkdir -p "$(dirname "$old_path")"
            log "INFO" "Undo: Moving '${new_path}' -> '${old_path}'"
            mv -n "$new_path" "$old_path" || log "WARN" "Could not restore '$new_path'."
        fi
    done
    
    local backup_log="${log_path}.backup_$(date +%Y%m%d_%H%M%S)"
    mv "$log_path" "$backup_log"
    log "INFO" "Undo process complete. Old log backed up to '$backup_log'."
}

main() {
    trap 'final_report' EXIT

    mkdir -p "$destination_dir" || { log "ERROR" "Could not create destination directory '$destination_dir'."; exit 1; }
    
    local EXTENSIONS
    EXTENSIONS=($(echo "$include_ext" | tr ',' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$'))
    if [[ ${#EXTENSIONS[@]} -eq 0 ]]; then
        log "ERROR" "Config 'include_ext' cannot be empty."
        exit 1
    fi

    declare -A counters
    if [[ "$dry_run" != "true" ]]; then
        mkdir -p "$(dirname "$undo_log")" || { log "ERROR" "Could not create directory for undo log."; exit 1; }
        rm -f "${undo_log}"
    fi

    local find_args=("$source_dir" -maxdepth 1 -type f)
    find_args+=(-and \( -false)
    for ext in "${EXTENSIONS[@]}"; do
        [[ -n "$ext" ]] && find_args+=(-o -iname "*.$ext")
    done
    find_args+=(\) )

    log "INFO" "Scanning for files..."
    
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
            log "WARN" "Failed (Conflict): Target file '${target_path}' already exists."
            ((FAILED_COUNT++)); continue;
        fi

        if [[ "$dry_run" == "true" ]]; then
            log "INFO" "[DRY RUN] Move: '$source_path' -> '$target_path'"
            ((PROCESSED_COUNT++))
        else
            mkdir -p "$target_dir"
            local error_message
            if ! error_message=$(mv -n -- "$source_path" "$target_path" 2>&1); then
                log "ERROR" "Failed to move '${filename}': ${error_message}"
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
        echo -e "\n${COLOR_CYAN}===== OPERATION SUMMARY =====${COLOR_RESET}"
        echo "✅ Successfully moved/simulated: $PROCESSED_COUNT"
        echo "❌ Failed or skipped: $FAILED_COUNT"
        
        if [[ "$dry_run" != "true" && -f "$undo_log" ]]; then
             echo -e "\n${COLOR_YELLOW}💡 UNDO INFORMATION:${COLOR_RESET}"
             echo "   To revert these changes, run the command:"
             echo -e "   ${COLOR_GREEN}$0 --undo${COLOR_RESET}"
        fi
        
        if [[ $FAILED_COUNT -gt 0 && $PROCESSED_COUNT -gt 0 ]]; then
            echo
            log "WARN" "Errors occurred during the operation."
            read -rp "Would you like to undo all successful moves now? (y/N) " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                undo_operation "$undo_log"
            fi
        fi
    fi
    
    local summary_msg="Success: $PROCESSED_COUNT | Failed: $FAILED_COUNT"
    local os_type=$(uname)
    if [[ "$os_type" == "Darwin" ]]; then
        osascript -e "display notification \"${summary_msg}\" with title \"File Organizer Finished\"" &>/dev/null || true
    elif command -v notify-send &>/dev/null; then
        notify-send "File Organizer Finished" "$summary_msg"
    fi
}

run_gui() {
    local os_type=$(uname)
    if [[ "$os_type" == "Darwin" ]]; then
        source_dir=$(osascript -e 'tell application "System Events" to choose folder with prompt "Please select the source folder:"' -e 'return POSIX path of result' || echo "")
        destination_dir=$(osascript -e 'tell application "System Events" to choose folder with prompt "Please select the destination folder:"' -e 'return POSIX path of result' || echo "")
    elif command -v zenity >/dev/null; then
        source_dir=$(zenity --file-selection --directory --title="Select Source Folder" || echo "")
        destination_dir=$(zenity --file-selection --directory --title="Select Destination Folder" || echo "")
    else
        log "ERROR" "No GUI tool found (Zenity for Linux, or you are not on macOS)."
        exit 1
    fi
    
    if [[ -z "$source_dir" || -z "$destination_dir" ]]; then
        log "INFO" "Operation cancelled by user."
        exit 0
    fi
    
    main
}

# --- Entry Point ---
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
        echo "Usage: $0 [--undo] [--gui]"
        echo "All other settings are managed in the 'organize.conf' file."
        exit 0
        ;;
esac

show_header
load_config
main
