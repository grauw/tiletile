;
; Sprite manager
;
; Mode 2, 16x16, not magnified
;
	INCLUDE "Sprite.asm"
	INCLUDE "SpriteColor.asm"
	INCLUDE "SpritePattern.asm"

Sprites: MACRO
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
		dw 0
		ENDM
	patterns:
		REPT 64
		dw 0
		ENDM
	ENDM

; ix = this
Sprites_Construct: PROC
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
	ld b,32
Loop:
	push bc
	ld de,Sprite_empty
	call Sprites_AddSprite
	pop bc
	djnz Loop
	ret
	ENDP

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
	or (ix + Sprites.sprites + 1)
	jr z,Found
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
Found:
	ld (ix + Sprites.sprites),e
	ld (ix + Sprites.sprites + 1),d
	ld ixl,e
	ld ixh,d
	ld e,(ix + Sprite.pattern)
	ld d,(ix + Sprite.pattern + 1)
	pop ix
	call Sprites_AddPattern
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
	ld (ix + Sprites.sprites),0
	ld (ix + Sprites.sprites + 1),0
	ld ixl,e
	ld ixh,d
	ld e,(ix + Sprite.pattern)
	ld d,(ix + Sprite.pattern + 1)
	pop ix
	call Sprites_RemovePattern
	ret
	ENDP

; de = pattern
; ix = this
Sprites_AddPattern: PROC
	push ix
	ld b,64
Loop:
	ld a,(ix + Sprites.patterns)
	or (ix + Sprites.patterns + 1)
	jr z,Found
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
Found:
	ld (ix + Sprites.patterns),e
	ld (ix + Sprites.patterns + 1),d
	pop ix
	ret
	ENDP

; de = pattern
; ix = this
Sprites_RemovePattern: PROC
	push ix
	ld b,64
Loop:
	ld l,(ix + Sprites.patterns)
	ld h,(ix + Sprites.patterns + 1)
	and a
	sbc hl,de
	jr z,Found
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
Found:
	ld (ix + Sprites.patterns),0
	ld (ix + Sprites.patterns + 1),0
	pop ix
	ret
	ENDP

; ix = this
Sprites_Draw:
	call Sprites_DrawPatterns
	call Sprites_DrawColors
	call Sprites_DrawSprites
	ret

; ix = this
Sprites_DrawSprites: PROC
	ld l,(ix + Sprites.attributeTable)
	ld h,(ix + Sprites.attributeTable + 1)
	ld a,(ix + Sprites.attributeTable + 2)
	call VDP_SetWriteAddress
	ld b,32
	push ix
Loop:
	push bc
	ld e,(ix + Sprites.sprites)
	ld d,(ix + Sprites.sprites + 1)
	ld iyl,e
	ld iyh,d
	call Sprite_Draw_IY
	inc ix
	inc ix
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Sprites_DrawColors: PROC
	ld l,(ix + Sprites.colorTable)
	ld h,(ix + Sprites.colorTable + 1)
	ld a,(ix + Sprites.colorTable + 2)
	call VDP_SetWriteAddress
	ld b,32
	push ix
Loop:
	push bc
	ld e,(ix + Sprites.sprites)
	ld d,(ix + Sprites.sprites + 1)
	ld iyl,e
	ld iyh,d
	call Sprite_DrawColor_IY
	inc ix
	inc ix
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
Sprites_DrawPatterns: PROC
	ld l,(ix + Sprites.patternTable)
	ld h,(ix + Sprites.patternTable + 1)
	ld a,(ix + Sprites.patternTable + 2)
	call VDP_SetWriteAddress
	ld b,64
	push ix
Loop:
	push bc
	ld e,(ix + Sprites.patterns)
	ld d,(ix + Sprites.patterns + 1)
	ld iyl,e
	ld iyh,d
	ld a,e
	or d
	call nz,SpritePattern_Draw_IY
	inc ix
	inc ix
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP
