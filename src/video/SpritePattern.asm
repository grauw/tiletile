;
;
;
SpritePattern: MACRO ?00 = 0, ?01 = 0, ?02 = 0, ?03 = 0, ?04 = 0, ?05 = 0, ?06 = 0, ?07 = 0,
                     ?08 = 0, ?09 = 0, ?10 = 0, ?11 = 0, ?12 = 0, ?13 = 0, ?14 = 0, ?15 = 0,
                     ?16 = 0, ?17 = 0, ?18 = 0, ?19 = 0, ?20 = 0, ?21 = 0, ?22 = 0, ?23 = 0,
                     ?24 = 0, ?25 = 0, ?26 = 0, ?27 = 0, ?28 = 0, ?29 = 0, ?30 = 0, ?31 = 0
	number:
		db -1
	referenceCount:
		db 0
	data:
		db ?00, ?01, ?02, ?03, ?04, ?05, ?06, ?07,
		   ?08, ?09, ?10, ?11, ?12, ?13, ?14, ?15,
		   ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23,
		   ?24, ?25, ?26, ?27, ?28, ?29, ?30, ?31
	_size:
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

; hl = tile data
; iy = this
SpritePattern_LoadFromTileBit0_IY:
	REPT 32, ?i
	call SpritePattern_GetByteFromTileBit0_IY
	ld (iy + SpritePattern.data + (?i >> 1 | ?i << 4 & 31)),c
	ENDM
	ret

; hl = tile data
; iy = this
SpritePattern_LoadFromTileBit1_IY:
	REPT 32, ?i
	call SpritePattern_GetByteFromTileBit1_IY
	ld (iy + SpritePattern.data + (?i >> 1 | ?i << 4 & 31)),c
	ENDM
	ret

; hl = tile data
; iy = this
SpritePattern_LoadFromTileBit2_IY:
	REPT 32, ?i
	call SpritePattern_GetByteFromTileBit2_IY
	ld (iy + SpritePattern.data + (?i >> 1 | ?i << 4 & 31)),c
	ENDM
	ret

; hl = tile data
; iy = this
SpritePattern_LoadFromTileBit3_IY:
	REPT 32, ?i
	call SpritePattern_GetByteFromTileBit3_IY
	ld (iy + SpritePattern.data + (?i >> 1 | ?i << 4 & 31)),c
	ENDM
	ret

; hl = tile data
; c <- pattern byte
SpritePattern_GetByteFromTileBit0_IY: PROC
	ld c,0
	ld b,4
Loop:
	ld a,(hl)
	rlca
	rlca
	rlca
	rlca
	rl c
	rlca
	rlca
	rlca
	rlca
	rl c
	inc hl
	djnz Loop
	ret
	ENDP

; hl = tile data
; c <- pattern byte
SpritePattern_GetByteFromTileBit1_IY: PROC
	ld c,0
	ld b,4
Loop:
	ld a,(hl)
	rlca
	rlca
	rlca
	rl c
	rlca
	rlca
	rlca
	rlca
	rl c
	rlca
	inc hl
	djnz Loop
	ret
	ENDP

; hl = tile data
; c <- pattern byte
SpritePattern_GetByteFromTileBit2_IY: PROC
	ld c,0
	ld b,4
Loop:
	ld a,(hl)
	rlca
	rlca
	rl c
	rlca
	rlca
	rlca
	rlca
	rl c
	rlca
	rlca
	inc hl
	djnz Loop
	ret
	ENDP

; hl = tile data
; c <- pattern byte
SpritePattern_GetByteFromTileBit3_IY: PROC
	ld c,0
	ld b,4
Loop:
	ld a,(hl)
	rlca
	rl c
	rlca
	rlca
	rlca
	rlca
	rl c
	rlca
	rlca
	rlca
	inc hl
	djnz Loop
	ret
	ENDP

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
