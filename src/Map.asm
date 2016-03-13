;
; A tile map
;
Map: MACRO
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
	ld l,(ix + Map.data)
	ld h,(ix + Map.data + 1)
	ld c,(ix + Map.screenHeight)
	ld (iy + VDPCommand.dy),0
RowLoop:
	ld b,(ix + Map.screenWidth)
	ld (iy + VDPCommand.dx),0
TileLoop:
	ld a,(hl)
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

