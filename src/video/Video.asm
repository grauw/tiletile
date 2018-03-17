;
; Video subsystem
;
	INCLUDE "DrawContext.asm"
	INCLUDE "VRAMTable.asm"
	INCLUDE "PatternNameTable.asm"
	INCLUDE "SpriteColorTable.asm"
	INCLUDE "SpriteAttributeTable.asm"
	INCLUDE "SpritePatternTable.asm"
	INCLUDE "Sprites.asm"
	INCLUDE "Sprite.asm"
	INCLUDE "SpriteColor.asm"
	INCLUDE "SpritePattern.asm"

Video: MACRO
	currentDrawContext:
		dw drawContextEven
	displayDrawContext:
		dw drawContextOdd
	drawContextEven:
		DrawContext 0H, 1F400H, 1F800H
	drawContextOdd:
		DrawContext 0H, 1F000H, 1F800H
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
	ret

; ix = this
Video_GetCurrentDrawContext:
	ld e,(ix + Video.currentDrawContext)
	ld d,(ix + Video.currentDrawContext + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Video_GetCurrentDrawContext_IY:
	ld e,(ix + Video.currentDrawContext)
	ld d,(ix + Video.currentDrawContext + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
Video_SwapTables: PROC
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
