# file-organizer
A powerful script for batch organizing files into subfolders, with smart handling for filename patterns and suffixes.

# 🗂️ Batch File Organizer

A simple yet powerful Bash script to automatically organize files into folders based on their filenames. Perfect for managing documents, images, or any file collection with consistent naming patterns.

🛠️ Originally created to sort hundreds of student documents (like diplomas and transcripts) — now made available for general use.

## ✨ Features

-   **✅ Automatic Folder Creation:** Creates a folder for each unique filename (without extension or suffix).
-   **✅ Smart Grouping:** Moves all related files (e.g., `file.pdf`, `file.jpg`) into the correct folder.
-   **✅ Suffix Handling:** Recognizes suffixes like `_transcript`, `_t`, etc., and groups related files together.
-   **✅ Minimal & Flexible:** Works with or without a suffix, handling batch processing cleanly.

## 🔧 Prerequisites

-   A Unix-like environment (Linux, macOS, or WSL on Windows).
-   Basic terminal usage knowledge.

## 📦 Installation

No installation required. Just make the script executable:
```bash
chmod +x file-organizer.sh
```

## 🚀 Usage

Run the script from your terminal, pointing it to the directory containing the files you want to organize.

#### Basic Usage (One File Per Folder)

Use this if you have files like `file1.pdf`, `file2.pdf`, etc., and you want to move each one into its own folder (`/file1/`, `/file2/`).
```bash
./file-organizer.sh /path/to/your/files
```

#### Advanced Usage (Grouping Files with a Suffix)

Use this for related files that share a base name but have a specific suffix (e.g., `john_doe.pdf` and `john_doe_transcript.pdf`).
```bash
./file-organizer.sh -s _transcript /path/to/your/files
```
The `-s` flag defines the suffix. The script will create a folder based on the filename *without* the suffix and move both files into it.

## 💡 Advanced Customization & Examples

The script is designed to be simple, but you can easily modify it for more complex needs. Here are a couple of examples.

#### Example 1: Moving Folders to a Specific Destination

By default, new folders are created inside the target directory. If you want to create them in a different location (e.g., `~/Documents/Organized`), you can make a small change.

Find this line in the script:
```bash
mkdir -p "${folder_name}"
```
And change it to specify your destination path:
```bash
DEST_PATH="/home/user/Documents/Organized"
mkdir -p "${DEST_PATH}/${folder_name}"
```
You will also need to update the `mv` command right after it to use the new path:
```bash
mv "${folder_name}"* "${DEST_PATH}/${folder_name}/"
```

#### Example 2: Adding a Prefix to All Folder Names

If you want every new folder to have a prefix (e.g., `Record_file1`, `Record_file2`), you can modify the script.

Find this line:
```bash
folder_name=$(basename "$file" ".pdf") # Or the relevant basename line
```
And then modify the `mkdir` and `mv` commands to include your desired prefix:
```bash
PREFIX="Record"
mkdir -p "${PREFIX}_${folder_name}"
mv "${folder_name}".* "${PREFIX}_${folder_name}/"
```

---
*Feel free to contribute or report issues.*

*Concept and original script by boykasep. Refactored for public use and documented with assistance from Google's Gemini.*
