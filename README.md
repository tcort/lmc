# lmc
[![Build Status](https://api.travis-ci.org/tcort/lmc.png?branch=master)](http://travis-ci.org/tcort/lmc)

LMC stands for Little Man Computer. It was created in 1965 by Dr. Stuart
Madnick as a way to illustrate the basic features of a programmable computer.

This repository contains an implementation of a virtual LMC as well as an
assembler to compile simple programs into byte code that can be executed
by the virtual machine.

See the TODO file for details about my future plans.

## Requirements

* C compiler and standard build tools (make, sh, ...).
* lex or flex
* yacc or bison
* NSIS (only for building the Windows installer).

## Building

Use the following commands to build, test, and install LMC.

    ./configure
    make
    make check
    make install

## Cross Compiling (Target: Windows Installer)

Use the follow commands to cross compile LMC and generate an installer
suitable for Windows.

    ./configure --host=i686-pc-mingw32
    make
    makensis lmc.nsi

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

