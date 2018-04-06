;
; Sprite pattern table in VRAM
;
SpritePatternTable_COUNT: equ 64
SpritePatternTable_SIZE: equ SpritePatternTable_COUNT * SpritePattern._size

SpritePatternTable: MACRO ?address
	super: VRAMTable ?address
	baseRegister6:
		db 0
	ENDM

; ix = this
SpritePatternTable_Construct:
	ld a,(ix + VRAMTable.address)
	and a
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 1)
	and 00000111B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + VRAMTable.address + 2)
	rra
	ld a,(ix + VRAMTable.address + 1)
	rra
	rra
	rra
	ld (ix + SpritePatternTable.baseRegister6),a
	ret

SpritePatternTable_Select: MACRO ?this, ?displaySettings
	ld a,(?this + SpritePatternTable.baseRegister6)
	ld (?displaySettings + DisplaySettings.spritePattern),a
	ENDM

; a = sprite pattern number
; iy = this
; b <- patterns remaining
; c <- write port
SpritePatternTable_SetPatternWriteIY:
	ld b,a
	add a,a
	call c,System_ThrowException
	add a,a
	call c,System_ThrowException
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	call VRAMTable_SetWriteIY
	ld a,SpritePatternTable_COUNT
	sub b
	ld b,a
	ret

; b = patterns remaining
; c = write port
; hl = sprite pattern
; iy = this
; b <- patterns remaining
; c <- write port
; f <- z: no patterns remaining
SpritePatternTable_WritePatternIY:
	ld a,b
	REPT 32
	outi
	ENDM
	sub 1
	ld b,a
	ret nc
	call System_ThrowException

; b = patterns remaining
; c = write port
; iy = this
SpritePatternTable_FinishWriteIY: PROC
	ld a,b
	and a
	ret z
	call m,System_ThrowException
Loop:
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	jr nz,Loop
	ret
	ENDP
