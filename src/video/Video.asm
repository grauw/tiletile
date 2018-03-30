;
; Video subsystem
;
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
	currentDrawContext:
		dw drawContextEven
	displayDrawContext:
		dw drawContextOdd
	drawContextEven:
		DrawContext 0H, 1EC00H, 1F800H
	drawContextOdd:
		DrawContext 0H, 1E800H, 1F000H
	ENDM

; ix = this
Video_Construct:
	ld de,Video.drawContextEven
	add ix,de
	call DrawContext_Construct
	ld de,Video.drawContextOdd - Video.drawContextEven
	add ix,de
	call DrawContext_Construct
	ld de,-Video.drawContextOdd
	add ix,de
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

; ix = this
; ix <- current draw context
Video_GetCurrentDrawContext:
	ld e,(ix + Video.currentDrawContext)
	ld d,(ix + Video.currentDrawContext + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; iy <- current draw context
Video_GetCurrentDrawContext_IY:
	ld e,(ix + Video.currentDrawContext)
	ld d,(ix + Video.currentDrawContext + 1)
	ld iyl,e
	ld iyh,d
	ret

; iy = this
; iy <- even draw context
Video_GetDrawContextEvenIY:
	ld de,Video.drawContextEven
	add iy,de
	ret

; iy = this
; iy <- odd draw context
Video_GetDrawContextOddIY:
	ld de,Video.drawContextOdd
	add iy,de
	ret

; ix = this
Video_UpdateSync: PROC
	push ix
	call Video_GetCurrentDrawContext
	call DrawContext_IsSubmitted
	jr z,Skip
	call DrawContext_Select
	pop ix
	ld c,(ix + Video.currentDrawContext)
	ld b,(ix + Video.currentDrawContext + 1)
	ld e,(ix + Video.displayDrawContext)
	ld d,(ix + Video.displayDrawContext + 1)
	ld (ix + Video.currentDrawContext),e
	ld (ix + Video.currentDrawContext + 1),d
	ld (ix + Video.displayDrawContext),c
	ld (ix + Video.displayDrawContext + 1),d
	push ix
	call Video_GetCurrentDrawContext
	call DrawContext_Release
Skip:
	pop ix
	ret
	ENDP
