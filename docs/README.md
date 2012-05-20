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
      -i          loop and prompt for new values
      --vc=<clr>  value color (default byellow)
      --bc=<clr>  border color (default magenta)
      --ic=<clr>  bit color (default cyan)
      --nc=<clr>  normal color (terminal default)

      <value>     dec:  decdigit+
                  hex:  '0' ('x'|'X') hexdigit+
                  oct:  '0' ('o'|'O') octdigit+ | '0' octdigit+
                  bin:  '0' ('b'|'B') bindigit+
                  bits: comma separated and/or ranges
                        2,6,13-17,30

      <clr>       default, black, red, green, yellow
                  blue, magenta, cyan, white
                  NOTE: prefix a 'b' for bright (i.e. byellow)

Screenshot
----------

![bitter](https://github.com/insanum/bitter/raw/master/docs/bitter.png)

