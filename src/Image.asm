;
; A screen 5 image
;
Image: MACRO ?width, ?height, ?palette, ?pixelData, ?bank
	width:
		dw ?width
	height:
		dw ?height
	size:
		dw ?width * ?height / 2
	palette:
		dw ?palette
	pixelData:
		dw ?pixelData | 0E000H
	bank:
		db ?bank
	ENDM

; c = write port
; ix = this
Image_Load: PROC
	ld a,(ix + Image.bank)
	ex af,af'
	ld l,(ix + Image.pixelData)
	ld h,(ix + Image.pixelData + 1)
	ld e,(ix + Image.size)
	ld d,(ix + Image.size + 1)
Loop:
	push hl
	and a
	adc hl,de
	jr nc,NoOverflow
	jr z,NoOverflow
Overflow:
	pop hl
	push de
	ex de,hl
	ld hl,0
	and a
	sbc hl,de
	ex de,hl
	call Write
	pop de
	ld a,d
	sub 20H
	ld d,a
	jr Loop
NoOverflow:
	pop hl
	call Write
	ret
Write:
	push hl
	ld hl,(ROM_bankA000)
	ex af,af'
	ld (hl),a
	inc a
	ex af,af'
	ex (sp),hl
	ld b,e
	dec de
	inc d
	set 5,h
	res 6,h
	set 7,h
WriteLoop:
	otir
	dec d
	jr nz,WriteLoop
	set 5,h
	set 6,h
	set 7,h
	ex (sp),hl
	ld (hl),l
	pop hl
	ret
	ENDP
