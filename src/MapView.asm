;
; A view on a section of the map.
;
MapView_OFFSET_X: equ 0
MapView_OFFSET_Y: equ -16

MapView: MACRO
	tileMap:
		dw 0
	x:
		dw 0
	y:
		dw 0
	targetX:
		dw 0
	targetY:
		dw 0
	maxX:
		dw 0
	maxY:
		dw 0
	width:
		db 248
	height:
		db 212
	tileCopyCommand: VDPCommand 0, 200H, 0, 0, 4, 16, 0, 0, VDPCommand_HMMM
	ENDM

; de = map
; ix = this
MapView_Construct:
	ld (ix + MapView.tileMap),e
	ld (ix + MapView.tileMap + 1),d
	push ix
	call MapView_GetTileMap
	ld l,(ix + TileMap.width)
	ld h,(ix + TileMap.width + 1)
	pop ix
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,(ix + MapView.width)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + MapView.maxX),l
	ld (ix + MapView.maxX + 1),h
	push ix
	call MapView_GetTileMap
	ld l,(ix + TileMap.height)
	ld h,(ix + TileMap.height + 1)
	pop ix
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,(ix + MapView.height)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + MapView.maxY),l
	ld (ix + MapView.maxY + 1),h
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
MapView_SetTargetPosition:
	push bc
	ex de,hl
	call MapView_SetTargetY
	pop hl
	jp MapView_SetTargetX

; hl = target x
; ix = this
MapView_SetTargetX: PROC
	ld e,(ix + MapView.width)
	ld d,0
	srl e  ; center
	sbc hl,de
	jp m,Negative
	ld (ix + MapView.targetX),l
	ld (ix + MapView.targetX + 1),h
	ld e,(ix + MapView.maxX)
	ld d,(ix + MapView.maxX + 1)
	sbc hl,de
	ret c
	ret z
	ld (ix + MapView.targetX),e
	ld (ix + MapView.targetX + 1),d
	ret
Negative:
	ld (ix + MapView.targetX),0
	ld (ix + MapView.targetX + 1),0
	ret
	ENDP

; hl = target y
; ix = this
MapView_SetTargetY: PROC
	ld e,(ix + MapView.height)
	ld d,0
	srl e  ; center
	sbc hl,de
	jp m,Negative
	ld (ix + MapView.targetY),l
	ld (ix + MapView.targetY + 1),h
	ld e,(ix + MapView.maxY)
	ld d,(ix + MapView.maxY + 1)
	sbc hl,de
	ret c
	ret z
	ld (ix + MapView.targetY),e
	ld (ix + MapView.targetY + 1),d
	ret
Negative:
	ld (ix + MapView.targetY),0
	ld (ix + MapView.targetY + 1),0
	ret
	ENDP

; bc = x
; de = y
; ix = this
; hl <- tile pointer pointer
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
MapView_Move:
	call MapView_MoveHorizontal
	jp MapView_MoveVertical

; ix = this
MapView_MoveHorizontal: PROC
	ld l,(ix + MapView.targetX)
	ld h,(ix + MapView.targetX + 1)
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	res 0,l
	res 1,l
	res 0,c
	res 1,c
	and a
	sbc hl,bc
	ret z
	jr nc,Right
Left:
	dec bc
	dec bc
	dec bc
	dec bc
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
	ld hl,256 - 4 - 4
	add hl,bc
	ld c,l
	ld b,h
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	jp MapView_DrawTileColumn
	ENDP

; ix = this
MapView_MoveVertical: PROC
	ld l,(ix + MapView.targetY)
	ld h,(ix + MapView.targetY + 1)
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	res 0,l
	res 1,l
	res 0,e
	res 1,e
	and a
	sbc hl,de
	ret z
	jp nc,Down
Up:
	dec de
	dec de
	dec de
	dec de
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
	ld hl,256 - 4 - 4
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
; iy = display offset
MapView_Update:
	ld a,(ix + MapView.targetY)
	call DisplayOffset_SetVerticalOffsetIY
	ld a,(ix + MapView.targetX)
	jp DisplayOffset_SetHorizontalOffsetIY

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
	IF MapView_OFFSET_X
	ld hl,MapView_OFFSET_X
	add hl,bc
	ld c,l
	ld b,h
	ENDIF
	ld hl,MapView_OFFSET_Y
	add hl,de
	push hl
	call MapView_GetTileCopyCommand_IY
	pop de
	ld a,c
	sub e
	and 0FH
	ld l,a
	ld h,0
	add hl,de
	ld e,l
	ld d,h
	ld a,e
	and 0F0H
	ld e,a
	ld (iy + VDPCommand.dy),e
	ld a,c
	and 0FCH
	ld c,a
	ld (iy + VDPCommand.dx),c
	push af
	call MapView_GetTileDataPointer
	pop af
	and 0CH
	ld c,a
	ld b,16
Loop:
	push bc
	push de
	push hl
	push ix
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld ixl,e
	ld ixh,d
	ld a,(ix + Tile.x)
	or c
	ld (iy + VDPCommand.sx),a
	ld a,(ix + Tile.y)
	ld (iy + VDPCommand.sy),a
	call VDPCommand_Execute_IY
	ld a,(iy + VDPCommand.dy)
	add a,16
	ld (iy + VDPCommand.dy),a
	pop ix
	pop hl
	pop de
	pop bc
	add hl,de
	djnz Loop
	ret
	ENDP

; bc = x
; de = y
; ix = this
MapView_DrawTileRow: PROC
	IF MapView_OFFSET_X
	ld hl,MapView_OFFSET_X
	add hl,bc
	ld c,l
	ld b,h
	ENDIF
	ld hl,MapView_OFFSET_Y
	add hl,de
	push hl
	call MapView_GetTileCopyCommand_IY
	pop de
	ld a,e
	sub c
	and 0FH
	ld l,a
	ld h,0
	add hl,bc
	ld c,l
	ld b,h
	ld a,e
	and 0F0H
	ld e,a
	ld (iy + VDPCommand.dy),e
	ld a,c
	and 0FCH
	ld c,a
	ld (iy + VDPCommand.dx),c
	push af
	call MapView_GetTileDataPointer
	pop af
	and 0CH
	ld c,a
	ld b,16
Loop:
	push bc
	push hl
	push ix
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld ixl,e
	ld ixh,d
	ld a,(ix + Tile.x)
	or c
	ld (iy + VDPCommand.sx),a
	ld a,(ix + Tile.y)
	ld (iy + VDPCommand.sy),a
	call VDPCommand_Execute_IY
	ld a,(iy + VDPCommand.dx)
	add a,16
	ld (iy + VDPCommand.dx),a
	pop ix
	pop hl
	pop bc
	inc hl
	inc hl
	djnz Loop
	ret
	ENDP
