;
; A set of split handlers for the frame of the gameplay
;
GameFrameHandler: MACRO ?settings
	mapSplitHandler:
		MapSplitHandler ?settings + GameFrame.mapSplit, dialogSplitHandler
	dialogSplitHandler:
		DialogSplitHandler ?settings + GameFrame.dialogSplit, overscanSplitHandler
	dialogEndSplitHandler:
		DialogEndSplitHandler ?settings + GameFrame.dialogEndSplit, mapSplitHandler
	overscanSplitHandler:
		OverscanSplitHandler ?settings + GameFrame.overscanSplit, dialogEndSplitHandler
	ENDM

; ix = this
; iy = interrupt
GameFrameHandler_Construct:
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
GameFrameHandler_SubmitIY:
	ex de,hl
	ld de,GameFrameHandler.mapSplitHandler
	add iy,de
	ld de,GameFrame.mapSplit
	add hl,de
	ex de,hl
	call SplitHandler_SubmitIY
	ex de,hl
	ld de,GameFrameHandler.dialogSplitHandler - GameFrameHandler.mapSplitHandler
	add iy,de
	ld de,GameFrame.dialogSplit - GameFrame.mapSplit
	add hl,de
	ex de,hl
	call SplitHandler_SubmitIY
	ex de,hl
	ld de,GameFrameHandler.dialogEndSplitHandler - GameFrameHandler.dialogSplitHandler
	add iy,de
	ld de,GameFrame.dialogEndSplit - GameFrame.dialogSplit
	add hl,de
	ex de,hl
	call SplitHandler_SubmitIY
	ex de,hl
	ld de,GameFrameHandler.overscanSplitHandler - GameFrameHandler.dialogEndSplitHandler
	add iy,de
	ld de,GameFrame.overscanSplit - GameFrame.dialogEndSplit
	add hl,de
	ex de,hl
	call SplitHandler_SubmitIY
	ex de,hl
	ld de,-GameFrameHandler.overscanSplitHandler
	add iy,de
	ld de,-GameFrame.overscanSplit
	add hl,de
	ret
