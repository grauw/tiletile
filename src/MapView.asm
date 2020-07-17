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
	verticalDrawCommand:
		VDPCommand 0, 0, 0, MapView_PAGE << 8, 4 * Video_X_SCALE, 100H, 0, 0, VDPCommand_HMMC
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

; bc = x
; de = y
; ix = this
; hl <- tile
; de <- row stride
; Modifies: af, bc, de
MapView_GetTile:
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
	call TileMap_GetTile
	ld e,(ix + TileMap.size.x)
	ld d,(ix + TileMap.size.x + 1)
	sla e
	rl d
	sla e
	rl d
	pop ix
	ret

; ix = this
MapView_DrawBitmap:
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
	ld hl,(ROMMapper_instance.pageA000)
	push hl
	ld iyl,c
	ld iyh,e
	exx         ; set-up for output
	ld c,iyl
	IF Video_X_SCALE = 2
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
	IF Video_X_BYTE = 2
	rrca
	ENDIF
	ld iyl,a
	ld c,VDP_PORT_3
	ld de,(16 - 4) / Video_X_BYTE
	exx
	inc d       ; set-up tile iteration
	ld e,0
	call MapView_GetTile
	push hl
	pop ix
	ld hl,0
	and a
	sbc hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld c,l
	ld b,h
	ld a,iyh
	ld h,a
	rrca
	rrca
	rrca
	rrca
	and 0FH
	ld l,a
	push hl
	call nz,Loop
	pop hl
	ld a,16
	sub l
	ld l,a
	call SplitAndLoop
	pop hl
	ld (hl),l
	pop ix
	ret
; bc = tile wrap stride
; de = tile stride
; l = tile count
; h = distance to split
; c' = VDP port 3
; de' = tile pixels stride
; ix = tile
; iyl = x offset
Loop:
	exx
	MapView_GetTileSource_M iyl
	MapView_DrawColumnTile_M 16
	exx
Continue:
	add ix,de
	dec l
	jp nz,Loop
	ret
SplitAndLoop:
	bit 3,h
	jr nz,Split8_12
	bit 2,h
	jr nz,Split4
Split0:
	add ix,bc
	jp Loop
Split4:
	exx
	call DrawColumnTile4
	exx
	add ix,bc
	ld a,iyl
	ld c,a
	add a,4 * 16 / Video_X_BYTE
	ld iyl,a
	exx
	call DrawColumnTile12
	exx
	ld iyl,c
	jp Continue
Split8_12:
	bit 2,h
	jr nz,Split12
Split8:
	exx
	call DrawColumnTile8
	exx
	add ix,bc
	ld a,iyl
	ld c,a
	add a,8 * 16 / Video_X_BYTE
	ld iyl,a
	exx
	call DrawColumnTile8
	exx
	ld iyl,c
	jp Continue
Split12:
	exx
	call DrawColumnTile12
	exx
	add ix,bc
	ld a,iyl
	ld c,a
	add a,12 * 16 / Video_X_BYTE
	ld iyl,a
	exx
	call DrawColumnTile4
	exx
	ld iyl,c
	jp Continue
DrawColumnTile4:
	MapView_GetTileSource_M iyl
	MapView_DrawColumnTile_M 4
	ret
DrawColumnTile8:
	MapView_GetTileSource_M iyl
	MapView_DrawColumnTile_M 8
	ret
DrawColumnTile12:
	MapView_GetTileSource_M iyl
	MapView_DrawColumnTile_M 12
	ret
	ENDP

; c = VDP port 3
; de = tile pixels stride
; hl = tile pixels
MapView_DrawColumnTile_M: MACRO ?lines
	REPT ?lines
	REPT 4 / Video_X_BYTE
	outi
	ENDM
	add hl,de
	ENDM
	ENDM

; bc = x
; de = y
; ix = this
MapView_DrawTileRow: PROC
	push ix
	ld hl,(ROMMapper_instance.pageA000)
	push hl
	ld iyl,c
	ld iyh,e
	exx         ; set-up for output
	ld a,iyh
	and Video_X_BYTE = 2 ? 80H : 0C0H
	or MapView_PAGE
	rlca
	IF Video_X_BYTE = 1
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
	IF Video_X_BYTE = 1
	add a,a
	ENDIF
	ld iyh,a
	IF Video_X_BYTE = 2
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
	pop ix
	ld de,Tile._size
	ld bc,-16 * Tile._size
	ld a,iyl
	ld h,a
	rrca
	rrca
	rrca
	rrca
	and 0FH
	ld l,a
	push hl
	call nz,Loop
	pop hl
	ld a,16
	sub l
	ld l,a
	call SplitAndLoop
	pop hl
	ld (hl),l
	pop ix
	ret
; bc = tile wrap stride
; de = tile stride
; l = tile count
; h = distance to split
; c' = VDP port 0
; de' = VRAM address (14-bit | 4000H)
; ix = tile
; iyh = y offset
Loop:
	exx
	MapView_GetTileSource_M iyh
	MapView_DrawRowTile_M 16
	exx
Continue:
	add ix,de
	dec l
	jp nz,Loop
	ret
SplitAndLoop:
	bit 3,h
	jr nz,Split8_12
	bit 2,h
	jr nz,Split4
Split0:
	add ix,bc
	jp Loop
Split4:
	exx
	call DrawRowTile4
	exx
	add ix,bc
	ld a,iyh
	ld c,a
	add a,4 / Video_X_BYTE
	ld iyh,a
	exx
	call DrawRowTile12
	exx
	ld iyh,c
	jr Continue
Split8_12:
	bit 2,h
	jr nz,Split12
Split8:
	exx
	call DrawRowTile8
	exx
	add ix,bc
	ld a,iyh
	ld c,a
	add a,8 / Video_X_BYTE
	ld iyh,a
	exx
	call DrawRowTile8
	exx
	ld iyh,c
	jr Continue
Split12:
	exx
	call DrawRowTile12
	exx
	add ix,bc
	ld a,iyh
	ld c,a
	add a,12 / Video_X_BYTE
	ld iyh,a
	exx
	call DrawRowTile4
	exx
	ld iyh,c
	jr Continue
DrawRowTile4:
	MapView_GetTileSource_M iyh
	MapView_DrawRowTile_M 4
	ret
DrawRowTile8:
	MapView_GetTileSource_M iyh
	MapView_DrawRowTile_M 8
	ret
DrawRowTile12:
	MapView_GetTileSource_M iyh
	MapView_DrawRowTile_M 12
	ret
	ENDP

; ix = tile
; hl <- tile pixels
MapView_GetTileSource_M: MACRO ?offset
	ld a,(ix + Tile.image.bank)
	ld (ROMMapper_instance.pageA000.BANK_SELECT),a
	IF Video_X_BYTE = 2
	ld a,(ix + Tile.image.address)
	or ?offset
	ld l,a
	ELSE
	ld a,?offset
	ld l,a
	ENDIF
	ld h,(ix + Tile.image.address + 1)
	ENDM

; c = VDP port 0
; de = VRAM destination (14-bit | 4000H)
; hl = tile pixels
MapView_DrawRowTile_M: MACRO ?pixels
	MapView_DrawRowTileLine_M ?pixels
	IF Video_X_BYTE = 2
	set 7,e
	ELSE
	inc d
	ENDIF
	MapView_DrawRowTileLine_M ?pixels
	IF Video_X_BYTE = 2
	res 7,e
	ENDIF
	inc d
	MapView_DrawRowTileLine_M ?pixels
	IF Video_X_BYTE = 2
	set 7,e
	ELSE
	inc d
	ENDIF
	MapView_DrawRowTileLine_M ?pixels
	IF Video_X_BYTE = 1
	dec d
	dec d
	ENDIF
	dec d
	ld a,e
	add a,(-100H + ?pixels) / Video_X_BYTE
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
	REPT ?pixels / Video_X_BYTE
	outi
	ENDM
	IF ?pixels != 16
	ld a,l
	add a,(16 - ?pixels) / Video_X_BYTE
	ld l,a
	ENDIF
	ENDM
