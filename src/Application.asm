;
; Top-level program class
;
Application: MACRO
	originalKeyClick:
		db 0
	engine:
		Engine
	scene:
		Scene FieldMap_instance, UIImage_instance, Silence_track
	ENDM

Application_Main:
	call VDP_GetVersion
	cp 2
	ret c

	ld a,ROM_CodeBank2
	ld h,60H
	call ROMMapper_SetBank

	call VDP_InitMirrorsOnVDPUpgrades

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
	push ix
	call Application_GetEngine_IY
	call Engine_StartIY
	pop ix

	push ix
	push ix
	call Application_GetScene
	ex (sp),ix
	call Application_GetEngine
	ex (sp),ix
	pop de
	call Scene_Construct
	call Scene_Start
	call Scene_Run
	call Scene_Stop
	pop ix

	push ix
	call Application_GetEngine_IY
	call Engine_StopIY
	pop ix
	ret

;
	SECTION RAM

Application_instance:
	Application

	ENDS
