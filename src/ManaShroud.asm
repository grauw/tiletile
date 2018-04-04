;
; Mana shroud effect
;
ManaShroud_PATTERN: equ 8
ManaShroud_SPRITES: equ 8

ManaShroud: MACRO
	palette:
		Palette
	ENDM

; ix = this
ManaShroud_Construct:
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
