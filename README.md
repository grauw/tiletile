Synthesix - Modular MIDI synthesizer for MSX
============================================

Copyright 2013 Laurens Holst

Project information
-------------------

Author: Laurens Holst <laurens.nospam@grauw.nl>  
Site: <https://bitbucket.org/grauw/synthesix>  
Issues: <https://bitbucket.org/grauw/synthesix/issues>
Support: <http://www.msx.org/forum/msx-talk/software/synthesix>
License: Simplified BSD License

Synthesix is synthesizer for MSX sound chips. It lets you play and tweak your
MSX sound chips in real-time, using external MIDI controllers and DAW software.

Patches are edited in a modular sound design paradigm. This architecture lets
you insert modules which perform various functions into the control chain
between your MIDI keyboard and the sound chip. This gives you great and flexible
control over the sound that is played.


System Requirements
-------------------

ROM version:

  * MSX2, MSX2+, MSX turboR and MSX1 models with V9938 VDP
  * 16kB video RAM
  * 64kB main RAM
  * 64kB Konami 4/5 ROM

DOS version:

  * MSX2, MSX2+, MSX turboR and MSX1 models with V9938 VDP
  * 16kB video RAM
  * 128kB main RAM, memory mapped


Supported output devices
------------------------

  * Konami SCC

Support for more sound chips will be added in the future.


Supported input devices
-----------------------

Synthesix currently supports the following input devices:

  * Internal MSX-MIDI (turboR GT)
  * External MSX-MIDI (µ-Pack), on all MSX models
  * Philips NMS-1205 Music Module MIDI
  * Yamaha SFG-01 / 05 FM Sound Synthesizer Unit MIDI
  * Philips NMS-1160 Music Keyboard, connected to NMS-1205
  * Toshiba HX-MU901 Music Keyboard, connected to HX-MU900 or FS-CA1
  * Yamaha YK-01/10/20 Music Keyboard, connected to HX-MU900 or FS-CA1
  * Computer alphanumeric keys

If you have another input device which you’d like to be supported, let me know
or file a ticket for it in the issue tracker.


Usage instructions
------------------

Synthesix can be loaded on an MSX using a Konami Snatcher SCC+ cartridge,
or compatible devices such as the MegaFlashROM SCC+ or the ESE Mega-SCC+
(built into One Chip MSX).


Development information
-----------------------

Synthesix is free and open source software. If you want to contribute to the
project you are very welcome to. Please contact me at any one of the places
mentioned in the project information section.

You are also free to re-use code such as the MIDI support routines for your own
projects, provided you abide by the license terms.

Label naming convention:

  * Constants: UPPERCASE
  * Variables: Class_variableName
  * Methods: Class_MethodName
  * Method-local labels: Class_MethodName_localName
