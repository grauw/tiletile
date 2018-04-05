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

DisplayOffset_Select: MACRO ?this, ?displaySettings
	ld a,(?this + DisplayOffset.horizontalOffsetCharacters)
	ld (?displaySettings + DisplaySettings.horizontalOffsetCharacters),a
	ld a,(?this + DisplayOffset.horizontalOffsetDots)
	ld (?displaySettings + DisplaySettings.horizontalOffsetDots),a
	ld a,(?this + DisplayOffset.verticalOffset)
	ld (?displaySettings + DisplaySettings.verticalOffset),a
	ENDM

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
