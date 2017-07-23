;
;
;
Player: MACRO
	x:
		dw 112
	y:
		dw 80
	softsprite:
		Softsprite
	ENDM

; ix = this
Player_Construct:
	push ix
	call Player_GetSoftsprite
	call Softsprite_Construct
	pop ix
	ret

; ix = this
Player_GetSoftsprite:
	ld de,Player.softsprite
	add ix,de
	ret

; ix = this
Player_Start:
	ret

; ix = this
Player_PreUpdate:
	push ix
	call Player_GetSoftsprite
	call Softsprite_Clear
	pop ix
	ret

; ix = this
Player_Update:
	call Player_MoveRight
	push ix
	ld l,(ix + Player.x)
	ld h,(ix + Player.y)
	call Player_GetSoftsprite
	ex de,hl
	call Softsprite_SetPosition
	call Softsprite_Draw
	pop ix
	ret

; ix = this
Player_MoveRight:
	ld a,(ix + Player.x)
	add a,2
	ld (ix + Player.x),a
	ret
