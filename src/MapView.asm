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
		VDPCommand 0, 0, 0, MapView_PAGE << 8, 4, 100H, 0, 0, VDPCommand_HMMC
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
	ld e,(ix + TileMap.size.x)
	ld d,(ix + TileMap.size.x + 1)
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
	ld hl,(ROM_bankA000)
	push hl
	push bc
	push de
	ld (ix + MapView.verticalDrawCommand.dx),c
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
	pop de
	pop bc
	call Draw
	pop hl
	ld (hl),l
	pop ix
	ret
Draw:
	ld iyl,c
	ld iyh,e
	inc d
	ld e,0
	call MapView_GetTileDataPointer
	push de
	exx
	pop de
	ld hl,0
	and a
	sbc hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld c,l
	ld b,h
	exx
	ex de,hl
	ld ixl,e
	ld ixh,d
	ld a,iyl
	and 0CH
	rrca
	ld iyl,a
	ld bc,16 << 8 | VDP_PORT_3
	ld de,8 - 2
; c = VDP port 3
; de = tile source stride
; de' = tile pointer stride
; bc' = tile pointer wrap stride
; ix = tile pointer
; iyl = x offset
; iyh = y distance to split
Loop:
	ld a,iyh
	sub 16
	ld iyh,a
	jp c,Split
NoSplit:
	MapView_GetTileSource_M iyl
	MapView_DrawColumnTile_M 16
Continue:
	exx
	add ix,de
	exx
	djnz Loop
	ret
Split:
	add a,16
	jr z,Split0
	cp 8
	jr c,Split4
	jr z,Split8
	jr Split12
Split0:
	exx
	add ix,bc
	exx
	jp NoSplit
Split4:
	call GetTileSource
	call DrawColumnTile4
	exx
	add ix,bc
	exx
	push iy
	ld a,iyl
	add a,4 * 8
	ld iyl,a
	call GetTileSource
	call DrawColumnTile12
	pop iy
	jp Continue
Split8:
	call GetTileSource
	call DrawColumnTile8
	exx
	add ix,bc
	exx
	push iy
	ld a,iyl
	add a,8 * 8
	ld iyl,a
	call GetTileSource
	call DrawColumnTile8
	pop iy
	jp Continue
Split12:
	call GetTileSource
	call DrawColumnTile12
	exx
	add ix,bc
	exx
	push iy
	ld a,iyl
	add a,12 * 8
	ld iyl,a
	call GetTileSource
	call DrawColumnTile4
	pop iy
	jp Continue
GetTileSource:
	MapView_GetTileSource_M iyl
	ret
DrawColumnTile12:
	MapView_DrawColumnTile_M 4
DrawColumnTile8:
	MapView_DrawColumnTile_M 4
DrawColumnTile4:
	MapView_DrawColumnTile_M 4
	ret
	ENDP

; c = VDP port 3
; de = tile source stride
; hl = tile source
MapView_DrawColumnTile_M: MACRO ?count
	REPT ?count
	outi
	outi
	add hl,de
	ENDM
	ENDM

; bc = x
; de = y
; ix = this
MapView_DrawTileRow: PROC
	push ix
	ld hl,(ROM_bankA000)
	push hl
	ld a,e
	and 80H
	or MapView_PAGE
	rlca
	di
	out (VDP_PORT_1),a
	ld a,14 | VDP_REGISTER
	ei
	out (VDP_PORT_1),a
	call Draw
	pop hl
	ld (hl),l
	pop ix
	ret
Draw:
	ld iyl,c
	ld iyh,e
	inc b
	ld c,0
	call MapView_GetTileDataPointer
	exx
	ld bc,-16 * 2
	exx
	ex de,hl
	ld ixl,e
	ld ixh,d
	ld d,iyh
	ld a,d
	and 0CH
	add a,a
	add a,a
	add a,a
	ld iyh,a
	srl d
	set 6,d
	res 7,d
	ld e,0
	ld c,VDP_PORT_0
; c = VDP port 0
; de = VRAM address (14-bit | 4000H)
; bc' = tile pointer wrap stride
; ix = tile pointer
; iyl = x distance to split
; iyh = y offset
Loop:
	ld a,iyl
	sub 16
	ld iyl,a
	jp c,Split
NoSplit:
	MapView_GetTileSource_M iyh
	MapView_DrawRowTile_M 8
Continue:
	inc ix
	inc ix
	jp p,Loop
	ret
Split:
	add a,16
	jr z,Split0
	cp 8
	jr c,Split4
	jr z,Split8
	jr Split12
Split0:
	exx
	add ix,bc
	exx
	jp NoSplit
Split4:
	call GetTileSource
	call DrawRowTile4
	exx
	add ix,bc
	exx
	push iy
	ld a,iyh
	add a,2
	ld iyh,a
	call GetTileSource
	call DrawRowTile12
	pop iy
	jr Continue
Split8:
	call GetTileSource
	call DrawRowTile8
	exx
	add ix,bc
	exx
	push iy
	ld a,iyh
	add a,4
	ld iyh,a
	call GetTileSource
	call DrawRowTile8
	pop iy
	jr Continue
Split12:
	call GetTileSource
	call DrawRowTile12
	exx
	add ix,bc
	exx
	push iy
	ld a,iyh
	add a,6
	ld iyh,a
	call GetTileSource
	call DrawRowTile4
	pop iy
	jr Continue
GetTileSource:
	MapView_GetTileSource_M iyh
	ret
DrawRowTile4:
	MapView_DrawRowTile_M 2
	ret
DrawRowTile8:
	MapView_DrawRowTile_M 4
	ret
DrawRowTile12:
	MapView_DrawRowTile_M 6
	ret
	ENDP

; ix = tile pointer
; hl <- tile source
MapView_GetTileSource_M: MACRO ?offset
	ld l,(ix)
	ld h,(ix + 1)
	ld a,(hl)
	ld (ROM_BANK_A000_CHANGE),a
	inc hl
	ld a,(hl)
	inc hl
	ld h,(hl)
	add a,?offset
	ld l,a
	ENDM

; c = VDP port 0
; de = VRAM destination (14-bit | 4000H)
; hl = tile source
; f <- p: end of odd line reached
MapView_DrawRowTile_M: MACRO ?count
	ld a,e
	MapView_DrawRowTileLine_M ?count, a, d
	add a,80H
	MapView_DrawRowTileLine_M ?count, a, d
	add a,80H
	inc d
	MapView_DrawRowTileLine_M ?count, a, d
	add a,80H
	MapView_DrawRowTileLine_M ?count, a, d
	dec d
	add a,80H + ?count
	ld e,a
	ENDM

; c = VDP port 0
; hl = tile source
MapView_DrawRowTileLine_M: MACRO ?count, ?vramLSB, ?vramMSB
	inc c
	di
	out (c),?vramLSB
	ei
	out (c),?vramMSB
	dec c
	REPT ?count
	outi
	ENDM
	REPT 8 - ?count
	inc l
	ENDM
	ENDM
