bitter
======

Which bits are set?

This simple tool is used to help determine which bits are set for a specified
value. If you do a lot of driver level programming and are constantly dealing
with register values this tool can be extremely helpful.


Usage
-----

    % bitter -h
    Usage: bitter [<args>] [<value> ...]

      -h          this text
      -n          no colors
      -a          ascii drawing
      -b          reset start bit label for each argument
      --sb=<bit>  start bit label (default 0)
      --vc=<clr>  value color (default byellow)
      --bc=<clr>  border color (default magenta)
      --ic=<clr>  bit color (default cyan)
      --nc=<clr>  normal color (terminal default)

      <value>     dec:  [0-9]+
                  hex:  '0' ('x'|'X') [0-9a-f]+
                  oct:  '0' ('o'|'O') [0-7]+
                  bin:  '0' ('b'|'B') [0-1]+
                  bits: comma separated and/or ranges
                        2,6,13-17,30

      <clr>       default, black, red, green, yellow
                  blue, magenta, cyan, white
                  NOTE: prefix a 'b' for bright (i.e. byellow)

Screenshot
----------

![bitter](https://github.com/insanum/bitter/raw/master/docs/bitter.png)

