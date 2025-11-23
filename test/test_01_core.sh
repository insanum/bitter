#!/bin/bash
#
# test_01_core.sh - Core Feature Tests
#
# These tests verify the fundamental functionality of bitz:
# - Basic value display in different formats
# - Hex, decimal, octal, and binary input parsing
# - Bit range/spec input parsing
# - 32-bit, 64-bit, and 128-bit value handling
# - Help output
#
# EXAMPLES:
#   bitz 0xff                    # Display hex value
#   bitz 255                     # Display decimal value
#   bitz 0o377                   # Display octal value
#   bitz 0b11111111              # Display binary value
#   bitz 0,1,2,3                 # Display value from bit spec
#   bitz 0-7                     # Display value from bit range
#

section "Core Features - Basic Value Display"

# -----------------------------------------------------------------------------
# TEST: Help output
# The -h flag should display usage information and exit
# -----------------------------------------------------------------------------
run_test "Help flag (-h) shows usage" \
    "$BITZ -h 2>&1 || true" \
    "Usage: bitz"

# -----------------------------------------------------------------------------
# TEST: Hexadecimal input
# Hex values are prefixed with 0x or 0X
# Output shows the value in hex and binary bit visualization
# -----------------------------------------------------------------------------
run_test "Hex input (lowercase 0x)" \
    "$BITZ -n 0xff" \
    "0x000000ff"

run_test "Hex input (uppercase 0X)" \
    "$BITZ -n 0XFF" \
    "0x000000ff"

run_test "Hex input (mixed case digits)" \
    "$BITZ -n 0xDeAdBeEf" \
    "0xdeadbeef"

# -----------------------------------------------------------------------------
# TEST: Decimal input
# Plain integers are interpreted as decimal
# -----------------------------------------------------------------------------
run_test "Decimal input (small)" \
    "$BITZ -n 255" \
    "0x000000ff"

run_test "Decimal input (large)" \
    "$BITZ -n 3735928559" \
    "0xdeadbeef"

run_test "Decimal input (zero)" \
    "$BITZ -n 0" \
    "0x00000000"

# -----------------------------------------------------------------------------
# TEST: Octal input
# Octal values are prefixed with 0o or 0O
# -----------------------------------------------------------------------------
run_test "Octal input (lowercase 0o)" \
    "$BITZ -n 0o377" \
    "0x000000ff"

run_test "Octal input (uppercase 0O)" \
    "$BITZ -n 0O377" \
    "0x000000ff"

run_test "Octal input (larger value)" \
    "$BITZ -n 0o7777" \
    "0x00000fff"

# -----------------------------------------------------------------------------
# TEST: Binary input
# Binary values are prefixed with 0b or 0B
# -----------------------------------------------------------------------------
run_test "Binary input (lowercase 0b)" \
    "$BITZ -n 0b11111111" \
    "0x000000ff"

run_test "Binary input (uppercase 0B)" \
    "$BITZ -n 0B11111111" \
    "0x000000ff"

run_test "Binary input (sparse bits)" \
    "$BITZ -n 0b10101010" \
    "0x000000aa"

# -----------------------------------------------------------------------------
# TEST: Bit specification input
# Comma-separated bit numbers set those bits
# Example: 0,1,2,3 sets bits 0-3 = 0xf
# NOTE: A single number is interpreted as a decimal value, not a bit position.
#       Use comma (0,) or range (0-0) to specify a single bit position.
# -----------------------------------------------------------------------------
run_test "Bit spec - single bit (with comma)" \
    "$BITZ -n 0," \
    "0x00000001"

run_test "Bit spec - multiple bits" \
    "$BITZ -n 0,1,2,3" \
    "0x0000000f"

run_test "Bit spec - scattered bits" \
    "$BITZ -n 0,4,8,12" \
    "0x00001111"

run_test "Bit spec - high bit (with comma)" \
    "$BITZ -n 31," \
    "0x80000000"

# -----------------------------------------------------------------------------
# TEST: Bit range input
# Ranges specified as START-END set all bits in range (inclusive)
# Example: 0-7 sets bits 0 through 7 = 0xff
# -----------------------------------------------------------------------------
run_test "Bit range - byte" \
    "$BITZ -n 0-7" \
    "0x000000ff"

run_test "Bit range - word" \
    "$BITZ -n 0-15" \
    "0x0000ffff"

run_test "Bit range - upper byte" \
    "$BITZ -n 24-31" \
    "0xff000000"

run_test "Bit range - middle bits" \
    "$BITZ -n 8-15" \
    "0x0000ff00"

# -----------------------------------------------------------------------------
# TEST: Mixed bit spec and ranges
# Can combine individual bits and ranges
# Example: 0,4-7,31 = bit 0 + bits 4-7 + bit 31
# -----------------------------------------------------------------------------
run_test "Mixed spec - bits and range" \
    "$BITZ -n 0,4-7" \
    "0x000000f1"

run_test "Mixed spec - multiple ranges" \
    "$BITZ -n 0-3,8-11" \
    "0x00000f0f"

run_test "Mixed spec - complex" \
    "$BITZ -n 0,4-7,12,16-19" \
    "0x000f10f1"


section "Core Features - Multi-Width Support"

# -----------------------------------------------------------------------------
# TEST: 32-bit values (default)
# Values <= 0xFFFFFFFF are displayed as 32-bit
# -----------------------------------------------------------------------------
run_test "32-bit value display" \
    "$BITZ -n 0xffffffff" \
    "0xffffffff"

run_test "32-bit max value" \
    "$BITZ -n 4294967295" \
    "0xffffffff"

# -----------------------------------------------------------------------------
# TEST: 64-bit values
# Values > 32-bit but <= 64-bit are displayed as 64-bit
# The display shows 16 hex digits
# -----------------------------------------------------------------------------
run_test "64-bit value display" \
    "$BITZ -n 0x123456789abcdef0" \
    "0x123456789abcdef0"

run_test "64-bit max value" \
    "$BITZ -n 0xffffffffffffffff" \
    "0xffffffffffffffff"

# -----------------------------------------------------------------------------
# TEST: 128-bit values
# Values > 64-bit are displayed as 128-bit (two 64-bit rows)
# The display shows 32 hex digits
# -----------------------------------------------------------------------------
run_test "128-bit value display" \
    "$BITZ -n 0x123456789abcdef0123456789abcdef0" \
    "0x123456789abcdef0123456789abcdef0"

run_test "128-bit with upper bits set" \
    "$BITZ -n 0xffffffffffffffffffffffffffffffff" \
    "0xffffffffffffffffffffffffffffffff"


section "Core Features - Multiple Values"

# -----------------------------------------------------------------------------
# TEST: Multiple value arguments
# Multiple values can be passed and each is displayed
# -----------------------------------------------------------------------------
run_test "Multiple values on command line" \
    "$BITZ -n 0xff 0xaa 0x55 | grep -c '0x'" \
    "3"


section "Core Features - ASCII Mode"

# -----------------------------------------------------------------------------
# TEST: ASCII drawing mode (-a)
# Uses ASCII characters instead of Unicode box-drawing characters
# Useful for terminals that don't support Unicode
# -----------------------------------------------------------------------------
run_test "ASCII mode uses dashes" \
    "$BITZ -n -a 0xff" \
    "--------"

run_test "ASCII mode uses pipes" \
    "$BITZ -n -a 0xff" \
    "|"


section "Core Features - No Color Mode"

# -----------------------------------------------------------------------------
# TEST: No color mode (-n)
# Disables ANSI color codes in output
# Useful for piping to files or non-color terminals
# -----------------------------------------------------------------------------
run_test "No color mode - output readable" \
    "$BITZ -n 0xff" \
    "0x000000ff"

run_test "No color mode - contains box chars" \
    "$BITZ -n 0xff" \
    "┌"


section "Core Features - Start Bit Labeling"

# -----------------------------------------------------------------------------
# TEST: Start bit option (--sb)
# Changes the starting bit number for labeling
# Useful when displaying a field from a larger register
# -----------------------------------------------------------------------------
run_test "Start bit at 0 (default)" \
    "$BITZ -n --sb=0 0xff" \
    "76543210"

run_test "Start bit at 8" \
    "$BITZ -n --sb=8 0xff" \
    "5432109" # Shows 15-8 range

run_test "Start bit at 32" \
    "$BITZ -n --sb=32 0xff" \
    "32" # Shows bits starting at 32

# -----------------------------------------------------------------------------
# TEST: Reset bit option (-b)
# Resets the bit counter for each value when displaying multiple values
# -----------------------------------------------------------------------------
run_test "Reset bit for each value" \
    "$BITZ -n -b 0xff 0xaa | grep -c '76543210'" \
    "2"
