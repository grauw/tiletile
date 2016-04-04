;
; Tile²
;
; Scrolling tile engine for MSX
;

	INCLUDE "Macros.asm"

DEBUG: equ 1

ROM_CodeBank1: equ 0
ROM_CodeBank2: equ 1
ROM_RAMInitBank: equ 2

	org 4000H
ROM_HEADER: ds 10H
ROM_BANK0: ds 1F0H
ROM: ds 3E00H
	org 06000H
RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 1800H
RAM_endAddress:
	ds 800H
	org 06000H
ROM_TILESET: ds 8020H
	org 06000H
	ds 3FE0H

ROM_BANK_4000_CHANGE: equ 5000H
ROM_BANK_6000_CHANGE: equ 7000H
ROM_BANK_8000_CHANGE: equ 9000H
ROM_BANK_A000_CHANGE: equ 0B000H

	SECTION ROM_HEADER

	db "AB"
	dw Application_Main
	dw 0, 0, 0, 0, 0, 0

	ENDS

	SECTION ROM

	INCLUDE "Application.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "VDP.asm"
	INCLUDE "VDPCommand.asm"
	INCLUDE "Sprites.asm"
	INCLUDE "Hook.asm"
	INCLUDE "TIMIHook.asm"
	INCLUDE "Input.asm"
	INCLUDE "TileSet.asm"
	INCLUDE "Map.asm"
	INCLUDE "MapView.asm"
	INCLUDE "Softsprite.asm"

	INCLUDE "FieldMap.asm"

	ENDS

	SECTION ROM_BANK0

ROM_Init:
	ld a,ROM_CodeBank1
	ld (ROM_BANK_4000_CHANGE),a
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ld a,ROM_CodeBank1
	ld (ROM_BANK_8000_CHANGE),a
	ld a,ROM_CodeBank2
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

	ld a,ROM_RAMInitBank
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,RAM_sourceAddress
	ld de,RAM_startAddress
	ld bc,RAM_endAddress - RAM_startAddress
	ldir
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ret

	ENDS

	SECTION ROM

RAM_insufficientTPA:
	db "Insufficient TPA memory.",0

	ENDS

	SECTION ROM_TILESET

	INCLUDE "FieldSet.asm"

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
	dw ROM_BANK_8000_CHANGE | ROM_CodeBank1
ROM_bankA000:
	dw ROM_BANK_A000_CHANGE | ROM_CodeBank2

	ENDS
