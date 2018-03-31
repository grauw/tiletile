;
; A view on a section of the map.
;
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

; ix = this
; bc <- x
; de <- y
MapView_GetTargetPosition:
	ld c,(ix + MapView.targetX)
	ld b,(ix + MapView.targetX + 1)
	ld e,(ix + MapView.targetY)
	ld d,(ix + MapView.targetY + 1)
	ret

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
; ix <- tile
; Modifies: af, bc, de
MapView_GetTile:
	REPT 4
	srl b
	rr c
	ENDM
	REPT 4
	srl d
	rr e
	ENDM
	push de
	call MapView_GetTileMap
	pop de
	call TileMap_GetTile
	ret

; ix = this
MapView_Move:
	call MapView_MoveHorizontal
	call MapView_MoveHorizontal
	call MapView_MoveHorizontal
	call MapView_MoveHorizontal
	call MapView_MoveVertical
	call MapView_MoveVertical
	call MapView_MoveVertical
	call MapView_MoveVertical
	ret

; ix = this
MapView_MoveHorizontal: PROC
	ld l,(ix + MapView.targetX)
	ld h,(ix + MapView.targetX + 1)
	ld e,(ix + MapView.x)
	ld d,(ix + MapView.x + 1)
	and a
	sbc hl,de
	ret z
	jr nc,Right
Left:
	dec de
	ld (ix + MapView.x),e
	ld (ix + MapView.x + 1),d
	ld a,e
	jp MapView_DrawTileHorizontal
Right:
	ld a,e
	inc de
	ld (ix + MapView.x),e
	ld (ix + MapView.x + 1),d
	jp MapView_DrawTileHorizontal
	ENDP

; ix = this
MapView_MoveVertical: PROC
	ld l,(ix + MapView.targetY)
	ld h,(ix + MapView.targetY + 1)
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	and a
	sbc hl,de
	ret z
	jp nc,Down
Up:
	dec de
	ld (ix + MapView.y),e
	ld (ix + MapView.y + 1),d
	ld a,e
	rlca
	rlca
	rlca
	rlca
	jp MapView_DrawTile
Down:
	ld a,e
	inc de
	ld (ix + MapView.y),e
	ld (ix + MapView.y + 1),d
	rlca
	rlca
	rlca
	rlca
	jp MapView_DrawTile
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
	call DisplayOffset_SetHorizontalOffsetIY
	ret

; ix = this
MapView_Draw: PROC
	ld a,0
Loop:
	push af
	call MapView_DrawTile
	pop af
	inc a
	jr nz,Loop
	ret
	ENDP

; a = dx.dy
; ix = this
; Modifies: af, bc, de, hl
MapView_DrawTile: PROC
	call MapView_GetTileCopyCommand_IY
	ld l,a
	rrca
	rrca
	rrca
	rrca
	call MapView_GetDrawY
	ld a,l
	and 0F3H
	call DrawSlice
	call DrawSlice
	call DrawSlice
	call DrawSlice
	ret
DrawSlice:
	push af
	push de
	call MapView_GetDrawX
	call MapView_ExecuteDraw
	pop de
	pop af
	add a,4
	ret
	ENDP

; a = dx.dy
; ix = this
; Modifies: af, bc, de, hl
MapView_DrawTileHorizontal: PROC
	call MapView_GetTileCopyCommand_IY
	ld l,a
	call MapView_GetDrawX
	ld a,l
	rrca
	rrca
	rrca
	rrca
	call DrawSlice
	call DrawSlice
	call DrawSlice
	call DrawSlice
	ret
DrawSlice:
	push af
	push bc
	call MapView_GetDrawY
	call MapView_ExecuteDraw
	pop bc
	pop af
	add a,4 << 4
	ret
	ENDP

; a = screen position (dx.dy)
; bc <- x: x.stepx + ((dx.dy - x&15.stepx) & 15.15) - 4
MapView_GetDrawX: PROC
	ld b,(ix + MapView.x + 1)
	cp (ix + MapView.x)
	jr nc,NoCarry
	inc b
NoCarry:
	sub 4
	ld c,a
	ret nc
	dec b
	ret
	ENDP

; a = screen position (dy.dx)
; de <- y: y.stepy + ((dy.dx - y&15.stepy) & 15.15) - 16
MapView_GetDrawY: PROC
	ld d,(ix + MapView.y + 1)
	cp (ix + MapView.y)
	jr nc,NoCarry
	inc d
NoCarry:
	sub 16
	ld e,a
	ret nc
	dec d
	ret
	ENDP

; bc = x
; de = y
; ix = this
; iy = tile copy command
MapView_ExecuteDraw:
	push ix
	ld a,e
	and 0F0H
	ld (iy + VDPCommand.dy),a
	ld a,c
	and 0FCH
	ld (iy + VDPCommand.dx),a
	and 0CH
	push af
	call MapView_GetTile
	ld a,(ix + Tile.x)
	pop de
	or d
	ld (iy + VDPCommand.sx),a
	ld a,(ix + Tile.y)
	ld (iy + VDPCommand.sy),a
	call VDPCommand_Execute_IY
	pop ix
	ret
