#!/bin/bash

# A robust script to organize files into subdirectories.
# Version 2.0 - Made generic for public use.

# Exit immediately if a command exits with a non-zero status.
# Exit if an unset variable is used.
# Pipelines return the exit status of the last command to exit with a non-zero status.
set -euo pipefail

# --- Function to display usage instructions ---
print_usage() {
    echo "Usage: $0 [-s SUFFIX] <directory>"
    echo "Organizes files in <directory> into their own subfolders."
    echo ""
    echo "Arguments:"
    echo "  <directory>         The target directory containing the files to organize."
    echo ""
    echo "Options:"
    echo "  -s SUFFIX           Specify a suffix. Files ending with SUFFIX.pdf"
    echo "                      will be grouped with their base filename."
    echo "                      Example: '-s _transcript' for 'file_transcript.pdf'"
    echo ""
    echo "  -h                  Display this help and exit."
    echo ""
    echo "Examples:"
    echo "  # Basic usage for files like 'file1.pdf', 'file2.pdf'"
    echo "  $0 /path/to/files"
    echo ""
    echo "  # Advanced usage for 'file_transcript.pdf' and 'file.pdf'"
    echo "  $0 -s _transcript /path/to/files"
}

# --- Main Logic ---

# Default values
SUFFIX=""

# Parse command-line options
while getopts 's:h' flag; do
  case "${flag}" in
    s) SUFFIX="${OPTARG}" ;;
    h) print_usage
       exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done

# Remove the options from the argument list
shift "$((OPTIND - 1))"

# Check if the main argument (directory) is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Target directory not specified." >&2
    print_usage
    exit 1
fi

TARGET_DIR="${1}"

# Check if the target directory exists
if [ ! -d "${TARGET_DIR}" ]; then
    echo "Error: Directory '${TARGET_DIR}' not found." >&2
    exit 1
fi

# Navigate to the target directory; exit if it fails
cd "${TARGET_DIR}" || exit

echo "Organizing files in: $(pwd)"

# --- File Processing Logic ---

if [ -n "${SUFFIX}" ]; then
    # ADVANCED MODE: Suffix is provided
    echo "Mode: Suffix grouping. Looking for suffix '${SUFFIX}'..."
    # Loop through files that have the suffix
    for file in *"${SUFFIX}".pdf; do
        # Check if any file matches the pattern to avoid errors
        [ -e "$file" ] || continue

        # Get the base folder name by removing the suffix and the extension
        # e.g., "filename_transcript.pdf" -> "filename"
        folder_name=$(basename "$file" "${SUFFIX}.pdf")

        echo "Processing: ${folder_name}"
        # Create the folder if it doesn't exist
        mkdir -p "${folder_name}"

        # Move all files starting with the base name into the new folder
        # e.g., moves "filename.pdf", "filename_transcript.pdf", "filename.jpg", etc.
        echo "  -> Moving files to '${folder_name}/'"
        mv "${folder_name}"* "${folder_name}/"
    done
else
    # BASIC MODE: No suffix
    echo "Mode: Basic grouping..."
    # Loop through all .pdf files
    for file in *.pdf; do
        # Check if any file matches the pattern
        [ -e "$file" ] || continue

        # Get the folder name by removing the .pdf extension
        folder_name=$(basename "$file" ".pdf")

        echo "Processing: ${folder_name}"
        # Create the folder if it doesn't exist
        mkdir -p "${folder_name}"

        # Move all files starting with that name into the new folder
        echo "  -> Moving files to '${folder_name}/'"
        mv "${folder_name}".* "${folder_name}/"
    done
fi

echo "Organization complete."
