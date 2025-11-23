
# bitter

Which bits are set?

## Features

- **Bit Visualization**: Colorized display showing which bits are set
- **Multiple Input Formats**: Decimal, hex, octal, binary, and bit specifications
- **32/64/128-bit Support**: Automatically scales to value size
- **Bitwise Operations**: NOT, OR, AND, XOR, XNOR, DIFF with visual output
- **Field Definitions**: Name and extract bit fields from register values
- **Expression Evaluation**: Evaluate bitwise expressions safely
- **Interactive REPL**: Explore values interactively
- **Custom Output Formats**: Format output for scripting and logging
- **Pipeline Support**: Read values from stdin

## Installation

```bash
% git clone https://github.com/insanum/bitter.git
% cd bitter
% chmod +x bitter
# Optionally add to PATH or create alias
```

## Usage

```bash
% bitter -h
Usage: bitter [<args>] [<value> ...]

  -h                this text
  -n                no colors
  -a                ascii drawing
  -b                reset start bit label for each argument
  -c                compact single-line output (same as --compact)
  --sb=<bit>        start bit label (default 0)
  --vc=<clr>        value color (default byellow)
  --bc=<clr>        border color (default magenta)
  --ic=<clr>        bit color (default red)
  --nc=<clr>        normal color (cyan)
  --theme=<t>       color theme: dark (default), light

  Bitwise operations:
  --not             invert bits: NOT <val>
  --or              bitwise OR:  <val1> OR <val2>
  --and             bitwise AND: <val1> AND <val2>
  --xor             bitwise XOR: <val1> XOR <val2> (bits that differ)
  --xnor            bitwise XNOR: <val1> XNOR <val2> (bits that match)
  --diff            show both values with changed bits highlighted

  Field definitions:
  --def=<fields>    define bit fields inline
                    format: [MSB:LSB]=NAME or [BIT]=NAME
                    example: --def="[31:24]=STATUS,[7:0]=DATA"
  --regfile=<file>  load field definitions from file
                    file format: one field per line, # for comments

  Utility operations:
  --mask            generate mask from bit spec (output hex only)
                    example: --mask 4,7-11,31 -> 0x80000f90
  --mask-inv        generate inverted mask from bit spec
                    example: --mask-inv 4,7-11,31 -> 0x7ffff06f
  --field=<spec>    extract field value from input
                    spec: MSB:LSB or BIT
                    example: --field=23:16 0xDEADBEEF -> 0xad (173)
  --bswap           swap byte order (endian swap)
                    example: --bswap 0x12345678 -> 0x78563412
  --bswap16         swap bytes within 16-bit words
                    example: --bswap16 0x12345678 -> 0x34127856

  Display options:
  --signed          show signed integer interpretation
  --stats           show bit statistics (popcount, leading/trailing zeros)
  --dec             show decimal value
  --oct             show octal value
  --bin             show binary value
  --width=<N>       force display width (8, 16, 32, 64, 128)
  --compact         compact single-line output with binary and stats, example:
                    0xdeadbeef = 11011110_... (3735928559) [pop:24 hi:31 lo:0]
  --format=<fmt>    custom output format string
                    field specifiers: %h hex
                                      %H hex (no 0x)
                                      %d decimal
                                      %s signed,
                                      %o octal
                                      %O octal (no 0o)
                                      %b binary
                                      %B binary (no 0b)
                                      %p popcount
                                      %hi highest bit
                                      %lo lowest bit
                                      %lz leading zeros
                                      %tz trailing zeros
                                      %w width
                                      %% literal %
                    example: --format="%h (%d)" -> 0xdeadbeef (3735928559)
                    example: --format="%h,%d,%p" -> 0xdeadbeef,3735928559,24

  Bit manipulation:
  --shl=<N>         shift left by N bits
  --shr=<N>         shift right by N bits
  --rol=<N>         rotate left by N bits
  --ror=<N>         rotate right by N bits
  --set=<bits>      set specified bits (e.g., --set=0,4-7)
  --clear=<bits>    clear specified bits (e.g., --clear=31)

  Expression evaluation:
  --expr=<expr>     evaluate bitwise expression and display result
                    supported: | & ^ ~ << >> + - * // % ()
                    integers: decimal, 0x hex, 0o octal, 0b binary
                    example: --expr="(0xff << 8) | 0x12"
                    example: --expr="0xdeadbeef & ~0xff"

  Interactive mode:
  --repl            start interactive REPL mode
                    commands: :help, :quit, :expr, :or, :and, :xor, :not,
                              :diff, :def, :load, :fields, :clear, :compact,
                              :format, :stats, :theme

  Standard input support:
  Values can be piped via <stdin>: echo "0xff 0x1234" | bitter

  <value>           dec:  [0-9]+
                    hex:  '0' ('x'|'X') [0-9a-f]+
                    oct:  '0' ('o'|'O') [0-7]+
                    bin:  '0' ('b'|'B') [0-1]+
                    bits: comma separated and/or ranges
                          2,6,13-17,30

  <clr>             default, black, red, green, yellow
                    blue, magenta, cyan, white
                    (prefix a 'b' for bright e.g., byellow)

```

## Examples

### Basic Usage

Display a hex value:

```bash
% bitter 0xdeadbeef
0xdeadbeef
┌────────┬────────┬────────┬────────┐
│11011110│10101101│10111110│11101111│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘
```

Display from bit specification (set bits 0, 4-7):

```bash
% bitter 0,4-7
0x000000f1
```

### Bitwise Operations

Show which bits differ between two values:

```bash
% bitter --diff 0xff00ff00 0x00ff00ff
DIFF (changed bits highlighted):
0xff00ff00
┌────────┬────────┬────────┬────────┐
│11111111│00000000│11111111│00000000│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘
vs
0x00ff00ff
┌────────┬────────┬────────┬────────┐
│00000000│11111111│00000000│11111111│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘
XOR (bits that differ):
0xffffffff
...
```

### Field Definitions

Define and display named bit fields:

```bash
% bitter --def="[31:16]=DEVICE_ID,[15:0]=VENDOR_ID" 0xdead1234
0xdead1234
┌────────┬────────┬────────┬────────┐
│11011110│10101101│00010010│00110100│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘

Fields:
  DEVICE_ID [31:16] = 0xdead (57005)
  VENDOR_ID [15:0]  = 0x1234 (4660)
```

Extract a specific field:

```bash
% bitter --field=23:16 0xdeadbeef
bits[23:16] = 0xad (173)
```

### Display Options

Compact single-line output:

```bash
% bitter --compact 0xdeadbeef
0xdeadbeef = 11011110_10101101_10111110_11101111 (3735928559) [pop:24 hi:31 lo:0]
```

Custom format for scripting:

```bash
% bitter --format="%h,%d,%p" 0xdeadbeef
0xdeadbeef,3735928559,24
```

Show bit statistics:

```bash
% bitter --stats 0xdeadbeef
0xdeadbeef
┌────────┬────────┬────────┬────────┐
│11011110│10101101│10111110│11101111│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘

Statistics:
  popcount      = 24
  leading zeros = 0
  trailing zeros= 0
  highest set   = 31
  lowest set    = 0
```

### Expression Evaluation

Evaluate bitwise expressions:

```bash
% bitter --expr="(0xff << 8) | 0x12"
0x0000ff12
┌────────┬────────┬────────┬────────┐
│00000000│00000000│11111111│00010010│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘
```

Create a mask and apply it:

```bash
% bitter --expr="0xdeadbeef & ~0xff"
0xdeadbe00
```

### Interactive REPL

```bash
% bitter --repl
bitter REPL - type :help for commands, :quit to exit
bitter> 0xff
0x000000ff
┌────────┬────────┬────────┬────────┐
│00000000│00000000│00000000│11111111│
├────────┼────────┼────────┼────────┤
│33222222│22221111│11111100│00000000│
│10987654│32109876│54321098│76543210│
└────────┴────────┴────────┴────────┘
bitter> :def [7:0]=DATA,[15:8]=STATUS
Defined 2 field(s).
bitter> :compact on
Compact mode: on
bitter> 0x1234
0x00001234 = 00000000_00000000_00010010_00110100 (4660) [pop:5 hi:12 lo:2]
bitter> :expr 0xff << 8
0x0000ff00 = 00000000_00000000_11111111_00000000 (65280) [pop:8 hi:15 lo:8]
bitter> :quit
Goodbye!
```

### Pipeline Integration

Read values from stdin:

```bash
% echo "0xff 0xaa" | bitter --compact
0x000000ff = 00000000_00000000_00000000_11111111 (255) [pop:8 hi:7 lo:0]
0x000000aa = 00000000_00000000_00000000_10101010 (170) [pop:4 hi:7 lo:1]
```

Extract register value from log and display:

```bash
% grep "REG=" debug.log | cut -d= -f2 | bitter --format="%h (pop=%p)"
```

## Testing

A comprehensive test suite is included:

```bash
% ./test/run_tests.sh        # Run all tests
% ./test/run_tests.sh -q     # Quiet mode (failures only)
% ./test/run_tests.sh -v     # Verbose mode
```

The test files in `test/` are heavily commented and serve as additional
documentation with usage examples for every feature.

