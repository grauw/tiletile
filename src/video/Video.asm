;
; Video subsystem
;
	INCLUDE "VDPRegister.asm"
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
	INCLUDE "VDPCommandEx.asm"

Video_MODE: equ 5
Video_4BPU: equ Video_MODE < 7 ? 1 : 0                     ; 8 or 4 bits per x-unit
Video_HIRES: equ Video_MODE = 6 || Video_MODE = 7 ? 1 : 0  ; 1 or 2 pixels per x-unit
Video_M12: equ Video_MODE = 0 ? 10H : Video_MODE = 3 ? 08H : 00H
Video_M345: equ Video_MODE = 2 ? 02H : Video_MODE = 4 ? 04H : Video_MODE = 5 ? 06H :
                Video_MODE = 6 ? 08H : Video_MODE = 7 ? 0AH : Video_MODE >= 8 ? 0EH : 00H
Video_YJKYAE: equ Video_MODE = 12 ? 08H : Video_MODE >= 10 ? 18H : 00H

Video_BACKDROP: equ Video_MODE = 8 ? 00H : 01H
Video_VERTICAL_ADJUST: equ -2

Video: MACRO
	interrupt:
		dw 0
	bootSplit:
		BootSplit
	bootSplitHandler:
		BootSplitHandler bootSplit, $
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
	ld de,Video.bootSplit
	add ix,de
	call BootSplit_Construct
	ld de,Video.bootSplitHandler - Video.bootSplit
	add ix,de
	call BootSplitHandler_Construct
	ld de,-Video.bootSplitHandler
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
	call Video_StartFadeOutIY
	ld a,(VDP_MIRROR_0 + 1)
	and 10000100B
	or  00100010B | Video_M12  ; BL: 1, IE0: 1, SI: 1, MAG: 0, M1, M2
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 0)
	and 11010001B
	or  00000000B | Video_M345  ; IE2: 0, M3, M4, M5
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ld a,(VDP_MIRROR_8 + 8)
	and 11011101B
	or  00100000B  ; TP: 1, SPD: 0
	ld (VDP_MIRROR_8 + 8),a
	ld b,8
	call VDP_SetRegister
	ld a,(VDP_MIRROR_8 + 9)
	and 01110001B
	or  10000000B  ; LN: 1, IL: 0, NT: 0
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ld a,1FH
	ld b,2
	call VDP_SetRegister
	ld a,Video_BACKDROP
	ld b,7
	call VDP_SetRegister
	ld a,(VDP_MIRROR_25 + 25)
	and 10100100B
	or  01000010B | Video_YJKYAE ; CMD: 1, MSK: 1, SP2: 0, YJK, YAE
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
	ld hl,Video_clearScreen
	call VDPCommand_Execute_HL
	call VDPCommand_WaitReady
	ld a,(VDP_MIRROR_0 + 1)
	and 10111111B
	or  01000000B | Video_M12  ; BL: 1
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ret

; iy = this
Video_StartFadeOutIY: PROC
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,Video.bootPalette
	add ix,de
	ld de,Video.bootSplitHandler
	add iy,de
	call SplitHandler_ActivateIY
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
	BootSplit_SetPalette_M (iy + Video.bootSplit - Video.bootSplitHandler), e, d
	ei
	call SplitHandler_SubmitSameSplitIY
	call SplitHandler_WaitIY
	call SplitHandler_SubmitSameSplitIY
	call SplitHandler_WaitIY
	pop af
	sub 11H
	jr nc,Loop
	ld de,-Video.bootSplitHandler
	add iy,de
	pop ix
	ret
	ENDP

; iy = this
Video_StopIY:
	push iy
	call Video_GetInterruptIY
	call Interrupt_ResetLineHandlerIY
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
	or Video_VERTICAL_ADJUST << 4
	ld (VDP_MIRROR_8 + 18),a
	ld b,18
	call VDP_SetRegister
	ret
	ENDP

;
Video_clearScreen:
	VDPCommand 000H, 000H, 000H, 000H, 100H << Video_HIRES, 100H, 00H, 00H, VDPCommand_HMMV
