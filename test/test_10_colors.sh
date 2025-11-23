#!/bin/bash
#
# test_10_colors.sh - Color Customization Tests
#
# These tests verify color customization options:
# - --vc: Value color
# - --bc: Border color
# - --ic: Bit color (set bits)
# - --nc: Normal color
# - --theme: Color themes (dark/light)
# - -n: No color mode
#
# Colors help distinguish different parts of the output:
# - Value color: The hex value display
# - Border color: The box-drawing borders
# - Bit color: Bits that are set (1)
# - Normal color: Bits that are clear (0) and other text
#
# Available colors:
#   black, red, green, yellow, blue, magenta, cyan, white
#   Prefix with 'b' for bright: bred, bgreen, byellow, etc.
#
# EXAMPLES:
#   bitter --vc=green 0xff            # Green value display
#   bitter --bc=cyan 0xff             # Cyan borders
#   bitter --ic=bred 0xff             # Bright red for set bits
#   bitter --theme=light 0xff         # Light terminal theme
#

section "Color Options - Value Color (--vc)"

# -----------------------------------------------------------------------------
# TEST: Custom value color
# Changes the color of the hex value display
# We can't easily test actual color codes, but we verify the option is accepted
# -----------------------------------------------------------------------------
run_test "Value color - green accepted" \
    "$BITTER --vc=green 0xff | head -1" \
    "0x"

run_test "Value color - bred accepted" \
    "$BITTER --vc=bred 0xff | head -1" \
    "0x"

run_test "Value color - byellow accepted" \
    "$BITTER --vc=byellow 0xff | head -1" \
    "0x"


section "Color Options - Border Color (--bc)"

# -----------------------------------------------------------------------------
# TEST: Custom border color
# Changes the color of the box-drawing characters
# -----------------------------------------------------------------------------
run_test "Border color - cyan accepted" \
    "$BITTER --bc=cyan 0xff" \
    "0x000000ff"

run_test "Border color - magenta accepted" \
    "$BITTER --bc=magenta 0xff" \
    "0x000000ff"


section "Color Options - Bit Color (--ic)"

# -----------------------------------------------------------------------------
# TEST: Custom bit color (set bits)
# Changes the color of bits that are 1
# -----------------------------------------------------------------------------
run_test "Bit color - red accepted" \
    "$BITTER --ic=red 0xff" \
    "0x000000ff"

run_test "Bit color - bgreen accepted" \
    "$BITTER --ic=bgreen 0xff" \
    "0x000000ff"


section "Color Options - Normal Color (--nc)"

# -----------------------------------------------------------------------------
# TEST: Custom normal color
# Changes the color of bits that are 0 and other normal text
# -----------------------------------------------------------------------------
run_test "Normal color - blue accepted" \
    "$BITTER --nc=blue 0xff" \
    "0x000000ff"

run_test "Normal color - white accepted" \
    "$BITTER --nc=white 0xff" \
    "0x000000ff"


section "Color Options - No Color Mode (-n)"

# -----------------------------------------------------------------------------
# TEST: No color mode
# Disables all ANSI color codes
# Essential for piping output to files or non-color terminals
# -----------------------------------------------------------------------------
run_test "No color - output readable" \
    "$BITTER -n 0xff" \
    "0x000000ff"

run_test "No color - output still correct" \
    "$BITTER -n 0xff" \
    "0x000000ff"

run_test "No color - borders still drawn" \
    "$BITTER -n 0xff" \
    "┌"

run_test "No color with ASCII - dashes drawn" \
    "$BITTER -n -a 0xff" \
    "----"


section "Color Options - Color Themes (--theme)"

# -----------------------------------------------------------------------------
# TEST: Dark theme (default)
# Optimized for dark terminal backgrounds
# Uses bright colors that stand out on dark backgrounds
# -----------------------------------------------------------------------------
run_test "Theme dark - accepted" \
    "$BITTER --theme=dark 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Light theme
# Optimized for light terminal backgrounds
# Uses darker colors that stand out on light backgrounds
# -----------------------------------------------------------------------------
run_test "Theme light - accepted" \
    "$BITTER --theme=light 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Invalid theme
# Should report error for unknown theme names
# -----------------------------------------------------------------------------
run_test_exit_code "Theme invalid - error" \
    "$BITTER --theme=invalid 0xff" \
    1

run_test "Theme invalid - error message" \
    "$BITTER --theme=invalid 0xff 2>&1 || true" \
    "Unknown theme"


section "Color Options - Combined Options"

# -----------------------------------------------------------------------------
# TEST: Multiple color options together
# All color options can be combined
# -----------------------------------------------------------------------------
run_test "Combined colors - all custom" \
    "$BITTER --vc=green --bc=blue --ic=red --nc=yellow 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Theme with override
# Individual color options override theme colors
# -----------------------------------------------------------------------------
run_test "Theme with override" \
    "$BITTER --theme=dark --vc=green 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: No color takes precedence
# -n should disable colors even if color options specified
# (This tests that -n is processed correctly)
# -----------------------------------------------------------------------------
run_test "No color with color options" \
    "$BITTER -n --vc=green 0xff" \
    "0x000000ff"


section "Color Options - All Color Names"

# -----------------------------------------------------------------------------
# TEST: Standard colors
# Verify all standard color names are accepted
# -----------------------------------------------------------------------------
run_test "Color - black" \
    "$BITTER --vc=black 0xff | head -1" \
    "0x"

run_test "Color - red" \
    "$BITTER --vc=red 0xff | head -1" \
    "0x"

run_test "Color - green" \
    "$BITTER --vc=green 0xff | head -1" \
    "0x"

run_test "Color - yellow" \
    "$BITTER --vc=yellow 0xff | head -1" \
    "0x"

run_test "Color - blue" \
    "$BITTER --vc=blue 0xff | head -1" \
    "0x"

run_test "Color - magenta" \
    "$BITTER --vc=magenta 0xff | head -1" \
    "0x"

run_test "Color - cyan" \
    "$BITTER --vc=cyan 0xff | head -1" \
    "0x"

run_test "Color - white" \
    "$BITTER --vc=white 0xff | head -1" \
    "0x"

# -----------------------------------------------------------------------------
# TEST: Bright colors (prefixed with 'b')
# -----------------------------------------------------------------------------
run_test "Color - bblack" \
    "$BITTER --vc=bblack 0xff | head -1" \
    "0x"

run_test "Color - bred" \
    "$BITTER --vc=bred 0xff | head -1" \
    "0x"

run_test "Color - bgreen" \
    "$BITTER --vc=bgreen 0xff | head -1" \
    "0x"

run_test "Color - byellow" \
    "$BITTER --vc=byellow 0xff | head -1" \
    "0x"

run_test "Color - bblue" \
    "$BITTER --vc=bblue 0xff | head -1" \
    "0x"

run_test "Color - bmagenta" \
    "$BITTER --vc=bmagenta 0xff | head -1" \
    "0x"

run_test "Color - bcyan" \
    "$BITTER --vc=bcyan 0xff | head -1" \
    "0x"

run_test "Color - bwhite" \
    "$BITTER --vc=bwhite 0xff | head -1" \
    "0x"

# -----------------------------------------------------------------------------
# TEST: Default color (empty string - terminal default)
# -----------------------------------------------------------------------------
run_test "Color - default" \
    "$BITTER --vc=default 0xff | head -1" \
    "0x"
