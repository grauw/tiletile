;
; AY-3-8910 PSG / YM2149 SSG driver
;
PSG_ADDRESS: equ 0A0H
PSG_DATA: equ 0A1H
PSG_READ: equ 0A2H

PSG: MACRO
	found:
		db 0
	ENDM

; ix = this
; iy = drivers
PSG_Construct:
	call PSG_Detect
	ret nc
	ld (ix + PSG.found),1
	jr PSG_Reset

; ix = this
PSG_Destruct:
	bit 0,(ix + PSG.found)
	ret nc
	jr PSG_Reset

; e = register
; d = value
; ix = this
PSG_WriteRegister:
	ld a,e
	di
	out (PSG_ADDRESS),a
	ld a,d
	ei
	out (PSG_DATA),a
	ret

; a = register
; a = value
; ix = this
PSG_ReadRegister:
	di
	out (PSG_ADDRESS),a
	ei
	in a,(PSG_READ)
	ret

; b = count
; e = register
; d = value
; ix = this
PSG_FillRegisters:
	call PSG_WriteRegister
	inc e
	djnz PSG_FillRegisters
	ret

; ix = this
PSG_Reset:
	ld b,6
	ld de,0008H
	call PSG_FillRegisters
	ld de,8007H
	call PSG_WriteRegister
	ld b,7
	ld de,0000H
	jr PSG_FillRegisters

; ix = this
; f <- c: found
PSG_Detect:
	ld de,1200H
	call PSG_WriteRegister
	ld de,3402H
	call PSG_WriteRegister
	ld a,0
	call PSG_ReadRegister
	xor 12H
	ret nz
	ld a,2
	call PSG_ReadRegister
	xor 34H
	ret nz
	scf
	ret
