;
; A screen 5 image
;
Image: MACRO ?width, ?height, ?palette, ?pixelData
	width:
		dw ?width
	height:
		dw ?height
	size:
		dw ?width * ?height / Video_X_BYTE
	palette:
		dw ?palette
	pixelData:
		ROMAddress ?pixelData, 0A000H
	ENDM

; c = write port
; ix = this
Image_Load:
	ld e,(ix + Image.size)
	ld d,(ix + Image.size + 1)
	ROMAddress_OTIR_M ix + Image.pixelData
	ret
