#!/bin/bash
OSRM_DIR=".nigeria-osrm"
SOURCE_PBF="$OSRM_DIR/nigeria-260316.osm.pbf"
EXTRACT_PBF="$OSRM_DIR/lagos-ogun.osm.pbf"
LAGOSOGUN_BBOX="2.7,6.2,4.8,7.8"

# Find OSRM binaries - POSIX-compliant check (works in sh, dash, and bash)
if command -v osmium >/dev/null 2>&1; then
    echo "✅ Osmium found at: $(command -v osmium)"
else
    echo "❌ Error: 'osmium' command not found."
    echo "Please install: sudo apt update && sudo apt install osmium-tool"
    exit 1
fi

osmium --version | head -n 1
echo "✅ osmium is installed"

# Create directories
mkdir -p "$OSRM_DIR/bike" "$OSRM_DIR/car"

# Create extract if needed
if [ ! -f "$EXTRACT_PBF" ]; then
    if [ ! -f "$SOURCE_PBF" ]; then
        echo "❌ Error: Source file $SOURCE_PBF is missing."
        echo "Please download Nigeria OSM data first."
        exit 1
    fi

    echo "Creating extract for Lagos-Ogun region..."
    osmium extract -b "$LAGOSOGUN_BBOX" "$SOURCE_PBF" -o "$EXTRACT_PBF"
    
    if [ $? -eq 0 ]; then
        echo "✅ Extract created successfully."
    else
        echo "❌ Error: Osmium extraction failed."
        exit 1
    fi
else
    echo "✅ Extract file already exists: $EXTRACT_PBF"
fi

# Find OSRM binaries
OSRM_EXTRACT=$(find node_modules/.pnpm -name "osrm-extract" -type f -path "*/@project-osrm/*" | head -n 1)

if [ -n "$OSRM_EXTRACT" ] && [ -f "$OSRM_EXTRACT" ]; then
    OSRM_BIN=$(dirname "$OSRM_EXTRACT")
    echo "✅ Success: Found osrm-extract"
    echo "OSRM bin path: $OSRM_BIN"
else
    echo "❌ Error: 'osrm-extract' not found."
    echo "Please check if it is installed: pnpm list @project-osrm/osrm"
    exit 1
fi

PROFILE_CONTAINER=$(dirname "$(dirname "$OSRM_BIN")")
echo "✅ Profile directory: $PROFILE_CONTAINER"

# Process Bike data
# 🔄 Process Bike data
echo "🔄 Preparing Bike extraction..."
ln -sf "$(realpath $EXTRACT_PBF)" "$OSRM_DIR/bike/lagos-ogun.osm.pbf"

$OSRM_BIN/osrm-extract "$OSRM_DIR/bike/lagos-ogun.osm.pbf" \
    --profile "$PROFILE_CONTAINER/profiles/bicycle.lua"

# Note: osrm-extract automatically creates $OSRM_DIR/bike/lagos-ogun.osrm
$OSRM_BIN/osrm-partition "$OSRM_DIR/bike/lagos-ogun.osrm"
$OSRM_BIN/osrm-customize "$OSRM_DIR/bike/lagos-ogun.osrm"
echo "✅ Bike data processed successfully"

# 🔄 Process Car data
echo "🔄 Preparing Car extraction..."
ln -sf "$(realpath $EXTRACT_PBF)" "$OSRM_DIR/car/lagos-ogun.osm.pbf"

$OSRM_BIN/osrm-extract "$OSRM_DIR/car/lagos-ogun.osm.pbf" \
    --profile "$PROFILE_CONTAINER/profiles/car.lua"

$OSRM_BIN/osrm-partition "$OSRM_DIR/car/lagos-ogun.osrm"
$OSRM_BIN/osrm-customize "$OSRM_DIR/car/lagos-ogun.osrm"
echo "✅ Car data processed successfully"

echo "🎉 All done! OSRM data is ready in $OSRM_DIR/"

# Show generated files
echo ""
echo "Generated files:"
ls -lh "$OSRM_DIR/bike/" | grep "lagos-ogun"
ls -lh "$OSRM_DIR/car/" | grep "lagos-ogun"