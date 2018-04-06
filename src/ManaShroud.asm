;
; Mana shroud effect
;
ManaShroud_DURATION: equ 64  ; max 128

ManaShroud: MACRO
	x1:
		db 1
	y1:
		db 1
	counter1:
		db -2
	x2:
		db 73
	y2:
		db 224
	counter2:
		db ManaShroud_DURATION - 2
	patternBase:
		db 0
	palette:
		Palette
	ENDM

ManaShroudStep: MACRO ?y, ?pattern
	y:
		db ?y
	pattern:
		db ?pattern
	ENDM

; ix = this
ManaShroud_Construct:
	ret

; ix = this
; iy = engine
ManaShroud_Tick: PROC
	ld a,(ix + ManaShroud.counter1)
	add a,2
	ld (ix + ManaShroud.counter1),a
	IF ManaShroud_DURATION < 128
	cp ManaShroud_DURATION * 2
	jr c,Particle2
	ld (ix + ManaShroud.counter1),0
	ELSE
	jr nc,Particle2
	ENDIF
	ld a,(ix + ManaShroud.x1)
	Math_XorShift_M 3, 5, 7
	ld (ix + ManaShroud.x1),a
	ld a,(ix + ManaShroud.y1)
	Math_XorShift_M 5, 3, 7
	ld (ix + ManaShroud.y1),a
Particle2:
	ld a,(ix + ManaShroud.counter2)
	add a,2
	ld (ix + ManaShroud.counter2),a
	IF ManaShroud_DURATION < 128
	cp ManaShroud_DURATION * 2
	ret c
	ld (ix + ManaShroud.counter2),0
	ELSE
	ret nc
	ENDIF
	ld a,(ix + ManaShroud.x2)
	Math_XorShift_M 7, 3, 5
	ld (ix + ManaShroud.x2),a
	ld a,(ix + ManaShroud.y2)
	Math_XorShift_M 5, 1, 3
	ld (ix + ManaShroud.y2),a
	ret
	ENDP

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
ManaShroud_DrawSpriteAttributes: PROC
	ld hl,ManaShroud_steps
	ld e,(ix + ManaShroud.counter1)
	ld d,0
	add hl,de
	ld e,(ix + ManaShroud.x1)
	ld d,(ix + ManaShroud.y1)
	call DrawSprite
	ld hl,ManaShroud_steps
	ld e,(ix + ManaShroud.counter2)
	ld d,0
	add hl,de
	ld e,(ix + ManaShroud.x2)
	ld d,(ix + ManaShroud.y2)
DrawSprite:
	ld a,e
	add a,(iy + SpriteAttributeTable.worldOffsetX)
	ld e,a
	ld a,d
	add a,(iy + SpriteAttributeTable.worldOffsetY)
	add a,(hl)
	cp 216
	jr nz,Not216
	dec a
Not216:
	ld d,a
	inc hl
	ld a,(ix + ManaShroud.patternBase)
	add a,(hl)
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
	ManaShroudStep -(?i / 4), ((?i & 1) << 2) +
		((?i >= 4 && ?i < 6) || (?i >= 8 && ?i < 40) || (?i >= 42 && ?i < 44) ||
		(?i >= 64 && ?i < 76) || (?i >= 80 && ?i < 84) || (?i >= 88 && ?i < 92) ? 4 : 0)
	ENDM
