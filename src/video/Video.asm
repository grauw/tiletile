;
; Video subsystem
;
	INCLUDE "DisplaySettings.asm"
	INCLUDE "DrawContext.asm"
	INCLUDE "DisplayOffset.asm"
	INCLUDE "VRAMTable.asm"
	INCLUDE "PatternNameTable.asm"
	INCLUDE "SpriteAttribute.asm"
	INCLUDE "SpriteAttributeTable.asm"
	INCLUDE "SpriteColor.asm"
	INCLUDE "SpriteColorTable.asm"
	INCLUDE "SpritePattern.asm"
	INCLUDE "SpritePatternTable.asm"

Video: MACRO
	submitted:
		db 0
	displaySettings:
		dw 0
	ENDM

; ix = this
Video_Construct:
	ld a,5
	call VDP_InitScreen
	call VDP_Enable212Lines
	call VDP_EnableSprites
	call VDP_Enable60Hz
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

; Waits until display settings is displayed
; iy = this
; de = display settings
Video_SubmitDisplaySettingsIY: PROC
	di
	ld (iy + Video.displaySettings),e
	ld (iy + Video.displaySettings + 1),d
	ei
	ld (iy + Video.submitted),1
Wait:
	bit 0,(iy + Video.submitted)
	jr nz,Wait
	ret
	ENDP

; ix = this
Video_UpdateVSync:
	bit 0,(ix + Video.submitted)
	ret z
	ld l,(ix + Video.displaySettings)
	ld h,(ix + Video.displaySettings + 1)
	call DisplaySettings_ApplyHL
	ld (ix + Video.submitted),0
	ret
