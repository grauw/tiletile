;
;
;
Camera: MACRO
	x:
		dw 0
	y:
		dw 0
	width:
		db 248
	height:
		db 240
	scrollX:
		db 0
	scrollY:
		db 0
	maxX:
		dw 0
	maxY:
		dw 0
	ENDM

; de = tile map
; ix = this
Camera_Construct:
	push iy
	ld iyl,e
	ld iyh,d
	ld l,(iy + TileMap.width)
	ld h,(iy + TileMap.width + 1)
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,(ix + Camera.width)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + Camera.maxX),l
	ld (ix + Camera.maxX + 1),h
	ld l,(iy + TileMap.height)
	ld h,(iy + TileMap.height + 1)
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,(ix + Camera.height)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + Camera.maxY),l
	ld (ix + Camera.maxY + 1),h
	pop iy
	ret

; ix = this
; iy = engine
Camera_TickPrimary:
	ld b,(ix + Camera.scrollX)
	ld a,(ix + Camera.x)
	sub b
	sra a
	add a,b
	ld (ix + Camera.scrollX),a
	ld b,(ix + Camera.scrollY)
	ld a,(ix + Camera.y)
	sub b
	sra a
	add a,b
	ld (ix + Camera.scrollY),a
	ret

; ix = this
; iy = engine
Camera_TickSecondary:
	ld a,(ix + Camera.x)
	ld (ix + Camera.scrollX),a
	ld a,(ix + Camera.y)
	ld (ix + Camera.scrollY),a
	ret

; bc = x
; de = y
; ix = this
Camera_SetTargetPosition:
	push bc
	ex de,hl
	call Camera_SetTargetY
	pop hl
	jp Camera_SetTargetX

; hl = target x
; ix = this
Camera_SetTargetX: PROC
	ld e,(ix + Camera.width)
	ld d,0
	srl e  ; center
	sbc hl,de
	jp m,Negative
	ld (ix + Camera.x),l
	ld (ix + Camera.x + 1),h
	ld e,(ix + Camera.maxX)
	ld d,(ix + Camera.maxX + 1)
	sbc hl,de
	ret c
	ret z
	ld (ix + Camera.x),e
	ld (ix + Camera.x + 1),d
	ret
Negative:
	ld (ix + Camera.x),0
	ld (ix + Camera.x + 1),0
	ret
	ENDP

; hl = target y
; ix = this
Camera_SetTargetY: PROC
	ld e,(ix + Camera.height)
	ld d,0
	srl e  ; center
	sbc hl,de
	jp m,Negative
	ld (ix + Camera.y),l
	ld (ix + Camera.y + 1),h
	ld e,(ix + Camera.maxY)
	ld d,(ix + Camera.maxY + 1)
	sbc hl,de
	ret c
	ret z
	ld (ix + Camera.y),e
	ld (ix + Camera.y + 1),d
	ret
Negative:
	ld (ix + Camera.y),0
	ld (ix + Camera.y + 1),0
	ret
	ENDP

; ix = this
; iy = game frame
Camera_UpdateGameFrame:
	ld a,(ix + Camera.scrollY)
	add a,16
	ld c,a
	ld b,(ix + Camera.scrollX)
	jp GameFrame_SetMapPositionIY

; ix = this
; iy = sprite attribute table
Camera_UpdateSpriteAttributTable:
	ld a,(ix + Camera.scrollY)
	add a,16
	ld l,a
	ld h,(ix + Camera.scrollX)
	jp SpriteAttributeTable_SetDisplayPositionIY
