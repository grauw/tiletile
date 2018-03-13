;
; A drawing context
;
DrawContext: MACRO ?patternNameAddress, ?spriteColorAddress, ?spritePatternAddress
	submitted:
		db 0
	displayOffset:
		db 0
	horizontalOffsetCharacters:
		db 0
	horizontalOffsetDots:
		db 0
	patternNameTable:
		PatternNameTable ?patternNameAddress
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
	call DrawContext_GetPatternNameTable
	call PatternNameTable_Construct
	pop ix
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
; ix <- pattern name table
DrawContext_GetPatternNameTable:
	ld de,DrawContext.patternNameTable
	add ix,de
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
; f <- nz: submitted
DrawContext_IsSubmitted:
	ld a,(ix + DrawContext.submitted)
	and a
	ret

; ix = this
DrawContext_Submit:
	ld (ix + DrawContext.submitted),1
	ret

; ix = this
DrawContext_Release:
	ld (ix + DrawContext.submitted),0
	ret

; ix = this
DrawContext_Select:
	call DrawContext_IsSubmitted
	call z,System_ThrowException
	push ix
	call DrawContext_GetPatternNameTable
	call PatternNameTable_Select
	pop ix
	push ix
	call DrawContext_GetSpriteAttributeTable
	call SpriteAttributeTable_Select
	pop ix
	push ix
	call DrawContext_GetSpritePatternTable
	call SpritePatternTable_Select
	pop ix
	ld a,(ix + DrawContext.displayOffset)
	ld b,23
	call VDP_SetRegister
	ld a,(ix + DrawContext.horizontalOffsetCharacters)
	ld b,26
	call VDP_SetRegister
	ld a,(ix + DrawContext.horizontalOffsetDots)
	ld b,27
	call VDP_SetRegister
	ret

; hl = offset
; ix = this
; c <- write port
DrawContext_SetPatternNameWriteIY:
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,DrawContext.patternNameTable
	add ix,de
	call PatternNameTable_SetPatternNameWrite
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

; a = offset
; iy = this
DrawContext_SetVerticalOffsetIY:
	ld (iy + DrawContext.displayOffset),a
	ret

; a = offset
; iy = this
DrawContext_SetHorizontalOffsetIY:
	push af
	neg
	and 07H
	ld (iy + DrawContext.horizontalOffsetDots),a
	pop af
	dec a
	srl a
	srl a
	srl a
	ld (iy + DrawContext.horizontalOffsetCharacters),a
	ret
