# lmc
[![Build Status](https://api.travis-ci.org/tcort/lmc.png?branch=master)](http://travis-ci.org/tcort/lmc)

LMC stands for Little Man Computer. It was created in 1965 by Dr. Stuart
Madnick as a way to illustrate the basic features of a programmable computer.

This repository contains an implementation of a virtual LMC as well as an
assembler to compile simple programs into byte code that can be executed
by the virtual machine.

## Requirements

* C compiler and standard build tools (make, sh, autoconf/automake, ...).
* lex or flex
* yacc or bison

## Building

Use the following commands to build, test, and install LMC.

    ./configure
    make
    make check
    make install

## Requirements for Cross Compiling (Target: mingw32)

* Cross toolchain (ex: mingw32 on Debian)
* lex or flex
* yacc or bison
* nsis (for generating an installer)
* wine (for running the test suite)

## Cross Compiling (Target: mingw32)

Use the follow commands to cross compile LMC, run the test suite under wine,
and generate an installer exe:

    ./configure --host=i586-mingw32msvc
    make
    make check
    makensis lmc.nsi

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

