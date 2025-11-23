#!/bin/bash
#
# test_08_repl.sh - REPL Mode Tests
#
# These tests verify the interactive REPL mode (--repl):
# - Basic value display
# - Commands: :help, :quit, :expr, :or, :and, :xor, :not, :diff
# - Field management: :def, :load, :fields, :clear
# - Display toggles: :compact, :format, :stats, :theme
#
# The REPL provides an interactive session for exploring register values
# without restarting bitz for each command.
#
# EXAMPLES:
#   $ bitz --repl
#   bitz> 0xff                      # Display value
#   bitz> :expr 0xff << 8           # Evaluate expression
#   bitz> :or 0xf0 0x0f             # Bitwise OR
#   bitz> :def [7:0]=DATA           # Define field
#   bitz> :compact on               # Enable compact mode
#   bitz> :quit                     # Exit REPL
#

section "REPL Mode - Basic Operation"

# -----------------------------------------------------------------------------
# TEST: REPL starts and shows welcome message
# -----------------------------------------------------------------------------
run_test "REPL - shows welcome message" \
    "echo ':quit' | $BITZ --repl" \
    "bitz REPL"

run_test "REPL - shows help hint" \
    "echo ':quit' | $BITZ --repl" \
    ":help"

run_test "REPL - shows goodbye on quit" \
    "echo ':quit' | $BITZ --repl" \
    "Goodbye"

# -----------------------------------------------------------------------------
# TEST: Basic value display in REPL
# -----------------------------------------------------------------------------
run_test "REPL - display hex value" \
    "echo -e '0xff\n:quit' | $BITZ -n --repl" \
    "0x000000ff"

run_test "REPL - display decimal value" \
    "echo -e '255\n:quit' | $BITZ -n --repl" \
    "0x000000ff"

run_test "REPL - display multiple values" \
    "echo -e '0xff\n0xaa\n:quit' | $BITZ -n --repl | grep -c '0x0000'" \
    "2"


section "REPL Mode - Help Command"

# -----------------------------------------------------------------------------
# TEST: :help command shows available commands
# -----------------------------------------------------------------------------
run_test "REPL - :help shows commands" \
    "echo -e ':help\n:quit' | $BITZ -n --repl" \
    "Commands:"

run_test "REPL - :help shows :expr" \
    "echo -e ':help\n:quit' | $BITZ -n --repl" \
    ":expr"

run_test "REPL - :help shows :def" \
    "echo -e ':help\n:quit' | $BITZ -n --repl" \
    ":def"

run_test "REPL - :help shows :quit" \
    "echo -e ':help\n:quit' | $BITZ -n --repl" \
    ":quit"

run_test "REPL - :h shortcut works" \
    "echo -e ':h\n:quit' | $BITZ -n --repl" \
    "Commands:"

run_test "REPL - :? shortcut works" \
    "echo -e ':?\n:quit' | $BITZ -n --repl" \
    "Commands:"


section "REPL Mode - Quit Command"

# -----------------------------------------------------------------------------
# TEST: :quit and :q commands exit REPL
# -----------------------------------------------------------------------------
run_test "REPL - :quit exits" \
    "echo ':quit' | $BITZ -n --repl" \
    "Goodbye"

run_test "REPL - :q shortcut exits" \
    "echo ':q' | $BITZ -n --repl" \
    "Goodbye"


section "REPL Mode - Expression Command"

# -----------------------------------------------------------------------------
# TEST: :expr evaluates bitwise expressions
# Same expression syntax as --expr option
# -----------------------------------------------------------------------------
run_test "REPL - :expr basic" \
    "echo -e ':expr 0xff << 8\n:quit' | $BITZ -n --repl" \
    "0x0000ff00"

run_test "REPL - :expr OR" \
    "echo -e ':expr 0xf0 | 0x0f\n:quit' | $BITZ -n --repl" \
    "0x000000ff"

run_test "REPL - :expr complex" \
    "echo -e ':expr (0xff << 8) | 0x12\n:quit' | $BITZ -n --repl" \
    "0x0000ff12"

run_test "REPL - :expr error handling" \
    "echo -e ':expr invalid\n:quit' | $BITZ -n --repl" \
    "ERROR"


section "REPL Mode - Bitwise Operations"

# -----------------------------------------------------------------------------
# TEST: :or command performs bitwise OR on two values
# -----------------------------------------------------------------------------
run_test "REPL - :or command" \
    "echo -e ':or 0xf0 0x0f\n:quit' | $BITZ -n --repl" \
    "0x000000ff"

run_test "REPL - :or shows label" \
    "echo -e ':or 0xf0 0x0f\n:quit' | $BITZ -n --repl" \
    "OR:"

run_test "REPL - :or error with 1 value" \
    "echo -e ':or 0xff\n:quit' | $BITZ -n --repl" \
    "Usage:"

# -----------------------------------------------------------------------------
# TEST: :and command performs bitwise AND on two values
# -----------------------------------------------------------------------------
run_test "REPL - :and command" \
    "echo -e ':and 0xff 0x0f\n:quit' | $BITZ -n --repl" \
    "0x0000000f"

run_test "REPL - :and shows label" \
    "echo -e ':and 0xff 0x0f\n:quit' | $BITZ -n --repl" \
    "AND:"

# -----------------------------------------------------------------------------
# TEST: :xor command performs bitwise XOR on two values
# -----------------------------------------------------------------------------
run_test "REPL - :xor command" \
    "echo -e ':xor 0xff 0xaa\n:quit' | $BITZ -n --repl" \
    "0x00000055"

run_test "REPL - :xor shows label" \
    "echo -e ':xor 0xff 0xaa\n:quit' | $BITZ -n --repl" \
    "XOR:"

# -----------------------------------------------------------------------------
# TEST: :not command performs bitwise NOT on a value
# -----------------------------------------------------------------------------
run_test "REPL - :not command" \
    "echo -e ':not 0x0f\n:quit' | $BITZ -n --repl" \
    "0xfffffff0"

run_test "REPL - :not shows label" \
    "echo -e ':not 0xff\n:quit' | $BITZ -n --repl" \
    "NOT:"

# -----------------------------------------------------------------------------
# TEST: :diff command shows visual difference between two values
# -----------------------------------------------------------------------------
run_test "REPL - :diff command" \
    "echo -e ':diff 0xff 0xaa\n:quit' | $BITZ -n --repl" \
    "DIFF"

run_test "REPL - :diff shows vs" \
    "echo -e ':diff 0xff 0xaa\n:quit' | $BITZ -n --repl" \
    "vs"

run_test "REPL - :diff shows XOR" \
    "echo -e ':diff 0xff 0xaa\n:quit' | $BITZ -n --repl" \
    "XOR (bits that differ)"


section "REPL Mode - Field Management"

# -----------------------------------------------------------------------------
# TEST: :def command defines fields
# Same syntax as --def option
# -----------------------------------------------------------------------------
run_test "REPL - :def defines field" \
    "echo -e ':def [7:0]=DATA\n:quit' | $BITZ -n --repl" \
    "Defined 1 field"

run_test "REPL - :def multiple fields" \
    "echo -e ':def [15:8]=STATUS,[7:0]=DATA\n:quit' | $BITZ -n --repl" \
    "Defined 2 field"

run_test "REPL - :def then display value shows field" \
    "echo -e ':def [7:0]=DATA\n0x12\n:quit' | $BITZ -n --repl" \
    "DATA"

# -----------------------------------------------------------------------------
# TEST: :fields command shows current field definitions
# -----------------------------------------------------------------------------
run_test "REPL - :fields shows no fields initially" \
    "echo -e ':fields\n:quit' | $BITZ -n --repl" \
    "No fields defined"

run_test "REPL - :fields after :def" \
    "echo -e ':def [7:0]=DATA\n:fields\n:quit' | $BITZ -n --repl" \
    "DATA"

# -----------------------------------------------------------------------------
# TEST: :clear command clears field definitions
# -----------------------------------------------------------------------------
run_test "REPL - :clear clears fields" \
    "echo -e ':def [7:0]=DATA\n:clear\n:fields\n:quit' | $BITZ -n --repl" \
    "No fields defined"

run_test "REPL - :clear shows confirmation" \
    "echo -e ':clear\n:quit' | $BITZ -n --repl" \
    "cleared"

# -----------------------------------------------------------------------------
# TEST: :load command loads fields from file
# -----------------------------------------------------------------------------
TEMP_REGFILE="/tmp/bitz_repl_test.def"
echo -e "[31:16]=ID\n[15:0]=VALUE" > "$TEMP_REGFILE"

run_test "REPL - :load loads file" \
    "echo -e ':load $TEMP_REGFILE\n:quit' | $BITZ -n --repl" \
    "Loaded 2 field"

run_test "REPL - :load fields are usable" \
    "echo -e ':load $TEMP_REGFILE\n0xdead1234\n:quit' | $BITZ -n --repl" \
    "ID"

rm -f "$TEMP_REGFILE"


section "REPL Mode - Display Toggles"

# -----------------------------------------------------------------------------
# TEST: :compact command toggles compact mode
# -----------------------------------------------------------------------------
run_test "REPL - :compact toggles on" \
    "echo -e ':compact\n:quit' | $BITZ -n --repl" \
    "Compact mode: on"

run_test "REPL - :compact on explicit" \
    "echo -e ':compact on\n:quit' | $BITZ -n --repl" \
    "Compact mode: on"

run_test "REPL - :compact off explicit" \
    "echo -e ':compact off\n:quit' | $BITZ -n --repl" \
    "Compact mode: off"

run_test "REPL - :compact affects display" \
    "echo -e ':compact on\n0xff\n:quit' | $BITZ -n --repl" \
    "pop:"

# -----------------------------------------------------------------------------
# TEST: :stats command toggles statistics display
# -----------------------------------------------------------------------------
run_test "REPL - :stats toggles on" \
    "echo -e ':stats\n:quit' | $BITZ -n --repl" \
    "Stats display: on"

run_test "REPL - :stats on explicit" \
    "echo -e ':stats on\n:quit' | $BITZ -n --repl" \
    "Stats display: on"

run_test "REPL - :stats affects display" \
    "echo -e ':stats on\n0xff\n:quit' | $BITZ -n --repl" \
    "popcount"

# -----------------------------------------------------------------------------
# TEST: :format command sets custom output format
# -----------------------------------------------------------------------------
run_test "REPL - :format sets format" \
    "echo -e ':format %h (%d)\n:quit' | $BITZ -n --repl" \
    "Format set"

run_test "REPL - :format affects display" \
    "echo -e ':format %h (%d)\n0xff\n:quit' | $BITZ -n --repl" \
    "0x000000ff (255)"

run_test "REPL - :format without args clears format" \
    "echo -e ':format %h\n:format\n:quit' | $BITZ -n --repl" \
    "Format cleared"

# -----------------------------------------------------------------------------
# TEST: :theme command changes color theme
# -----------------------------------------------------------------------------
run_test "REPL - :theme dark" \
    "echo -e ':theme dark\n:quit' | $BITZ -n --repl" \
    "Theme set to: dark"

run_test "REPL - :theme light" \
    "echo -e ':theme light\n:quit' | $BITZ -n --repl" \
    "Theme set to: light"

run_test "REPL - :theme invalid" \
    "echo -e ':theme invalid\n:quit' | $BITZ -n --repl" \
    "Unknown theme"


section "REPL Mode - Error Handling"

# -----------------------------------------------------------------------------
# TEST: Unknown commands show error
# -----------------------------------------------------------------------------
run_test "REPL - unknown command error" \
    "echo -e ':badcommand\n:quit' | $BITZ -n --repl" \
    "Unknown command"

# -----------------------------------------------------------------------------
# TEST: Invalid values show error
# -----------------------------------------------------------------------------
run_test "REPL - invalid value error" \
    "echo -e 'notavalue\n:quit' | $BITZ -n --repl" \
    "ERROR"


section "REPL Mode - Initial Fields from Command Line"

# -----------------------------------------------------------------------------
# TEST: Fields defined with --def are available in REPL
# -----------------------------------------------------------------------------
run_test "REPL - initial fields from --def" \
    "echo -e '0x1234\n:quit' | $BITZ -n '--def=[7:0]=DATA' --repl" \
    "DATA"

run_test "REPL - :fields shows initial fields" \
    "echo -e ':fields\n:quit' | $BITZ -n '--def=[7:0]=DATA' --repl" \
    "DATA"
