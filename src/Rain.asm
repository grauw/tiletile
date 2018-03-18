;
; Rain effect
;
Rain_PATTERN: equ 8
Rain_SPRITES: equ 8

Rain: MACRO
	x:
		db 0
	y:
		db 0
	dropOffset:
		dw 2B20H
	ENDM

; ix = this
Rain_Construct:
	ret

; ix = this
; iy = input (debug control with 1/2 keys)
Rain_Tick: PROC
	ld a,(ix + Rain.x)
	add a,128 - 2
	ld (ix + Rain.x),a
	ld a,(ix + Rain.y)
	add a,8
	ld (ix + Rain.y),a
	bit 1,(iy + Input.newKey)
	jr nz,NoOne
	dec (ix + Rain.dropOffset + 1)
NoOne:
	bit 2,(iy + Input.newKey)
	ret nz
	inc (ix + Rain.dropOffset + 1)
	ret
	ENDP

; c = transfer port
; ix = this
; iy = sprite attribute table
Rain_DrawSpriteAttributes:
	ld a,(ix + Rain.x)
	add a,(iy + SpriteAttributeTable.cameraOffsetX)
	ld h,a
	ld a,(ix + Rain.y)
	add a,(iy + SpriteAttributeTable.cameraOffsetY)
	ld l,a
	ld b,Rain_PATTERN << 2
	ld e,(ix + Rain.dropOffset)
	ld d,(ix + Rain.dropOffset + 1)
	call SpriteAttributeTable_WriteAttributeIY
	REPT Rain_SPRITES - 1
	add hl,de
	call SpriteAttributeTable_WriteAttributeIY
	ENDM
	ret

; c = transfer port
; ix = this
; iy = sprite color table
Rain_DrawSpriteColors:
	REPT Rain_SPRITES
	ld hl,SpriteColor_solid1
	call SpriteColorTable_DrawIY
	ENDM
	ret

; ix = this
; iy = sprite pattern table
Rain_DrawSpritePatterns:
	ld a,Rain_PATTERN
	call SpritePatternTable_SetPatternWriteIY
	ld hl,Rain_pattern
	call SpritePatternTable_WritePatternIY
	ret

;
Rain_pattern:
	SpritePattern 1, 1, 1, 1, 2, 2, 2, 2,
	              4, 4, 4, 4, 8, 8, 8, 8,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0
