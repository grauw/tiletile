;
; Tile²
;
; Scrolling tile engine for MSX
;

	INCLUDE "Macros.asm"
	INCLUDE "DebugMacros.asm"

DEBUG: equ 1

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
ROM_FieldMapBank: equ 2
ROM_RAMInitBank: equ 3

	org 4000H

ROM_BANK0: ds 2000H
ROM_BANK1: ds 2000H
ROM_BANK2: ds 2000H
ROM_BANK3: ds 2000H

	org 4000H

ROM_BANK4567: ds 8000H

	org 8000H

ROM_BANK89: ds 4000H

TPA_PAGE1: equ ROM_BANK1
RAM_RESIDENT: equ RAM
ROM_FieldMap: equ ROM_BANK2
ROM_FieldSet: equ ROM_BANK4567
ROM_FieldSet_BANK: equ 4
ROM_UIImage: equ ROM_BANK89
ROM_UIImage_BANK: equ 8

ROM_BANK_4000_CHANGE: equ 5000H
ROM_BANK_6000_CHANGE: equ 7000H
ROM_BANK_8000_CHANGE: equ 9000H
ROM_BANK_A000_CHANGE: equ 0B000H

	SECTION ROM_BANK0

	db "AB"
	dw Application_Main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "Application.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "MemoryTest.asm"
	INCLUDE "VDP.asm"
	INCLUDE "VDPCommand.asm"
	INCLUDE "video/VDPCommandEx.asm"
	INCLUDE "Math.asm"
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
	INCLUDE "TileSet.asm"
	INCLUDE "TileMap.asm"
	INCLUDE "Image.asm"
	INCLUDE "Dialog.asm"
	INCLUDE "MapView.asm"
	INCLUDE "Player.asm"
	INCLUDE "Scene.asm"
	INCLUDE "Weather.asm"
	INCLUDE "Sunny.asm"
	INCLUDE "Rain.asm"
	INCLUDE "ManaShroud.asm"
	INCLUDE "Lightning.asm"
	INCLUDE "Resources.asm"

	ENDS

	SECTION ROM_BANK3

RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 1800H
RAM_endAddress:

	ENDS

	SECTION ROM_BANK0

ROM_Init:
	ld h,40H
	call Memory_GetSlot
	ld h,80H
	call Memory_SetSlot
	ld a,ROM_CodeBank1
	ld (ROM_BANK_4000_CHANGE),a
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ld a,ROM_FieldMapBank
	ld (ROM_BANK_8000_CHANGE),a
	ld a,ROM_RAMInitBank
	ld (ROM_BANK_A000_CHANGE),a
	ret

;
; Copy RAM initialisation data from ROM to RAM.
; These values are defined in the RAM section and copied on boot.
;
RAM_Init:
	and a
	ld hl,(HIMEM)
	ld bc,RAM_endAddress
	sbc hl,bc
	ld hl,RAM_insufficientTPA
	call c,System_ThrowExceptionWithMessage
	ld hl,RAM_sourceAddress
	ld de,RAM_startAddress
	ld bc,RAM_endAddress - RAM_startAddress
	ldir
	ret

RAM_insufficientTPA:
	db "Insufficient TPA memory.",0

	ENDS

	SECTION RAM

; The initial ROM banks
; Stored as words that include the bank select register address
; Example: ld hl,(ROM_bank6000) / ld (hl),l
ROM_bank4000:
	dw ROM_BANK_4000_CHANGE | ROM_CodeBank1
ROM_bank6000:
	dw ROM_BANK_6000_CHANGE | ROM_CodeBank2
ROM_bank8000:
	dw ROM_BANK_8000_CHANGE | ROM_FieldMapBank
ROM_bankA000:
	dw ROM_BANK_A000_CHANGE | ROM_RAMInitBank

	ENDS
