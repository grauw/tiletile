;
; A tile map
;
Map: MACRO ?width, ?height, ?data, ?dataRows
	width:
		dw ?width
	height:
		dw ?height
	data:
		dw ?data
	dataRows:
		dw ?dataRows
	ENDM

; bc = x
; de = y
; ix = this
; hl <- data position
; Modifies: af, bc, de
Map_GetDataPosition: PROC
	ld l,(ix + Map.height)
	ld h,(ix + Map.height + 1)
	and a
	sbc hl,de
	jr nc,NoClip
	ld de,0
NoClip:
	ex de,hl
	ld e,(ix + Map.dataRows)
	ld d,(ix + Map.dataRows + 1)
	add hl,hl
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	add hl,bc
	ret
	ENDP
