#!/bin/bash

# dismantle.sh (Corrected Version)
# Deconstructs the HTML story file into editable parts.

# The source HTML file.
SOURCE_HTML="superposition_choose_your_own_adventure.html"
# The directory to store the parts.
OUTPUT_DIR="story_parts"

# --- Safety Check ---
if [ ! -f "$SOURCE_HTML" ]; then
    echo "Error: Source file '$SOURCE_HTML' not found."
    echo "Please place the script in the same directory as the HTML file."
    exit 1
fi

# --- Setup ---
# Create the output directory, cleaning any previous runs.
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
echo "Created directory: $OUTPUT_DIR"

# --- Helper Function ---
# Extracts a section by its ID, creates the file, and adds metadata.
# Arguments: $1=section_id, $2=output_file_path
extract_section() {
    local section_id="$1"
    local output_file="$2"
    
    echo "Extracting section: '$section_id' -> '$output_file'"
    
    # Extract the HTML content for the section
    local content
    content=$(awk "/<section id=\"$section_id\"/,/<\/section>/" "$SOURCE_HTML")
    
    # Find image assets within the content
    local assets
    assets=$(echo "$content" | grep -o 'src="[^"]*\.\(jpg\|png\)"' | sed 's/src="//' | sed 's/"//')
    
    # Write metadata and content to the file
    {
        echo "## METADATA ##"
        echo "# ID: $section_id"
        echo "# PATH: $(basename "$output_file" .txt)"
        if [ -n "$assets" ]; then
            echo "# ASSETS:"
            echo "$assets" | sed 's/^/# - /'
        else
            echo "# ASSETS: None"
        fi
        echo "##############"
        echo ""
        echo "$content"
    } > "$output_file"
}

# --- Extraction Process ---

# 1. Extract Header (everything before the first story element in <main>)
echo "Extracting Header..."
awk '1;/<h1>A Quest for Quantum Silence<\/h1>/ {exit}' "$SOURCE_HTML" | head -n -1 > "$OUTPUT_DIR/0_header.html"

# 2. Extract Footer (everything after the last story section)
echo "Extracting Footer..."
awk '/<\/section>/ {p=1} p && /<button class="restart-button"/, /<\/html>/' "$SOURCE_HTML" | tail -n +2 > "$OUTPUT_DIR/ZZ_footer.html"

# 3. Extract Intro Block (H1, H2, Hero Figure, Intro, and Path Choice sections)
echo "Extracting Intro Block..."
# !--- THIS IS THE CORRECTED COMMAND ---!
# It now reliably captures everything from the H1 tag to the end of the path-choice section.
intro_content=$(awk '
    /<h1>A Quest for Quantum Silence<\/h1>/ { in_block = 1 }
    /<section id="gamer-path"/ { in_block = 0 }
    in_block { print }
' "$SOURCE_HTML")

assets=$(echo "$intro_content" | grep -o 'src="[^"]*\.jpg"' | sed 's/src="//; s/"//')
{
    echo "## METADATA ##"
    echo "# ID: hero, intro, path-choice"
    echo "# PATH: 1_intro_and_path_choice"
    echo "# ASSETS:"
    echo "$assets" | sed 's/^/# - /'
    echo "##############"
    echo ""
    echo "$intro_content"
} > "$OUTPUT_DIR/1_intro_and_path_choice.txt"


# 4. Extract Unique Story Sections
extract_section "gamer-path"       "$OUTPUT_DIR/10_gamer-path.txt"
extract_section "philosopher-path" "$OUTPUT_DIR/11_philosopher-path.txt"
extract_section "ofad-dialogue"    "$OUTPUT_DIR/100_ofad-dialogue.txt"
extract_section "flex-dialogue"    "$OUTPUT_DIR/101_flex-dialogue.txt"
extract_section "explanation"      "$OUTPUT_DIR/1000_explanation.txt"

# 5. Create Duplicates for Converging Paths (as requested by the node structure)
echo "Creating duplicates for converging story paths..."
cp "$OUTPUT_DIR/100_ofad-dialogue.txt" "$OUTPUT_DIR/110_ofad-dialogue.txt"
cp "$OUTPUT_DIR/101_flex-dialogue.txt" "$OUTPUT_DIR/111_flex-dialogue.txt"

cp "$OUTPUT_DIR/1000_explanation.txt" "$OUTPUT_DIR/1010_explanation.txt"
cp "$OUTPUT_DIR/1000_explanation.txt" "$OUTPUT_DIR/1100_explanation.txt"
cp "$OUTPUT_DIR/1000_explanation.txt" "$OUTPUT_DIR/1110_explanation.txt"

echo "✅ Dismantling complete. Check the '$OUTPUT_DIR' directory."
