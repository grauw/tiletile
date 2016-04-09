;
; A view on a section of the map.
;
MapView_SCROLLSPEED: equ 1

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
		db 16
	tileCopyCommand: VDPCommand 0, 200H, 0, 0, 16, 16, 0, 0, VDPCommand_HMMM
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
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
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
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
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

; bc = x
; de = y
; ix = this
; hl <- position
; Modifies: af, bc, de
MapView_GetDataPosition:
	REPT 4
	srl b
	rr c
	ENDM
	REPT 4
	srl d
	rr e
	ENDM
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
	ld de,-MapView_SCROLLSPEED
	add hl,de
	ret nc
	ld (ix + MapView.x),l
	ld (ix + MapView.x + 1),h
	ld de,-16
	add hl,de
	ld c,l
	ld b,h
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	ld hl,-16
	add hl,de
	ex de,hl
	call MapView_DrawColumn
	ret

; ix = this
MapView_MoveRight:
	ld l,(ix + MapView.x)
	ld h,(ix + MapView.x + 1)
	ld de,MapView_SCROLLSPEED
	add hl,de
	ld e,(ix + MapView.maxX)
	ld d,(ix + MapView.maxX + 1)
	ex de,hl
	sbc hl,de
	ret c
	ld (ix + MapView.x),e
	ld (ix + MapView.x + 1),d
	ld hl,240 - 1
	add hl,de
	ld c,l
	ld b,h
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	ld hl,-16
	add hl,de
	ex de,hl
	call MapView_DrawColumn
	ret

; ix = this
MapView_MoveUp:
	ld l,(ix + MapView.y)
	ld h,(ix + MapView.y + 1)
	ld de,-MapView_SCROLLSPEED
	add hl,de
	ret nc
	ld (ix + MapView.y),l
	ld (ix + MapView.y + 1),h
	ld de,-16
	add hl,de
	ex de,hl
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	ld hl,-16
	add hl,bc
	ld c,l
	ld b,h
	call MapView_DrawRow
	ret

; ix = this
MapView_MoveDown:
	ld l,(ix + MapView.y)
	ld h,(ix + MapView.y + 1)
	ld de,MapView_SCROLLSPEED
	add hl,de
	ld e,(ix + MapView.maxY)
	ld d,(ix + MapView.maxY + 1)
	ex de,hl
	sbc hl,de
	ret c
	ld (ix + MapView.y),e
	ld (ix + MapView.y + 1),d
	ld hl,240 - 1
	add hl,de
	ex de,hl
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	ld hl,-16
	add hl,bc
	ld c,l
	ld b,h
	call MapView_DrawRow
	ret

; ix = this
MapView_Update:
	ld a,(VDP_MIRROR_25 + 25)
	or 00000010B
	ld (VDP_MIRROR_25 + 25),a
	ld b,25
	call VDP_SetRegister
	ld a,(ix + MapView.y)
	ld b,23
	call VDP_SetRegister
	ld a,(ix + MapView.x)
	neg
	and 07H
	ld b,27
	call VDP_SetRegister
	ld a,(ix + MapView.x)
	dec a
	srl a
	srl a
	srl a
	ld b,26
	call VDP_SetRegister
	ret

; ix = this
MapView_Draw: PROC
	ld e,(ix + MapView.y)
	ld d,(ix + MapView.y + 1)
	ld a,(ix + MapView.height)
RowLoop:
	push af
	ld c,(ix + MapView.x)
	ld b,(ix + MapView.x + 1)
	ld a,(ix + MapView.width)
TileLoop:
	push af
	push bc
	push de
	ld a,c
	and 0F0H
	ld h,a
	ld a,e
	and 0F0H
	ld l,a
	push hl
	call MapView_GetDataPosition
	call MapView_GetTileCopyCommand_IY
	ld a,(hl)
	pop de
	call MapView_DrawTile
	pop de
	pop bc
	pop af
	ld hl,16
	add hl,bc
	ld c,l
	ld b,h
	dec a
	jr nz,TileLoop
	pop af
	ld hl,16
	add hl,de
	ex de,hl
	dec a
	jr nz,RowLoop
	ret
	ENDP

; bc = x
; de = y
; ix = this
MapView_DrawRow: PROC
	ld a,e
	and 0F0H
	ld l,a  ; dy
	ld a,e
	add a,a
	add a,a
	add a,a
	add a,a
	ld h,a  ; dx
	push hl
	ld a,l  ; x.stepx + ((dx.dy - x&15.stepx) & 15.15)
	rrca
	rrca
	rrca
	rrca
	or h
	sub c
	add a,c
	ld c,a
	jr nc,NoCarry
	inc b
NoCarry:
	call MapView_GetDataPosition
	ld a,(hl)
	call MapView_GetTileCopyCommand_IY
	pop de
	call MapView_DrawTile
	ret
	ENDP

; bc = x
; de = y
; ix = this
MapView_DrawColumn: PROC
	ld a,c
	and 0F0H
	ld h,a  ; dx
	ld a,c
	add a,a
	add a,a
	add a,a
	add a,a
	ld l,a  ; dy
	push hl
	ld a,h  ; y.stepy + ((dy.dx - y&15.stepy) & 15.15)
	rrca
	rrca
	rrca
	rrca
	or l
	sub e
	add a,e
	ld e,a
	jr nc,NoCarry
	inc d
NoCarry:
	call MapView_GetDataPosition
	ld a,(hl)
	call MapView_GetTileCopyCommand_IY
	pop de
	call MapView_DrawTile
	ret
	ENDP

; a = tile
; d = dx
; e = dy
; ix = this
; iy = VDP command
; Modifies: af, bc, hl
MapView_DrawTile:
	ld (iy + VDPCommand.dx),d
	ld (iy + VDPCommand.dy),e
	ld h,a
	add a,a
	add a,a
	add a,a
	add a,a
	ld (iy + VDPCommand.sx),a
	ld a,h
	and 0F0H
	ld (iy + VDPCommand.sy),a
	call VDPCommand_Execute_IY
	ret
