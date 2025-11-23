#!/bin/bash
#
# test_07_expression.sh - Expression Evaluation Tests
#
# These tests verify the expression evaluation feature (--expr):
# - Bitwise operators: | & ^ ~
# - Shift operators: << >>
# - Arithmetic operators: + - * // %
# - Parentheses for grouping
# - Multiple number formats in expressions
# - Security: rejection of unsafe operations
#
# The expression evaluator uses Python's AST module for safe evaluation,
# preventing code injection attacks while allowing useful calculations.
#
# EXAMPLES:
#   bitter --expr="0xff << 8"              # Shift: 0xff00
#   bitter --expr="0xf0 | 0x0f"            # OR: 0xff
#   bitter --expr="0xff & 0x0f"            # AND: 0x0f
#   bitter --expr="0xff ^ 0xaa"            # XOR: 0x55
#   bitter --expr="~0xff"                  # NOT: (depends on width)
#   bitter --expr="(0xff << 8) | 0x12"     # Combined: 0xff12
#   bitter --expr="100 + 50"               # Arithmetic: 150
#

section "Expression Evaluation - Bitwise Operators"

# -----------------------------------------------------------------------------
# TEST: Bitwise OR in expression
# The | operator performs bitwise OR
# -----------------------------------------------------------------------------
run_test "Expr - bitwise OR" \
    "$BITTER -n '--expr=0xf0 | 0x0f'" \
    "0x000000ff"

run_test "Expr - OR with zero" \
    "$BITTER -n '--expr=0xff | 0x00'" \
    "0x000000ff"

run_test "Expr - OR multiple" \
    "$BITTER -n '--expr=0x01 | 0x02 | 0x04 | 0x08'" \
    "0x0000000f"

# -----------------------------------------------------------------------------
# TEST: Bitwise AND in expression
# The & operator performs bitwise AND
# -----------------------------------------------------------------------------
run_test "Expr - bitwise AND" \
    "$BITTER -n '--expr=0xff & 0x0f'" \
    "0x0000000f"

run_test "Expr - AND mask" \
    "$BITTER -n '--expr=0xdeadbeef & 0x0000ffff'" \
    "0x0000beef"

run_test "Expr - AND with all ones" \
    "$BITTER -n '--expr=0xff & 0xffffffff'" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Bitwise XOR in expression
# The ^ operator performs bitwise XOR
# -----------------------------------------------------------------------------
run_test "Expr - bitwise XOR" \
    "$BITTER -n '--expr=0xff ^ 0xaa'" \
    "0x00000055"

run_test "Expr - XOR same values" \
    "$BITTER -n '--expr=0xff ^ 0xff'" \
    "0x00000000"

run_test "Expr - XOR toggle bits" \
    "$BITTER -n '--expr=0xf0 ^ 0x0f'" \
    "0x000000ff"

# -----------------------------------------------------------------------------
# TEST: Bitwise NOT in expression
# The ~ operator performs bitwise NOT (complement)
# Note: Python's ~ on positive int gives -(n+1), so we AND with mask
# -----------------------------------------------------------------------------
run_test "Expr - bitwise NOT with mask" \
    "$BITTER -n '--expr=~0xff & 0xffffffff'" \
    "0xffffff00"

run_test "Expr - NOT zero" \
    "$BITTER -n '--expr=~0x0 & 0xffffffff'" \
    "0xffffffff"


section "Expression Evaluation - Shift Operators"

# -----------------------------------------------------------------------------
# TEST: Left shift in expression
# The << operator shifts bits left
# -----------------------------------------------------------------------------
run_test "Expr - shift left by 1" \
    "$BITTER -n '--expr=0x01 << 1'" \
    "0x00000002"

run_test "Expr - shift left by 8" \
    "$BITTER -n '--expr=0xff << 8'" \
    "0x0000ff00"

run_test "Expr - shift left by 16" \
    "$BITTER -n '--expr=0xffff << 16'" \
    "0xffff0000"

run_test "Expr - shift left into 64-bit" \
    "$BITTER -n '--expr=0xffffffff << 32'" \
    "0xffffffff00000000"

# -----------------------------------------------------------------------------
# TEST: Right shift in expression
# The >> operator shifts bits right
# -----------------------------------------------------------------------------
run_test "Expr - shift right by 1" \
    "$BITTER -n '--expr=0x02 >> 1'" \
    "0x00000001"

run_test "Expr - shift right by 8" \
    "$BITTER -n '--expr=0xff00 >> 8'" \
    "0x000000ff"

run_test "Expr - shift right by 16" \
    "$BITTER -n '--expr=0xffff0000 >> 16'" \
    "0x0000ffff"


section "Expression Evaluation - Arithmetic Operators"

# -----------------------------------------------------------------------------
# TEST: Addition
# The + operator adds values
# -----------------------------------------------------------------------------
run_test "Expr - addition" \
    "$BITTER -n '--expr=100 + 55'" \
    "0x0000009b"

run_test "Expr - addition hex" \
    "$BITTER -n '--expr=0x10 + 0x20'" \
    "0x00000030"

# -----------------------------------------------------------------------------
# TEST: Subtraction
# The - operator subtracts values
# -----------------------------------------------------------------------------
run_test "Expr - subtraction" \
    "$BITTER -n '--expr=0xff - 0x0f'" \
    "0x000000f0"

run_test "Expr - subtraction decimal" \
    "$BITTER -n '--expr=100 - 50'" \
    "0x00000032"

# -----------------------------------------------------------------------------
# TEST: Multiplication
# The * operator multiplies values
# -----------------------------------------------------------------------------
run_test "Expr - multiplication" \
    "$BITTER -n '--expr=16 * 16'" \
    "0x00000100"

run_test "Expr - multiplication hex" \
    "$BITTER -n '--expr=0x10 * 0x10'" \
    "0x00000100"

# -----------------------------------------------------------------------------
# TEST: Integer division
# The // operator performs integer division
# -----------------------------------------------------------------------------
run_test "Expr - integer division" \
    "$BITTER -n '--expr=100 // 10'" \
    "0x0000000a"

run_test "Expr - integer division truncates" \
    "$BITTER -n '--expr=100 // 7'" \
    "0x0000000e"

# -----------------------------------------------------------------------------
# TEST: Modulo
# The % operator gives remainder
# -----------------------------------------------------------------------------
run_test "Expr - modulo" \
    "$BITTER -n '--expr=100 % 7'" \
    "0x00000002"

run_test "Expr - modulo power of 2" \
    "$BITTER -n '--expr=0xff % 16'" \
    "0x0000000f"


section "Expression Evaluation - Grouping with Parentheses"

# -----------------------------------------------------------------------------
# TEST: Parentheses for grouping
# Parentheses control order of operations
# -----------------------------------------------------------------------------
run_test "Expr - parentheses shift then OR" \
    "$BITTER -n '--expr=(0xff << 8) | 0x12'" \
    "0x0000ff12"

run_test "Expr - nested parentheses" \
    "$BITTER -n '--expr=((0xf << 4) | 0xf) << 8'" \
    "0x0000ff00"

run_test "Expr - complex grouping" \
    "$BITTER -n '--expr=(0xaa | 0x55) & 0x0f'" \
    "0x0000000f"

run_test "Expr - arithmetic grouping" \
    "$BITTER -n '--expr=(10 + 5) * 2'" \
    "0x0000001e"


section "Expression Evaluation - Number Formats"

# -----------------------------------------------------------------------------
# TEST: Different number formats in expressions
# Supports: decimal, hex (0x), octal (0o), binary (0b)
# -----------------------------------------------------------------------------
run_test "Expr - decimal numbers" \
    "$BITTER -n '--expr=255'" \
    "0x000000ff"

run_test "Expr - hex numbers" \
    "$BITTER -n '--expr=0xff'" \
    "0x000000ff"

run_test "Expr - octal numbers" \
    "$BITTER -n '--expr=0o377'" \
    "0x000000ff"

run_test "Expr - binary numbers" \
    "$BITTER -n '--expr=0b11111111'" \
    "0x000000ff"

run_test "Expr - mixed formats" \
    "$BITTER -n '--expr=0xff + 255 + 0o377 + 0b11111111'" \
    "0x000003fc"


section "Expression Evaluation - Complex Expressions"

# -----------------------------------------------------------------------------
# TEST: Real-world use cases
# Common patterns used in embedded/driver programming
# -----------------------------------------------------------------------------

# Create a field value: shift value into position
run_test "Expr - create field value" \
    "$BITTER -n '--expr=(0xab << 16) | (0xcd << 8) | 0xef'" \
    "0x00abcdef"

# Extract and modify a field
run_test "Expr - clear and set field" \
    "$BITTER -n '--expr=(0xdeadbeef & ~0xff00) | (0x12 << 8)'" \
    "0xdead12ef"

# Toggle specific bits
run_test "Expr - toggle bits" \
    "$BITTER -n '--expr=0xaa ^ 0x0f'" \
    "0x000000a5"

# Align to power of 2
run_test "Expr - align down" \
    "$BITTER -n '--expr=0x1234 & ~0xfff'" \
    "0x00001000"


section "Expression Evaluation - With Other Options"

# -----------------------------------------------------------------------------
# TEST: Expression combined with display options
# Expression result can be formatted with other options
# -----------------------------------------------------------------------------
run_test "Expr with --compact" \
    "$BITTER -n --compact '--expr=0xff << 8'" \
    "pop:8"

run_test "Expr with --stats" \
    "$BITTER -n --stats '--expr=0xff'" \
    "popcount      = 8"

run_test "Expr with --format" \
    "$BITTER -n '--format=%h (%d)' '--expr=0xff + 1'" \
    "0x00000100 (256)"


section "Expression Evaluation - Security"

# -----------------------------------------------------------------------------
# TEST: Security - blocked operations
# The AST-based evaluator rejects potentially dangerous operations
# This prevents code injection attacks
# -----------------------------------------------------------------------------
run_test_exit_code "Expr - blocks function calls" \
    "$BITTER '--expr=print(1)'" \
    1

run_test_exit_code "Expr - blocks import" \
    "$BITTER '--expr=__import__(\"os\")'" \
    1

run_test "Expr - import error message" \
    "$BITTER '--expr=__import__(\"os\")' 2>&1 || true" \
    "Unsupported operation"

run_test_exit_code "Expr - blocks attribute access" \
    "$BITTER '--expr=().__class__'" \
    1


section "Expression Evaluation - Error Handling"

# -----------------------------------------------------------------------------
# TEST: Syntax errors are reported
# -----------------------------------------------------------------------------
run_test_exit_code "Expr - syntax error exits non-zero" \
    "$BITTER '--expr=0xff +'" \
    1

run_test "Expr - syntax error message" \
    "$BITTER '--expr=0xff +' 2>&1 || true" \
    "Syntax error"

run_test_exit_code "Expr - unbalanced parentheses" \
    "$BITTER '--expr=(0xff'" \
    1
