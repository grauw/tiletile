;
; Test scene
;
TestScene: MACRO
	super: Scene FieldSet_instance, FieldMap_instance
	softsprite:
		Softsprite
	ENDM

; ix = this
TestScene_Construct:
	call Scene_Construct
	ret

; ix = this
TestScene_GetSoftsprite:
	ld de,TestScene.softsprite
	add ix,de
	ret

; ix = this
TestScene_Start:
	call Scene_Start
	push ix
	call Scene_GetSprites
	ld de,Sprite_block
	call Sprites_AddSprite
	pop ix
	ret

; ix = this
TestScene_Update:
	push ix
	call TestScene_GetSoftsprite
	call Softsprite_Clear
	pop ix

	call Scene_Update

	push ix
	call TestScene_GetSoftsprite
	call Softsprite_MoveRight
	call Softsprite_Draw
	pop ix

	ld iy,Sprite_block
	ld (iy + Sprite.x),100
	inc (iy + Sprite.y)
	ret
