;
; Engine
;
Engine: MACRO
	frame:
		db 0
	input:
		Input
	video:
		Video
	timiHook:
		TIMIHook
	drawContextEven:
		DrawContext 0H, 1EC00H, 1F800H
	drawContextOdd:
		DrawContext 0H, 1E800H, 1F000H
	displaySettingsEven:
		DisplaySettings
	displaySettingsOdd:
		DisplaySettings
	ENDM

; ix = this
Engine_Construct:
	push ix
	ld de,Engine.input
	add ix,de
	call Input_Construct
	pop ix

	push ix
	call Engine_GetVideo
	call Video_Construct
	pop ix

	ld e,ixl
	ld d,ixh
	ld hl,Engine_TIMIInterruptEntry
	push ix
	push de
	call Engine_GetTIMIHook
	pop de
	call TIMIHook_Construct
	pop ix

	ld de,Engine.drawContextEven
	add ix,de
	call DrawContext_Construct
	ld de,Engine.drawContextOdd - Engine.drawContextEven
	add ix,de
	call DrawContext_Construct
	ld de,-Engine.drawContextOdd
	add ix,de
	ret

; iy = this
; iy <- input
Engine_GetInputIY:
	ld de,Engine.input
	add iy,de
	ret

; ix = this
; ix <- video
Engine_GetVideo:
	ld de,Engine.video
	add ix,de
	ret

; iy = this
; iy <- video
Engine_GetVideoIY:
	ld de,Engine.video
	add iy,de
	ret

; ix = this
; ix <- TIMI hook
Engine_GetTIMIHook:
	ld de,Engine.timiHook
	add ix,de
	ret

; iy = this
; iy <- even draw context
Engine_GetDrawContextIY:
	bit 0,(iy + Engine.frame)
	jr z,Engine_GetDrawContextEvenIY
	jr Engine_GetDrawContextOddIY

; iy = this
; iy <- even draw context
Engine_GetDrawContextEvenIY:
	ld de,Engine.drawContextEven
	add iy,de
	ret

; iy = this
; iy <- odd draw context
Engine_GetDrawContextOddIY:
	ld de,Engine.drawContextOdd
	add iy,de
	ret

; ix = this
Engine_Start:
	push ix
	call Engine_GetTIMIHook
	call Hook_Install
	pop ix
	ret

; ix = this
Engine_Stop:
	push ix
	call Engine_GetTIMIHook
	call Hook_Uninstall
	pop ix
	ret

; iy = this
Engine_SubmitIY:
	inc (iy + Engine.frame)
	bit 0,(iy + Engine.frame)
	jr nz,Engine_SubmitEvenIY
	jr Engine_SubmitOddIY

; iy = this
Engine_SubmitEvenIY:
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,Engine.displaySettingsEven
	add ix,de
	ld de,Engine.drawContextEven
	add iy,de
	call DrawContext_SelectIY
	ld de,Engine.video - Engine.drawContextEven
	add iy,de
	ex (sp),ix
	pop de
	call Video_SubmitDisplaySettingsIY
	ld de,-Engine.video
	add iy,de
	ret

; iy = this
Engine_SubmitOddIY:
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,Engine.displaySettingsOdd
	add ix,de
	ld de,Engine.drawContextOdd
	add iy,de
	call DrawContext_SelectIY
	ld de,Engine.video - Engine.drawContextOdd
	add iy,de
	ex (sp),ix
	pop de
	call Video_SubmitDisplaySettingsIY
	ld de,-Engine.video
	add iy,de
	ret

; ix = this
Engine_TIMIInterruptEntry:
	IF DEBUG
	PROFILE_BEGIN 6
	ENDIF

	ld a,0FFH
	ld (SCNCNT),a

	push ix
	call Engine_GetVideo
	call Video_UpdateVSync
	pop ix

	IF DEBUG
	PROFILE_END 6
	ENDIF
	ret
