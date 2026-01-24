;
; A view on a section of the map.
;
MapView_OFFSET_X: equ -4
MapView_OFFSET_Y: equ -8
MapView_PAGE: equ 0

MapView: MACRO
	tileMap:
		dw 0
	camera:
		dw 0
	position:
		Vector2W MapView_OFFSET_X, MapView_OFFSET_Y
	rowStride:
		dw 0
	verticalDrawCommand:
		VDPCommand 0, 0, 0, MapView_PAGE << 8, 4 << Video_HIRES, 100H, 0, 0, VDPCommand_HMMC
	ENDM

; de = map
; hl = camera
; ix = this
MapView_Construct:
	ld (ix + MapView.tileMap),e
	ld (ix + MapView.tileMap + 1),d
	ld (ix + MapView.camera),l
	ld (ix + MapView.camera + 1),h
	push ix
	call MapView_GetTileMap
	ld bc,0
	ld de,TileMap_TILE_SIZE * TileMap_CHUNK_SIZE
	call TileMap_GetIndex
	pop ix
	add hl,hl
	add hl,hl
	ex de,hl
	ld hl,0
	and a
	sbc hl,de
	ld (ix + MapView.rowStride),l
	ld (ix + MapView.rowStride + 1),h
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

; bc = x
; de = y
; ix = this
; hl <- tile
; Modifies: af, bc, de
MapView_GetTile:
	push ix
	ex de,hl
	call MapView_GetTileMap
	ex de,hl
	call TileMap_GetTile
	pop ix
	ret

; ix = this
MapView_DrawBitmap:
	push ix
	call MapView_GetTileMap
	call TileMap_SelectTiles
	pop ix
	call MapView_MoveVertical
	jp MapView_MoveHorizontal

; ix = this
MapView_MoveHorizontal: PROC
	push ix
	call MapView_GetCamera
	ld l,(ix + Camera.position.x)
	ld h,(ix + Camera.position.x + 1)
	ld de,MapView_OFFSET_X
	add hl,de
	pop ix
	ld c,(ix + MapView.position.x)
	ld b,(ix + MapView.position.x + 1)
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
	ld (ix + MapView.position.x),c
	ld (ix + MapView.position.x + 1),b
	ld e,(ix + MapView.position.y)
	ld d,(ix + MapView.position.y + 1)
	jp MapView_DrawTileColumn
Right:
	inc bc
	inc bc
	inc bc
	inc bc
	ld (ix + MapView.position.x),c
	ld (ix + MapView.position.x + 1),b
	ld hl,256 - 4
	add hl,bc
	ld c,l
	ld b,h
	ld e,(ix + MapView.position.y)
	ld d,(ix + MapView.position.y + 1)
	jp MapView_DrawTileColumn
	ENDP

; ix = this
MapView_MoveVertical: PROC
	push ix
	call MapView_GetCamera
	ld l,(ix + Camera.position.y)
	ld h,(ix + Camera.position.y + 1)
	ld de,MapView_OFFSET_Y
	add hl,de
	pop ix
	ld e,(ix + MapView.position.y)
	ld d,(ix + MapView.position.y + 1)
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
	ld (ix + MapView.position.y),e
	ld (ix + MapView.position.y + 1),d
	ld c,(ix + MapView.position.x)
	ld b,(ix + MapView.position.x + 1)
	jp MapView_DrawTileRow
Down:
	inc de
	inc de
	inc de
	inc de
	ld (ix + MapView.position.y),e
	ld (ix + MapView.position.y + 1),d
	ld hl,256 - 4
	add hl,de
	ex de,hl
	ld c,(ix + MapView.position.x)
	ld b,(ix + MapView.position.x + 1)
	jp MapView_DrawTileRow
	ENDP

; ix = this
MapView_Start:
	push ix
	call MapView_GetTileMap
	call TileMap_SelectTiles
	pop ix
	call MapView_Draw
	ret

; ix = this
MapView_Draw: PROC
	ld c,(ix + MapView.position.x)
	ld b,(ix + MapView.position.x + 1)
	ld e,(ix + MapView.position.y)
	ld d,(ix + MapView.position.y + 1)
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
	push ix
	ld hl,(ROM_mapper.pageA000)
	push hl
	ld iyl,c
	ld iyh,e
	exx         ; set-up for output
	ld c,iyl
	IF Video_HIRES
	xor a
	sla c
	rla
	ld (ix + MapView.verticalDrawCommand.dx),c
	ld (ix + MapView.verticalDrawCommand.dx + 1),a
	ELSE
	ld (ix + MapView.verticalDrawCommand.dx),c
	ENDIF
	ld e,ixl
	ld d,ixh
	ld hl,MapView.verticalDrawCommand
	add hl,de
	call VDPCommand_ExecuteS2HL
	ld bc,VDP_PORT_1
	ld de,(46 | VDP_REGISTER) << 8 | VDPCommand_HMMC
	ld hl,(17 | VDP_REGISTER) << 8 | (44 | 128)
	di
	out (c),b  ; flush colour and restart
	out (c),d
	out (c),l
	out (c),h
	out (c),e
	ei
	out (c),d
	ld a,iyl
	and 0CH
	IF Video_4BPU
	rrca
	ENDIF
	ld l,a
	ld c,VDP_PORT_3
	ld de,16 - 4 >> Video_4BPU
	exx
	inc d       ; set-up tile iteration
	ld e,0
	call MapView_GetTile
	push hl
	ld de,TileMap_CHUNK_SIZE * Tile._size
	ld c,(ix + MapView.rowStride)
	ld b,(ix + MapView.rowStride + 1)
	ld a,iyh
	pop iy
	rrca
	rrca
	ld h,a
	call DrawTilesBeforeSplit
	add iy,bc
	ld a,40H
	sub h
	ld h,a
	call DrawTilesAfterSplit
	pop hl
	ld (hl),l
	pop ix
	ret
; a = h = distance to split / 4
; de = tile stride
; c' = VDP port 3
; de' = tile pixels stride
; l' = tile offset
; iy = tile
DrawTilesBeforeSplit:
	and ~03H
	call nz,DrawTiles16
	ld a,h
	and 03H
	jp nz,DrawTileA
	ret
; a = h = distance from split / 4
; de = tile stride
; c' = VDP port 3
; de' = tile pixels stride
; l' = tile offset
; iy = tile
DrawTilesAfterSplit: PROC
	and 03H
	jr z,Continue
	call DrawTileA
	add iy,de
Continue:
	ld a,h
	and ~03H
	jp nz,DrawTiles16
	ret
	ENDP
DrawTileA:
	bit 0,a
	jr z,DrawTile8
	bit 1,a
	jp nz,DrawTile12
DrawTile4:
	exx
	MapView_GetTileSource_M
	MapView_DrawColumnTile_M 4
	exx
	ret
DrawTile8:
	exx
	MapView_GetTileSource_M
	MapView_DrawColumnTile_M 8
	exx
	ret
DrawTile12:
	exx
	MapView_GetTileSource_M
	MapView_DrawColumnTile_M 12
	exx
	ret
DrawTiles16: PROC
	rrca
	rrca
	ld l,a
Loop:
	exx
	MapView_GetTileSource_M
	MapView_DrawColumnTile_M 16
	exx
	add iy,de
	dec l
	jp nz,Loop
	ret
	ENDP
	ENDP

; bc = x
; de = y
; ix = this
MapView_DrawTileRow: PROC
	push ix
	ld hl,(ROM_mapper.pageA000)
	push hl
	ld iyl,c
	ld iyh,e
	exx         ; set-up for output
	ld a,iyh
	and 0C0H << Video_4BPU
	or MapView_PAGE
	rlca
	IF !Video_4BPU
	rlca
	ENDIF
	di
	out (VDP_PORT_1),a
	ld a,14 | VDP_REGISTER
	ei
	out (VDP_PORT_1),a
	ld d,iyh
	ld a,d
	and 0CH
	add a,a
	add a,a
	add a,a
	IF !Video_4BPU
	add a,a
	ENDIF
	ld l,a
	IF Video_4BPU
	srl d
	ENDIF
	set 6,d
	res 7,d
	ld e,0
	ld c,VDP_PORT_0
	exx
	inc b       ; set-up tile iteration
	ld c,0
	call MapView_GetTile
	push hl
	ld de,Tile._size
	ld bc,-(TileMap_CHUNK_SIZE * TileMap_CHUNK_SIZE * Tile._size)
	ld a,iyl
	pop iy
	rrca
	rrca
	ld h,a
	call DrawTilesBeforeSplit
	add iy,bc
	ld a,40H
	sub h
	ld h,a
	call DrawTilesAfterSplit
	pop hl
	ld (hl),l
	pop ix
	ret
; a = h = distance to split / 4
; de = tile stride
; c' = VDP port 3
; de' = tile pixels stride
; l' = tile offset
; iy = tile
DrawTilesBeforeSplit:
	and ~03H
	call nz,DrawTiles16
	ld a,h
	and 03H
	jp nz,DrawTileA
	ret
; a = h = distance from split / 4
; de = tile stride
; c' = VDP port 3
; de' = tile pixels stride
; l' = tile offset
; iy = tile
DrawTilesAfterSplit: PROC
	and 03H
	jr z,Continue
	call DrawTileA
	add iy,de
Continue:
	ld a,h
	and ~03H
	jp nz,DrawTiles16
	ret
	ENDP
DrawTileA:
	bit 0,a
	jr z,DrawTile8
	bit 1,a
	jp nz,DrawTile12
DrawTile4:
	exx
	MapView_GetTileSource_M
	MapView_DrawRowTile_M 4
	exx
	ret
DrawTile8:
	exx
	MapView_GetTileSource_M
	MapView_DrawRowTile_M 8
	exx
	ret
DrawTile12:
	exx
	MapView_GetTileSource_M
	MapView_DrawRowTile_M 12
	exx
	ret
DrawTiles16: PROC
	rrca
	rrca
	ld l,a
Loop:
	exx
	MapView_GetTileSource_M
	MapView_DrawRowTile_M 16
	exx
	add iy,de
	dec l
	jp nz,Loop
	ret
	ENDP
	ENDP

; l = tile offset (msb ignored in 4bpp mode)
; iy = tile
; l <- tile offset (msb ignored in 4bpp mode)
; hl <- tile pixels
MapView_GetTileSource_M: MACRO
	ld a,(iy + Tile.image.bank)
	ld (ROM_mapper.pageA000.BANK_SELECT),a
	IF Video_4BPU
	ld h,(iy + Tile.image.address)
	add hl,hl
	rr l
	ENDIF
	ld h,(iy + Tile.image.address + 1)
	ENDM

; c = VDP port 3
; de = tile pixels stride
; hl = tile pixels
MapView_DrawColumnTile_M: MACRO ?lines
	REPT ?lines
	REPT 4 >> Video_4BPU
	outi
	ENDM
	add hl,de
	ENDM
	ENDM

; c = VDP port 0
; de = VRAM destination (14-bit | 4000H)
; hl = tile pixels
MapView_DrawRowTile_M: MACRO ?pixels
	ld a,l
	MapView_DrawRowTileLine_M ?pixels
	IF ?pixels != 16
	add a,16 >> Video_4BPU
	ld l,a
	ENDIF
	IF Video_4BPU
	set 7,e
	ELSE
	inc d
	ENDIF
	MapView_DrawRowTileLine_M ?pixels
	IF ?pixels != 16
	add a,16 >> Video_4BPU
	ld l,a
	ENDIF
	IF Video_4BPU
	res 7,e
	ENDIF
	inc d
	MapView_DrawRowTileLine_M ?pixels
	IF ?pixels != 16
	add a,16 >> Video_4BPU
	ld l,a
	ENDIF
	IF Video_4BPU
	set 7,e
	ELSE
	inc d
	ENDIF
	MapView_DrawRowTileLine_M ?pixels
	IF ?pixels != 16
	add a,-48 + ?pixels >> Video_4BPU
	and ~33H >> Video_4BPU
	ENDIF
	ld l,a
	IF !Video_4BPU
	dec d
	dec d
	ENDIF
	dec d
	ld a,e
	add a,-100H + ?pixels >> Video_4BPU
	ld e,a
	ENDM

; c = VDP port 0
; hl = tile pixels
MapView_DrawRowTileLine_M: MACRO ?pixels
	inc c
	di
	out (c),e
	ei
	out (c),d
	dec c
	REPT ?pixels >> Video_4BPU
	outi
	ENDM
	ENDM
