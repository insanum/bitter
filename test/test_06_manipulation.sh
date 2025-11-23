#!/bin/bash
#
# test_06_manipulation.sh - Bit Manipulation Tests
#
# These tests verify bit manipulation operations:
# - --shl: Shift left
# - --shr: Shift right
# - --rol: Rotate left
# - --ror: Rotate right
# - --set: Set specific bits
# - --clear: Clear specific bits
#
# These operations transform the input value before display.
# Multiple operations can be combined and are applied in order:
# set/clear -> shift -> rotate
#
# EXAMPLES:
#   bitter --shl=8 0xff               # Shift left: 0xff00
#   bitter --shr=4 0xff               # Shift right: 0x0f
#   bitter --rol=4 0xf0000000         # Rotate left: 0x0000000f
#   bitter --ror=4 0x0f               # Rotate right: 0xf0000000
#   bitter --set=0,4-7 0x00           # Set bits: 0xf1
#   bitter --clear=0-3 0xff           # Clear bits: 0xf0
#

section "Bit Manipulation - Shift Left (--shl)"

# -----------------------------------------------------------------------------
# TEST: Shift left operation
# Shifts all bits left by N positions
# Bits shifted out are lost, zeros fill from right
# Example: 0xff << 8 = 0xff00
# -----------------------------------------------------------------------------
run_test "Shift left - by 1" \
    "$BITTER -n --shl=1 0x01" \
    "0x00000002"

run_test "Shift left - by 4 (nibble)" \
    "$BITTER -n --shl=4 0x0f" \
    "0x000000f0"

run_test "Shift left - by 8 (byte)" \
    "$BITTER -n --shl=8 0xff" \
    "0x0000ff00"

run_test "Shift left - by 16 (word)" \
    "$BITTER -n --shl=16 0xffff" \
    "0xffff0000"

run_test "Shift left - overflow (bits lost)" \
    "$BITTER -n --shl=8 0xff000000" \
    "0x00000000"

run_test "Shift left - partial overflow" \
    "$BITTER -n --shl=4 0xf0000000" \
    "0x00000000"

run_test "Shift left - by 0 (no change)" \
    "$BITTER -n --shl=0 0xdeadbeef" \
    "0xdeadbeef"


section "Bit Manipulation - Shift Right (--shr)"

# -----------------------------------------------------------------------------
# TEST: Shift right operation
# Shifts all bits right by N positions
# Bits shifted out are lost, zeros fill from left
# Example: 0xff00 >> 8 = 0xff
# -----------------------------------------------------------------------------
run_test "Shift right - by 1" \
    "$BITTER -n --shr=1 0x02" \
    "0x00000001"

run_test "Shift right - by 4 (nibble)" \
    "$BITTER -n --shr=4 0xf0" \
    "0x0000000f"

run_test "Shift right - by 8 (byte)" \
    "$BITTER -n --shr=8 0xff00" \
    "0x000000ff"

run_test "Shift right - by 16 (word)" \
    "$BITTER -n --shr=16 0xffff0000" \
    "0x0000ffff"

run_test "Shift right - underflow (bits lost)" \
    "$BITTER -n --shr=8 0x000000ff" \
    "0x00000000"

run_test "Shift right - by 0 (no change)" \
    "$BITTER -n --shr=0 0xdeadbeef" \
    "0xdeadbeef"

run_test "Shift right - extract upper byte" \
    "$BITTER -n --shr=24 0xde000000" \
    "0x000000de"


section "Bit Manipulation - Rotate Left (--rol)"

# -----------------------------------------------------------------------------
# TEST: Rotate left operation
# Rotates all bits left by N positions within the value's width
# Bits rotated out from left come back in from right
# Example (32-bit): 0xf0000000 ROL 4 = 0x0000000f
# -----------------------------------------------------------------------------
run_test "Rotate left - by 4" \
    "$BITTER -n --rol=4 0xf0000000" \
    "0x0000000f"

run_test "Rotate left - by 8" \
    "$BITTER -n --rol=8 0xff000000" \
    "0x000000ff"

run_test "Rotate left - full rotation (32)" \
    "$BITTER -n --rol=32 0xdeadbeef" \
    "0xdeadbeef"

run_test "Rotate left - by 1" \
    "$BITTER -n --rol=1 0x80000000" \
    "0x00000001"

run_test "Rotate left - pattern" \
    "$BITTER -n --rol=4 0x12345678" \
    "0x23456781"

run_test "Rotate left - by 0 (no change)" \
    "$BITTER -n --rol=0 0xdeadbeef" \
    "0xdeadbeef"


section "Bit Manipulation - Rotate Right (--ror)"

# -----------------------------------------------------------------------------
# TEST: Rotate right operation
# Rotates all bits right by N positions within the value's width
# Bits rotated out from right come back in from left
# Example (32-bit): 0x0000000f ROR 4 = 0xf0000000
# -----------------------------------------------------------------------------
run_test "Rotate right - by 4" \
    "$BITTER -n --ror=4 0x0000000f" \
    "0xf0000000"

run_test "Rotate right - by 8" \
    "$BITTER -n --ror=8 0x000000ff" \
    "0xff000000"

run_test "Rotate right - full rotation (32)" \
    "$BITTER -n --ror=32 0xdeadbeef" \
    "0xdeadbeef"

run_test "Rotate right - by 1" \
    "$BITTER -n --ror=1 0x00000001" \
    "0x80000000"

run_test "Rotate right - pattern" \
    "$BITTER -n --ror=4 0x12345678" \
    "0x81234567"

run_test "Rotate right - by 0 (no change)" \
    "$BITTER -n --ror=0 0xdeadbeef" \
    "0xdeadbeef"


section "Bit Manipulation - Set Bits (--set)"

# -----------------------------------------------------------------------------
# TEST: Set specific bits
# Sets the specified bits to 1 (OR operation)
# Uses same bit specification format as value input
# Example: --set=0,4-7 with 0x00 = 0xf1
# -----------------------------------------------------------------------------
run_test "Set - single bit" \
    "$BITTER -n --set=0 0x00" \
    "0x00000001"

run_test "Set - multiple bits" \
    "$BITTER -n --set=0,1,2,3 0x00" \
    "0x0000000f"

run_test "Set - bit range" \
    "$BITTER -n --set=0-7 0x00" \
    "0x000000ff"

run_test "Set - mixed spec" \
    "$BITTER -n --set=0,4-7 0x00" \
    "0x000000f1"

run_test "Set - already set bits unchanged" \
    "$BITTER -n --set=0-3 0x0f" \
    "0x0000000f"

run_test "Set - add to existing value" \
    "$BITTER -n --set=4-7 0x0f" \
    "0x000000ff"

run_test "Set - high bits" \
    "$BITTER -n --set=31 0x00" \
    "0x80000000"


section "Bit Manipulation - Clear Bits (--clear)"

# -----------------------------------------------------------------------------
# TEST: Clear specific bits
# Clears the specified bits to 0 (AND with inverted mask)
# Uses same bit specification format as value input
# Example: --clear=0-3 with 0xff = 0xf0
# -----------------------------------------------------------------------------
run_test "Clear - single bit" \
    "$BITTER -n --clear=0 0xff" \
    "0x000000fe"

run_test "Clear - multiple bits" \
    "$BITTER -n --clear=0,1,2,3 0xff" \
    "0x000000f0"

run_test "Clear - bit range" \
    "$BITTER -n --clear=0-7 0xffffffff" \
    "0xffffff00"

run_test "Clear - mixed spec" \
    "$BITTER -n --clear=0,4-7 0xff" \
    "0x0000000e"

run_test "Clear - already clear bits unchanged" \
    "$BITTER -n --clear=0-3 0xf0" \
    "0x000000f0"

run_test "Clear - high bits" \
    "$BITTER -n --clear=31 0xffffffff" \
    "0x7fffffff"


section "Bit Manipulation - Combined Operations"

# -----------------------------------------------------------------------------
# TEST: Multiple operations combined
# Operations are applied in order: set/clear -> shift -> rotate
# This allows complex bit manipulations in a single command
# -----------------------------------------------------------------------------
run_test "Combined - set then shift left" \
    "$BITTER -n --set=0-7 --shl=8 0x00" \
    "0x0000ff00"

run_test "Combined - clear then shift right" \
    "$BITTER -n --clear=0-7 --shr=8 0xffffff00" \
    "0x00ffffff"

run_test "Combined - shift then rotate" \
    "$BITTER -n --shl=4 --rol=4 0x0f" \
    "0x00000f00"

run_test "Combined - set, clear, shift" \
    "$BITTER -n --set=0-3 --clear=4-7 --shl=4 0xf0" \
    "0x000000f0"

# -----------------------------------------------------------------------------
# TEST: Operations with width forcing
# Width affects rotation boundary
# -----------------------------------------------------------------------------
run_test "Rotate with width=64" \
    "$BITTER -n --width=64 --rol=32 0xffffffff" \
    "0xffffffff00000000"

run_test "Shift with width=64" \
    "$BITTER -n --width=64 --shl=32 0xffffffff" \
    "0xffffffff00000000"
