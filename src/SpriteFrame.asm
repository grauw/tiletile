;
;
;
SpriteFrame: MACRO ?duration, ?patternCount, ?data
	duration:
		db ?duration
	patternCount:
		db ?patternCount
	data:
		ROMAddress ?data, 0A000H
	ENDM

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
; f <- z: no patterns remaining
SpriteFrame_WritePatterns:
	ld l,(ix + SpriteFrame.patternCount)
	ld h,0
	add hl,hl
	add hl,hl
	ld a,b
	sub l
	ld b,a
	add hl,hl
	add hl,hl
	add hl,hl
	push ix
	ld de,SpriteFrame.data
	add ix,de
	ex de,hl
	call ROMAddress_OTIR
	pop ix
	ld a,b
	and a
	ret
