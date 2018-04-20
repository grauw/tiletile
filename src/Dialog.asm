;
; Dialog
;
Dialog_OPEN_SPEED: equ 6
Dialog_MAX_HEIGHT: equ 24

Dialog: MACRO ?uiImage
	active:
		db 0
	height:
		db 0
	uiImage:
		dw ?uiImage
	patternName:
		PatternNameTable 18000H
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
