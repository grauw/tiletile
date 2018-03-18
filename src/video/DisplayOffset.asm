;
; Display x/y offset
;
DisplayOffset: MACRO
	horizontalOffset:
		db 0
	horizontalOffsetCharacters:
		db 0
	horizontalOffsetDots:
		db 0
	verticalOffset:
		db 0
	ENDM

; ix = this
DisplayOffset_Construct:
	ret

; ix = this
DisplayOffset_Select:
	ld a,(ix + DisplayOffset.horizontalOffsetCharacters)
	ld b,26
	call VDP_SetRegister
	ld a,(ix + DisplayOffset.horizontalOffsetDots)
	ld b,27
	call VDP_SetRegister
	ld a,(ix + DisplayOffset.verticalOffset)
	ld b,23
	call VDP_SetRegister
	ret

; a = offset
; iy = this
DisplayOffset_SetHorizontalOffsetIY:
	ld (iy + DisplayOffset.horizontalOffset),a
	push af
	neg
	and 07H
	ld (iy + DisplayOffset.horizontalOffsetDots),a
	pop af
	dec a
	srl a
	srl a
	srl a
	ld (iy + DisplayOffset.horizontalOffsetCharacters),a
	ret

; a = offset
; iy = this
DisplayOffset_SetVerticalOffsetIY:
	ld (iy + DisplayOffset.verticalOffset),a
	ret
