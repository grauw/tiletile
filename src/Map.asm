;
; A tile map
;
Map: MACRO
	x:
		dw 0
	y:
		dw 0
	width:
		dw 0
	height:
		dw 0
	screenWidth:
		db 16
	screenHeight:
		db 12
	data:
		dw 0
	tileCopyCommand: VDPCommand 0, 200H, 0, 0, 16, 16, 0, 0, VDPCommand_HMMM
	ENDM

; bc = width
; de = height
; hl = data
; ix = this
Map_Construct:
	ld (ix + Map.width),c
	ld (ix + Map.width + 1),b
	ld (ix + Map.height),e
	ld (ix + Map.height + 1),d
	ld (ix + Map.data),l
	ld (ix + Map.data + 1),h
	ret

; ix = this
Map_MoveLeft:
	ld l,(ix + Map.x)
	ld h,(ix + Map.x + 1)
	ld de,-1
	add hl,de
	ret nc
	ld (ix + Map.x),l
	ld (ix + Map.x + 1),h
	ret

; ix = this
Map_MoveRight:
	ld l,(ix + Map.screenWidth)
	ld h,0
	ld e,(ix + Map.width)
	ld d,(ix + Map.width + 1)
	scf
	sbc hl,de
	ex de,hl
	ld l,(ix + Map.x)
	ld h,(ix + Map.x + 1)
	scf
	adc hl,de
	ret c
	sbc hl,de
	ld (ix + Map.x),l
	ld (ix + Map.x + 1),h
	ret

; ix = this
Map_MoveUp:
	ld l,(ix + Map.y)
	ld h,(ix + Map.y + 1)
	ld de,-1
	add hl,de
	ret nc
	ld (ix + Map.y),l
	ld (ix + Map.y + 1),h
	ret

; ix = this
Map_MoveDown:
	ld l,(ix + Map.screenHeight)
	ld h,0
	ld e,(ix + Map.height)
	ld d,(ix + Map.height + 1)
	scf
	sbc hl,de
	ex de,hl
	ld l,(ix + Map.y)
	ld h,(ix + Map.y + 1)
	scf
	adc hl,de
	ret c
	sbc hl,de
	ld (ix + Map.y),l
	ld (ix + Map.y + 1),h
	ret

; ix = this
; hl <- data position
; Modifies: af, bc, de
Map_GetDataPosition:
	ld c,(ix + Map.y)
	ld b,(ix + Map.y + 1)
	ld e,(ix + Map.width)
	ld d,(ix + Map.width + 1)
	call Map_Multiply16x16
	ld c,(ix + Map.x)
	ld b,(ix + Map.x + 1)
	add hl,bc
	ld c,(ix + Map.data)
	ld b,(ix + Map.data + 1)
	add hl,bc
	ret

; ix = this
Map_Draw: PROC
	ld e,ixl
	ld d,ixh
	ld iy,Map.tileCopyCommand
	add iy,de
	ld l,(ix + Map.width)
	ld h,(ix + Map.width + 1)
	ld e,(ix + Map.screenWidth)
	ld d,0
	and a
	sbc hl,de
	ex de,hl
	push de
	call Map_GetDataPosition
	pop de
	ld c,(ix + Map.screenHeight)
	ld (iy + VDPCommand.dy),0
RowLoop:
	ld b,(ix + Map.screenWidth)
	ld (iy + VDPCommand.dx),0
TileLoop:
	ld a,(hl)
	call Map_DrawTile
	ld a,(iy + VDPCommand.dx)
	add a,16
	ld (iy + VDPCommand.dx),a
	inc hl
	djnz TileLoop
	ld a,(iy + VDPCommand.dy)
	add a,16
	ld (iy + VDPCommand.dy),a
	add hl,de
	dec c
	jr nz,RowLoop
	ret
	ENDP

; a = tile
; ix = this
; iy = VDP command
; Modifies: af
Map_DrawTile:
	add a,a
	add a,a
	add a,a
	add a,a
	ld (iy + VDPCommand.sx),a
	ld a,(hl)
	and 0F0H
	ld (iy + VDPCommand.sy),a
	push bc
	push hl
	call VDPCommand_Execute_IY
	pop hl
	pop bc
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
