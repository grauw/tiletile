;
; A drawing context
;
DrawContext: MACRO ?spriteColorAddress, ?spritePatternAddress
	spriteColorTable:
		SpriteColorTable ?spriteColorAddress
	spriteAttributeTable:
		SpriteAttributeTable ?spriteColorAddress + 200H
	spritePatternTable:
		SpritePatternTable ?spritePatternAddress
	ENDM

; ix = this
DrawContext_Construct:
	push ix
	call DrawContext_GetSpriteColorTable
	call SpriteColorTable_Construct
	pop ix
	push ix
	call DrawContext_GetSpriteAttributeTable
	call SpriteAttributeTable_Construct
	pop ix
	push ix
	call DrawContext_GetSpritePatternTable
	call SpritePatternTable_Construct
	pop ix
	ret

; ix = this
; ix <- sprite color table
DrawContext_GetSpriteColorTable:
	ld de,DrawContext.spriteColorTable
	add ix,de
	ret

; ix = this
; ix <- sprite attribute table
DrawContext_GetSpriteAttributeTable:
	ld de,DrawContext.spriteAttributeTable
	add ix,de
	ret

; ix = this
; ix <- sprite pattern table
DrawContext_GetSpritePatternTable:
	ld de,DrawContext.spritePatternTable
	add ix,de
	ret

; ix = this
DrawContext_Select:
	push ix
	call DrawContext_GetSpriteAttributeTable
	call SpriteAttributeTable_Select
	pop ix
	push ix
	call DrawContext_GetSpritePatternTable
	call SpritePatternTable_Select
	pop ix
	ret

; a = sprite number
; ix = this
; c <- write port
DrawContext_SetSpriteColorWriteIY:
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,DrawContext.spriteColorTable
	add ix,de
	call SpriteColorTable_SetColorWrite
	pop ix
	ret

; a = sprite number
; ix = this
; c <- write port
DrawContext_SetSpriteAttributeWriteIY:
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,DrawContext.spriteAttributeTable
	add ix,de
	call SpriteAttributeTable_SetAttributeWrite
	pop ix
	ret

; a = sprite pattern number
; ix = this
; c <- write port
DrawContext_SetSpritePatternWriteIY:
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,DrawContext.spritePatternTable
	add ix,de
	call SpritePatternTable_SetPatternWrite
	pop ix
	ret
