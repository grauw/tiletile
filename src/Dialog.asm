;
; Dialog
;
Dialog_OPEN_SPEED: equ 6
Dialog_MAX_HEIGHT: equ 24
Dialog_START_X: equ 16
Dialog_START_Y: equ 5
Dialog_LINE_HEIGHT: equ 10

Dialog: MACRO ?uiImage
	active:
		db 0
	height:
		db 0
	text:
		dw Dialog_testText
	characters:
		dw Character_characters
	uiImage:
		dw ?uiImage
	patternName:
		PatternNameTable 18000H
	drawCommand:
		VDPCommand 0, 300H, Dialog_START_X, 300H + Dialog_START_Y, 0, 0, 0, 0, VDPCommand_HMMM
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
	ld (ix + Dialog.active),a
	ret z
	ld (ix + Dialog.active),-1
	ret

; ix = this
Dialog_Tick: PROC
	ld a,(ix + Dialog.active)
	and a
	ld a,(ix + Dialog.height)
	jr nz,Show
Hide:
	sub Dialog_OPEN_SPEED
	ret c
	ld (ix + Dialog.height),a
	ret
Show:
	add a,Dialog_OPEN_SPEED
	cp Dialog_MAX_HEIGHT + 1
	ret nc
	ld (ix + Dialog.height),a
	ret
	ENDP

; ix = this
Dialog_UpdateGameFrame:
	ld a,(ix + Dialog.height)
	jp GameFrame_SetDialogOffsetIY

; ix = this
Dialog_DrawBitmap:
	bit 0,(ix + Dialog.active)
	ret z
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
	ld (iy + VDPCommand.dx),Dialog_START_X
	ld a,(iy + VDPCommand.dy)
	add a,Dialog_LINE_HEIGHT
	ld (iy + VDPCommand.dy),a
	jr Loop
NoNewline:
	sub 32
	ld e,(ix + Dialog.characters)
	ld d,(ix + Dialog.characters + 1)
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,de
	call Character_SetCopyHL
	call VDPCommand_ExecuteS2IY
	ld a,(iy + VDPCommand.dx)
	add a,(iy + VDPCommand.nx)
	ld (iy + VDPCommand.dx),a
	ret

;
Dialog_testText:
	db "Energy stones scatter across the land.",10
	db "Sun shines, water falls...",10
	db "Lightning strikes, mana flows.",0
