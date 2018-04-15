;
; Video subsystem
;
	INCLUDE "VDPRegister.asm"
	INCLUDE "Frame.asm"
	INCLUDE "FrameHandler.asm"
	INCLUDE "BootFrame.asm"
	INCLUDE "BootFrameHandler.asm"
	INCLUDE "MapFrame.asm"
	INCLUDE "MapFrameHandler.asm"
	INCLUDE "DialogFrame.asm"
	INCLUDE "DialogFrameHandler.asm"
	INCLUDE "OverscanFrame.asm"
	INCLUDE "OverscanFrameHandler.asm"
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
	interrupt:
		dw 0
	bootFrame:
		BootFrame
	bootFrameHandler:
		BootFrameHandler bootFrame, $
	bootPalette:
		Palette
	ENDM

; ix = this
; iy = interrupt
Video_Construct:
	ld e,iyl
	ld d,iyh
	ld (ix + Video.interrupt),e
	ld (ix + Video.interrupt + 1),d
	call Video_EnableLineInterrupt
	ld de,Video.bootFrame
	add ix,de
	call BootFrame_Construct
	ld de,Video.bootFrameHandler - Video.bootFrame
	add ix,de
	call BootFrameHandler_Construct
	ld de,-Video.bootFrameHandler
	add ix,de
	ret

; ix = this
Video_Destruct:
	call Video_DisableLineInterrupt
	ret

; iy = this
; iy = interrupt
Video_GetInterruptIY:
	ld e,(iy + Video.interrupt)
	ld d,(iy + Video.interrupt + 1)
	ld iyl,e
	ld iyh,d
	ret

Video_EnableLineInterrupt:
	ld a,(VDP_MIRROR_0 + 0)
	set 4,a  ; IE1
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ret

Video_DisableLineInterrupt:
	ld a,(VDP_MIRROR_0 + 0)
	res 4,a  ; IE1
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ret

; iy = this
Video_StartIY:
	ld a,0
	ld (VDP_MIRROR_8 + 16),a
	ld b,16
	call VDP_SetRegister
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
	ld de,Video.bootFrameHandler
	add iy,de
	call FrameHandler_ActivateIY
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
	di
	BootFrame_SetPalette_M (iy + Video.bootFrame - Video.bootFrameHandler), e, d
	ei
	call FrameHandler_SubmitSameFrameIY
	call FrameHandler_WaitIY
	call FrameHandler_SubmitSameFrameIY
	call FrameHandler_WaitIY
	pop af
	sub 11H
	jr nc,Loop
	ld de,-Video.bootFrameHandler
	add iy,de
	pop ix
	ret
	ENDP

; iy = this
Video_StopIY:
	push iy
	call Video_GetInterruptIY
	call Interrupt_ResetLineInterruptHandlerIY
	pop iy
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
