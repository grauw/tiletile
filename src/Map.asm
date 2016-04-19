;
; A tile map
;
Map: MACRO ?width, ?height, ?data
	width:
		dw ?width
	height:
		dw ?height
	data:
		dw ?data
	ENDM

; ix = this
Map_Construct:
	ret

; bc = x
; de = y
; ix = this
; hl <- data position
; Modifies: af, bc, de
Map_GetDataPosition:
	push bc
	ld c,(ix + Map.width)
	ld b,(ix + Map.width + 1)
	call Map_Multiply16x16
	pop bc
	add hl,bc
	ld c,(ix + Map.data)
	ld b,(ix + Map.data + 1)
	add hl,bc
	ret

; bc = multiplicand
; de = multiplier
; hl <- product
; Modifies: af, bc
Map_Multiply16x16: PROC
	ld a,b
	ld b,16
Loop:
	add hl,hl
	sla c
	rla
	jr nc,NoAdd
	add hl,de
NoAdd:
	djnz Loop
	ret
	ENDP
