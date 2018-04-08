;
; Video subsystem
;
	INCLUDE "DisplayFrame.asm"
	INCLUDE "DisplayOffset.asm"
	INCLUDE "VRAMTable.asm"
	INCLUDE "VRAMTableCopy.asm"
	INCLUDE "PatternNameTable.asm"
	INCLUDE "SpriteAttribute.asm"
	INCLUDE "SpriteAttributeTable.asm"
	INCLUDE "SpriteColor.asm"
	INCLUDE "SpriteColorTable.asm"
	INCLUDE "SpritePattern.asm"
	INCLUDE "SpritePatternTable.asm"
	INCLUDE "Palette.asm"
	INCLUDE "PaletteColor.asm"
	INCLUDE "PaletteFader.asm"
	INCLUDE "LineInterrupt.asm"

Video: MACRO
	this:
	submitted:
		db 0
	lineInterrupt:
		LineInterrupt 228, InterruptEntry
	InterruptEntry:
		ld a,(submitted)
		and a
		ret z
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		call System_ThrowException
	displayFrame: equ $ - 2
		xor a
		ld (submitted),a
		IF DEBUG
		PROFILE_END 10
		ENDIF
		ret
	initialDisplayFrame:
		DisplayFrame
	initialPalette:
		Palette
	ENDM

; ix = this
; iy = interrupt
Video_Construct:
	push ix
	ex (sp),iy
	pop ix
	ld de,Video.lineInterrupt
	add iy,de
	call LineInterrupt_InstallIY
	ld de,-Video.lineInterrupt
	add iy,de
	push ix
	ex (sp),iy
	pop ix
	ret

; ix = this
; iy = interrupt
Video_Destruct:
	push ix
	ex (sp),iy
	pop ix
	ld de,Video.lineInterrupt
	add iy,de
	call LineInterrupt_UninstallIY
	ld de,-Video.lineInterrupt
	add iy,de
	push ix
	ex (sp),iy
	pop ix
	ret

; iy = this
Video_StartIY:
	call Video_StartFadeOutIY
	ld a,5
	call VDP_InitScreen
	call VDP_Enable212Lines
	call VDP_EnableSprites
	ld a,0F1H
	call VDP_SetColor
	ld a,(VDP_MIRROR_0 + 1)
	res 0,a  ; MAG
	set 1,a  ; SI
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ld a,(VDP_MIRROR_8 + 8)
	set 5,a  ; TP
	ld (VDP_MIRROR_8 + 8),a
	ld b,8
	call VDP_SetRegister
	ld a,(VDP_MIRROR_25 + 25)
	set 1,a  ; MSK
	ld (VDP_MIRROR_25 + 25),a
	ld b,25
	call VDP_SetRegister
	ld a,-1
	ld b,26
	call VDP_SetRegister
	ld a,0
	ld b,27
	call VDP_SetRegister
	call Video_Recenter
	ret

; iy = this
Video_StartFadeOutIY: PROC
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,Video.initialPalette
	add ix,de
	push iy
	ld de,Video.initialDisplayFrame
	add iy,de
	call DisplayFrame_InitializeFromSystemVariablesIY
	ld e,iyl
	ld d,iyh
	pop iy
	ld a,77H
Loop:
	push af
	push de
	push ix
	ld b,a
	ld c,a
	ld hl,Palette_black
	ld de,Palette_system
	call Palette_Interpolate
	pop ix
	ld e,ixl
	ld d,ixh
	ld (iy + Video.initialDisplayFrame + DisplayFrame.palette),e
	ld (iy + Video.initialDisplayFrame + DisplayFrame.palette + 1),d
	pop de
	call Video_SubmitDisplayFrameIY
	call Video_WaitDisplayedIY
	call Video_SubmitDisplayFrameIY
	call Video_WaitDisplayedIY
	pop af
	sub 11H
	jr nc,Loop
	pop ix
	ret
	ENDP

; iy = this
Video_StopIY:
	call VDP_InitText
	ret

; ix = this
Video_Recenter: PROC
	ld a,(VDP_MIRROR_8 + 18)
	ld b,a
	and 0FH
	sub 8
	add a,4
	jr nc,NoOverflow
	ld a,255
NoOverflow:
	add a,8
	and 0FH
	ld c,a
	ld a,b
	and 0F0H
	or c
	ld b,18
	call VDP_SetRegister
	ret
	ENDP

; iy = this
Video_ToggleFrequencyIY:
	ld a,(VDP_MIRROR_8 + 9)
	xor 00000010B
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ret

; iy = this
Video_WaitDisplayedIY:
	bit 0,(iy + Video.submitted)
	ret z
	IF DEBUG
	PROFILE_BEGIN 29
	ENDIF
	halt
	IF DEBUG
	PROFILE_END 29
	ENDIF
	jr Video_WaitDisplayedIY

; Waits until previous display frame is displayed
; iy = this
; de = display frame
Video_SubmitDisplayFrameIY:
	call Video_WaitDisplayedIY
	di
	ld (iy + Video.displayFrame),e
	ld (iy + Video.displayFrame + 1),d
	ei
	ld (iy + Video.submitted),1
	ret
