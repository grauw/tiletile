;
; Engine
;
Engine: MACRO
	frameCount:
		db 0
	input:
		Input
	displayOffset:
		DisplayOffset
	patternNameTable:
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
	palette:
		dw Palette_system
	gameFrameEven:
		GameFrame
	gameFrameOdd:
		GameFrame
	gameFrameHandler:
		GameFrameHandler gameFrameOdd
	video:
		Video
	interrupt:
		Interrupt
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

	ld de,Engine.displayOffset
	add ix,de
	call DisplayOffset_Construct
	ld de,Engine.patternNameTable - Engine.displayOffset
	add ix,de
	call PatternNameTable_Construct
	ld de,Engine.spriteAttributeTableEven - Engine.patternNameTable
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
	call Engine_GetInterrupt
	call Interrupt_Construct
	pop ix

	call Engine_GetInterrupt_IY
	ld de,Engine.gameFrameHandler
	add ix,de
	call GameFrameHandler_Construct
	ld de,-Engine.gameFrameHandler
	add ix,de

	push ix
	call Engine_GetInterrupt_IY
	call Engine_GetVideo
	call Video_Construct
	pop ix

	push ix
	call Engine_GetTIMIHook
	call Hook_Install
	pop ix
	ret

; ix = this
Engine_Destruct:
	push ix
	call Engine_GetTIMIHook
	call Hook_Uninstall
	pop ix

	push ix
	call Engine_GetInterrupt_IY
	call Engine_GetVideo
	call Video_Destruct
	pop ix

	push ix
	call Engine_GetInterrupt
	call Interrupt_Destruct
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
; iy <- display offset
Engine_GetDisplayOffsetIY:
	ld de,Engine.displayOffset
	add iy,de
	ret

; iy = this
; iy <- current sprite attribute table
Engine_GetSpriteAttributeTableIY: PROC
	ld h,(iy + Engine.displayOffset + DisplayOffset.horizontalOffset)
	ld l,(iy + Engine.displayOffset + DisplayOffset.verticalOffset)
	bit 0,(iy + Engine.frameCount)
	jr nz,Odd
	ld de,Engine.spriteAttributeTableEven
	add iy,de
	jp SpriteAttributeTable_SetDisplayPositionIY
Odd:
	ld de,Engine.spriteAttributeTableOdd
	add iy,de
	jp SpriteAttributeTable_SetDisplayPositionIY
	ENDP

; iy = this
; iy <- current sprite color table
Engine_GetSpriteColorTableIY: PROC
	bit 0,(iy + Engine.frameCount)
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
	bit 1,(iy + Engine.frameCount)
	jr nz,Odd
	ld de,Engine.spritePatternTableEven
	add iy,de
	ret
Odd:
	ld de,Engine.spritePatternTableOdd
	add iy,de
	ret
	ENDP

; de = palette
; iy = this
Engine_SetPaletteIY:
	ld (iy + Engine.palette),e
	ld (iy + Engine.palette + 1),d
	ret

; ix = this
; ix <- interrupt
Engine_GetInterrupt:
	ld de,Engine.interrupt
	add ix,de
	ret

; ix = this
; iy <- interrupt
Engine_GetInterrupt_IY:
	ld e,ixl
	ld d,ixh
	ld iy,Engine.interrupt
	add iy,de
	ret

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
Engine_StartIY:
	push iy
	call Engine_GetVideoIY
	call Video_StartIY
	pop iy

	ld e,iyl
	ld d,iyh
	ld ix,Engine.gameFrameEven
	add ix,de
	call GameFrame_Construct
	ld de,Engine.gameFrameOdd - Engine.gameFrameEven
	add ix,de
	call GameFrame_Construct
	ld de,Engine.gameFrameHandler
	add iy,de
	call GameFrameHandler_ActivateIY
	ld de,-Engine.gameFrameHandler
	add iy,de
	ret

; iy = this
Engine_StopIY:
	push iy
	call Engine_GetVideoIY
	call Video_StopIY
	pop iy
	ret

; iy = this
Engine_CopySpriteColorToSecondary:
	IF DEBUG
	PROFILE_BEGIN 4
	ENDIF

	ld e,iyl
	ld d,iyh
	ld hl,Engine.spriteColorCopy
	add hl,de
	call VRAMTableCopy_ExecuteHL

	IF DEBUG
	PROFILE_END 4
	ENDIF
	ret

; iy = this
Engine_SubmitPrimaryIY: PROC
	bit 0,(iy + Engine.frameCount)
	call nz,System_ThrowException
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,Engine.gameFrameEven
	add ix,de
	bit 1,(iy + Engine.frameCount)
	jr nz,Odd
Even:
	GameFrame_SetSpritePatternTable_M ix, iy + Engine.spritePatternTableEven
	jr Continue
Odd:
	GameFrame_SetSpritePatternTable_M ix, iy + Engine.spritePatternTableOdd
Continue:
	GameFrame_SetPatternNameTable_M ix, iy + Engine.patternNameTable
	GameFrame_SetDisplayOffset_M ix, iy + Engine.displayOffset
	GameFrame_SetSpriteAttributeTable_M ix, iy + Engine.spriteAttributeTableEven
	ld e,(iy + Engine.palette)
	ld d,(iy + Engine.palette + 1)
	GameFrame_SetPalette_M ix, e, d
	ld de,Engine.gameFrameHandler
	add iy,de
	ld e,ixl
	ld d,ixh
	call GameFrameHandler_SubmitIY
	ld de,-Engine.gameFrameHandler
	add iy,de
	inc (iy + Engine.frameCount)
	pop ix
	ret
	ENDP

; iy = this
Engine_SubmitSecondaryIY: PROC
	bit 0,(iy + Engine.frameCount)
	call z,System_ThrowException
	push ix
	ld e,iyl
	ld d,iyh
	ld ix,Engine.gameFrameOdd
	add ix,de
	bit 1,(iy + Engine.frameCount)
	jr nz,Odd
Even:
	GameFrame_SetSpritePatternTable_M ix, iy + Engine.spritePatternTableEven
	jr Continue
Odd:
	GameFrame_SetSpritePatternTable_M ix, iy + Engine.spritePatternTableOdd
Continue:
	GameFrame_SetPatternNameTable_M ix, iy + Engine.patternNameTable
	GameFrame_SetDisplayOffset_M ix, iy + Engine.displayOffset
	GameFrame_SetSpriteAttributeTable_M ix, iy + Engine.spriteAttributeTableOdd
	ld e,(iy + Engine.palette)
	ld d,(iy + Engine.palette + 1)
	GameFrame_SetPalette_M ix, e, d
	ld de,Engine.gameFrameHandler
	add iy,de
	ld e,ixl
	ld d,ixh
	call GameFrameHandler_SubmitIY
	ld de,-Engine.gameFrameHandler
	add iy,de
	inc (iy + Engine.frameCount)
	pop ix
	ret
	ENDP

; iy = this
Engine_WaitDisplayedIY:
	ld de,Engine.gameFrameHandler
	add iy,de
	call GameFrameHandler_WaitIY
	ld de,-Engine.gameFrameHandler
	add iy,de
	ret
