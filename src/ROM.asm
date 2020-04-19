;
; Tile²
;
; Scrolling tile engine for MSX
;

	INCLUDE "Macros.asm"

DEBUG: equ 1

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
ROM_CodeBank3: equ 2
ROM_RAMInitBank: equ 3

	org 4000H

ROM_BANK0: ds ROMMapper_BANK_SIZE
ROM_BANK1: ds ROMMapper_BANK_SIZE
ROM_BANK2: ds ROMMapper_BANK_SIZE
ROM_BANK3: ds ROMMapper_BANK_SIZE

	org 8000H

ROM_DATA: ds ROMMapper_BANK_SIZE * 12

TPA_PAGE1: equ ROM_BANK1
RAM_RESIDENT: equ RAM

	SECTION ROM_BANK0

	ROMRuntime Application_Main

	INCLUDE "ROMRuntime.asm"
	INCLUDE "ROMMapper.asm"
	INCLUDE "ROMAddress.asm"
	INCLUDE "Application.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "MemoryTest.asm"
	INCLUDE "VDP.asm"
	INCLUDE "VDPCommand.asm"
	INCLUDE "Math.asm"
	INCLUDE "Vector.asm"
	INCLUDE "Engine.asm"
	INCLUDE "video/Video.asm"
	INCLUDE "split/Split.asm"
	INCLUDE "Interrupt.asm"
	INCLUDE "Hook.asm"
	INCLUDE "TIMIHook.asm"
	INCLUDE "Input.asm"

	ENDS

	SECTION ROM_BANK1

	INCLUDE "Tile.asm"
	INCLUDE "TileMap.asm"
	INCLUDE "Image.asm"
	INCLUDE "SpriteFrame.asm"
	INCLUDE "Glyph.asm"
	INCLUDE "Dialog.asm"
	INCLUDE "Camera.asm"
	INCLUDE "MapView.asm"
	INCLUDE "Player.asm"
	INCLUDE "PlayerView.asm"
	INCLUDE "Scene.asm"
	INCLUDE "Weather.asm"
	INCLUDE "Sunny.asm"
	INCLUDE "Rain.asm"
	INCLUDE "ManaShroud.asm"
	INCLUDE "Lightning.asm"
	INCLUDE "Resources.asm"

	ENDS
