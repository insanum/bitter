#!/bin/bash
#
# test_04_utility.sh - Utility Operation Tests
#
# These tests verify utility operations:
# - --mask: Generate bitmask from bit specification
# - --mask-inv: Generate inverted bitmask
# - --field: Extract field value from input
# - --bswap: Byte swap (endian conversion)
# - --bswap16: Byte swap within 16-bit words
#
# EXAMPLES:
#   bitter --mask 0-7                 # Generate mask: 0x000000ff
#   bitter --mask 4,7-11,31           # Generate mask: 0x80000f90
#   bitter --mask-inv 0-7             # Inverted mask: 0xffffff00
#   bitter --field=23:16 0xdeadbeef   # Extract bits 23:16 = 0xad
#   bitter --bswap 0x12345678         # Byte swap: 0x78563412
#   bitter --bswap16 0x12345678       # Word swap: 0x34127856
#

section "Utility Operations - Mask Generation (--mask)"

# -----------------------------------------------------------------------------
# TEST: Generate mask from bit range
# Creates a bitmask with specified bits set
# Output is just the hex value (no visualization)
# Useful for creating masks for register manipulation
# -----------------------------------------------------------------------------
run_test "Mask - single byte" \
    "$BITTER --mask 0-7" \
    "0x000000ff"

run_test "Mask - upper byte" \
    "$BITTER --mask 24-31" \
    "0xff000000"

run_test "Mask - middle word" \
    "$BITTER --mask 8-23" \
    "0x00ffff00"

run_test "Mask - single bit" \
    "$BITTER --mask 0" \
    "0x00000001"

run_test "Mask - high bit" \
    "$BITTER --mask 31" \
    "0x80000000"

# -----------------------------------------------------------------------------
# TEST: Mask from scattered bits
# Comma-separated bits create sparse mask
# -----------------------------------------------------------------------------
run_test "Mask - scattered bits" \
    "$BITTER --mask 0,4,8,12" \
    "0x00001111"

run_test "Mask - mixed bits and ranges" \
    "$BITTER --mask 0,4-7,31" \
    "0x800000f1"

run_test "Mask - complex pattern" \
    "$BITTER --mask 0-3,8-11,16-19,24-27" \
    "0x0f0f0f0f"

# -----------------------------------------------------------------------------
# TEST: Mask for 64-bit values
# When high bits are specified, output is 64-bit
# -----------------------------------------------------------------------------
run_test "Mask - 64-bit range" \
    "$BITTER --mask 32-63" \
    "0xffffffff00000000"

run_test "Mask - scattered 64-bit" \
    "$BITTER --mask 0,32,63" \
    "0x8000000100000001"


section "Utility Operations - Inverted Mask (--mask-inv)"

# -----------------------------------------------------------------------------
# TEST: Generate inverted mask
# Creates the inverse of the specified mask
# Useful for clearing specific bits: value & ~mask
# -----------------------------------------------------------------------------
run_test "Mask-inv - single byte" \
    "$BITTER --mask-inv 0-7" \
    "0xffffff00"

run_test "Mask-inv - upper byte" \
    "$BITTER --mask-inv 24-31" \
    "0x00ffffff"

run_test "Mask-inv - single bit" \
    "$BITTER --mask-inv 0" \
    "0xfffffffe"

run_test "Mask-inv - scattered bits" \
    "$BITTER --mask-inv 0,4,8,12" \
    "0xffffeee"

run_test "Mask-inv - all but one nibble" \
    "$BITTER --mask-inv 4-7" \
    "0xffffff0f"


section "Utility Operations - Field Extraction (--field)"

# -----------------------------------------------------------------------------
# TEST: Extract field value from input
# Extracts and right-shifts a specified bit range
# Output: bits[MSB:LSB] = value (decimal)
# Useful for quickly checking a specific field in a register dump
# -----------------------------------------------------------------------------
run_test "Field extract - single byte" \
    "$BITTER --field=7:0 0xdeadbeef" \
    "0xef"

run_test "Field extract - shows decimal" \
    "$BITTER --field=7:0 0xdeadbeef" \
    "(239)"

run_test "Field extract - upper byte" \
    "$BITTER --field=31:24 0xdeadbeef" \
    "0xde"

run_test "Field extract - middle byte" \
    "$BITTER --field=23:16 0xdeadbeef" \
    "0xad"

run_test "Field extract - shows bit range label" \
    "$BITTER --field=23:16 0xdeadbeef" \
    "bits[23:16]"

# -----------------------------------------------------------------------------
# TEST: Single bit extraction
# For single bits, shows SET or CLEAR
# -----------------------------------------------------------------------------
run_test "Field extract - single bit set" \
    "$BITTER --field=0 0x01" \
    "SET"

run_test "Field extract - single bit clear" \
    "$BITTER --field=0 0x00" \
    "CLEAR"

run_test "Field extract - single bit label" \
    "$BITTER --field=31 0x80000000" \
    "bit[31]"

# -----------------------------------------------------------------------------
# TEST: Nibble extraction
# -----------------------------------------------------------------------------
run_test "Field extract - nibble" \
    "$BITTER --field=7:4 0xab" \
    "0x0a"

run_test "Field extract - nibble shows decimal" \
    "$BITTER --field=7:4 0xab" \
    "(10)"


section "Utility Operations - Byte Swap (--bswap)"

# -----------------------------------------------------------------------------
# TEST: Full byte swap (endian conversion)
# Reverses byte order of the value
# Converts between big-endian and little-endian
# Example: 0x12345678 -> 0x78563412
# -----------------------------------------------------------------------------
run_test "Byte swap - 32-bit" \
    "$BITTER --bswap 0x12345678" \
    "0x78563412"

run_test "Byte swap - all same bytes unchanged" \
    "$BITTER --bswap 0xaaaaaaaa" \
    "0xaaaaaaaa"

run_test "Byte swap - single byte" \
    "$BITTER --bswap 0x000000ff" \
    "0xff000000"

run_test "Byte swap - pattern" \
    "$BITTER --bswap 0xdeadbeef" \
    "0xefbeadde"

# -----------------------------------------------------------------------------
# TEST: 64-bit byte swap
# -----------------------------------------------------------------------------
run_test "Byte swap - 64-bit" \
    "$BITTER --bswap 0x123456789abcdef0" \
    "0xf0debc9a78563412"


section "Utility Operations - Word Byte Swap (--bswap16)"

# -----------------------------------------------------------------------------
# TEST: Byte swap within 16-bit words
# Swaps bytes within each 16-bit word, preserving word order
# Example: 0x12345678 -> 0x34127856
# Useful for certain bus protocols that swap within words
# -----------------------------------------------------------------------------
run_test "Byte swap 16 - 32-bit" \
    "$BITTER --bswap16 0x12345678" \
    "0x34127856"

run_test "Byte swap 16 - single word" \
    "$BITTER --bswap16 0x0000abcd" \
    "0x0000cdab"

run_test "Byte swap 16 - pattern" \
    "$BITTER --bswap16 0xdeadbeef" \
    "0xaddeefbe"

# -----------------------------------------------------------------------------
# TEST: 64-bit word byte swap
# Each 16-bit word has its bytes swapped
# -----------------------------------------------------------------------------
run_test "Byte swap 16 - 64-bit" \
    "$BITTER --bswap16 0x123456789abcdef0" \
    "0x34127856bc9af0de"


section "Utility Operations - Error Handling"

# -----------------------------------------------------------------------------
# TEST: Mask requires exactly 1 argument
# -----------------------------------------------------------------------------
run_test_exit_code "Mask - no argument error" \
    "$BITTER --mask" \
    1

# -----------------------------------------------------------------------------
# TEST: Field extract requires exactly 1 value
# -----------------------------------------------------------------------------
run_test_exit_code "Field - no value error" \
    "$BITTER --field=7:0" \
    1

# -----------------------------------------------------------------------------
# TEST: Byte swap requires exactly 1 value
# -----------------------------------------------------------------------------
run_test_exit_code "Bswap - no value error" \
    "$BITTER --bswap" \
    1
