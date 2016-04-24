;
;
;
SpritePattern: MACRO ?00, ?01, ?02, ?03, ?04, ?05, ?06, ?07,
                     ?08, ?09, ?10, ?11, ?12, ?13, ?14, ?15,
                     ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23,
                     ?24, ?25, ?26, ?27, ?28, ?29, ?30, ?31
	number:
		db -1
	referenceCount:
		db 0
	data:
		db ?00, ?01, ?02, ?03, ?04, ?05, ?06, ?07,
		   ?08, ?09, ?10, ?11, ?12, ?13, ?14, ?15,
		   ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23,
		   ?24, ?25, ?26, ?27, ?28, ?29, ?30, ?31
	ENDM

; iy = this
; f <- z: has no number
SpritePattern_HasNumber_IY:
	ld a,(iy + SpritePattern.number)
	inc a
	ret

; iy = this
; a <- pattern number
SpritePattern_GetNumber_IY:
	ld a,(iy + SpritePattern.number)
	ret

; a = pattern number
; iy = this
SpritePattern_SetNumber_IY:
	ld (iy + SpritePattern.number),a
	ret

; iy = this
SpritePattern_ClearNumber_IY:
	ld (iy + SpritePattern.number),-1
	ret

; iy = this
; f <- z: not referenced
SpritePattern_IsReferenced_IY:
	ld a,(iy + SpritePattern.referenceCount)
	and a
	ret

; a = pattern number
; iy = this
SpritePattern_IncreaseReferenceCount_IY:
	inc (iy + SpritePattern.referenceCount)
	call z,System_ThrowException
	ret

; iy = this
SpritePattern_DecreaseReferenceCount_IY:
	call SpritePattern_IsReferenced_IY
	call z,System_ThrowException
	dec (iy + SpritePattern.referenceCount)
	ret

; iy = this
SpritePattern_Draw_IY:
	ld e,iyl
	ld d,iyh
	ld hl,SpritePattern.data
	add hl,de
	ld c,VDP_PORT_0
	REPT 32
	outi
	ENDM
	ret

;
	SECTION RAM

SpritePattern_unused:
	SpritePattern 0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0

SpritePattern_blank:
	SpritePattern 0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 0, 0, 0, 0, 0, 0, 0

SpritePattern_filled:
	SpritePattern 255, 255, 255, 255, 255, 255, 255, 255,
	              255, 255, 255, 255, 255, 255, 255, 255,
	              255, 255, 255, 255, 255, 255, 255, 255,
	              255, 255, 255, 255, 255, 255, 255, 255

	ENDS
