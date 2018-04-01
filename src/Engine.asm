;
; Engine
;
Engine: MACRO
	frame:
		db 0
	input:
		Input
	displayOffsetEven:
		DisplayOffset
	displayOffsetOdd:
		DisplayOffset
	patternNameTableEven:
		PatternNameTable 0H
	patternNameTableOdd:
		PatternNameTable 0H
	spriteAttributeTableEven:
		SpriteAttributeTable 1EE00H
	spriteAttributeTableOdd:
		SpriteAttributeTable 1EA00H
	spriteColorTableEven:
		SpriteColorTable 1EC00H
	spriteColorTableOdd:
		SpriteColorTable 1E800H
	spritePatternTableEven:
		SpritePatternTable 1F800H
	spritePatternTableOdd:
		SpritePatternTable 1F000H
	displaySettingsEven:
		DisplaySettings
	displaySettingsOdd:
		DisplaySettings
	video:
		Video
	timiHook:
		TIMIHook
	spriteColorCopy:
		VRAMTableCopy 1EC00H, 1E800H, SpriteColorTable_SIZE
	ENDM

; ix = this
Engine_Construct:
	push ix
	ld de,Engine.input
	add ix,de
	call Input_Construct
	pop ix

	ld de,Engine.displayOffsetEven
	add ix,de
	call DisplayOffset_Construct
	ld de,Engine.displayOffsetOdd - Engine.displayOffsetEven
	add ix,de
	call DisplayOffset_Construct
	ld de,Engine.patternNameTableEven - Engine.displayOffsetOdd
	add ix,de
	call PatternNameTable_Construct
	ld de,Engine.patternNameTableOdd - Engine.patternNameTableEven
	add ix,de
	call PatternNameTable_Construct
	ld de,Engine.spriteAttributeTableEven - Engine.patternNameTableOdd
	add ix,de
	call SpriteAttributeTable_Construct
	ld de,Engine.spriteAttributeTableOdd - Engine.spriteAttributeTableEven
	add ix,de
	call SpriteAttributeTable_Construct
	ld de,Engine.spriteColorTableEven - Engine.spriteAttributeTableOdd
	add ix,de
	call SpriteColorTable_Construct
	ld de,Engine.spriteColorTableOdd - Engine.spriteColorTableEven
	add ix,de
	call SpriteColorTable_Construct
	ld de,Engine.spritePatternTableEven - Engine.spriteColorTableOdd
	add ix,de
	call SpritePatternTable_Construct
	ld de,Engine.spritePatternTableOdd - Engine.spritePatternTableEven
	add ix,de
	call SpritePatternTable_Construct
	ld de,-Engine.spritePatternTableOdd
	add ix,de

	push ix
	call Engine_GetVideo
	call Video_Construct
	pop ix

	ld e,ixl
	ld d,ixh
	ld hl,Engine_TIMIInterruptEntry
	push ix
	push de
	call Engine_GetTIMIHook
	pop de
	call TIMIHook_Construct
	pop ix
	ret

; ix = this
Engine_Destruct:
	push ix
	call Engine_GetVideo
	call Video_Destruct
	pop ix
	ret

; iy = this
; iy <- input
Engine_GetInputIY:
	ld de,Engine.input
	add iy,de
	ret

; iy = this
; iy <- even sprite pattern table
Engine_GetSpritePatternTableEvenIY:
	ld de,Engine.spritePatternTableEven
	add iy,de
	ret

; iy = this
; iy <- odd sprite pattern table
Engine_GetSpritePatternTableOddIY:
	ld de,Engine.spritePatternTableOdd
	add iy,de
	ret

; iy = this
; iy <- current display offset
Engine_GetDisplayOffsetIY: PROC
	bit 0,(iy + Engine.frame)
	jr nz,Odd
	ld de,Engine.displayOffsetEven
	add iy,de
	ret
Odd:
	ld de,Engine.displayOffsetOdd
	add iy,de
	ret
	ENDP

; iy = this
; iy <- current sprite attribute table
Engine_GetSpriteAttributeTableIY: PROC
	bit 0,(iy + Engine.frame)
	jr nz,Odd
	ld h,(iy + Engine.displayOffsetEven + DisplayOffset.horizontalOffset)
	ld l,(iy + Engine.displayOffsetEven + DisplayOffset.verticalOffset)
	ld de,Engine.spriteAttributeTableEven
	add iy,de
	jp SpriteAttributeTable_SetDisplayPositionIY
Odd:
	ld h,(iy + Engine.displayOffsetOdd + DisplayOffset.horizontalOffset)
	ld l,(iy + Engine.displayOffsetOdd + DisplayOffset.verticalOffset)
	ld de,Engine.spriteAttributeTableOdd
	add iy,de
	jp SpriteAttributeTable_SetDisplayPositionIY
	ENDP

; iy = this
; iy <- current sprite color table
Engine_GetSpriteColorTableIY: PROC
	bit 0,(iy + Engine.frame)
	jr nz,Odd
	ld de,Engine.spriteColorTableEven
	add iy,de
	ret
Odd:
	ld de,Engine.spriteColorTableOdd
	add iy,de
	ret
	ENDP

; iy = this
; iy <- current sprite pattern table
Engine_GetSpritePatternTableIY: PROC
	bit 1,(iy + Engine.frame)
	jr nz,Odd
	ld de,Engine.spritePatternTableEven
	add iy,de
	ret
Odd:
	ld de,Engine.spritePatternTableOdd
	add iy,de
	ret
	ENDP

; ix = this
; ix <- video
Engine_GetVideo:
	ld de,Engine.video
	add ix,de
	ret

; iy = this
; iy <- video
Engine_GetVideoIY:
	ld de,Engine.video
	add iy,de
	ret

; ix = this
; ix <- TIMI hook
Engine_GetTIMIHook:
	ld de,Engine.timiHook
	add ix,de
	ret

; iy = this
; ix <- TIMI hook
Engine_GetTIMIHookIY_IX:
	ld e,iyl
	ld d,iyh
	ld ix,Engine.timiHook
	add ix,de
	ret

; iy = this
Engine_StartIY:
	push ix
	call Engine_GetTIMIHookIY_IX
	call Hook_Install
	pop ix
	ret

; iy = this
Engine_StopIY:
	push ix
	call Engine_GetTIMIHookIY_IX
	call Hook_Uninstall
	pop ix
	ret

; iy = this
Engine_CopySpriteColorToSecondary:
	IF DEBUG
	PROFILE_BEGIN 3
	ENDIF

	ld e,iyl
	ld d,iyh
	ld hl,Engine.spriteColorCopy
	add hl,de
	call VRAMTableCopy_ExecuteHL

	IF DEBUG
	PROFILE_END 3
	ENDIF
	ret

; iy = this
Engine_SubmitPrimaryIY:
	bit 0,(iy + Engine.frame)
	call nz,System_ThrowException
	inc (iy + Engine.frame)
	bit 1,(iy + Engine.frame)
	jr nz,Engine_SubmitPrimaryEvenIY
	jr Engine_SubmitPrimaryOddIY

; iy = this
Engine_SubmitPrimaryEvenIY:
	DisplayOffset_Select (iy + Engine.displayOffsetEven), (iy + Engine.displaySettingsEven)
	PatternNameTable_Select (iy + Engine.patternNameTableEven), (iy + Engine.displaySettingsEven)
	SpriteAttributeTable_Select (iy + Engine.spriteAttributeTableEven), (iy + Engine.displaySettingsEven)
	SpritePatternTable_Select (iy + Engine.spritePatternTableEven), (iy + Engine.displaySettingsEven)
	ld e,iyl
	ld d,iyh
	ld hl,Engine.displaySettingsEven
	add hl,de
	ld de,Engine.video
	add iy,de
	ex de,hl
	call Video_SubmitDisplaySettingsIY
	ld de,-Engine.video
	add iy,de
	ret

; iy = this
Engine_SubmitPrimaryOddIY:
	DisplayOffset_Select (iy + Engine.displayOffsetEven), (iy + Engine.displaySettingsEven)
	PatternNameTable_Select (iy + Engine.patternNameTableOdd), (iy + Engine.displaySettingsOdd)
	SpriteAttributeTable_Select (iy + Engine.spriteAttributeTableEven), (iy + Engine.displaySettingsEven)
	SpritePatternTable_Select (iy + Engine.spritePatternTableOdd), (iy + Engine.displaySettingsOdd)
	ld e,iyl
	ld d,iyh
	ld hl,Engine.displaySettingsEven
	add hl,de
	ld de,Engine.video
	add iy,de
	ex de,hl
	call Video_SubmitDisplaySettingsIY
	ld de,-Engine.video
	add iy,de
	ret

; iy = this
Engine_SubmitSecondaryIY:
	bit 0,(iy + Engine.frame)
	call z,System_ThrowException
	inc (iy + Engine.frame)
	bit 1,(iy + Engine.frame)
	jr nz,Engine_SubmitSecondaryEvenIY
	jr Engine_SubmitSecondaryOddIY

; iy = this
Engine_SubmitSecondaryEvenIY:
	DisplayOffset_Select (iy + Engine.displayOffsetOdd), (iy + Engine.displaySettingsOdd)
	PatternNameTable_Select (iy + Engine.patternNameTableEven), (iy + Engine.displaySettingsEven)
	SpriteAttributeTable_Select (iy + Engine.spriteAttributeTableOdd), (iy + Engine.displaySettingsOdd)
	SpritePatternTable_Select (iy + Engine.spritePatternTableEven), (iy + Engine.displaySettingsEven)
	ld e,iyl
	ld d,iyh
	ld hl,Engine.displaySettingsOdd
	add hl,de
	ld de,Engine.video
	add iy,de
	ex de,hl
	call Video_SubmitDisplaySettingsIY
	call Video_WaitDisplayedIY
	ld de,-Engine.video
	add iy,de
	ret

; iy = this
Engine_SubmitSecondaryOddIY:
	DisplayOffset_Select (iy + Engine.displayOffsetOdd), (iy + Engine.displaySettingsOdd)
	PatternNameTable_Select (iy + Engine.patternNameTableOdd), (iy + Engine.displaySettingsOdd)
	SpriteAttributeTable_Select (iy + Engine.spriteAttributeTableOdd), (iy + Engine.displaySettingsOdd)
	SpritePatternTable_Select (iy + Engine.spritePatternTableOdd), (iy + Engine.displaySettingsOdd)
	ld e,iyl
	ld d,iyh
	ld hl,Engine.displaySettingsOdd
	add hl,de
	ld de,Engine.video
	add iy,de
	ex de,hl
	call Video_SubmitDisplaySettingsIY
	call Video_WaitDisplayedIY
	ld de,-Engine.video
	add iy,de
	ret

; ix = this
Engine_TIMIInterruptEntry:
	IF DEBUG
	PROFILE_BEGIN 6
	ENDIF

	xor a  ; disable part of the BIOS ISR
	ld (INTCNT),a
	ld (SCNCNT),a

	push ix
	call Engine_GetVideo
	call Video_UpdateVSync
	pop ix

	IF DEBUG
	PROFILE_END 6
	ENDIF
	ret
