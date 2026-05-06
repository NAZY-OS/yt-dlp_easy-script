#!/bin/bash

# Help function
show_help() {
    echo "Usage: $0 -o OUTPUT_DIR [OPTIONS]"
    echo "Options:"
    echo "  -o, --output    Specify the download directory"
    echo "  -i, --ignore    Ignore already downloaded HD files"
    echo "  -h, --help      Show this help message"
}

DATE=$(date +"%Y-%m-%d %H:%M")
SCRIPT_NAME=$(basename "$0")
SCRIPT_PATH=$(dirname "$0")

# Default output directory
OUTDIR="$HOME/Downloads/"
IGNORE_EXISTING=false

# Parse parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -o|--output) OUTDIR="$2"; shift ;;
        -i|--ignore) IGNORE_EXISTING=true ;;
        -h|--help) show_help; exit 0 ;;
        *) items+=("$1") ;;  # Collect other parameters
    esac
    shift
done

# Create log file if it doesn't exist
if [ ! -f "$SCRIPT_PATH/yt-dlp-url_succeed.log" ]; then
    touch "$SCRIPT_PATH/yt-dlp-url_succeed.log"
fi

echo "${DATE}" >> "$SCRIPT_PATH/yt-dlp-url_list.log"

# Validate output directory
if [[ -z "$OUTDIR" || ! -d "$OUTDIR" ]]; then
    echo "Error: The directory '$OUTDIR' does not exist."
    exit 1
fi

# Loop through other parameters and execute command
for item in "${items[@]}"; do
    # Check if we should ignore already downloaded files
    if $IGNORE_EXISTING && grep -q "${item}.*HD" "$SCRIPT_PATH/yt-dlp-url_succeed.log"; then
        echo "File already downloaded: ${item} HD, skipping..."
        continue
    fi

    echo "Try to download as HD: ${item} with yt-dlp" >> "$SCRIPT_PATH/yt-dlp-url_list.log"
    echo "Try to download as HD: ${item} with yt-dlp"

    if command -v yt-dlp >/dev/null 2>&1; then
        yt-dlp --ignore-errors -f "bestvideo[height<=1080]+bestaudio/best[height<=480]" --add-metadata --embed-thumbnail --force-overwrite --merge-output-format mp4 \
        --output "%(title)s.%(ext)s" --paths "$OUTDIR" "$item"

        if [ $? -ne 0 ]; then
            echo "Error Code: $? - Downloading as HD: $item yt-dlp"
            echo "Error Code: $? - Downloading as HD: $item yt-dlp" >> "$SCRIPT_PATH/yt-dlp-error.log"
        else
            echo "Download Succeed as HD: $item yt-dlp" >> "$SCRIPT_PATH/yt-dlp-url_succeed.log"
        fi

    else
        if pipx run yt-dlp --version >/dev/null 2>&1; then
            pip="pipx run yt-dlp"
        else
            pip="python -m yt-dlp"
        fi

        cd "$SCRIPT_PATH"
        sh -c "${pip} --ignore-errors -f "bestvideo[height<=1080]+bestaudio/best[height<=480]" --add-metadata --embed-thumbnail --force-overwrite --merge-output-format mp4 \
        --output "%(title)s.%(ext)s" --paths '$OUTDIR' '$item'"

        if [ $? -ne 0 ]; then
            echo "Error Code: $? - Downloading as HD: $item yt-dlp"
            echo "Error Code: $? - Downloading as HD: $item yt-dlp" >> "$SCRIPT_PATH/yt-dlp-error.log"
        else
            echo "Download Succeed as HD: $item yt-dlp" >> "$SCRIPT_PATH/yt-dlp-url_succeed.log"
        fi

    fi
done
