#!/bin/bash
#
# test_03_fields.sh - Field Definition Tests
#
# These tests verify the field definition functionality:
# - Inline field definitions with --def
# - Loading fields from register definition files with --regfile
# - Field coloring in bit display
# - Field value extraction and summary
#
# Field definitions allow naming bit ranges within a register, making it
# easier to understand complex register values.
#
# EXAMPLES:
#   bitz --def="[7:0]=DATA" 0x1234         # Define DATA field as bits 7:0
#   bitz --def="[15:8]=STATUS,[7:0]=CMD" 0x1234  # Multiple fields
#   bitz --def="[0]=ENABLE" 0x01           # Single-bit field
#   bitz --regfile=regs.def 0x1234         # Load fields from file
#
# Field Definition File Format (regs.def):
#   # Comment line
#   [31:16]=DEVICE_ID
#   [15:0]=VENDOR_ID
#   [0]=ENABLE  # Inline comment
#

section "Field Definitions - Inline (--def)"

# -----------------------------------------------------------------------------
# TEST: Single field definition
# Format: [MSB:LSB]=NAME
# The field value is extracted and shown in the Fields summary
# -----------------------------------------------------------------------------
run_test "Define single field" \
    "$BITZ -n '--def=[7:0]=DATA' 0xff" \
    "DATA"

run_test "Field shows extracted value (hex)" \
    "$BITZ -n '--def=[7:0]=DATA' 0x12" \
    "0x12"

run_test "Field shows extracted value (decimal)" \
    "$BITZ -n '--def=[7:0]=DATA' 0x12" \
    "(18)"

# -----------------------------------------------------------------------------
# TEST: Multi-bit field extraction
# The field value is shifted and masked properly
# Example: bits [15:8] of 0x1234 = 0x12
# -----------------------------------------------------------------------------
run_test "Field extraction - upper byte" \
    "$BITZ -n '--def=[15:8]=STATUS' 0x1234" \
    "0x12"

run_test "Field extraction - middle bits" \
    "$BITZ -n '--def=[11:4]=MID' 0xabc" \
    "0xab"

# -----------------------------------------------------------------------------
# TEST: Single-bit field
# Format: [BIT]=NAME (same as [BIT:BIT]=NAME)
# Shows SET or CLEAR for single-bit fields
# -----------------------------------------------------------------------------
run_test "Single-bit field (set)" \
    "$BITZ -n '--def=[0]=ENABLE' 0x01" \
    "SET"

run_test "Single-bit field (clear)" \
    "$BITZ -n '--def=[0]=ENABLE' 0x00" \
    "CLEAR"

run_test "Single-bit field - high bit" \
    "$BITZ -n '--def=[31]=BUSY' 0x80000000" \
    "SET"

# -----------------------------------------------------------------------------
# TEST: Multiple field definitions
# Comma-separated list of fields
# Fields are shown sorted by MSB (highest first)
# -----------------------------------------------------------------------------
run_test "Multiple fields - comma separated" \
    "$BITZ -n '--def=[15:8]=STATUS,[7:0]=DATA' 0x1234" \
    "STATUS"

run_test "Multiple fields - shows all fields" \
    "$BITZ -n '--def=[15:8]=STATUS,[7:0]=DATA' 0x1234" \
    "DATA"

run_test "Multiple fields - correct STATUS value" \
    "$BITZ -n '--def=[15:8]=STATUS,[7:0]=DATA' 0x1234 | grep STATUS" \
    "0x12"

run_test "Multiple fields - correct DATA value" \
    "$BITZ -n '--def=[15:8]=STATUS,[7:0]=DATA' 0x1234 | grep DATA" \
    "0x34"

# -----------------------------------------------------------------------------
# TEST: Complex field layout (typical register)
# Example: PCIe-style configuration register
# -----------------------------------------------------------------------------
run_test "Complex fields - 4 fields" \
    "$BITZ -n '--def=[31:24]=A,[23:16]=B,[15:8]=C,[7:0]=D' 0xdeadbeef | grep -c '='" \
    "4"

run_test "Complex fields - field A value" \
    "$BITZ -n '--def=[31:24]=A,[23:16]=B,[15:8]=C,[7:0]=D' 0xdeadbeef | grep 'A '" \
    "0xde"

run_test "Complex fields - field D value" \
    "$BITZ -n '--def=[31:24]=A,[23:16]=B,[15:8]=C,[7:0]=D' 0xdeadbeef | grep 'D '" \
    "0xef"


section "Field Definitions - Register File (--regfile)"

# -----------------------------------------------------------------------------
# TEST: Loading fields from file
# Create a temporary register definition file and load it
# -----------------------------------------------------------------------------

# Create test register file
TEMP_REGFILE="/tmp/bitz_test_regs.def"
cat > "$TEMP_REGFILE" << 'EOF'
# PCIe Configuration Space Header
# This is a comment line

[31:16]=DEVICE_ID
[15:0]=VENDOR_ID

# Status and Command register
[31]=BUSY       # Device is busy
[0]=ENABLE      # Enable bit
EOF

run_test "Load regfile - DEVICE_ID field" \
    "$BITZ -n --regfile=$TEMP_REGFILE 0xdead1234" \
    "DEVICE_ID"

run_test "Load regfile - VENDOR_ID field" \
    "$BITZ -n --regfile=$TEMP_REGFILE 0xdead1234" \
    "VENDOR_ID"

run_test "Load regfile - DEVICE_ID value" \
    "$BITZ -n --regfile=$TEMP_REGFILE 0xdead1234 | grep DEVICE_ID" \
    "0xdead"

run_test "Load regfile - VENDOR_ID value" \
    "$BITZ -n --regfile=$TEMP_REGFILE 0xdead1234 | grep VENDOR_ID" \
    "0x1234"

run_test "Load regfile - single bit field" \
    "$BITZ -n --regfile=$TEMP_REGFILE 0x80000001 | grep BUSY" \
    "SET"

run_test "Load regfile - ENABLE field" \
    "$BITZ -n --regfile=$TEMP_REGFILE 0x80000001 | grep ENABLE" \
    "SET"

# Clean up
rm -f "$TEMP_REGFILE"


section "Field Definitions - With Bitwise Operations"

# -----------------------------------------------------------------------------
# TEST: Fields with DIFF operation
# Shows field changes between two values
# Extremely useful for debugging register changes
# -----------------------------------------------------------------------------
run_test "Fields with DIFF - shows CHANGED" \
    "$BITZ -n '--def=[7:0]=DATA' --diff 0xff 0xaa" \
    "CHANGED"

run_test "Fields with DIFF - shows field name" \
    "$BITZ -n '--def=[7:0]=DATA' --diff 0xff 0xaa" \
    "DATA"

# -----------------------------------------------------------------------------
# TEST: Fields with NOT operation
# -----------------------------------------------------------------------------
run_test "Fields with NOT" \
    "$BITZ -n '--def=[7:0]=DATA' --not 0x0f | grep DATA" \
    "0xf0"

# -----------------------------------------------------------------------------
# TEST: Fields with OR operation
# -----------------------------------------------------------------------------
run_test "Fields with OR" \
    "$BITZ -n '--def=[7:0]=DATA' --or 0xf0 0x0f | grep 'DATA.*0xff'" \
    "0xff"


section "Field Definitions - Edge Cases"

# -----------------------------------------------------------------------------
# TEST: Field spanning full width
# -----------------------------------------------------------------------------
run_test "Field spanning full 32 bits" \
    "$BITZ -n '--def=[31:0]=FULL' 0xdeadbeef | grep FULL" \
    "0xdeadbeef"

# -----------------------------------------------------------------------------
# TEST: Adjacent non-overlapping fields
# -----------------------------------------------------------------------------
run_test "Adjacent fields - no gap" \
    "$BITZ -n '--def=[7:4]=HIGH,[3:0]=LOW' 0xab | grep HIGH" \
    "0xa"

run_test "Adjacent fields - LOW value" \
    "$BITZ -n '--def=[7:4]=HIGH,[3:0]=LOW' 0xab | grep LOW" \
    "0xb"

# -----------------------------------------------------------------------------
# TEST: Fields with gaps (undefined bits between)
# -----------------------------------------------------------------------------
run_test "Fields with gap" \
    "$BITZ -n '--def=[15:12]=A,[3:0]=B' 0xf00f | grep -c '='" \
    "2"

# -----------------------------------------------------------------------------
# TEST: Reversed bit order (should auto-correct)
# [LSB:MSB] should be treated same as [MSB:LSB]
# -----------------------------------------------------------------------------
run_test "Reversed bit order" \
    "$BITZ -n '--def=[0:7]=DATA' 0xff | grep DATA" \
    "0xff"
