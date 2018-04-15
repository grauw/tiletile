;
; A screen 5 image
;
Image: MACRO ?width, ?height, ?palette, ?pixelData, ?bank
	width:
		dw ?width
	height:
		dw ?height
	palette:
		dw ?palette
	pixelData:
		dw ?pixelData
	bank:
		db ?bank
	ENDM
