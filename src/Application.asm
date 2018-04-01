;
; Top-level program class
;
Application: MACRO
	originalKeyClick:
		db 0
	engine:
		Engine
	scene:
		Scene FieldSet_instance, FieldMap_instance
	ENDM

Application_Main:
	call VDP_GetVersion
	cp 2
	ret c

	call ROM_Init
	call RAM_Init

	call System_SetDirectBIOSHandlers

	call MemoryTest_Test

	ld ix,Application_instance
	call Application_Construct
	call Application_EnterMainLoop
	call Application_Destruct
	ret

; ix = this
Application_Construct:
	ld a,(CLIKSW)
	ld (ix + Application.originalKeyClick),a
	ld a,0
	ld (CLIKSW),a  ; disable key click

	push ix
	call Application_GetEngine
	call Engine_Construct
	pop ix

	push ix
	push ix
	call Application_GetScene
	ex (sp),ix
	call Application_GetEngine
	ex (sp),ix
	pop de
	call Scene_Construct
	pop ix
	ret

; ix = this
Application_Destruct:
	push ix
	call Application_GetEngine
	call Engine_Destruct
	pop ix

	ld a,(ix + Application.originalKeyClick)
	ld (CLIKSW),a
	call KILBUF
	ret

; ix = this
; ix <- engine
Application_GetEngine:
	ld de,Application.engine
	add ix,de
	ret

; ix = this
; iy <- engine
Application_GetEngine_IY:
	ld e,ixl
	ld d,ixh
	ld iy,Application.engine
	add iy,de
	ret

; ix = this
; ix <- scene
Application_GetScene:
	ld de,Application.scene
	add ix,de
	ret

; ix = this
Application_EnterMainLoop:
	call VDP_EnableBlank
	call Application_GetEngine_IY
	call Engine_StartIY

	push ix
	call Application_GetScene
	call Scene_Start
	call VDP_DisableBlank
	call Scene_Run
	call VDP_EnableBlank
	call Scene_Stop
	pop ix

	call Application_GetEngine_IY
	call Engine_StopIY
	call VDP_DisableBlank
	ret

;
	SECTION RAM

Application_instance: Application

	ENDS
