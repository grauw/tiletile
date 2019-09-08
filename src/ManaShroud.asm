;
; Mana shroud effect
;
ManaShroud_DURATION: equ 64  ; power of two, max 256
ManaShroud_DURATION_LOG2: equ 6

ManaShroud: MACRO
	particle1:
		ManaShroudParticle 0
	particle2:
		ManaShroudParticle 8080H
	palette:
		Palette
	ENDM

ManaShroudParticle: MACRO ?counter
	counter:
		dw ?counter
	patternBase:
		db 0
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
	call ManaShroudParticle_Tick
	ld de,ManaShroud.particle2
	add ix,de
	call ManaShroudParticle_Tick
	ld de,-ManaShroud.particle2
	add ix,de
	ret

; ix = this
; iy = engine
ManaShroudParticle_Tick:
	ld a,(ix + ManaShroudParticle.counter)
	add a,256 / ManaShroud_DURATION
	ld (ix + ManaShroudParticle.counter),a
	ret nz
	inc (ix + ManaShroudParticle.counter + 1)
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
ManaShroud_DrawSpriteAttributes:
	call ManaShroudParticle_DrawSpriteAttributes
	ld de,ManaShroud.particle2
	add ix,de
	call ManaShroudParticle_DrawSpriteAttributes
	ld de,-ManaShroud.particle2
	add ix,de
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
ManaShroudParticle_DrawSpriteAttributes: PROC
	push bc
	ld a,(ix + ManaShroudParticle.counter)
	REPT 8 - ManaShroud_DURATION_LOG2
	rrca
	ENDM
	ld c,a
	ld h,Math_random8 >> 8
	ld l,(ix + ManaShroudParticle.counter + 1)
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
	ld a,(ix + ManaShroudParticle.patternBase)
	add a,(hl)
	pop bc
	SpriteAttributeTable_WriteAttribute_M e, d, a
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
	ld (ix + ManaShroud.particle1.patternBase),a
	ld (ix + ManaShroud.particle2.patternBase),a
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
