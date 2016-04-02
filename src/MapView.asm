;
; A view on a section of the map.
;
MapView: MACRO
	map:
		dw 0
	x:
		dw 0
	y:
		dw 0
	maxX:
		dw 0
	maxY:
		dw 0
	width:
		db 16
	height:
		db 12
	tileCopyCommand: VDPCommand 0, 200H, 0, 0, 16, 16, 0, 0, VDPCommand_HMMM
	screen:
		ds 16 * 12,255
	ENDM

; de = map
; ix = this
MapView_Construct:
	ld (ix + MapView.map),e
	ld (ix + MapView.map + 1),d
	push ix
	call MapView_GetMap
	ld l,(ix + Map.width)
	ld h,(ix + Map.width + 1)
	pop ix
	ld e,(ix + MapView.width)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + MapView.maxX),l
	ld (ix + MapView.maxX + 1),h
	push ix
	call MapView_GetMap
	ld l,(ix + Map.height)
	ld h,(ix + Map.height + 1)
	pop ix
	ld e,(ix + MapView.height)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + MapView.maxY),l
	ld (ix + MapView.maxY + 1),h
	ret

; ix = this
; ix <- map
MapView_GetMap:
	ld e,(ix + MapView.map)
	ld d,(ix + MapView.map + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
MapView_GetTileCopyCommand_IY:
	ld e,ixl
	ld d,ixh
	ld iy,MapView.tileCopyCommand
	add iy,de
	ret

; ix = this
; hl <- screen
MapView_GetScreen:
	ld hl,MapView.screen
	ld e,ixl
	ld d,ixh
	add hl,de
	ret

; ix = this
; hl <- position
; Modifies: af, bc, de
MapView_GetDataPosition:
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	push ix
	push de
	call MapView_GetMap
	pop de
	call Map_GetDataPosition
	pop ix
	ret

; ix = this
MapView_MoveLeft:
	ld l,(ix + MapView.x)
	ld h,(ix + MapView.x + 1)
	ld de,-1
	add hl,de
	ret nc
	ld (ix + MapView.x),l
	ld (ix + MapView.x + 1),h
	ret

; ix = this
MapView_MoveRight:
	ld l,(ix + MapView.maxX)
	ld h,(ix + MapView.maxX + 1)
	ld e,(ix + MapView.x)
	ld d,(ix + MapView.x + 1)
	inc de
	and a
	sbc hl,de
	ret c
	ld (ix + MapView.x),e
	ld (ix + MapView.x + 1),d
	ret

; ix = this
MapView_MoveUp:
	ld l,(ix + MapView.y)
	ld h,(ix + MapView.y + 1)
	ld de,-1
	add hl,de
	ret nc
	ld (ix + MapView.y),l
	ld (ix + MapView.y + 1),h
	ret

; ix = this
MapView_MoveDown:
	ld l,(ix + MapView.maxY)
	ld h,(ix + MapView.maxY + 1)
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	inc de
	and a
	sbc hl,de
	ret c
	ld (ix + MapView.y),e
	ld (ix + MapView.y + 1),d
	ret

; ix = this
MapView_Draw: PROC
	call MapView_GetTileCopyCommand_IY
	ld e,(ix + MapView.maxX)
	ld d,(ix + MapView.maxX + 1)
	push de
	call MapView_GetDataPosition
	pop de
	exx
	call MapView_GetScreen
	exx
	ld c,(ix + MapView.height)
	ld (iy + VDPCommand.dy),0
RowLoop:
	ld b,(ix + MapView.width)
	ld (iy + VDPCommand.dx),0
TileLoop:
	ld a,(hl)
	inc hl
	exx
	cp (hl)
	call nz,MapView_DrawTile
	inc hl
	exx
	ld a,(iy + VDPCommand.dx)
	add a,16
	ld (iy + VDPCommand.dx),a
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
; (hl) = screen tile
; ix = this
; iy = VDP command
; Modifies: af
MapView_DrawTile:
	ld (hl),a
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
