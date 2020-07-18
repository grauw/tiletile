Tile²
=====

Copyright 2016 Laurens Holst

Project information
-------------------

Tile² game engine

  * Author: Laurens Holst <laurens@grauw.nl>
  * Site: <http://www.grauw.nl/projects/tiletile/>
  * Source: <https://hg.sr.ht/~grauw/tiletile>
  * Support: <https://www.msx.org/forum/msx-talk/development/grauw%E2%80%99s-rpg-in-development>
  * License: Simplified BSD License (code), CC BY-NC-ND (art, music, story, etc.)


System requirements
-------------------

  * MSX2+, MSX turboR
  * 64K main RAM
  * 128K video RAM
  * 128K ASCII8 ROM


Development information
-----------------------

Tile² is free and open source software. If you want to contribute to the
project you are very welcome to. Please contact me at any one of the places
mentioned in the project information section.

You are also free to re-use code for your own projects, provided you abide by
the license terms.

Tile² depends on the library project Neonlib; it is recommended to clone the
project with Mercurial so they will automatically be pulled in at the correct
version, otherwise you have to download them manually:

    hg clone https://hg.sr.ht/~grauw/tiletile

Building the project is easy on all modern desktop platforms. On MacOS and
Linux, simply invoke `make` to build the binary and symbol files into the
`bin` directory:

    make

Windows users can open the `Makefile` and build by pasting the line in the
`node_modules` and `all` targets into the Windows command prompt.

To launch the build in openMSX after building, invoke the `make run` command.

Note that the [glass](http://www.grauw.nl/projects/glass/) assembler which is
embedded in the project requires [Java 8](http://java.com/getjava). To check
your Java version, invoke the `java -version` command.

Additionally, the conversion tools are written in JavaScript for Node.js.
You need to have Node.js and NPM installed.
