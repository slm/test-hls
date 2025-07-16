#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg first."
    exit 1
fi

# Source directory containing MP4 files
source_dir="reels-example-videos"

# Check if source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Directory '$source_dir' not found!"
    exit 1
fi

# Process each MP4 file in the source directory
for mp4_file in "$source_dir"/*.mp4; do
    # Check if any MP4 files exist
    [ -e "$mp4_file" ] || continue
    
    # Get filename without path and extension
    filename=$(basename "$mp4_file" .mp4)
    
    # Create output directory
    output_dir="$filename"
    mkdir -p "$output_dir"
    
    echo "Processing: $mp4_file"
    
    # Convert MP4 to HLS (M3U8)
    ffmpeg -i "$mp4_file" \
        -c:v h264 \
        -c:a aac \
        -hls_time 10 \
        -hls_list_size 0 \
        -hls_segment_filename "$output_dir/${filename}_%03d.ts" \
        "$output_dir/${filename}.m3u8" \
        -y
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully converted: $filename"
        echo "  Output: $output_dir/"
        echo "  - ${filename}.m3u8"
        echo "  - ${filename}_*.ts segments"
    else
        echo "✗ Failed to convert: $filename"
    fi
    
    echo "---"
done

echo "Conversion complete!"

