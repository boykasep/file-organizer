# 🗂️ Batch File Organizer (GUI & CLI)

A powerful and user-friendly Bash script to automatically organize files into folders based on their filenames. Now featuring both a graphical interface (GUI) and a command-line interface (CLI).

🛠️ Originally created to sort hundreds of student documents — now evolved into a full-featured utility for general use.

## ✨ Features

-   **✅ Dual Interface:** Run it with a simple, user-friendly GUI or use the powerful command-line for automation.
-   **✅ Safe Dry-Run Mode:** See what changes will be made *before* any files are moved. A crucial safety feature!
-   **✅ Automatic Folder Creation:** Creates a folder for each unique filename.
-   **✅ Smart Grouping:** Moves all related files (e.g., `file.pdf`, `file.jpg`) into the correct folder.
-   **✅ Intelligent Suffix Handling:** Recognizes suffixes (like `_t`) to group related files (e.g., `diploma.pdf` and `diploma_t.pdf`) together.

## 🔧 Prerequisites

-   A Unix-like environment (Linux, macOS, WSL).
-   For GUI mode: `zenity` must be installed.
    -   On Debian/Ubuntu, install with: `sudo apt install zenity`

## 📦 Installation

No installation required. Just make the script executable:
```bash
chmod +x file-organizer.sh
```

## 🚀 Usage

### Using the Graphical Interface (Recommended for Beginners)

Simply run the script with the `--gui` flag. A window will pop up asking you to select a folder.

```bash
./file-organizer.sh --gui
```

### Using the Command-Line

Point the script to the target directory.

```bash
# To execute immediately
./file-organizer.sh /path/to/your/files

# To see a preview of the changes without moving any files
./file-organizer.sh /path/to/your/files --dry-run
```

---
*Feel free to contribute or report issues.*

*Concept and script by Hendra. Evolved and documented with assistance from Google's Gemini.*
