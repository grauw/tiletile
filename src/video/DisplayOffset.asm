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

; a = offset
; iy = this
DisplayOffset_SetHorizontalOffsetIY:
	ld (iy + DisplayOffset.horizontalOffset),a
	ld b,a
	neg
	and 07H
	ld (iy + DisplayOffset.horizontalOffsetDots),a
	dec b
	srl b
	srl b
	srl b
	ld (iy + DisplayOffset.horizontalOffsetCharacters),b
	ret

; a = offset
; iy = this
DisplayOffset_SetVerticalOffsetIY:
	ld (iy + DisplayOffset.verticalOffset),a
	ret
