;
; ROM runtime
;
ROMRuntime_STACK_SIZE: equ 100H

ROMRuntime: MACRO ?main
	header:
		db "AB"
		dw Entry
		dw 0, 0, 0, 0, 0, 0
	Entry:
		ld hl,-(RAM_endAddress + ROMRuntime_STACK_SIZE)
		add hl,sp
		ret nc
		ld h,40H
		call Memory_GetSlot
		ld h,80H
		call Memory_SetSlot
		ld a,ROM_RAMInitBank
		ld (ROM_BANK_A000_CHANGE),a
		ld hl,RAM_sourceAddress
		ld de,RAM_startAddress
		ld bc,RAM_endAddress - RAM_startAddress
		ldir
		call System_SetDirectBIOSHandlers
		ld hl,?main
		call System_TryCall
		ret
	ENDM

;
	SECTION ROM_BANK3

RAM_sourceAddress:
	org 0C000H
RAM_startAddress:
RAM: ds 2000H
RAM_endAddress:

	ENDS
