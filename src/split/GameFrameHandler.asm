;
; A set of split handlers for the frame of the gameplay
;
GameFrameHandler: MACRO ?settings
	this:
	super:
		SplitHandler GameFrame_LINE, ?settings, mapSplitHandler

	; c = VDP port 1
	; hl = game frame
	; Modifies: af, bc, hl
	Apply: PROC
		push de
		bit 0,(hl)
		inc hl
		jr nz,Dialog
	NoDialog:
		ld de,overscanSplitHandler
		ld (mapSplitHandler + SplitHandler.next),de
		inc hl
		jr Continue
	Dialog:
		ld de,dialogSplitHandler
		ld (mapSplitHandler + SplitHandler.next),de
		ld a,(hl)
		inc hl
		ld (dialogSplitHandler + SplitHandler.line),a
		ld a,(hl)
		ld (dialogEndSplitHandler + SplitHandler.line),a
	Continue:
		ld de,GameFrame.mapSplit - 2
		add hl,de
		ld (mapSplitHandler + SplitHandler.settings),hl
		ld de,GameFrame.dialogSplit - GameFrame.mapSplit
		add hl,de
		ld (dialogSplitHandler + SplitHandler.settings),hl
		ld de,GameFrame.dialogEndSplit - GameFrame.dialogSplit
		add hl,de
		ld (dialogEndSplitHandler + SplitHandler.settings),hl
		ld de,GameFrame.overscanSplit - GameFrame.dialogEndSplit
		add hl,de
		ld (overscanSplitHandler + SplitHandler.settings),hl
		pop de
		jp super.Return
		ENDP

	mapSplitHandler:
		MapSplitHandler ?settings + GameFrame.mapSplit, dialogSplitHandler
	dialogSplitHandler:
		DialogSplitHandler ?settings + GameFrame.dialogSplit, dialogEndSplitHandler
	dialogEndSplitHandler:
		DialogEndSplitHandler ?settings + GameFrame.dialogEndSplit, overscanSplitHandler
	overscanSplitHandler:
		OverscanSplitHandler ?settings + GameFrame.overscanSplit, this
	ENDM

; ix = this
; iy = interrupt
GameFrameHandler_Construct:
	call SplitHandler_Construct
	ld de,GameFrameHandler.mapSplitHandler
	add ix,de
	call MapSplitHandler_Construct
	ld de,GameFrameHandler.dialogSplitHandler - GameFrameHandler.mapSplitHandler
	add ix,de
	call DialogSplitHandler_Construct
	ld de,GameFrameHandler.dialogEndSplitHandler - GameFrameHandler.dialogSplitHandler
	add ix,de
	call DialogSplitHandler_Construct
	ld de,GameFrameHandler.overscanSplitHandler - GameFrameHandler.dialogEndSplitHandler
	add ix,de
	call OverscanSplitHandler_Construct
	ld de,-GameFrameHandler.overscanSplitHandler
	add ix,de
	ret

; iy = this
GameFrameHandler_ActivateIY: equ SplitHandler_ActivateIY

; iy = this
GameFrameHandler_WaitIY: equ SplitHandler_WaitIY

; de = game frame
; iy = this
GameFrameHandler_SubmitIY: equ SplitHandler_SubmitIY
