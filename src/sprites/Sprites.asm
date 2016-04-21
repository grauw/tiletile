;
; Sprite manager
;
; Mode 2, 16x16, not magnified
;
	INCLUDE "Sprite.asm"
	INCLUDE "SpriteColor.asm"
	INCLUDE "SpritePattern.asm"

Sprites: MACRO
	x:
		dw 0
	y:
		dw 0
	patternTable:
		dw 0F800H
		db 1H
	attributeTable:
		dw 0F600H
		db 1H
	colorTable:
		dw 0F400H
		db 1H
	sprites:
		REPT 32
		dw Sprite_unused
		ENDM
	patterns:
		REPT 64
		dw SpritePattern_unused
		ENDM
	ENDM

; ix = this
Sprites_Construct:
	ld a,(ix + Sprites.patternTable)
	and a
	call nz,System_ThrowException
	ld a,(ix + Sprites.patternTable + 1)
	and 00000111B
	call nz,System_ThrowException
	ld a,(ix + Sprites.patternTable + 2)
	and 11111110B
	call nz,System_ThrowException
	ld a,(ix + Sprites.attributeTable)
	cp (ix + Sprites.colorTable)
	call nz,System_ThrowException
	and a
	call nz,System_ThrowException
	ld a,(ix + Sprites.attributeTable + 1)
	sub 2
	cp (ix + Sprites.colorTable + 1)
	call nz,System_ThrowException
	add a,2
	and 00000011B
	cp 00000010B
	call nz,System_ThrowException
	ld a,(ix + Sprites.attributeTable + 2)
	cp (ix + Sprites.colorTable + 2)
	call nz,System_ThrowException
	and 11111110B
	call nz,System_ThrowException
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
Sprites_InitializeTableAddresses:
	ld a,(VDP_MIRROR_0 + 1)
	res 0,a  ; MAG
	set 1,a  ; SI
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ld a,(ix + Sprites.patternTable + 2)
	rra
	ld a,(ix + Sprites.patternTable + 1)
	rra
	rra
	rra
	ld b,6
	call VDP_SetRegister
	ld a,(ix + Sprites.attributeTable + 1)
	rla
	push af
	or 00000011B
	ld b,5
	call VDP_SetRegister
	pop af
	ld a,(ix + Sprites.attributeTable + 2)
	rla
	ld b,11
	call VDP_SetRegister
	ret

; de = sprite
; ix = this
Sprites_AddSprite: PROC
	push ix
	ld b,32
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
	ld b,32
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
	ld b,64
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
	ld a,64
	sub b
	ld iyl,e
	ld iyh,d
	call SpritePattern_SetNumber_IY
	call Sprites_DrawPattern
	ret
	ENDP

; ix = this
Sprites_Draw:
	call Sprites_DrawSprites
	call Sprites_DrawColors
	ret

; ix = this
Sprites_DrawSprites: PROC
	ld l,(ix + Sprites.attributeTable)
	ld h,(ix + Sprites.attributeTable + 1)
	ld a,(ix + Sprites.attributeTable + 2)
	call VDP_SetWriteAddress
	ld b,32
	ld hl,Sprites.sprites
	ld e,ixl
	ld d,ixh
	add hl,de
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
	ret
	ENDP

; ix = this
Sprites_DrawColors: PROC
	ld l,(ix + Sprites.colorTable)
	ld h,(ix + Sprites.colorTable + 1)
	ld a,(ix + Sprites.colorTable + 2)
	call VDP_SetWriteAddress
	ld b,32
	ld hl,Sprites.sprites
	ld e,ixl
	ld d,ixh
	add hl,de
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
	ret
	ENDP

; iy = pattern
; ix = this
Sprites_DrawPattern:
	call SpritePattern_GetNumber_IY
	add a,a
	add a,a
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,(ix + Sprites.patternTable)
	ld d,(ix + Sprites.patternTable + 1)
	add hl,de
	ld a,(ix + Sprites.patternTable + 2)
	call VDP_SetWriteAddress
	call SpritePattern_Draw_IY
	ret
