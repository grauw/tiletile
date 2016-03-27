;
; VDP command
;
VDPCommand_STOP: equ 00H
VDPCommand_POINT: equ 40H
VDPCommand_PSET: equ 50H
VDPCommand_SRCH: equ 60H
VDPCommand_LINE: equ 70H
VDPCommand_LMMV: equ 80H
VDPCommand_LMMM: equ 90H
VDPCommand_LMCM: equ 0A0H
VDPCommand_LMMC: equ 0B0H
VDPCommand_HMMV: equ 0C0H
VDPCommand_HMMM: equ 0D0H
VDPCommand_YMMM: equ 0E0H
VDPCommand_HMMC: equ 0F0H
VDPCommand_IMP: equ 00H
VDPCommand_AND: equ 01H
VDPCommand_OR: equ 02H
VDPCommand_XOR: equ 03H
VDPCommand_NOT: equ 04H
VDPCommand_TIMP: equ 08H
VDPCommand_TAND: equ 09H
VDPCommand_TOR: equ 0AH
VDPCommand_TXOR: equ 0BH
VDPCommand_TNOT: equ 0CH

VDPCommand: MACRO ?sx, ?sy, ?dx, ?dy, ?nx, ?ny, ?color, ?argument, ?command
	sx:
		dw ?sx
	sy:
		dw ?sy
	dx:
		dw ?dx
	dy:
		dw ?dy
	nx:
		dw ?nx
	ny:
		dw ?ny
	color:
		db ?color
	argument:
		db ?argument
	command:
		db ?command
	ENDM

; ix = this
; Modifies: af, bc, hl
VDPCommand_Execute:
	push ix
	pop hl
	jp VDPCommand_Execute_HL

; ix = this
; Modifies: af, bc, hl
VDPCommand_Execute_IY:
	push iy
	pop hl
	jp VDPCommand_Execute_HL

; ix = this
; Modifies: af, bc, hl
VDPCommand_Execute_HL:
	ld a,32
	di
	out (VDP_PORT_1),a
	ld a,17 | 128
	ei
	out (VDP_PORT_1),a
	ld c,VDP_PORT_3
WaitReady:
	ld a,2
	di
	out (VDP_PORT_1),a  ; select s#2
	ld a,15 | 128
	out (VDP_PORT_1),a
	in a,(VDP_PORT_1)
	rra
	ld a,0
	out (VDP_PORT_1),a  ; select s#0
	ld a,15 | 128
	ei
	out (VDP_PORT_1),a
	jr c,WaitReady
	REPT 15
	outi
	ENDM
	ret

; ix = this
VDPCommand_WaitReady:
	call VDPCommand_IsReady
	jr c,VDPCommand_WaitReady
	ret

; f <- c: not ready (CE=1)
; ix = this
; Modifies: af
VDPCommand_IsReady:
	ld a,2
	di
	out (VDP_PORT_1),a  ; select s#2
	ld a,15 | 128
	out (VDP_PORT_1),a
	in a,(VDP_PORT_1)
	rra
	ld a,0
	out (VDP_PORT_1),a  ; select s#0
	ld a,15 | 128
	ei
	out (VDP_PORT_1),a
	ret
