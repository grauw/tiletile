;
; Video subsystem
;
	INCLUDE "VDPRegister.asm"
	INCLUDE "DisplayFrame.asm"
	INCLUDE "BootFrame.asm"
	INCLUDE "GameFrame.asm"
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

Video: MACRO
	this:
	submitted:
		db 0
	InterruptEntry:
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		call Return
	displayFrame: equ $ - 2
		xor a
		ld (submitted),a
		IF DEBUG
		PROFILE_END 10
		ENDIF
		jp Interrupt_Return
	Return:
		ret
	bootFrame:
		BootFrame
	bootPalette:
		Palette
	ENDM

; ix = this
; iy = interrupt
Video_Construct:
	ld e,ixl
	ld d,ixh
	ld hl,Video.InterruptEntry
	add hl,de
	ex de,hl
	call Interrupt_SetLineInterruptHandlerIY
	ld a,DisplayFrame_FRAME_LINE
	call Video_EnableLineInterrupt
	ret

; ix = this
Video_Destruct:
	call Video_DisableLineInterrupt
	ret

; a = line
Video_EnableLineInterrupt:
	ld b,19
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 0)
	set 4,a
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ret

Video_DisableLineInterrupt:
	ld a,(VDP_MIRROR_0 + 0)
	res 4,a
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
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
	ld ix,Video.bootPalette
	add ix,de
	ld hl,Video.bootFrame
	add hl,de
	ex de,hl
	call Video_SetDisplayFrameIY
	push iy
	ld iyl,e
	ld iyh,d
	ld a,77H
Loop:
	push af
	push ix
	ld b,a
	ld c,a
	ld hl,Palette_black
	ld de,Palette_system
	call Palette_Interpolate
	pop ix
	ld e,ixl
	ld d,ixh
	call BootFrame_SubmitIY
	call BootFrame_WaitIY
	pop af
	sub 11H
	jr nc,Loop
	pop iy
	pop ix
	ret
	ENDP

; iy = this
Video_StopIY:
	call Video_ReleaseDisplayFrameIY
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

; iy = this
; de = display frame
Video_SetDisplayFrameIY:
	di
	ld (iy + Video.displayFrame),e
	ei
	ld (iy + Video.displayFrame + 1),d
	ret

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

; Waits until previous display frame is displayed
; iy = this
Video_ReleaseDisplayFrameIY:
	call Video_WaitDisplayedIY
	ld e,iyl
	ld d,iyh
	ld hl,Video.Return
	add hl,de
	di
	ld (iy + Video.displayFrame),l
	ld (iy + Video.displayFrame + 1),h
	ei
	ld (iy + Video.submitted),1
	ret
