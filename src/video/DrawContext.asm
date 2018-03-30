;
; A drawing context
;
DrawContext: MACRO ?patternNameAddress, ?spriteColorAddress, ?spritePatternAddress
	submitted:
		db 0
	displayOffset:
		DisplayOffset
	patternNameTable:
		PatternNameTable ?patternNameAddress
	spriteAttributeTable:
		SpriteAttributeTable ?spriteColorAddress + 200H
	spriteColorTable:
		SpriteColorTable ?spriteColorAddress
	spritePatternTable:
		SpritePatternTable ?spritePatternAddress
	ENDM

; ix = this
DrawContext_Construct:
	push ix
	call DrawContext_GetDisplayOffset
	call DisplayOffset_Construct
	pop ix
	push ix
	call DrawContext_GetPatternNameTable
	call PatternNameTable_Construct
	pop ix
	push ix
	call DrawContext_GetSpriteAttributeTable
	call SpriteAttributeTable_Construct
	pop ix
	push ix
	call DrawContext_GetSpriteColorTable
	call SpriteColorTable_Construct
	pop ix
	push ix
	call DrawContext_GetSpritePatternTable
	call SpritePatternTable_Construct
	pop ix
	ret

; ix = this
; ix <- display offset
DrawContext_GetDisplayOffset:
	ld de,DrawContext.displayOffset
	add ix,de
	ret

; iy = this
; iy <- display offset
DrawContext_GetDisplayOffsetIY:
	ld de,DrawContext.displayOffset
	add iy,de
	ret

; ix = this
; ix <- pattern name table
DrawContext_GetPatternNameTable:
	ld de,DrawContext.patternNameTable
	add ix,de
	ret

; iy = this
; iy <- pattern name table
DrawContext_GetPatternNameTableIY:
	ld de,DrawContext.patternNameTable
	add iy,de
	ret

; ix = this
; ix <- sprite attribute table
DrawContext_GetSpriteAttributeTable:
	ld de,DrawContext.spriteAttributeTable
	add ix,de
	ret

; iy = this
; iy <- sprite attribute table
DrawContext_GetSpriteAttributeTableIY:
	ld de,DrawContext.spriteAttributeTable
	add iy,de
	ret

; ix = this
; ix <- sprite color table
DrawContext_GetSpriteColorTable:
	ld de,DrawContext.spriteColorTable
	add ix,de
	ret

; iy = this
; iy <- sprite color table
DrawContext_GetSpriteColorTableIY:
	ld de,DrawContext.spriteColorTable
	add iy,de
	ret

; ix = this
; ix <- sprite pattern table
DrawContext_GetSpritePatternTable:
	ld de,DrawContext.spritePatternTable
	add ix,de
	ret

; iy = this
; iy <- sprite pattern table
DrawContext_GetSpritePatternTableIY:
	ld de,DrawContext.spritePatternTable
	add iy,de
	ret

; ix = this
; f <- nz: submitted
DrawContext_IsSubmitted:
	bit 0,(ix + DrawContext.submitted)
	ret

; iy = this
; f <- nz: submitted
DrawContext_IsSubmittedIY:
	bit 0,(iy + DrawContext.submitted)
	ret

; ix = this
DrawContext_Submit:
	ld (ix + DrawContext.submitted),1
	ret

; iy = this
DrawContext_SubmitIY:
	ld (iy + DrawContext.submitted),1
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
	call DrawContext_GetDisplayOffset
	call DisplayOffset_Select
	pop ix
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
