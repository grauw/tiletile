;
;
;
Camera: MACRO
	position:
		Vector2W
	maxPosition:
		Vector2W
	size:
		Vector2 248, 240
	scroll:
		Vector2
	ENDM

; de = tile map
; ix = this
Camera_Construct:
	push iy
	ld iyl,e
	ld iyh,d
	ld l,(iy + TileMap.size.x)
	ld h,(iy + TileMap.size.x + 1)
	ld e,(ix + Camera.size.x)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + Camera.maxPosition.x),l
	ld (ix + Camera.maxPosition.x + 1),h
	ld l,(iy + TileMap.size.y)
	ld h,(iy + TileMap.size.y + 1)
	ld e,(ix + Camera.size.y)
	ld d,0
	and a
	sbc hl,de
	call c,System_ThrowException
	ld (ix + Camera.maxPosition.y),l
	ld (ix + Camera.maxPosition.y + 1),h
	pop iy
	ret

; ix = this
; iy = engine
Camera_TickPrimary:
	ld b,(ix + Camera.scroll.x)
	ld a,(ix + Camera.position.x)
	sub b
	sra a
	add a,b
	ld (ix + Camera.scroll.x),a
	ld b,(ix + Camera.scroll.y)
	ld a,(ix + Camera.position.y)
	sub b
	sra a
	add a,b
	ld (ix + Camera.scroll.y),a
	ret

; ix = this
; iy = engine
Camera_TickSecondary:
	ld a,(ix + Camera.position.x)
	ld (ix + Camera.scroll.x),a
	ld a,(ix + Camera.position.y)
	ld (ix + Camera.scroll.y),a
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
	ld e,(ix + Camera.size.x)
	ld d,0
	srl e  ; center
	sbc hl,de
	jp m,Negative
	ld (ix + Camera.position.x),l
	ld (ix + Camera.position.x + 1),h
	ld e,(ix + Camera.maxPosition.x)
	ld d,(ix + Camera.maxPosition.x + 1)
	sbc hl,de
	ret c
	ret z
	ld (ix + Camera.position.x),e
	ld (ix + Camera.position.x + 1),d
	ret
Negative:
	ld (ix + Camera.position.x),0
	ld (ix + Camera.position.x + 1),0
	ret
	ENDP

; hl = target y
; ix = this
Camera_SetTargetY: PROC
	ld e,(ix + Camera.size.y)
	ld d,0
	srl e  ; center
	sbc hl,de
	jp m,Negative
	ld (ix + Camera.position.y),l
	ld (ix + Camera.position.y + 1),h
	ld e,(ix + Camera.maxPosition.y)
	ld d,(ix + Camera.maxPosition.y + 1)
	sbc hl,de
	ret c
	ret z
	ld (ix + Camera.position.y),e
	ld (ix + Camera.position.y + 1),d
	ret
Negative:
	ld (ix + Camera.position.y),0
	ld (ix + Camera.position.y + 1),0
	ret
	ENDP

; ix = this
; iy = game frame
Camera_UpdateGameFrame:
	ld a,(ix + Camera.scroll.y)
	add a,16
	ld c,a
	ld b,(ix + Camera.scroll.x)
	jp GameFrame_SetMapPositionIY

; ix = this
; iy = sprite attribute table
Camera_UpdateSpriteAttributTable:
	ld a,(ix + Camera.scroll.y)
	add a,16
	ld l,a
	ld h,(ix + Camera.scroll.x)
	jp SpriteAttributeTable_SetDisplayPositionIY
