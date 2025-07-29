# 🗂️ Batch File Organizer

A production-ready, cross-platform utility to safely organize files based on a flexible configuration file. This definitive version features strict configuration validation and cross-platform desktop notifications for a truly professional experience.

## ✨ Core Features

-   **✅ Cross-Platform Notifications:** Sends a native desktop notification on both **Linux (`notify-send`)** and **macOS (`osascript`)**.
-   **✅ Strict Config Validation:** Meticulously validates all boolean (`true`/`false`) settings in `organize.conf` to prevent runtime errors.
-   **✅ Professional Logging & UI:** A consistent and clear interface with a full header, color-coded logs, a comprehensive summary, and an interactive undo prompt.
-   **✅ Safe and Reversible:** A persistent `undo` system allows you to revert any operation, backed by a safe `--dry-run` mode.
-   **✅ High Performance & Reliability:** Efficiently processes thousands of files, with robust handling for names with spaces and special characters.

## 🔧 Prerequisites

-   A Unix-like environment (Linux, macOS, or **WSL/Git Bash on Windows**).
-   For desktop notifications on Linux: `notify-send` is recommended.

## 🚀 Usage

1.  **Configure:** Edit `organize.conf` with your rules. Ensure boolean values are `true` or `false`.
2.  **Run:** Execute `./organizer.sh`.
3.  **Undo:** To revert, run `./organizer.sh --undo`.

---
*Concept and original script by boykasep. Evolved into a professional utility with collaborative refinement via Google's Gemini.*
