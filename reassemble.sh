#!/bin/bash

# reassemble.sh
# Reconstructs the single HTML file from the deconstructed parts.

# The directory where the parts are stored.
SOURCE_DIR="story_parts"
# The name of the final, reassembled HTML file.
OUTPUT_HTML="reassembled_story.html"

# --- Safety Check ---
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Directory '$SOURCE_DIR' not found."
    echo "Please run the dismantle.sh script first."
    exit 1
fi

# --- Helper Function ---
# Reads a .txt file and outputs only the HTML content, skipping the metadata.
get_content() {
    if [ -f "$1" ]; then
        awk '/^##############/{flag=1; next} flag' "$1"
    fi
}

# --- Assembly Process ---
echo "Reassembling story from parts in '$SOURCE_DIR'..."

# 1. Start with the header.
cat "$SOURCE_DIR/0_header.html" > "$OUTPUT_HTML"

# 2. Append the main content sections in their original order.
#    The helper function strips the metadata we added.
get_content "$SOURCE_DIR/1_intro_and_path_choice.txt" >> "$OUTPUT_HTML"
get_content "$SOURCE_DIR/10_gamer-path.txt"           >> "$OUTPUT_HTML"
get_content "$SOURCE_DIR/11_philosopher-path.txt"     >> "$OUTPUT_HTML"
get_content "$SOURCE_DIR/100_ofad-dialogue.txt"       >> "$OUTPUT_HTML"
get_content "$SOURCE_DIR/101_flex-dialogue.txt"       >> "$OUTPUT_HTML"
get_content "$SOURCE_DIR/1000_explanation.txt"        >> "$OUTPUT_HTML"

# 3. Finish with the footer.
cat "$SOURCE_DIR/ZZ_footer.html" >> "$OUTPUT_HTML"

echo "✅ Reassembly complete. The new file is '$OUTPUT_HTML'."
