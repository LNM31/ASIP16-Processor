#!/bin/bash
# run.sh - Compile and run a program on the SoC processor
#
# Usage:
#   ./run.sh                    # Shows menu to select program
#   ./run.sh program.hex        # Runs specific program
#   ./run.sh program            # Also works (auto-adds .hex)
#   ./run.sh program_asip_add 2 # ASIP program with matrix size (1=2x3, 2=1x3, 3=3x3, 4=2x2)

# Detect project root (where this script lives)
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Find available .hex programs in Programs/
mapfile -t PROGRAMS < <(ls "$ROOT/Programs/"*.hex 2>/dev/null | xargs -n1 basename | sort)

if [ ${#PROGRAMS[@]} -eq 0 ]; then
    echo "Error: No .hex files found in $ROOT/Programs/"
    exit 1
fi

# Select program
if [ -n "$1" ]; then
    PROG="$1"
    # Auto-add .hex extension if missing
    [[ "$PROG" != *.hex ]] && PROG="${PROG}.hex"
else
    echo "Available programs:"
    echo ""
    for i in "${!PROGRAMS[@]}"; do
        printf "  %d) %s\n" "$((i+1))" "${PROGRAMS[$i]}"
    done
    echo ""
    read -p "Select program (1-${#PROGRAMS[@]}): " choice

    # Validate input
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#PROGRAMS[@]} ]; then
        echo "Error: Invalid selection"
        exit 1
    fi

    PROG="${PROGRAMS[$((choice-1))]}"
fi

# Check program exists
if [ ! -f "$ROOT/Programs/$PROG" ]; then
    echo "Error: $PROG not found in Programs/"
    exit 1
fi

# ASIP programs: allow choosing matrix dimensions
ASIP_PROGRAMS="program_asip_add.hex program_asip_sub.hex program_asip_elmul.hex program_asip_mul.hex"
HEX_FILE="$ROOT/Programs/$PROG"

if echo "$ASIP_PROGRAMS" | grep -qw "$PROG"; then
    # Select matrix size
    if [ -n "$2" ]; then
        SIZE_CHOICE="$2"
    else
        echo "Matrix size options for $PROG:"
        echo ""
        echo "  1) 2x3"
        echo "  2) 1x3"
        echo "  3) 3x3"
        echo "  4) 2x2"
        echo ""
        read -p "Select matrix size (1-4): " SIZE_CHOICE
    fi

    if ! [[ "$SIZE_CHOICE" =~ ^[1-4]$ ]]; then
        echo "Error: Invalid selection"
        exit 1
    fi

    # Lines to toggle: group A (6-9), group B (13-16)
    LINE_A=$((5 + SIZE_CHOICE))  # 6, 7, 8, or 9
    LINE_B=$((12 + SIZE_CHOICE)) # 13, 14, 15, or 16

    # Comment all lines 6-9 and 13-16 (add // if not already commented)
    for L in 6 7 8 9 13 14 15 16; do
        sed -i "${L}s|^[^/]|//&|" "$HEX_FILE"
    done

    # Uncomment the selected pair (remove leading //)
    sed -i "${LINE_A}s|^//||" "$HEX_FILE"
    sed -i "${LINE_B}s|^//||" "$HEX_FILE"

    SIZES=("2x3" "1x3" "3x3" "2x2")
    echo "Running: $PROG (matrix: ${SIZES[$((SIZE_CHOICE-1))]})"
else
    echo "Running: $PROG"
fi
echo ""

# Update INIT_FILE in SoC.v
sed -i "s|\.INIT_FILE(\"[^\"]*\")|\.INIT_FILE(\"../Programs/$PROG\")|" "$ROOT/SoC/SoC.v"

# Generate files.txt with absolute paths from relative paths
sed "s|^|$ROOT/|" "$ROOT/files_relative.txt" > "$ROOT/files.txt"

# Compile and run
cd "$ROOT/SoC"
iverilog -o lic -c "$ROOT/files.txt" ./SoC_tb2.v && ./lic
