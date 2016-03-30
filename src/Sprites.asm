;
; Sprite manager
;
; Mode 2, 16x16, not magnified
;
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

; ix = this
Sprites_Initialize:
	call VDP_DisableSprites
	call Sprites_InitializeTableAddresses
	call Sprites_ClearTables
	call VDP_EnableSprites
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

; ix = this
Sprites_ClearTables: PROC
	ld l,(ix + Sprites.attributeTable)
	ld h,(ix + Sprites.attributeTable + 1)
	ld a,(ix + Sprites.attributeTable + 2)
	call VDP_SetWriteAddress
	ld b,32
Loop:
	ld a,216
	out (VDP_PORT_0),a
	ld a,0
	out (VDP_PORT_0),a
	ld a,0
	out (VDP_PORT_0),a
	ld a,0
	out (VDP_PORT_0),a
	djnz Loop
	ret
	ENDP
