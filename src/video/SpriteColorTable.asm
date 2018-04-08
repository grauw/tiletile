;
; Sprite color table in VRAM
;
SpriteColorTable_COUNT: equ 32
SpriteColorTable_SIZE: equ SpriteColorTable_COUNT * SpriteColor._size

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

; a = sprite number
; iy = this
; b <- sprites remaining
; c <- write port
SpriteColorTable_SetColorWriteIY:
	ld b,a
	add a,a
	add a,a
	add a,a
	add a,a
	ld l,a
	ld h,0
	rl h
	call VRAMTable_SetWriteIY
	ld a,SpriteColorTable_COUNT
	sub b
	ld b,a
	ret

; b = sprites remaining
; c = write port
; hl = sprite color
; iy = this
; b <- sprites remaining
; c <- write port
; f <- z: no sprites remaining
SpriteColorTable_WriteColorIY:
	ld a,b
	REPT 16
	outi
	ENDM
	sub 1
	ld b,a
	ret nc
	call System_ThrowException

; b = sprites remaining
; c = write port
; iy = this
SpriteColorTable_FinishWriteIY: PROC
	ld a,b
	and a
	ret z
	call m,System_ThrowException
Loop:
	ld hl,SpriteColor_solid0
	call SpriteColorTable_WriteColorIY
	jr nz,Loop
	ret
	ENDP
