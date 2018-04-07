;
; Sunny effect
;
Sunny: MACRO
	color:
		PaletteColor 0, 0, 0
	palette:
		Palette
	ENDM

; ix = this
Sunny_Construct:
	ret

; ix = this
; iy = input (debug control with 1/2 keys)
Sunny_UpdateInput: PROC
	bit 2,(iy + Input.newKey + 5)
	jr nz,NotU
	bit 2,(iy + Input.oldKey + 5)
	jr z,NotU
	ld a,(ix + Sunny.color)
	add a,10H
	ld (ix + Sunny.color),a
NotU:
	bit 7,(iy + Input.newKey + 3)
	jr nz,NotJ
	bit 7,(iy + Input.oldKey + 3)
	jr z,NotJ
	ld a,(ix + Sunny.color)
	sub 10H
	ld (ix + Sunny.color),a
NotJ:
	bit 6,(iy + Input.newKey + 3)
	jr nz,NotI
	bit 6,(iy + Input.oldKey + 3)
	jr z,NotI
	inc (ix + Sunny.color + 1)
NotI:
	bit 0,(iy + Input.newKey + 4)
	jr nz,NotK
	bit 0,(iy + Input.oldKey + 4)
	jr z,NotK
	dec (ix + Sunny.color + 1)
NotK:
	bit 4,(iy + Input.newKey + 4)
	jr nz,NotO
	bit 4,(iy + Input.oldKey + 4)
	jr z,NotO
	ld a,(ix + Sunny.color)
	rlca
	rlca
	rlca
	rlca
	add a,10H
	rlca
	rlca
	rlca
	rlca
	ld (ix + Sunny.color),a
NotO:
	bit 1,(iy + Input.newKey + 4)
	jr nz,NotL
	bit 1,(iy + Input.oldKey + 4)
	jr z,NotL
	ld a,(ix + Sunny.color)
	rlca
	rlca
	rlca
	rlca
	sub 10H
	rlca
	rlca
	rlca
	rlca
	ld (ix + Sunny.color),a
NotL:
	bit 5,(iy + Input.newKey + 4)
	ret nz
	bit 5,(iy + Input.oldKey + 4)
	ret z
	ld (ix + Sunny.color),0
	ld (ix + Sunny.color + 1),0
	ret
	ENDP

; de = palette
; ix = this
; de <- palette
Sunny_UpdatePalette: PROC
	ld hl,0
	ld c,(ix + Sunny.color)
	ld b,(ix + Sunny.color + 1)
	bit 7,c
	jr z,PositiveRed
	ld a,c
	and 0F0H
	xor 0F0H
	add a,10H
	ld l,a
	ld a,c
	and 0FH
	ld c,a
PositiveRed:
	bit 3,b
	jr z,PositiveGreen
	ld a,b
	neg
	ld h,a
	ld b,0
PositiveGreen:
	bit 3,c
	jr z,PositiveBlue
	ld a,c
	neg
	and 0FH
	or l
	ld l,a
	ld a,c
	and 0F0H
	ld c,a
PositiveBlue:

	push hl
	push ix
	push de
	ld de,Sunny.palette
	add ix,de
	pop de
	push ix
	call Palette_AddConstant
	pop de
	pop ix

	pop bc
	push de
	ld de,Sunny.palette
	add ix,de
	pop de
	push ix
	call Palette_SubtractConstant
	pop de
	ret
	ENDP
