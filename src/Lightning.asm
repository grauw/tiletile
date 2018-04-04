;
; Lightning effect
;
Lightning_PATTERN: equ 8
Lightning_SPRITES: equ 8

Lightning: MACRO
	counter:
		db 1
	palette:
		Palette
	ENDM

; ix = this
Lightning_Construct:
	ret

; ix = this
; iy = input
Lightning_Tick:
	dec (ix + Lightning.counter)
	ret nz
	ld a,r
	srl a
	ld b,a
	srl a
	add a,b
	add a,66
	ld (ix + Lightning.counter),a
	ret

; de = palette
; ix = this
; de <- palette
Lightning_UpdatePalette:
	call Lightning_GetColor
	push de
	ld de,Lightning.palette
	add ix,de
	pop de
	push ix
	call Palette_SubtractConstant
	pop de
	ret

; de = palette
; ix = this
; de <- palette
Lightning_GetColor:
	ld bc,563H
	ld a,(ix + Lightning.counter)
	cp 32
	ret nc
	ld bc,230H
	cp 30
	ret nc
	ld bc,341H
	cp 28
	ret nc
	ld bc,230H
	cp 18
	ret nc
	ld bc,341H
	cp 16
	ret nc
	ld bc,230H
	cp 8
	ret nc
	ld bc,341H
	cp 4
	ret nc
	ld bc,452H
	ret
