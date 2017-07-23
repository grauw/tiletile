;
; A software sprite
;
Softsprite: MACRO
	x:
		db 0
	y:
		db 0
	sx:
		db 224
	sy:
		db 224
	index:
		db 0
	count:
		db 16
	drawCommand: VDPCommand 0, 200H, 0, 0, 16, 32, 0, 0, VDPCommand_LMMM | VDPCommand_TIMP
	saveCommand: VDPCommand 0, 0, 0, 300H, 16, 32, 0, 0, VDPCommand_HMMM
	restoreCommand: VDPCommand 0, 300H, 0, 0, 16, 32, 0, 0, VDPCommand_HMMM
	ENDM

Softsprite_Construct:
	ret

; ix = this
Softsprite_Clear:
	push ix
	ld de,Softsprite.restoreCommand
	add ix,de
	call VDPCommand_ExecuteWrapDX
	pop ix
	ret

; e = x
; d = y
; ix = this
Softsprite_SetPosition:
	ld (ix + Softsprite.x),e
	ld (ix + Softsprite.y),d
	ret

; ix = this
Softsprite_Draw: PROC
	ld a,(ix + Softsprite.x)
	ld (ix + Softsprite.drawCommand.dx),a
	ld (ix + Softsprite.saveCommand.sx),a
	ld (ix + Softsprite.restoreCommand.dx),a
	ld a,(ix + Softsprite.y)
	ld (ix + Softsprite.drawCommand.dy),a
	ld (ix + Softsprite.saveCommand.sy),a
	ld (ix + Softsprite.restoreCommand.dy),a
	ld a,(ix + Softsprite.index)
	inc a
	cp (ix + Softsprite.count)
	jr c,NoWrap
	xor a
NoWrap:
	ld (ix + Softsprite.index),a
	and 11111000B
	add a,a
	add a,(ix + Softsprite.sx)
	ld (ix + Softsprite.drawCommand.sx),a
	ld a,(ix + Softsprite.sy)
	ld (ix + Softsprite.drawCommand.sy),a
	push ix
	ld de,Softsprite.saveCommand
	add ix,de
	call VDPCommand_ExecuteWrapSX
	pop ix
	push ix
	ld de,Softsprite.drawCommand
	add ix,de
	call VDPCommand_ExecuteWrapDX
	pop ix
	ret
	ENDP
