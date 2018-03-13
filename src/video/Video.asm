;
; Video subsystem
;
	INCLUDE "DrawContext.asm"
	INCLUDE "VRAMTable.asm"
	INCLUDE "PatternNameTable.asm"
	INCLUDE "SpriteColorTable.asm"
	INCLUDE "SpriteAttributeTable.asm"
	INCLUDE "SpritePatternTable.asm"

Video: MACRO
	currentDrawContext:
		dw drawContextEven
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
	ld c,(ix + Video.currentDrawContext)
	ld b,(ix + Video.currentDrawContext + 1)
	ld e,ixl
	ld d,ixh
	ld hl,Video.drawContextEven
	add hl,de
	ld a,l
	cp c
	jr nz,Even
	ld a,h
	cp b
	jr nz,Even
	ld hl,Video.drawContextOdd
	add hl,de
Even:
	ld (ix + Video.currentDrawContext),l
	ld (ix + Video.currentDrawContext + 1),h
	ret
	ENDP
