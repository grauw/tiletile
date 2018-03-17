;
; Sprite manager
;
; Mode 2, 16x16, not magnified
;
Sprites_MAX_SPRITES: equ 32
Sprites_MAX_PATTERNS: equ 64

Sprites: MACRO
	x:
		dw 0
	y:
		dw 0
	patternTable:
		SpritePatternTable 1F800H
	sprites:
		REPT Sprites_MAX_SPRITES
		dw Sprite_unused
		ENDM
	patterns:
		REPT Sprites_MAX_PATTERNS
		dw SpritePattern_unused
		ENDM
	ENDM

; ix = this
Sprites_Construct:
	push ix
	call Sprites_GetPatternTable
	call SpritePatternTable_Construct
	pop ix
	ret

; ix = this
; ix <- sprite pattern table
Sprites_GetPatternTable:
	ld de,Sprites.patternTable
	add ix,de
	ret

; bc = x
; de = y
; ix = this
Sprites_SetPosition:
	ld hl,-8
	add hl,bc
	ld (ix + Sprites.x),l
	ld (ix + Sprites.x + 1),h
	ld hl,-15
	add hl,de
	ld (ix + Sprites.y),l
	ld (ix + Sprites.y + 1),h
	ret

; ix = this
Sprites_InitializeTables:
	ld a,(VDP_MIRROR_0 + 1)
	res 0,a  ; MAG
	set 1,a  ; SI
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	push ix
	call Sprites_GetPatternTable
	call SpritePatternTable_Select
	pop ix
	ret

; de = sprite
; ix = this
Sprites_AddSprite: PROC
	push ix
	ld b,Sprites_MAX_SPRITES
Loop:
	ld a,(ix + Sprites.sprites)
	cp Sprite_unused
	jr nz,NotFound
	ld a,(ix + Sprites.sprites + 1)
	cp Sprite_unused >> 8
	jr z,Found
NotFound:
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
Found:
	ld (ix + Sprites.sprites),e
	ld (ix + Sprites.sprites + 1),d
	pop ix
	ld iyl,e
	ld iyh,d
	call Sprite_Register_IY
	ret
	ENDP

; de = sprite
; ix = this
Sprites_RemoveSprite: PROC
	push ix
	ld b,Sprites_MAX_SPRITES
Loop:
	ld l,(ix + Sprites.sprites)
	ld h,(ix + Sprites.sprites + 1)
	and a
	sbc hl,de
	jr z,Found
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
Found:
	ld (ix + Sprites.sprites),Sprite_unused
	ld (ix + Sprites.sprites + 1),Sprite_unused >> 8
	pop ix
	ld iyl,e
	ld iyh,d
	call Sprite_Unregister_IY
	ret
	ENDP

; de = pattern
; ix = this
; de <- pattern
; iy <- pattern
Sprites_AddPattern: PROC
	push ix
	ld b,Sprites_MAX_PATTERNS
Loop:
	ld c,(ix + Sprites.patterns)
	ld a,(ix + Sprites.patterns + 1)
	ld iyl,c
	ld iyh,a
	call SpritePattern_IsReferenced_IY
	jr z,Found
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
Found:
	call SpritePattern_ClearNumber_IY
	ld (ix + Sprites.patterns),e
	ld (ix + Sprites.patterns + 1),d
	pop ix
	ld a,Sprites_MAX_PATTERNS
	sub b
	ld iyl,e
	ld iyh,d
	call SpritePattern_SetNumber_IY
	call Sprites_DrawPattern
	ret
	ENDP

; ix = this
; iy = draw context
Sprites_Draw:
	call Sprites_DrawSprites
	call Sprites_DrawColors
	ret

; ix = this
; iy = draw context
Sprites_DrawSprites: PROC
	ld a,0
	call DrawContext_SetSpriteAttributeWriteIY
	ld b,Sprites_MAX_SPRITES
	ld hl,Sprites.sprites
	ld e,ixl
	ld d,ixh
	add hl,de
	push iy
Loop:
	push bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld iyl,e
	ld iyh,d
	push hl
	call Sprite_Draw_IY
	pop hl
	pop bc
	djnz Loop
	pop iy
	ret
	ENDP

; ix = this
; iy = draw context
Sprites_DrawColors: PROC
	ld a,0
	call DrawContext_SetSpriteColorWriteIY
	ld b,Sprites_MAX_SPRITES
	ld hl,Sprites.sprites
	ld e,ixl
	ld d,ixh
	add hl,de
	push iy
Loop:
	push bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld iyl,e
	ld iyh,d
	push hl
	call Sprite_DrawColor_IY
	pop hl
	pop bc
	djnz Loop
	pop iy
	ret
	ENDP

; iy = pattern
; ix = this
Sprites_DrawPattern:
	call SpritePattern_GetNumber_IY
	push ix
	call Sprites_GetPatternTable
	call SpritePatternTable_SetPatternWrite
	pop ix
	call SpritePattern_Draw_IY
	ret
