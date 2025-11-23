#!/bin/bash
#
# test_09_stdin.sh - Stdin/Pipeline Tests
#
# These tests verify stdin and pipeline support:
# - Reading values from stdin
# - Piping output from other commands
# - Multiple values via stdin
# - Integration with shell pipelines
#
# Stdin support allows bitz to be used in shell pipelines,
# making it easy to integrate with other tools.
#
# EXAMPLES:
#   echo "0xff" | bitz                    # Single value from stdin
#   echo "0xff 0xaa 0x55" | bitz          # Multiple values (space-separated)
#   echo -e "0xff\n0xaa" | bitz           # Multiple values (newline-separated)
#   cat values.txt | bitz                 # Values from file
#   grep "REG=" log.txt | cut -d= -f2 | bitz  # Pipeline integration
#

section "Stdin Input - Single Values"

# -----------------------------------------------------------------------------
# TEST: Read single value from stdin
# When no arguments are provided and stdin is not a TTY,
# bitz reads values from stdin
# -----------------------------------------------------------------------------
run_test "Stdin - single hex value" \
    "echo '0xff' | $BITZ -n" \
    "0x000000ff"

run_test "Stdin - single decimal value" \
    "echo '255' | $BITZ -n" \
    "0x000000ff"

run_test "Stdin - single octal value" \
    "echo '0o377' | $BITZ -n" \
    "0x000000ff"

run_test "Stdin - single binary value" \
    "echo '0b11111111' | $BITZ -n" \
    "0x000000ff"


section "Stdin Input - Multiple Values"

# -----------------------------------------------------------------------------
# TEST: Multiple values from stdin (space-separated)
# Values separated by spaces are each displayed
# -----------------------------------------------------------------------------
run_test "Stdin - space-separated values" \
    "echo '0xff 0xaa 0x55' | $BITZ -n | grep -c '0x0000'" \
    "3"

run_test "Stdin - space-separated shows each value" \
    "echo '0xff 0xaa' | $BITZ -n" \
    "0x000000aa"

# -----------------------------------------------------------------------------
# TEST: Multiple values from stdin (newline-separated)
# Values on separate lines are each displayed
# -----------------------------------------------------------------------------
run_test "Stdin - newline-separated values" \
    "echo -e '0xff\n0xaa\n0x55' | $BITZ -n | grep -c '0x0000'" \
    "3"

run_test "Stdin - newline-separated shows each value" \
    "echo -e '0xff\n0xaa' | $BITZ -n" \
    "0x000000aa"

# -----------------------------------------------------------------------------
# TEST: Mixed whitespace
# Tabs, spaces, newlines all work as separators
# -----------------------------------------------------------------------------
run_test "Stdin - tab-separated values" \
    "printf '0xff\t0xaa' | $BITZ -n | grep -c '0x0000'" \
    "2"

run_test "Stdin - mixed whitespace" \
    "echo -e '0xff  0xaa\n0x55   0x12' | $BITZ -n | grep -c '0x0000'" \
    "4"


section "Stdin Input - With Options"

# -----------------------------------------------------------------------------
# TEST: Stdin with display options
# Options work normally with stdin input
# -----------------------------------------------------------------------------
run_test "Stdin with --compact" \
    "echo '0xff' | $BITZ -n --compact" \
    "pop:8"

run_test "Stdin with --stats" \
    "echo '0xff' | $BITZ -n --stats" \
    "popcount"

run_test "Stdin with --format" \
    "echo '0xff' | $BITZ -n '--format=%h (%d)'" \
    "0x000000ff (255)"

run_test "Stdin with --signed" \
    "echo '0xffffffff' | $BITZ -n --signed" \
    "signed: -1"

# -----------------------------------------------------------------------------
# TEST: Stdin with field definitions
# -----------------------------------------------------------------------------
run_test "Stdin with --def" \
    "echo '0x1234' | $BITZ -n '--def=[7:0]=DATA'" \
    "DATA"

# -----------------------------------------------------------------------------
# TEST: Stdin with bitwise operations
# -----------------------------------------------------------------------------
run_test "Stdin with --not" \
    "echo '0x0f' | $BITZ -n --not" \
    "0xfffffff0"

run_test "Stdin with --or (2 values)" \
    "echo '0xf0 0x0f' | $BITZ -n --or" \
    "0x000000ff"


section "Stdin Input - Bit Manipulation"

# -----------------------------------------------------------------------------
# TEST: Stdin with bit manipulation options
# Transformation options work with stdin input
# -----------------------------------------------------------------------------
run_test "Stdin with --shl" \
    "echo '0xff' | $BITZ -n --shl=8" \
    "0x0000ff00"

run_test "Stdin with --shr" \
    "echo '0xff00' | $BITZ -n --shr=8" \
    "0x000000ff"

run_test "Stdin with --set" \
    "echo '0x00' | $BITZ -n --set=0-7" \
    "0x000000ff"

run_test "Stdin with --clear" \
    "echo '0xff' | $BITZ -n --clear=0-3" \
    "0x000000f0"


section "Stdin Input - Pipeline Integration"

# -----------------------------------------------------------------------------
# TEST: Pipeline with grep/cut
# Realistic pipeline scenarios
# -----------------------------------------------------------------------------
run_test "Pipeline - extract from simulated log" \
    "echo 'REG=0xdeadbeef' | cut -d= -f2 | $BITZ -n '--format=%h'" \
    "0xdeadbeef"

run_test "Pipeline - multiple values from simulated log" \
    "echo -e 'A=0xff\nB=0xaa' | cut -d= -f2 | $BITZ -n '--format=%h' | wc -l | tr -d ' '" \
    "2"

# -----------------------------------------------------------------------------
# TEST: Pipeline with awk
# Process values extracted by awk
# -----------------------------------------------------------------------------
run_test "Pipeline - awk extraction" \
    "echo 'value: 0x1234' | awk '{print \$2}' | $BITZ -n '--format=%d'" \
    "4660"

# -----------------------------------------------------------------------------
# TEST: Pipeline with xargs
# Using xargs to pass values to bitz
# Note: xargs provides arguments, not stdin
# -----------------------------------------------------------------------------
run_test "Pipeline - xargs single value" \
    "echo '0xff' | xargs $BITZ -n '--format=%h'" \
    "0x000000ff"


section "Stdin Input - Edge Cases"

# -----------------------------------------------------------------------------
# TEST: Empty stdin
# Empty input should not produce output
# -----------------------------------------------------------------------------
run_test "Stdin - empty input" \
    "echo '' | $BITZ -n '--format=%h' | wc -l | tr -d ' '" \
    "0"

# -----------------------------------------------------------------------------
# TEST: Stdin with extra whitespace
# Leading/trailing whitespace should be ignored
# -----------------------------------------------------------------------------
run_test "Stdin - leading whitespace" \
    "echo '   0xff' | $BITZ -n '--format=%h'" \
    "0x000000ff"

run_test "Stdin - trailing whitespace" \
    "echo '0xff   ' | $BITZ -n '--format=%h'" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Stdin with bit spec
# Bit specifications work via stdin
# -----------------------------------------------------------------------------
run_test "Stdin - bit spec" \
    "echo '0-7' | $BITZ -n '--format=%h'" \
    "0x000000ff"

run_test "Stdin - bit range" \
    "echo '0,4,8' | $BITZ -n '--format=%h'" \
    "0x00000111"


section "Stdin Input - Does NOT interfere with --expr"

# -----------------------------------------------------------------------------
# TEST: --expr mode should not read from stdin
# When --expr is used, stdin should be ignored
# This prevents hanging when running in non-interactive mode
# -----------------------------------------------------------------------------
run_test "Expr mode ignores stdin" \
    "echo 'garbage' | $BITZ -n '--expr=0xff + 1' '--format=%h'" \
    "0x00000100"


section "Stdin Input - Here Documents"

# -----------------------------------------------------------------------------
# TEST: Here document input
# Values can come from shell here documents
# -----------------------------------------------------------------------------
run_test "Here document - multiple values" \
    "$BITZ -n '--format=%h' <<< $'0xff\n0xaa' | wc -l | tr -d ' '" \
    "2"

run_test "Here string - single value" \
    "$BITZ -n '--format=%h' <<< '0xdeadbeef'" \
    "0xdeadbeef"
