;
; Top-level program class
;
Application: MACRO
	timiHook:
		TIMIHook
	input:
		Input
	scene:
		Scene FieldSet_instance, FieldMap_instance
	ENDM

Application_Main:
	call VDP_GetVersion
	cp 2
	ret c

;	call System_EnableTurbo

	call ROM_Init
	call RAM_Init

	call System_SetDirectBIOSHandlers

	call MemoryTest_Test

	ld ix,Application_instance
	call Application_Construct
	call Application_EnterMainLoop

	call KILBUF
	ret

; ix = this
Application_Construct:
	call Application_GetInput_IY
	push ix
	call Application_GetScene
	ld e,iyl
	ld d,iyh
	call Scene_Construct
	pop ix
	ld e,ixl
	ld d,ixh
	ld hl,Application_TIMIInterruptEntry
	push ix
	push de
	call Application_GetTIMIHook
	pop de
	call TIMIHook_Construct
	pop ix
	ret

; ix = this
Application_GetInput_IY:
	ld e,ixl
	ld d,ixh
	ld iy,Application.input
	add iy,de
	ret

; ix = this
Application_GetTIMIHook:
	ld de,Application.timiHook
	add ix,de
	ret

; ix = this
Application_GetScene:
	ld de,Application.scene
	add ix,de
	ret

; ix = this
Application_EnterMainLoop:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	call VDP_InitScreen5
	call VDP_Enable212Lines
	call VDP_EnableSprites
	call VDP_Enable60Hz
	ld a,0F1H
	call VDP_SetColor
	ld a,(VDP_MIRROR_8 + 8)
	or 00100000B  ; TP
	ld (VDP_MIRROR_8 + 8),a
	ld b,8
	call VDP_SetRegister

	call VDP_EnableBlank

	push ix
	call Application_GetScene
	call Scene_Start
	pop ix

	call VDP_DisableBlank

	push ix
	call Application_GetTIMIHook
	call Hook_Install
	pop ix

	call Application_MainLoop

	push ix
	call Application_GetTIMIHook
	call Hook_Uninstall
	pop ix
	ret

; ix = this
Application_MainLoop:
	jp Application_MainLoop
	ret

; ix = this
Application_TIMIInterruptEntry:
	ld a,0FFH
	ld (SCNCNT),a
	call Application_GetInput_IY
	call Input_Update_IY
	push ix
	call Application_GetScene
	call Scene_Update
	pop ix
	ret

;
	SECTION RAM

Application_instance: Application

	ENDS
