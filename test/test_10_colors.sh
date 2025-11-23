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
#   bitz --vc=green 0xff            # Green value display
#   bitz --bc=cyan 0xff             # Cyan borders
#   bitz --ic=bred 0xff             # Bright red for set bits
#   bitz --theme=light 0xff         # Light terminal theme
#

section "Color Options - Value Color (--vc)"

# -----------------------------------------------------------------------------
# TEST: Custom value color
# Changes the color of the hex value display
# We can't easily test actual color codes, but we verify the option is accepted
# -----------------------------------------------------------------------------
run_test "Value color - green accepted" \
    "$BITZ --vc=green 0xff | head -1" \
    "0x"

run_test "Value color - bred accepted" \
    "$BITZ --vc=bred 0xff | head -1" \
    "0x"

run_test "Value color - byellow accepted" \
    "$BITZ --vc=byellow 0xff | head -1" \
    "0x"


section "Color Options - Border Color (--bc)"

# -----------------------------------------------------------------------------
# TEST: Custom border color
# Changes the color of the box-drawing characters
# -----------------------------------------------------------------------------
run_test "Border color - cyan accepted" \
    "$BITZ --bc=cyan 0xff" \
    "0x000000ff"

run_test "Border color - magenta accepted" \
    "$BITZ --bc=magenta 0xff" \
    "0x000000ff"


section "Color Options - Bit Color (--ic)"

# -----------------------------------------------------------------------------
# TEST: Custom bit color (set bits)
# Changes the color of bits that are 1
# -----------------------------------------------------------------------------
run_test "Bit color - red accepted" \
    "$BITZ --ic=red 0xff" \
    "0x000000ff"

run_test "Bit color - bgreen accepted" \
    "$BITZ --ic=bgreen 0xff" \
    "0x000000ff"


section "Color Options - Normal Color (--nc)"

# -----------------------------------------------------------------------------
# TEST: Custom normal color
# Changes the color of bits that are 0 and other normal text
# -----------------------------------------------------------------------------
run_test "Normal color - blue accepted" \
    "$BITZ --nc=blue 0xff" \
    "0x000000ff"

run_test "Normal color - white accepted" \
    "$BITZ --nc=white 0xff" \
    "0x000000ff"


section "Color Options - No Color Mode (-n)"

# -----------------------------------------------------------------------------
# TEST: No color mode
# Disables all ANSI color codes
# Essential for piping output to files or non-color terminals
# -----------------------------------------------------------------------------
run_test "No color - output readable" \
    "$BITZ -n 0xff" \
    "0x000000ff"

run_test "No color - output still correct" \
    "$BITZ -n 0xff" \
    "0x000000ff"

run_test "No color - borders still drawn" \
    "$BITZ -n 0xff" \
    "┌"

run_test "No color with ASCII - dashes drawn" \
    "$BITZ -n -a 0xff" \
    "----"


section "Color Options - Color Themes (--theme)"

# -----------------------------------------------------------------------------
# TEST: Dark theme (default)
# Optimized for dark terminal backgrounds
# Uses bright colors that stand out on dark backgrounds
# -----------------------------------------------------------------------------
run_test "Theme dark - accepted" \
    "$BITZ --theme=dark 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Light theme
# Optimized for light terminal backgrounds
# Uses darker colors that stand out on light backgrounds
# -----------------------------------------------------------------------------
run_test "Theme light - accepted" \
    "$BITZ --theme=light 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Invalid theme
# Should report error for unknown theme names
# -----------------------------------------------------------------------------
run_test_exit_code "Theme invalid - error" \
    "$BITZ --theme=invalid 0xff" \
    1

run_test "Theme invalid - error message" \
    "$BITZ --theme=invalid 0xff 2>&1 || true" \
    "Unknown theme"


section "Color Options - Combined Options"

# -----------------------------------------------------------------------------
# TEST: Multiple color options together
# All color options can be combined
# -----------------------------------------------------------------------------
run_test "Combined colors - all custom" \
    "$BITZ --vc=green --bc=blue --ic=red --nc=yellow 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Theme with override
# Individual color options override theme colors
# -----------------------------------------------------------------------------
run_test "Theme with override" \
    "$BITZ --theme=dark --vc=green 0xff" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: No color takes precedence
# -n should disable colors even if color options specified
# (This tests that -n is processed correctly)
# -----------------------------------------------------------------------------
run_test "No color with color options" \
    "$BITZ -n --vc=green 0xff" \
    "0x000000ff"


section "Color Options - All Color Names"

# -----------------------------------------------------------------------------
# TEST: Standard colors
# Verify all standard color names are accepted
# -----------------------------------------------------------------------------
run_test "Color - black" \
    "$BITZ --vc=black 0xff | head -1" \
    "0x"

run_test "Color - red" \
    "$BITZ --vc=red 0xff | head -1" \
    "0x"

run_test "Color - green" \
    "$BITZ --vc=green 0xff | head -1" \
    "0x"

run_test "Color - yellow" \
    "$BITZ --vc=yellow 0xff | head -1" \
    "0x"

run_test "Color - blue" \
    "$BITZ --vc=blue 0xff | head -1" \
    "0x"

run_test "Color - magenta" \
    "$BITZ --vc=magenta 0xff | head -1" \
    "0x"

run_test "Color - cyan" \
    "$BITZ --vc=cyan 0xff | head -1" \
    "0x"

run_test "Color - white" \
    "$BITZ --vc=white 0xff | head -1" \
    "0x"

# -----------------------------------------------------------------------------
# TEST: Bright colors (prefixed with 'b')
# -----------------------------------------------------------------------------
run_test "Color - bblack" \
    "$BITZ --vc=bblack 0xff | head -1" \
    "0x"

run_test "Color - bred" \
    "$BITZ --vc=bred 0xff | head -1" \
    "0x"

run_test "Color - bgreen" \
    "$BITZ --vc=bgreen 0xff | head -1" \
    "0x"

run_test "Color - byellow" \
    "$BITZ --vc=byellow 0xff | head -1" \
    "0x"

run_test "Color - bblue" \
    "$BITZ --vc=bblue 0xff | head -1" \
    "0x"

run_test "Color - bmagenta" \
    "$BITZ --vc=bmagenta 0xff | head -1" \
    "0x"

run_test "Color - bcyan" \
    "$BITZ --vc=bcyan 0xff | head -1" \
    "0x"

run_test "Color - bwhite" \
    "$BITZ --vc=bwhite 0xff | head -1" \
    "0x"

# -----------------------------------------------------------------------------
# TEST: Default color (empty string - terminal default)
# -----------------------------------------------------------------------------
run_test "Color - default" \
    "$BITZ --vc=default 0xff | head -1" \
    "0x"
