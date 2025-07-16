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

# Process each MP4 file
for mp4_file in "$source_dir"/*.mp4; do
    # Check if any MP4 files exist
    [ -e "$mp4_file" ] || continue
    
    # Get filename without path and extension
    filename=$(basename "$mp4_file" .mp4)
    
    # Check if the output folder exists
    if [ ! -d "$filename" ]; then
        echo "Warning: Folder '$filename' not found, skipping..."
        continue
    fi
    
    echo "Generating thumbnail for: $filename"
    
    # Generate thumbnail at 5th second
    # -ss 5: seek to 5 seconds
    # -frames:v 1: extract only 1 frame
    # -q:v 2: high quality (1-31, lower is better)
    ffmpeg -i "$mp4_file" \
        -ss 5 \
        -frames:v 1 \
        -q:v 2 \
        "$filename/thumbnail.jpg" \
        -y
    
    if [ $? -eq 0 ]; then
        echo "✓ Thumbnail created: $filename/thumbnail.jpg"
        
        # Also create a smaller thumbnail for web use (optional)
        ffmpeg -i "$mp4_file" \
            -ss 5 \
            -frames:v 1 \
            -q:v 2 \
            -vf "scale=640:-1" \
            "$filename/thumbnail_640.jpg" \
            -y
        
        if [ $? -eq 0 ]; then
            echo "✓ Web thumbnail created: $filename/thumbnail_640.jpg"
        fi
    else
        echo "✗ Failed to create thumbnail for: $filename"
    fi
    
    echo "---"
done

echo "Thumbnail generation complete!"

# List all generated thumbnails
echo ""
echo "Generated thumbnails:"
for dir in expose-* story-*; do
    if [ -d "$dir" ] && [ -f "$dir/thumbnail.jpg" ]; then
        echo "- $dir/thumbnail.jpg"
    fi
done
