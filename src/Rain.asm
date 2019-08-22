;
; Rain effect
;
Rain_SPRITES: equ 8

Rain: MACRO
	position:
		Vector2 0, 0
	dropOffset:
		dw 2B20H
	patternBase:
		db 0
	palette:
		Palette
	ENDM

; ix = this
Rain_Construct:
	ret

; ix = this
; iy = input (debug control with 1/2 keys)
Rain_UpdateInput: PROC
	bit 1,(iy + Input.newKey)
	jr nz,NoOne
	dec (ix + Rain.dropOffset + 1)
NoOne:
	bit 2,(iy + Input.newKey)
	ret nz
	inc (ix + Rain.dropOffset + 1)
	ret
	ENDP

; ix = this
; iy = engine
Rain_Tick:
	ld a,(ix + Rain.position.x)
	add a,128 - 2
	ld (ix + Rain.position.x),a
	ld a,(ix + Rain.position.y)
	add a,8
	ld (ix + Rain.position.y),a
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
Rain_DrawSpriteAttributes:
	ld a,(ix + Rain.position.x)
	add a,(iy + SpriteAttributeTable.cameraOffset.x)
	ld h,a
	ld a,(ix + Rain.position.y)
	add a,(iy + SpriteAttributeTable.cameraOffset.y)
	ld l,a
	ld a,(ix + Rain.patternBase)
	ld e,(ix + Rain.dropOffset)
	ld d,(ix + Rain.dropOffset + 1)
	SpriteAttributeTable_WriteAttribute_M h, l, a
	REPT Rain_SPRITES - 1
	add hl,de
	SpriteAttributeTable_WriteAttribute_M h, l, a
	ENDM
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite color table
; b <- sprites remaining
; c <- write port
Rain_DrawSpriteColors:
	ld hl,SpriteColor_solid1
	call SpriteColorTable_WriteColorIY
	REPT Rain_SPRITES - 1
	ld hl,SpriteColor_solid1
	call nz,SpriteColorTable_WriteColorIY
	ENDM
	ret

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
Rain_InitializeSpritePatterns:
	ld a,SpritePatternTable_COUNT
	sub b
	ld (ix + Rain.patternBase),a
	ld hl,Rain_pattern
	call SpritePatternTable_WritePatternIY
	ret

; de = palette
; ix = this
; de <- palette
Rain_UpdatePalette:
	ld bc,Rain.palette
	add ix,bc
	push ix
	ld bc,120H
	call Palette_SubtractConstant
	pop de
	ret

;
Rain_pattern:
	SpritePattern 1, 1, 1, 1, 2, 2, 2, 2,
	              4, 4, 4, 4, 8, 8, 8, 8,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0
