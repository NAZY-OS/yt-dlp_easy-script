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

# Author: NAZY-OS
# Version: 1.0.1

SCRIPTPATH="$(dirname -- "${BASH_SOURCE[0]}")"

show_help() {
    echo "Usage: $0 -i <input_file> -o <output_file> -s <start_time> -e <end_time> [-p <output_directory>]"
    echo "Options:"
    echo "    -i, --input    Input audio file."
    echo "    -o, --output   Output audio file name."
    echo "    -s, --start    Start time for cutting (format: hh:mm:ss)."
    echo "    -e, --end      End time for cutting (format: hh:mm:ss)."
    echo "    -p, --path     (Optional) Output directory. Default is current directory."
    echo "    -h, --help     Show this help message."
}

# Using getopt to parse input
OPTIONS=$(getopt -o i:o:s:e:p:h --long input:,output:,start:,end:,path:,help -- "$@")
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
        -i | --input)
            INPUT="$2"
            shift 2
            ;;
        -o | --output)
            OUTPUT="$2"
            shift 2
            ;;
        -s | --start)
            START_TIME="$2"
            shift 2
            ;;
        -e | --end)
            END_TIME="$2"
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
if [ -z "$INPUT" ] || [ -z "$OUTPUT" ] || [ -z "$START_TIME" ] || [ -z "$END_TIME" ]; then
    echo "Missing required parameters."
    show_help
    exit 1
fi

# Execute ffmpeg command
ffmpeg -i "$INPUT" -ss "$START_TIME" -to "$END_TIME" -c copy "$OUTPUT_PATH/$OUTPUT"

echo "Audio cut successfully from $START_TIME to $END_TIME and saved as $OUTPUT_PATH/$OUTPUT"
