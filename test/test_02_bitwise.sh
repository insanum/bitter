#!/bin/bash
#
# test_02_bitwise.sh - Bitwise Operation Tests
#
# These tests verify the bitwise operations:
# - NOT: Inverts all bits
# - OR: Combines bits from two values
# - AND: Masks bits present in both values
# - XOR: Shows bits that differ between values
# - XNOR: Shows bits that match between values
# - DIFF: Visual comparison with changed bits highlighted
#
# EXAMPLES:
#   bitter --not 0xff              # Invert bits: ~0xff = 0xffffff00
#   bitter --or 0xf0 0x0f          # OR: 0xf0 | 0x0f = 0xff
#   bitter --and 0xff 0x0f         # AND: 0xff & 0x0f = 0x0f
#   bitter --xor 0xff 0xaa         # XOR: 0xff ^ 0xaa = 0x55
#   bitter --xnor 0xff 0xaa        # XNOR: ~(0xff ^ 0xaa) = 0xffffffaa
#   bitter --diff 0xff 0xaa        # Visual diff showing changed bits
#

section "Bitwise Operations - NOT"

# -----------------------------------------------------------------------------
# TEST: NOT operation (--not)
# Inverts all bits in a value
# Result width matches input width (32-bit input -> 32-bit mask)
# Example: NOT 0xff = 0xffffff00 (in 32-bit)
# -----------------------------------------------------------------------------
run_test "NOT - invert byte" \
    "$BITTER -n --not 0xff" \
    "0xffffff00"

run_test "NOT - invert zero" \
    "$BITTER -n --not 0x0" \
    "0xffffffff"

run_test "NOT - invert all ones" \
    "$BITTER -n --not 0xffffffff" \
    "0x00000000"

run_test "NOT - invert pattern" \
    "$BITTER -n --not 0xaa" \
    "0xffffff55"

run_test "NOT - shows NOT label" \
    "$BITTER -n --not 0xff" \
    "NOT:"

# -----------------------------------------------------------------------------
# TEST: NOT with 64-bit values
# When input is 64-bit, mask is also 64-bit
# -----------------------------------------------------------------------------
run_test "NOT - 64-bit value" \
    "$BITTER -n --not 0x0000000100000000" \
    "0xfffffffeffffffff"


section "Bitwise Operations - OR"

# -----------------------------------------------------------------------------
# TEST: OR operation (--or)
# Combines bits from two values (union)
# A bit is set if it's set in EITHER input
# Example: 0xf0 | 0x0f = 0xff
# -----------------------------------------------------------------------------
run_test "OR - combine nibbles" \
    "$BITTER -n --or 0xf0 0x0f" \
    "0x000000ff"

run_test "OR - same values" \
    "$BITTER -n --or 0xff 0xff" \
    "0x000000ff"

run_test "OR - zero with value" \
    "$BITTER -n --or 0x00 0xff" \
    "0x000000ff"

run_test "OR - overlapping bits" \
    "$BITTER -n --or 0x0f 0x07" \
    "0x0000000f"

run_test "OR - shows OR label" \
    "$BITTER -n --or 0xf0 0x0f" \
    "OR:"

# -----------------------------------------------------------------------------
# TEST: OR requires exactly 2 values
# -----------------------------------------------------------------------------
run_test_exit_code "OR - error with 1 value" \
    "$BITTER --or 0xff" \
    1


section "Bitwise Operations - AND"

# -----------------------------------------------------------------------------
# TEST: AND operation (--and)
# Masks bits present in both values (intersection)
# A bit is set only if it's set in BOTH inputs
# Example: 0xff & 0x0f = 0x0f
# -----------------------------------------------------------------------------
run_test "AND - mask lower nibble" \
    "$BITTER -n --and 0xff 0x0f" \
    "0x0000000f"

run_test "AND - no overlap" \
    "$BITTER -n --and 0xf0 0x0f" \
    "0x00000000"

run_test "AND - same values" \
    "$BITTER -n --and 0xff 0xff" \
    "0x000000ff"

run_test "AND - with zero" \
    "$BITTER -n --and 0xff 0x00" \
    "0x00000000"

run_test "AND - partial overlap" \
    "$BITTER -n --and 0x0f 0x07" \
    "0x00000007"

run_test "AND - shows AND label" \
    "$BITTER -n --and 0xff 0x0f" \
    "AND:"


section "Bitwise Operations - XOR"

# -----------------------------------------------------------------------------
# TEST: XOR operation (--xor)
# Shows bits that differ between two values
# A bit is set if it's set in ONE input but not the other
# Example: 0xff ^ 0xaa = 0x55 (alternating bits differ)
# Useful for finding which bits changed between two register values
# -----------------------------------------------------------------------------
run_test "XOR - alternating pattern" \
    "$BITTER -n --xor 0xff 0xaa" \
    "0x00000055"

run_test "XOR - same values (no diff)" \
    "$BITTER -n --xor 0xff 0xff" \
    "0x00000000"

run_test "XOR - completely different" \
    "$BITTER -n --xor 0xffffffff 0x00000000" \
    "0xffffffff"

run_test "XOR - single bit change" \
    "$BITTER -n --xor 0xff 0xfe" \
    "0x00000001"

run_test "XOR - shows XOR label" \
    "$BITTER -n --xor 0xff 0xaa" \
    "XOR:"


section "Bitwise Operations - XNOR"

# -----------------------------------------------------------------------------
# TEST: XNOR operation (--xnor)
# Shows bits that match between two values (inverse of XOR)
# A bit is set if it has the SAME value in both inputs
# Example: XNOR(0xff, 0xaa) = ~(0xff ^ 0xaa) = ~0x55 = 0xffffffaa
# Useful for finding which bits stayed the same
# -----------------------------------------------------------------------------
run_test "XNOR - alternating pattern" \
    "$BITTER -n --xnor 0xff 0xaa" \
    "0xffffffaa"

run_test "XNOR - same values (all match)" \
    "$BITTER -n --xnor 0xff 0xff" \
    "0xffffffff"

run_test "XNOR - completely different" \
    "$BITTER -n --xnor 0xffffffff 0x00000000" \
    "0x00000000"

run_test "XNOR - shows XNOR label" \
    "$BITTER -n --xnor 0xff 0xaa" \
    "XNOR:"


section "Bitwise Operations - DIFF"

# -----------------------------------------------------------------------------
# TEST: DIFF operation (--diff)
# Visual comparison showing both values with changed bits highlighted
# Shows:
#   1. First value with changed bits highlighted
#   2. Second value with changed bits highlighted
#   3. XOR result showing which bits differ
# Extremely useful for comparing register values before/after an operation
# -----------------------------------------------------------------------------
run_test "DIFF - shows both values" \
    "$BITTER -n --diff 0xff 0xaa | grep -c '0x'" \
    "3"

run_test "DIFF - shows 'DIFF' label" \
    "$BITTER -n --diff 0xff 0xaa" \
    "DIFF"

run_test "DIFF - shows 'vs' separator" \
    "$BITTER -n --diff 0xff 0xaa" \
    "vs"

run_test "DIFF - shows XOR result" \
    "$BITTER -n --diff 0xff 0xaa" \
    "XOR (bits that differ)"

run_test "DIFF - displays first value" \
    "$BITTER -n --diff 0xff 0xaa" \
    "0x000000ff"

run_test "DIFF - displays second value" \
    "$BITTER -n --diff 0xff 0xaa" \
    "0x000000aa"

run_test "DIFF - displays XOR value" \
    "$BITTER -n --diff 0xff 0xaa" \
    "0x00000055"


section "Bitwise Operations - Mixed Width"

# -----------------------------------------------------------------------------
# TEST: Operations with different width values
# When operands have different widths, result uses larger width
# Example: 32-bit OR 64-bit -> 64-bit result
# -----------------------------------------------------------------------------
run_test "OR - 32-bit with 64-bit" \
    "$BITTER -n --or 0xffffffff 0x100000000" \
    "0x00000001ffffffff"

run_test "XOR - mixed widths" \
    "$BITTER -n --xor 0xff 0x100000000000000ff" \
    "0x00000000000000010000000000000000"
