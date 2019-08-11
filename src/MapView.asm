;
; A view on a section of the map.
;
MapView_OFFSET_X: equ -4
MapView_OFFSET_Y: equ -8

MapView: MACRO
	tileMap:
		dw 0
	camera:
		dw 0
	x:
		dw MapView_OFFSET_X
	y:
		dw MapView_OFFSET_Y
	tileCopyCommand: VDPCommand 0, Tile_PAGE << 8, 0, 0, 4, 4, 0, 0, VDPCommand_HMMM
	ENDM

; de = map
; hl = camera
; ix = this
MapView_Construct:
	ld (ix + MapView.tileMap),e
	ld (ix + MapView.tileMap + 1),d
	ld (ix + MapView.camera),l
	ld (ix + MapView.camera + 1),h
	ret

; ix = this
; ix <- tile map
MapView_GetTileMap:
	ld e,(ix + MapView.tileMap)
	ld d,(ix + MapView.tileMap + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; ix <- camera
MapView_GetCamera:
	ld e,(ix + MapView.camera)
	ld d,(ix + MapView.camera + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; iy <- tile copy command
MapView_GetTileCopyCommand_IY:
	ld e,ixl
	ld d,ixh
	ld iy,MapView.tileCopyCommand
	add iy,de
	ret

; bc = x
; de = y
; ix = this
; hl <- tile pointer pointer
; de <- row stride
; Modifies: af, bc, de
MapView_GetTileDataPointer:
	push ix
	REPT 4
	sra b
	rr c
	ENDM
	REPT 4
	sra d
	rr e
	ENDM
	push de
	call MapView_GetTileMap
	pop de
	call TileMap_GetTileDataPointer
	ld e,(ix + TileMap.width)
	ld d,(ix + TileMap.width + 1)
	sla e
	rl d
	pop ix
	ret

; ix = this
MapView_DrawBitmap:
	call MapView_MoveHorizontal
	jp MapView_MoveVertical

; ix = this
MapView_MoveHorizontal: PROC
	push ix
	call MapView_GetCamera
	ld l,(ix + Camera.x)
	ld h,(ix + Camera.x + 1)
	ld de,MapView_OFFSET_X
	add hl,de
	pop ix
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	res 0,l
	res 1,l
	res 0,c
	res 1,c
	and a
	sbc hl,bc
	jr z,Idle
	jp p,Right
Left:
	dec bc
	dec bc
	dec bc
	dec bc
Idle:
	ld (ix + MapView.x),c
	ld (ix + MapView.x + 1),b
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	jp MapView_DrawTileColumn
Right:
	inc bc
	inc bc
	inc bc
	inc bc
	ld (ix + MapView.x),c
	ld (ix + MapView.x + 1),b
	ld hl,256 - 4
	add hl,bc
	ld c,l
	ld b,h
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	jp MapView_DrawTileColumn
	ENDP

; ix = this
MapView_MoveVertical: PROC
	push ix
	call MapView_GetCamera
	ld l,(ix + Camera.y)
	ld h,(ix + Camera.y + 1)
	ld de,MapView_OFFSET_Y
	add hl,de
	pop ix
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	res 0,l
	res 1,l
	res 0,e
	res 1,e
	and a
	sbc hl,de
	jr z,Idle
	jp p,Down
Up:
	dec de
	dec de
	dec de
	dec de
Idle:
	ld (ix + MapView.y),e
	ld (ix + MapView.y + 1),d
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	jp MapView_DrawTileRow
Down:
	inc de
	inc de
	inc de
	inc de
	ld (ix + MapView.y),e
	ld (ix + MapView.y + 1),d
	ld hl,256 - 4
	add hl,de
	ex de,hl
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	jp MapView_DrawTileRow
	ENDP

; ix = this
MapView_Start:
	call MapView_Draw
	ret

; ix = this
MapView_Draw: PROC
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	ld a,256 / 4
Loop:
	push af
	push bc
	push de
	call MapView_DrawTileColumn
	pop de
	pop bc
	pop af
	inc bc
	inc bc
	inc bc
	inc bc
	dec a
	jr nz,Loop
	ret
	ENDP

; bc = x
; de = y
; ix = this
MapView_DrawTileColumn: PROC
	ex de,hl
	call MapView_GetTileCopyCommand_IY
	ex de,hl
	ld a,e
	and 0FCH
	ld e,a
	ld (iy + VDPCommand.dy),e
	and 0CH
	ld h,a
	ld a,c
	and 0FCH
	ld c,a
	ld (iy + VDPCommand.dx),c
	and 0CH
	ld l,a
	push hl
	call MapView_GetTileDataPointer
	pop bc
	push ix
	ld (iy + VDPCommand.nx),4
	ld a,16
	sub b
	ld (iy + VDPCommand.ny),a
	call DrawTile
	ld a,b
	push af
	ld b,0
	ld (iy + VDPCommand.ny),16
	REPT 15
	call DrawTile
	ENDM
	pop af
	and a
	ld (iy + VDPCommand.ny),a
	call nz,DrawTile
	pop ix
	ret
DrawTile:
	push bc
	push de
	push hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld ixl,e
	ld ixh,d
	ld a,(ix + Tile.x)
	or c
	ld (iy + VDPCommand.sx),a
	ld a,(ix + Tile.y)
	or b
	ld (iy + VDPCommand.sy),a
	call VDPCommand_ExecuteS2IY
	ld a,(iy + VDPCommand.dy)
	add a,(iy + VDPCommand.ny)
	ld (iy + VDPCommand.dy),a
	pop hl
	pop de
	pop bc
	add hl,de
	ret
	ENDP

; bc = x
; de = y
; ix = this
MapView_DrawTileRow: PROC
	ex de,hl
	call MapView_GetTileCopyCommand_IY
	ex de,hl
	ld a,e
	and 0FCH
	ld e,a
	ld (iy + VDPCommand.dy),e
	and 0CH
	ld h,a
	ld a,c
	and 0FCH
	ld c,a
	ld (iy + VDPCommand.dx),c
	and 0CH
	ld l,a
	push hl
	call MapView_GetTileDataPointer
	pop bc
	push ix
	ld (iy + VDPCommand.ny),4
	ld a,16
	sub c
	ld (iy + VDPCommand.nx),a
	call DrawTile
	ld a,c
	push af
	ld c,0
	ld (iy + VDPCommand.nx),16
	REPT 15
	call DrawTile
	ENDM
	pop af
	and a
	ld (iy + VDPCommand.nx),a
	call nz,DrawTile
	pop ix
	ret
DrawTile:
	push bc
	push hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld ixl,e
	ld ixh,d
	ld a,(ix + Tile.x)
	or c
	ld (iy + VDPCommand.sx),a
	ld a,(ix + Tile.y)
	or b
	ld (iy + VDPCommand.sy),a
	call VDPCommand_ExecuteS2IY
	ld a,(iy + VDPCommand.dx)
	add a,(iy + VDPCommand.nx)
	ld (iy + VDPCommand.dx),a
	pop hl
	pop bc
	inc hl
	inc hl
	ret
	ENDP

; bc = x
; de = y
; ix = tile
; iy = this
MapView_DrawTileIY: PROC
	ld l,(iy + MapView.x)
	ld h,(iy + MapView.x + 1)
	and a
	sbc hl,bc
	jp m,ClampMaxX
ClampMinX:
	ld a,h
	and a
	ret nz
	ld h,l
	ld a,16
	sub l
	ret c
	ret z
	ld l,a
	jr SetX
ClampMaxX:
	inc h
	ret nz
	ld a,l
	and a
	ret z
	cp 16
	jr c,SetX
	ld l,16
SetX:
	ld a,(ix + Tile.x)
	add a,h
	ld (iy + MapView.tileCopyCommand.sx),a
	ld a,c
	add a,h
	ld (iy + MapView.tileCopyCommand.dx),a
	ld (iy + MapView.tileCopyCommand.nx),l
	ld l,(iy + MapView.y)
	ld h,(iy + MapView.y + 1)
	and a
	sbc hl,de
	jp m,ClampMaxY
ClampMinY:
	ld a,h
	and a
	ret nz
	ld h,l
	ld a,16
	sub l
	ret c
	ret z
	ld l,a
	jr SetY
ClampMaxY:
	inc h
	ret nz
	ld a,l
	and a
	ret z
	cp 16
	jr c,SetY
	ld l,16
SetY:
	ld a,(ix + Tile.y)
	add a,h
	ld (iy + MapView.tileCopyCommand.sy),a
	ld a,e
	add a,h
	ld (iy + MapView.tileCopyCommand.dy),a
	ld (iy + MapView.tileCopyCommand.ny),l
	ld e,iyl
	ld d,iyh
	ld hl,MapView.tileCopyCommand
	add hl,de
	jp VDPCommand_ExecuteS2HL
	ENDP
