;
; Dialog
;
Dialog_OPEN_SPEED: equ 6
Dialog_MAX_HEIGHT: equ 24
Dialog_START_X: equ 16
Dialog_START_Y: equ 6
Dialog_LINE_WIDTH: equ 232
Dialog_LINE_HEIGHT: equ 12
Dialog_LINE_COUNT: equ 3

Dialog: MACRO ?uiImage
	active:
		db 0
	height:
		db 0
	text:
		dw 0
	clear:
		db 0
	kerning:
		db 0
	glyphs:
		dw Glyph_glyphs - 32 * Glyph._size
	uiImage:
		dw ?uiImage
	patternName:
		PatternNameTable 10000H
	drawCommand:
		VDPCommand 0, 100H << Video_4BPU, Dialog_START_X, (100H << Video_4BPU) + Dialog_START_Y, 0, 0, 0DDH, 0, VDPCommand_LMMM | VDPCommand_TIMP
	ENDM

; ix = this
Dialog_Construct:
	ret

; ix = this
Dialog_Load:
	push ix
	ld e,ixl
	ld d,ixh
	ld iy,Dialog.patternName
	add iy,de
	ld hl,0
	call PatternNameTable_SetPatternNameWriteIY
	ld e,(ix + Dialog.uiImage)
	ld d,(ix + Dialog.uiImage + 1)
	ld ixl,e
	ld ixh,d
	call Image_Load
	pop ix
	ret

; a = collision ID
; ix = this
Dialog_UpdateTriggers:
	and a
	jp z,Dialog_Hide
	bit 0,(ix + Dialog.active)
	ret nz
	ld de,Dialog_testText
	jp Dialog_Show

; de = text
Dialog_Show:
	ld (ix + Dialog.text),e
	ld (ix + Dialog.text + 1),d
	ld (ix + Dialog.active),-1
	ld (ix + Dialog.clear),-1
	ret

; de = text
Dialog_Hide:
	ld (ix + Dialog.active),0
	ret

; ix = this
; iy = game frame
Dialog_UpdateGameFrame: PROC
	ld a,(ix + Dialog.active)
	and a
	ld a,(ix + Dialog.height)
	jr nz,Show
Hide:
	sub Dialog_OPEN_SPEED
	jr nc,Set
	add a,Dialog_OPEN_SPEED
	jr Set
Show:
	add a,Dialog_OPEN_SPEED
	cp Dialog_MAX_HEIGHT + 1
	jr c,Set
	sub Dialog_OPEN_SPEED
Set:
	ld (ix + Dialog.height),a
	ld b,a
	GameFrame_SetDialogOffset_M iy, b
	ret
	ENDP

; ix = this
; iy = engine
Dialog_DrawBitmap: PROC
	bit 0,(ix + Dialog.active)
	ret z
	bit 0,(ix + Dialog.clear)
	jr nz,Clear
	push iy
	call Engine_GetInputIY
	bit 4,(iy + Input.newStick)
	pop iy
	call z,Dialog_DrawGlyph
	jp Dialog_DrawGlyph
Clear:
	ld (ix + Dialog.clear),0
	ld (ix + Dialog.kerning),0
	ld e,ixl
	ld d,ixh
	ld iy,Dialog.drawCommand
	add iy,de
	ld (iy + VDPCommand.dx),Dialog_START_X << Video_HIRES
	IF Video_HIRES
	ld (iy + VDPCommand.dx + 1),Dialog_START_X << Video_HIRES >> 8
	ENDIF
	ld (iy + VDPCommand.dy),Dialog_START_Y
	ld (iy + VDPCommand.nx),Dialog_LINE_WIDTH << Video_HIRES
	IF Video_HIRES
	ld (iy + VDPCommand.nx + 1),Dialog_LINE_WIDTH << Video_HIRES >> 8
	ENDIF
	ld (iy + VDPCommand.ny),Dialog_LINE_HEIGHT * Dialog_LINE_COUNT
	ld (iy + VDPCommand.command),VDPCommand_HMMV
	call VDPCommand_ExecuteS2IY
	IF Video_HIRES
	ld (iy + VDPCommand.nx + 1),0
	ENDIF
	ld (iy + VDPCommand.command),VDPCommand_LMMM | VDPCommand_TIMP
	ret
	ENDP

; ix = this
Dialog_DrawGlyph: PROC
	ld e,ixl
	ld d,ixh
	ld iy,Dialog.drawCommand
	add iy,de
	ld e,(ix + Dialog.text)
	ld d,(ix + Dialog.text + 1)
Loop:
	ld a,(de)
	and a
	ret z
	inc de
	ld (ix + Dialog.text),e
	ld (ix + Dialog.text + 1),d
	cp 10
	jr nz,NoNewline
	ld (iy + VDPCommand.dx),Dialog_START_X << Video_HIRES
	IF Video_HIRES
	ld (iy + VDPCommand.dx + 1),Dialog_START_X << Video_HIRES >> 8
	ENDIF
	ld a,(iy + VDPCommand.dy)
	add a,Dialog_LINE_HEIGHT
	ld (iy + VDPCommand.dy),a
	ld (ix + Dialog.kerning),0
	jr Loop
NoNewline:
	push af
	ld e,(ix + Dialog.glyphs)
	ld d,(ix + Dialog.glyphs + 1)
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,de
	call Glyph_SetCopyHL
	bit 7,(ix + Dialog.kerning)
	jr z,NoKerning
	and Glyph_CAPITAL | Glyph_ASCENDER
	jr nz,NoKerning
	IF Video_HIRES
	ld a,(iy + VDPCommand.dx)
	sub 1 << Video_HIRES
	ld (iy + VDPCommand.dx),a
	jr nc,NoKerning
	dec (iy + VDPCommand.dx + 1)
	ELSE
	dec (iy + VDPCommand.dx)
	ENDIF
NoKerning:
	call VDPCommand_ExecuteS2IY
	ld a,(iy + VDPCommand.dx)
	add a,(iy + VDPCommand.nx)
	ld (iy + VDPCommand.dx),a
	IF Video_HIRES
	ld a,(iy + VDPCommand.dx + 1)
	adc a,0
	ld (iy + VDPCommand.dx + 1),a
	ENDIF
	pop af
	cp "f"
	jr z,Kerning1
	cp "F"
	jr z,Kerning1
	cp "T"
	jr z,Kerning1
	ld (ix + Dialog.kerning),0
	ret
Kerning1:
	ld (ix + Dialog.kerning),-1
	ret
	ENDP

;
Dialog_testText:
	db "Energy stones scatter across the land.",10
	db "Sun shines, water falls...",10
	db "Lightning strikes, mana flows.",0
