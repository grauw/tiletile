;
; Sprite color table in VRAM
;
SpriteColorTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister5:
		db 0
	baseRegister11:
		db 0
	ENDM

; ix = this
SpriteColorTable_Construct:
	ld a,(ix + VRAMTable.address)
	and a
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	and 00000011B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	rla
	push af
	or 00000011B
	ld (ix + SpriteColorTable.baseRegister5),a
	pop af
	ld a,(ix + VRAMTable.address + 2)
	rla
	ld (ix + SpriteColorTable.baseRegister11),a
	ret

; ix = this
SpriteColorTable_Select:
	ld a,(ix + SpriteColorTable.baseRegister5)
	ld b,5
	call VDP_SetRegister
	ld a,(ix + SpriteColorTable.baseRegister11)
	ld b,11
	call VDP_SetRegister
	ret

; a = sprite number
; ix = this
; c <- write port
SpriteColorTable_SetColorWrite:
	add a,a
	add a,a
	add a,a
	add a,a
	ld l,a
	ld h,0
	rl h
	call VRAMTable_SetWrite
	ret

; a = sprite number
; iy = this
; c <- write port
SpriteColorTable_SetColorWriteIY:
	add a,a
	add a,a
	add a,a
	add a,a
	ld l,a
	ld h,0
	rl h
	call VRAMTable_SetWriteIY
	ret

; c = write port
; hl = sprite color
; iy = this
SpriteColorTable_DrawIY:
	REPT 16
	outi
	ENDM
	ret
