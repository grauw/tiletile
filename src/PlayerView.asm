;
;
;
PlayerView_PATTERNS: equ 8

PlayerView: MACRO
	player:
		dw 0
	position:
		Vector2
	frame:
		db 0
	direction:
		db 0  ; 0 = down, 5 = left, 10 = up, 15 = right
	moving:
		db 0
	movingStep:
		db 0
	patternBase:
		db 0
	sourcePatterns:
		SpritePatternTable 1C000H
	patternCopy:
		VRAMTableCopy 0, 0, 8 * SpritePattern._size
	ENDM

; de = player
; ix = this
PlayerView_Construct:
	ld (ix + PlayerView.player),e
	ld (ix + PlayerView.player + 1),d
	push iy
	call PlayerView_GetPlayer_IY
	ld a,(iy + Player.position.x)
	ld (ix + PlayerView.position.x),a
	ld a,(iy + Player.position.y)
	ld (ix + PlayerView.position.y),a
	pop iy
	call PlayerView_LoadSourceSpritePatterns
	ret

; ix = this
; iy <- player
PlayerView_GetPlayer_IY:
	ld e,(ix + PlayerView.player)
	ld d,(ix + PlayerView.player + 1)
	ld iyl,e
	ld iyh,d
	ret

; ix = this
; iy = engine
PlayerView_TickPrimary:
	push iy
	call PlayerView_GetPlayer_IY
	call PlayerView_TickInterpolatePosition
	call PlayerView_TickMovingDirection
	pop iy
	inc (ix + PlayerView.frame)
	ret

; ix = this
; iy = player
PlayerView_TickInterpolatePosition:
	ld b,(ix + PlayerView.position.x)
	ld a,(iy + Player.position.x)
	sub b
	sra a
	add a,b
	ld (ix + PlayerView.position.x),a
	ld b,(ix + PlayerView.position.y)
	ld a,(iy + Player.position.y)
	sub b
	sra a
	add a,b
	ld (ix + PlayerView.position.y),a
	ret

; ix = this
; iy = player
PlayerView_TickMovingDirection:
	ld a,(iy + Player.velocity.x)
	or (iy + Player.velocity.y)
	add a,-1
	sbc a,a
	ld (ix + PlayerView.moving),a
	ld e,(iy + Player.control)
	ld d,(iy + Player.control + 1)
	ld iyl,e
	ld iyh,d
	ld a,(iy + PlayerControl.direction)
	and a
	ret m
	ld (ix + PlayerView.direction),a
	ret

; ix = this
; iy = engine
PlayerView_TickSecondary:
	push iy
	call PlayerView_GetPlayer_IY
	ld a,(iy + Player.position.x)
	ld (ix + PlayerView.position.x),a
	ld a,(iy + Player.position.y)
	ld (ix + PlayerView.position.y),a
	pop iy
	inc (ix + PlayerView.frame)
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
PlayerView_DrawSpriteAttributes: PROC
	ld a,b
	cp PlayerView_PATTERNS + 1
	ret c
	ld a,(ix + PlayerView.position.x)
	add a,(iy + SpriteAttributeTable.worldOffset.x)
	add a,-8
	ld h,a
	ld a,(ix + PlayerView.position.y)
	add a,(iy + SpriteAttributeTable.worldOffset.y)
	add a,-30
	ld l,a
	add a,16
	ld e,a
	ld a,(ix + PlayerView.patternBase)
	ld d,4
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, l, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	add a,d
	SpriteAttributeTable_WriteAttribute_M h, e, a
	inc e
	inc e
	inc e
	inc e
	add a,d
	bit 0,(ix + PlayerView.frame)
	jr nz,ShadowContinue
	add a,d
ShadowContinue:
	SpriteAttributeTable_WriteAttribute_M h, e, a
	ret
	ENDP

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite color table
; b <- sprites remaining
; c <- write port
PlayerView_DrawSpriteColors:
	ld a,b
	cp PlayerView_PATTERNS + 1
	ret c
	ld hl,SpriteColor_solid1
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid2CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid4CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid8CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid1
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid2CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid4CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid8CC
	call SpriteColorTable_WriteColorIY
	ld hl,SpriteColor_solid1
	jp SpriteColorTable_WriteColorIY

; ix = this
PlayerView_LoadSourceSpritePatterns:
	ld e,ixl
	ld d,ixh
	ld iy,PlayerView.sourcePatterns
	add iy,de
	ld a,0
	call SpritePatternTable_SetPatternWriteIY
	push ix
	ld ix,May_Idle_1
	call SpriteFrame_WritePatterns
	ld ix,May_Down_0
	call SpriteFrame_WritePatterns
	ld ix,May_Down_1
	call SpriteFrame_WritePatterns
	ld ix,May_Down_2
	call SpriteFrame_WritePatterns
	ld ix,May_Down_3
	call SpriteFrame_WritePatterns
	ld ix,May_Idle_2
	call SpriteFrame_WritePatterns
	ld ix,May_Right_0
	call SpriteFrame_WritePatterns
	ld ix,May_Right_1
	call SpriteFrame_WritePatterns
	ld ix,May_Right_2
	call SpriteFrame_WritePatterns
	ld ix,May_Right_3
	call SpriteFrame_WritePatterns
	ld ix,May_Idle_3
	call SpriteFrame_WritePatterns
	ld ix,May_Up_0
	call SpriteFrame_WritePatterns
	ld ix,May_Up_1
	call SpriteFrame_WritePatterns
	ld ix,May_Up_2
	call SpriteFrame_WritePatterns
	ld ix,May_Up_3
	call SpriteFrame_WritePatterns
	ld ix,May_Idle_0
	call SpriteFrame_WritePatterns
	ld ix,May_Left_0
	call SpriteFrame_WritePatterns
	ld ix,May_Left_1
	call SpriteFrame_WritePatterns
	ld ix,May_Left_2
	call SpriteFrame_WritePatterns
	ld ix,May_Left_3
	call SpriteFrame_WritePatterns
	pop ix
	ret

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
PlayerView_InitializeSpritePatterns:
	ld a,b
	and 15  ; alignment for copy
	call nz,System_ThrowException
	ld a,SpritePatternTable_COUNT
	sub b
	ld (ix + PlayerView.patternBase),a
	REPT PlayerView_PATTERNS
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	ENDM
	ld hl,PlayerView_shadowPattern
	call SpritePatternTable_WritePatternIY
	ld hl,SpritePattern_blank
	call SpritePatternTable_WritePatternIY
	ret

; ix = this
; iy = sprite pattern table
PlayerView_DrawSpritePatterns:
	push iy
	ld e,ixl
	ld d,ixh
	ld iy,PlayerView.patternCopy
	add iy,de
	call PlayerView_GetSourcePatternOffset
	ld de,PlayerView.sourcePatterns
	add ix,de
	call VRAMTableCopy_SetSourceIY
	ld de,-PlayerView.sourcePatterns
	add ix,de
	ld l,(ix + PlayerView.patternBase)
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ex (sp),ix
	call VRAMTableCopy_SetDestinationIY
	ex (sp),ix
	call VRAMTableCopy_ExecuteIY
	pop iy
	ret

; ix = this
; hl <- pattern offset
PlayerView_GetSourcePatternOffset: PROC
	bit 0,(ix + PlayerView.moving)
	jr nz,Moving
NotMoving:
	xor a
	ld (ix + PlayerView.movingStep),a
	jr Continue
Moving:
	ld a,(ix + PlayerView.movingStep)
	inc (ix + PlayerView.movingStep)
	rra
	rra
	and 00000011B
	inc a
Continue:
	add a,(ix + PlayerView.direction)
	ld l,0
	ld h,a
	ret
	ENDP

;
PlayerView_shadowPattern:
	SpritePattern 0, 0, 0, 0, 0, 0, 0, 0,
	              0, 7, 31, 63, 63, 31, 7, 0,
	              0, 0, 0, 0, 0, 0, 0, 0,
	              0, 224, 248, 252, 252, 248, 224, 0
