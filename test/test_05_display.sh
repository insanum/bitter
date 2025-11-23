#!/bin/bash
#
# test_05_display.sh - Display Option Tests
#
# These tests verify display options:
# - --signed: Show signed integer interpretation
# - --stats: Show bit statistics (popcount, leading/trailing zeros)
# - --dec: Show decimal value
# - --oct: Show octal value
# - --bin: Show binary value
# - --width: Force display width
# - --compact: Single-line compact output
# - --theme: Color themes (dark/light)
# - --format: Custom output format
#
# EXAMPLES:
#   bitter --signed 0xffffffff        # Show as signed: -1
#   bitter --stats 0xdeadbeef         # Show popcount, leading zeros, etc.
#   bitter --dec 0xff                 # Show decimal: 255
#   bitter --bin 0xff                 # Show binary
#   bitter --width=64 0xff            # Force 64-bit display
#   bitter --compact 0xdeadbeef       # Single-line output
#   bitter --theme=light 0xff         # Use light terminal theme
#   bitter --format="%h (%d)" 0xff    # Custom format
#

section "Display Options - Signed Integer (--signed)"

# -----------------------------------------------------------------------------
# TEST: Signed integer display
# Interprets the value as a signed integer based on bit width
# 32-bit: values >= 0x80000000 are negative
# 64-bit: values >= 0x8000000000000000 are negative
# -----------------------------------------------------------------------------
run_test "Signed - positive 32-bit" \
    "$BITTER -n --signed 0x7fffffff" \
    "signed: 2147483647"

run_test "Signed - negative 32-bit (-1)" \
    "$BITTER -n --signed 0xffffffff" \
    "signed: -1"

run_test "Signed - negative 32-bit (min)" \
    "$BITTER -n --signed 0x80000000" \
    "signed: -2147483648"

run_test "Signed - small positive" \
    "$BITTER -n --signed 0xff" \
    "signed: 255"

run_test "Signed - negative pattern" \
    "$BITTER -n --signed 0xfffffffe" \
    "signed: -2"

# -----------------------------------------------------------------------------
# TEST: Signed with 64-bit values
# -----------------------------------------------------------------------------
run_test "Signed - 64-bit negative" \
    "$BITTER -n --signed 0xffffffffffffffff" \
    "signed: -1"


section "Display Options - Statistics (--stats)"

# -----------------------------------------------------------------------------
# TEST: Bit statistics display
# Shows:
# - popcount: Number of set bits
# - leading zeros: Zero bits from MSB down
# - trailing zeros: Zero bits from LSB up
# - highest set: Position of highest set bit
# - lowest set: Position of lowest set bit
# -----------------------------------------------------------------------------
run_test "Stats - shows popcount" \
    "$BITTER -n --stats 0xff" \
    "popcount"

run_test "Stats - popcount value for 0xff" \
    "$BITTER -n --stats 0xff" \
    "popcount      = 8"

run_test "Stats - shows leading zeros" \
    "$BITTER -n --stats 0xff" \
    "leading zeros = 24"

run_test "Stats - shows trailing zeros" \
    "$BITTER -n --stats 0xf0" \
    "trailing zeros= 4"

run_test "Stats - shows highest set" \
    "$BITTER -n --stats 0xff" \
    "highest set   = 7"

run_test "Stats - shows lowest set" \
    "$BITTER -n --stats 0xf0" \
    "lowest set    = 4"

# -----------------------------------------------------------------------------
# TEST: Stats for various patterns
# -----------------------------------------------------------------------------
run_test "Stats - single bit popcount" \
    "$BITTER -n --stats 0x80000000" \
    "popcount      = 1"

run_test "Stats - alternating pattern popcount" \
    "$BITTER -n --stats 0xaaaaaaaa" \
    "popcount      = 16"

run_test "Stats - all bits set" \
    "$BITTER -n --stats 0xffffffff" \
    "popcount      = 32"


section "Display Options - Multi-Base Output"

# -----------------------------------------------------------------------------
# TEST: Decimal output (--dec)
# Shows the value in decimal notation
# -----------------------------------------------------------------------------
run_test "Decimal output" \
    "$BITTER -n --dec 0xff" \
    "dec: 255"

run_test "Decimal output - large value" \
    "$BITTER -n --dec 0xdeadbeef" \
    "dec: 3735928559"

# -----------------------------------------------------------------------------
# TEST: Octal output (--oct)
# Shows the value in octal notation with 0o prefix
# -----------------------------------------------------------------------------
run_test "Octal output" \
    "$BITTER -n --oct 0xff" \
    "oct: 0o377"

run_test "Octal output - larger value" \
    "$BITTER -n --oct 0x1ff" \
    "oct: 0o777"

# -----------------------------------------------------------------------------
# TEST: Binary output (--bin)
# Shows the value in binary notation with 0b prefix
# Zero-padded to full width (32/64/128 bits)
# -----------------------------------------------------------------------------
run_test "Binary output" \
    "$BITTER -n --bin 0xff" \
    "bin: 0b"

run_test "Binary output - shows all 32 bits" \
    "$BITTER -n --bin 0xff" \
    "00000000000000000000000011111111"

run_test "Binary output - pattern" \
    "$BITTER -n --bin 0xaa" \
    "10101010"

# -----------------------------------------------------------------------------
# TEST: Multiple base outputs together
# Can combine --dec, --oct, --bin, --signed
# -----------------------------------------------------------------------------
run_test "Multiple bases - dec and oct" \
    "$BITTER -n --dec --oct 0xff | grep -c ':'" \
    "2"

run_test "Multiple bases - all formats" \
    "$BITTER -n --dec --oct --bin --signed 0xff | grep -c ':'" \
    "4"


section "Display Options - Width Control (--width)"

# -----------------------------------------------------------------------------
# TEST: Force display width
# Forces the value to be displayed as specific bit width
# Valid widths: 8, 16, 32, 64, 128
# Useful for seeing a value in context of its register width
# -----------------------------------------------------------------------------
run_test "Width - force 32-bit (default)" \
    "$BITTER -n --width=32 0xff" \
    "0x000000ff"

run_test "Width - force 64-bit" \
    "$BITTER -n --width=64 0xff" \
    "0x00000000000000ff"

run_test "Width - force 128-bit" \
    "$BITTER -n --width=128 0xff" \
    "0x000000000000000000000000000000ff"

run_test "Width - 8-bit shows as 32" \
    "$BITTER -n --width=8 0xff" \
    "0x000000ff"

run_test "Width - 16-bit shows as 32" \
    "$BITTER -n --width=16 0xffff" \
    "0x0000ffff"

# -----------------------------------------------------------------------------
# TEST: Invalid width values
# -----------------------------------------------------------------------------
run_test_exit_code "Width - invalid value" \
    "$BITTER --width=24 0xff" \
    1


section "Display Options - Compact Mode (--compact / -c)"

# -----------------------------------------------------------------------------
# TEST: Compact single-line output
# Shows: hex = binary (decimal) [pop:N hi:N lo:N]
# Binary is underscore-separated by bytes for readability
# Useful for quick checks or logging
# -----------------------------------------------------------------------------
run_test "Compact - shows hex" \
    "$BITTER -n --compact 0xdeadbeef" \
    "0xdeadbeef"

run_test "Compact - shows binary with underscores" \
    "$BITTER -n --compact 0xff" \
    "_11111111"

run_test "Compact - shows decimal" \
    "$BITTER -n --compact 0xff" \
    "(255)"

run_test "Compact - shows popcount" \
    "$BITTER -n --compact 0xff" \
    "pop:8"

run_test "Compact - shows highest bit" \
    "$BITTER -n --compact 0xff" \
    "hi:7"

run_test "Compact - shows lowest bit" \
    "$BITTER -n --compact 0xff" \
    "lo:0"

run_test "Compact - short flag (-c)" \
    "$BITTER -n -c 0xff" \
    "pop:8"

# -----------------------------------------------------------------------------
# TEST: Compact with multiple values
# Each value on its own line
# -----------------------------------------------------------------------------
run_test "Compact - multiple values" \
    "$BITTER -n --compact 0xff 0xaa 0x55 | wc -l | tr -d ' '" \
    "3"


section "Display Options - Themes (--theme)"

# -----------------------------------------------------------------------------
# TEST: Color themes
# dark: For dark terminal backgrounds (default)
# light: For light terminal backgrounds
# Changes the color palette for better visibility
# -----------------------------------------------------------------------------
run_test "Theme - dark (default)" \
    "$BITTER --theme=dark 0xff" \
    "0x000000ff"

run_test "Theme - light" \
    "$BITTER --theme=light 0xff" \
    "0x000000ff"

run_test_exit_code "Theme - invalid name" \
    "$BITTER --theme=invalid 0xff" \
    1


section "Display Options - Custom Format (--format)"

# -----------------------------------------------------------------------------
# TEST: Custom output format strings
# Format specifiers:
#   %h - hex (with 0x)      %H - hex (no prefix)
#   %d - decimal            %s - signed decimal
#   %o - octal (with 0o)    %O - octal (no prefix)
#   %b - binary (with 0b)   %B - binary (no prefix)
#   %p - popcount           %w - bit width
#   %hi - highest set bit   %lo - lowest set bit
#   %lz - leading zeros     %tz - trailing zeros
#   %% - literal percent
# -----------------------------------------------------------------------------
run_test "Format - hex and decimal" \
    "$BITTER -n '--format=%h (%d)' 0xff" \
    "0x000000ff (255)"

run_test "Format - hex only" \
    "$BITTER -n '--format=%h' 0xdeadbeef" \
    "0xdeadbeef"

run_test "Format - decimal only" \
    "$BITTER -n '--format=%d' 0xff" \
    "255"

run_test "Format - signed" \
    "$BITTER -n '--format=%s' 0xffffffff" \
    "-1"

run_test "Format - popcount" \
    "$BITTER -n '--format=pop=%p' 0xff" \
    "pop=8"

run_test "Format - highest bit" \
    "$BITTER -n '--format=hi=%hi' 0xff" \
    "hi=7"

run_test "Format - lowest bit" \
    "$BITTER -n '--format=lo=%lo' 0xf0" \
    "lo=4"

run_test "Format - leading zeros" \
    "$BITTER -n '--format=lz=%lz' 0xff" \
    "lz=24"

run_test "Format - trailing zeros" \
    "$BITTER -n '--format=tz=%tz' 0xf0" \
    "tz=4"

run_test "Format - width" \
    "$BITTER -n '--format=width=%w' 0xff" \
    "width=32"

run_test "Format - hex no prefix" \
    "$BITTER -n '--format=%H' 0xff" \
    "000000ff"

run_test "Format - binary no prefix" \
    "$BITTER -n '--format=%B' 0x0f" \
    "00001111"

run_test "Format - octal" \
    "$BITTER -n '--format=%o' 0xff" \
    "0o377"

run_test "Format - CSV style" \
    "$BITTER -n '--format=%h,%d,%p' 0xdeadbeef" \
    "0xdeadbeef,3735928559,24"

run_test "Format - literal percent" \
    "$BITTER -n '--format=100%%' 0xff" \
    "100%"

# -----------------------------------------------------------------------------
# TEST: Format with multiple values
# -----------------------------------------------------------------------------
run_test "Format - multiple values" \
    "$BITTER -n '--format=%h' 0xff 0xaa 0x55 | wc -l | tr -d ' '" \
    "3"
