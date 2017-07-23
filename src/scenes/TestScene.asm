;
; Test scene
;
TestScene: MACRO
	super: Scene FieldSet_instance, FieldMap_instance
	player:
		Player
	ENDM

; ix = this
TestScene_Construct:
	call Scene_Construct
	push ix
	call Scene_GetTileSet
	pop ix
	push ix
	push de
	call Scene_GetSpritesIY
	call TestScene_GetPlayer
	pop de
	call Player_Construct
	pop ix
	ret

; ix = this
; ix <- player
TestScene_GetPlayer:
	ld de,TestScene.player
	add ix,de
	ret

; ix = this
TestScene_Start:
	call Scene_Start
	push ix
	call TestScene_GetPlayer
	call Player_Start
	pop ix
	ret

; ix = this
TestScene_Update:
	push ix
	call TestScene_GetPlayer
	call Player_PreUpdate
	pop ix

	call Scene_Update

	push ix
	call TestScene_GetPlayer
	call Player_Update
	pop ix
	ret
