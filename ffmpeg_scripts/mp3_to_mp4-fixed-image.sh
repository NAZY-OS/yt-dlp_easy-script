#!/bin/bash

# MIT License
# 
# Copyright (c) 2026 NAZY-OS
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#

# Author: NAZY-OS
# Version: 1.0.1

SCRIPTPATH="$(dirname -- "${BASH_SOURCE[0]}")"

show_help() {
    echo "Usage: $0 -i <image_file> -a <audio_file> -o <output_file> [-p <output_directory>]"
    echo "Options:"
    echo "    -i, --image     Input image file."
    echo "    -a, --audio     Input audio file."
    echo "    -o, --output    Output video file name."
    echo "    -p, --path      (Optional) Output directory. Default is current directory."
    echo "    -h, --help      Show this help message."
}

# Using getopt to parse input
OPTIONS=$(getopt -o i:a:o:p:h --long image:,audio:,output:,path:,help -- "$@")
if [ $? -ne 0 ]; then
    show_help
    exit 1
fi

eval set -- "$OPTIONS"

# Default values
OUTPUT_PATH="."

# Parse options
while true; do
    case "$1" in
        -i | --image)
            IMAGE="$2"
            shift 2
            ;;
        -a | --audio)
            AUDIO="$2"
            shift 2
            ;;
        -o | --output)
            OUTPUT="$2"
            shift 2
            ;;
        -p | --path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        --) 
            shift
            break
            ;;
        *) 
            echo "Invalid option"
            exit 1
            ;;
    esac
done

# Check required parameters
if [ -z "$IMAGE" ] || [ -z "$AUDIO" ] || [ -z "$OUTPUT" ]; then
    echo "Missing required parameters."
    show_help
    exit 1
fi

# Execute ffmpeg command
ffmpeg -loop 1 -i "$IMAGE" -i "$AUDIO" -c:v libx264 -c:a aac -b:a 192k -shortest -pix_fmt yuv420p "$OUTPUT_PATH/$OUTPUT"

echo "Video created successfully from $IMAGE and $AUDIO, saved as $OUTPUT_PATH/$OUTPUT"
