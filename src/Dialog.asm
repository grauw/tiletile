;
; Dialog
;
Dialog: MACRO ?uiImage
	uiImage:
		dw ?uiImage
	patternName:
		PatternNameTable 18000H
	ENDM

; ix = this
Dialog_Construct:
	ret

; ix = this
Dialog_Load:
	push ix
	ld e,ixl
	ld d,ixh
	ld iy,Dialog.patternName
	add iy,de
	ld hl,0
	call PatternNameTable_SetPatternNameWriteIY
	ld e,(ix + Dialog.uiImage)
	ld d,(ix + Dialog.uiImage + 1)
	ld ixl,e
	ld ixh,d
	call Image_Load
	pop ix
	ret
