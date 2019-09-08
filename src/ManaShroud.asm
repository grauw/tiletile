;
; Mana shroud effect
;
ManaShroud_DURATION: equ 64  ; power of two, max 256
ManaShroud_DURATION_LOG2: equ 6

ManaShroud: MACRO
	counter:
		dw 0
	patternBase:
		db 0
	palette:
		Palette
	ENDM

ManaShroudStep: MACRO ?pattern
	pattern:
		db ?pattern
	ENDM

; ix = this
ManaShroud_Construct:
	ret

; ix = this
; iy = engine
ManaShroud_Tick:
	ld a,(ix + ManaShroud.counter)
	add a,256 / ManaShroud_DURATION
	ld (ix + ManaShroud.counter),a
	ret nz
	inc (ix + ManaShroud.counter + 1)
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
ManaShroud_DrawSpriteAttributes:
	ld l,(ix + ManaShroud.counter)
	ld h,(ix + ManaShroud.counter + 1)
	call ManaShroud_DrawSpriteAttributesParticle
	ld de,8080H
	add hl,de
	jp ManaShroud_DrawSpriteAttributesParticle

; b = sprites remaining
; c = write port
; hl = counter
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
ManaShroud_DrawSpriteAttributesParticle: PROC
	push hl
	push bc
	ld a,l
	REPT 8 - ManaShroud_DURATION_LOG2
	rrca
	ENDM
	ld c,a
	ld l,h
	ld h,Math_random8 >> 8
	ld a,(hl)
	add a,(iy + SpriteAttributeTable.worldOffset.x)
	ld e,a
	ld a,l
	cpl
	ld l,a
	ld a,(hl)
	add a,(iy + SpriteAttributeTable.worldOffset.y)
	ld d,c
	srl d
	srl d  ; -1/4 velocity
	sub d
	ld d,a
	cp 216
	jr nz,Not216
	dec d
Not216:
	ld b,0
	ld hl,ManaShroud_steps
	add hl,bc
	ld a,(ix + ManaShroud.patternBase)
	add a,(hl)
	pop bc
	SpriteAttributeTable_WriteAttribute_M e, d, a
	pop hl
	ret
	ENDP

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite color table
; b <- sprites remaining
; c <- write port
ManaShroud_DrawSpriteColors:
	ld hl,ManaShroud_color
	call SpriteColorTable_WriteColorIY
	ld hl,ManaShroud_color
	call SpriteColorTable_WriteColorIY
	ret

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
ManaShroud_InitializeSpritePatterns:
	ld a,SpritePatternTable_COUNT
	sub b
	ld (ix + ManaShroud.patternBase),a
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	ld hl,ManaShroud_pattern1
	call SpritePatternTable_WritePatternIY
	ld hl,ManaShroud_pattern2
	call SpritePatternTable_WritePatternIY
	ret

; de = palette
; ix = this
; de <- palette
ManaShroud_UpdatePalette:
	push ix
	ld bc,ManaShroud.palette
	add ix,bc
	push ix
	ld bc,200H
	call Palette_SubtractConstant
	pop de
	pop ix
	ret

;
ManaShroud_pattern1:
	SpritePattern 0, 2, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0

ManaShroud_pattern2:
	SpritePattern 2, 7, 2, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0

ManaShroud_color:
	SpriteColor 7, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

ManaShroud_steps: REPT ManaShroud_DURATION, ?i
	ManaShroudStep ((?i & 1) << 2) +
		((?i >= 4 && ?i < 6) || (?i >= 8 && ?i < 40) || (?i >= 42 && ?i < 44) ||
		(?i >= 64 && ?i < 76) || (?i >= 80 && ?i < 84) || (?i >= 88 && ?i < 92) ? 4 : 0)
	ENDM
