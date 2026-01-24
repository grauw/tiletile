;
;
;
Player_SPEED: equ 4
Player_COLLIDER_WIDTH: equ 16
Player_COLLIDER_HEIGHT: equ 8

Player: MACRO
	position:
		Vector2W 124, 120
	control:
		dw Player_controlLUT + 15 * PlayerControl._size
	velocity:
		Vector2
	tileMap:
		dw 0
	tileMapWidthStride:
		dw 0
	currentTile:
		dw 0
	ENDM

PlayerControl: MACRO ?rldu
	x: equ (?rldu >> 3 & 1) - (?rldu >> 2 & 1)
	y: equ (?rldu >> 1 & 1) - (?rldu >> 0 & 1)
	velocity:
		Vector2 x * Player_SPEED, y * Player_SPEED
	direction:
		db x < 0 ? 15 : x > 0 ? 5 : y < 0 ? 10 : y > 0 ? 0 : -1
	_size:
	ENDM

; de = tile map
; ix = this
Player_Construct:
	ld (ix + Player.tileMap),e
	ld (ix + Player.tileMap + 1),d
	push ix
	call Player_GetTileMap
	ld l,(ix + TileMap.widthStride)
	ld h,(ix + TileMap.widthStride + 1)
	pop ix
	ld (ix + Player.tileMapWidthStride),l
	ld (ix + Player.tileMapWidthStride + 1),h
	ld bc,124
	ld de,120
	call Player_SetPosition
	ret

; ix = this
; ix <- tile map
Player_GetTileMap:
	ld e,(ix + Player.tileMap)
	ld d,(ix + Player.tileMap + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; bc <- x
; de <- y
Player_GetPosition:
	ld c,(ix + Player.position.x)
	ld b,(ix + Player.position.x + 1)
	ld e,(ix + Player.position.y)
	ld d,(ix + Player.position.y + 1)
	ret

; bc <- x
; de <- y
; ix = this
Player_SetPosition:
	ld (ix + Player.position.x),c
	ld (ix + Player.position.x + 1),b
	ld (ix + Player.position.y),e
	ld (ix + Player.position.y + 1),d
	push ix
	ex de,hl
	call Player_GetTileMap
	ex de,hl
	call TileMap_GetTile
	pop ix
	ld (ix + Player.currentTile),l
	ld (ix + Player.currentTile + 1),h
	ret

; ix = this
; ix <- tile
Player_GetTile:
	ld e,(ix + Player.currentTile)
	ld d,(ix + Player.currentTile + 1)
	ld ixl,e
	ld ixh,d
	ret

; c = x offset (range: -16 .. 16)
; e = y offset (range: -16 .. 16)
; ix = this
; ix <- tile
Player_GetTileWithOffset_IX:
	call Player_GetTileWithOffset
	push hl
	pop ix
	ret

; c = x offset (range: -16 .. 16)
; e = y offset (range: -16 .. 16)
; ix = this
; hl <- tile
Player_GetTileWithOffset: PROC
	ld l,(ix + Player.currentTile)
	ld h,(ix + Player.currentTile + 1)
	ld a,(ix + Player.position.x)
	and 0FH
	add a,c
	and 0F0H
	jr z,ContinueX
	jp p,IncreaseX
DecreaseX:
	dec hl
	dec hl
	dec hl
	dec hl
	jr ContinueX
IncreaseX:
	inc hl
	inc hl
	inc hl
	inc hl
ContinueX:
	ld a,(ix + Player.position.y)
	and 0FH
	add a,e
	and 0F0H
	ret z
	ld e,(ix + Player.tileMapWidthStride)
	ld d,(ix + Player.tileMapWidthStride + 1)
	jp p,IncreaseY
DecreaseY:
	sbc hl,de
	ret
IncreaseY:
	add hl,de
	ret
	ENDP

; ix = this
; iy = input
Player_UpdateInput:
	ld a,(iy + Input.newStick)
	and 0FH
	ld b,a
	add a,a
	add a,b
	add a,Player_controlLUT & 0FFH
	ld (ix + Player.control),a
	ld a,0
	adc a,Player_controlLUT >> 8
	ld (ix + Player.control + 1),a
	ret

; ix = this
; iy = engine
Player_TickPrimary:
	call Player_TickVelocity
	call Player_TickPosition
	ret

; ix = this
Player_TickPosition:
	ld c,(ix + Player.velocity.x)
	ld e,(ix + Player.velocity.y)
	call Player_GetTileWithOffset
	ld (ix + Player.currentTile),l
	ld (ix + Player.currentTile + 1),h
	ld l,(ix + Player.position.x)
	ld h,(ix + Player.position.x + 1)
	ld c,(ix + Player.velocity.x)
	ld a,c
	add a,a
	sbc a,a  ; sign extend
	ld b,a
	add hl,bc
	ld (ix + Player.position.x),l
	ld (ix + Player.position.x + 1),h
	ld l,(ix + Player.position.y)
	ld h,(ix + Player.position.y + 1)
	ld c,(ix + Player.velocity.y)
	ld a,c
	add a,a
	sbc a,a  ; sign extend
	ld b,a
	add hl,bc
	ld (ix + Player.position.y),l
	ld (ix + Player.position.y + 1),h
	ret

; ix = this
; iy = control
Player_TickVelocity:
	push iy
	ld e,(ix + Player.control)
	ld d,(ix + Player.control + 1)
	ld iyl,e
	ld iyh,d
	ld c,(iy + PlayerControl.velocity.x)
	ld e,(iy + PlayerControl.velocity.y)
	pop iy
	ld (ix + Player.velocity.x),c
	ld (ix + Player.velocity.y),e
	call Player_CanMove16x16
	ret c
	ld (ix + Player.velocity.x),0
	ld (ix + Player.velocity.y),0
	ret

; c = x
; e = y
; ix = this
; f <- c: can
Player_CanMove16x16:
	ld a,c
	add a,-Player_COLLIDER_WIDTH / 2
	ld c,a
	ld a,e
	add a,-Player_COLLIDER_HEIGHT / 2
	ld e,a
	call Player_CanMove
	ret nc
	ld a,e
	add a,Player_COLLIDER_HEIGHT - 1
	ld e,a
	call Player_CanMove
	ret nc
	ld a,c
	add a,Player_COLLIDER_WIDTH - 1
	ld c,a
	call Player_CanMove
	ret nc
	ld a,e
	add a,-(Player_COLLIDER_HEIGHT - 1)
	ld e,a
	call Player_CanMove
	ret nc
	ld a,c
	add a,-(Player_COLLIDER_WIDTH / 2 - 1)
	ld c,a
	ld a,e
	add a,Player_COLLIDER_HEIGHT / 2
	ld e,a
	scf
	ret

; c = x
; e = y
; ix = this
; f <- c: can
Player_CanMove:
	push bc
	push de
	push ix
	call Player_GetTileWithOffset_IX
	Tile_IsSolid_M ix
	pop ix
	pop de
	pop bc
	scf
	ret z
	ccf
	ret

;
Player_controlLUT:
	REPT 16, ?value
	PlayerControl ?value ^ 15
	ENDM
