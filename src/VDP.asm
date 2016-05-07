VDP_PORT_0: equ 98H
VDP_PORT_1: equ 99H
VDP_PORT_2: equ 9AH
VDP_PORT_3: equ 9BH

VDP_READ: equ 00000000B
VDP_WRITE: equ 01000000B
VDP_REGISTER: equ 10000000B

VDP_MIRROR_0: equ 0F3DFH
VDP_MIRROR_8: equ 0FFE7H - 8
VDP_MIRROR_25: equ 0FFFAH - 25

VDP_InitScreen5: PROC
	ld a,5
	call CHGMOD
	ret
	ENDP

VDP_Enable212Lines:
	ld a,(VDP_MIRROR_8 + 9)
	or 10000000B
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ret

VDP_Enable192Lines:
	ld a,(VDP_MIRROR_8 + 9)
	and 01111111B
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ret

VDP_Enable60Hz:
	ld a,(VDP_MIRROR_8 + 9)
	and 11111101B
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ret

VDP_EnableLineInt:
	ld a,0  ; set HR line 0
	ld b,19
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 1)  ; disable IE0
	and 11011111B
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 0)  ; enable IE1
	or 00010000B
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ret

VDP_DisableLineInt:
	ld a,(VDP_MIRROR_0 + 0)  ; disable IE1
	and 11101111B
	ld (VDP_MIRROR_0 + 0),a
	ld b,0
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 1)  ; enable IE0
	or 00100000B
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ret

VDP_EnableScrollMask:
	ld a,(VDP_MIRROR_25 + 25)
	or 00000010B
	ld (VDP_MIRROR_25 + 25),a
	ld b,25
	call VDP_SetRegister
	ld a,(VDP_MIRROR_8 + 18)
	and 0F0H
	ld b,a
	ld a,(VDP_MIRROR_8 + 18)
	and 0FH
	add a,4  ; re-center screen
	cp 8     ; clamp if it was already adjusted far to the left
	jp c,NoClamp
	cp 12
	jp nc,NoClamp
	ld a,7
NoClamp:
	and 0FH
	or b
	ld b,18
	call VDP_SetRegister
	ret

VDP_EnableSprites:
	ld a,(VDP_MIRROR_8 + 8)
	and 11111101B
	ld (VDP_MIRROR_8 + 8),a
	ld b,8
	call VDP_SetRegister
	ret

VDP_DisableSprites:
	ld a,(VDP_MIRROR_8 + 8)
	or 00000010B
	ld (VDP_MIRROR_8 + 8),a
	ld b,8
	call VDP_SetRegister
	ret

VDP_EnableBlank:
	ld a,(VDP_MIRROR_0 + 1)
	and 10111111B
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ret

VDP_DisableBlank:
	ld a,(VDP_MIRROR_0 + 1)
	or 01000000B
	ld (VDP_MIRROR_0 + 1),a
	ld b,1
	call VDP_SetRegister
	ret

VDP_SetColor:
	di
	out (VDP_PORT_1),a
	ld a,7 | VDP_REGISTER
	ei
	out (VDP_PORT_1),a
	ret

VDP_EnableBlink: PROC
	xor a
	ld hl,0C00H
	call VDP_SetColorTableBase
	ld a,0F8H
	ld (VDP_MIRROR_8 + 12),a
	ld b,12
	call VDP_SetRegister
	ld a,0F0H
	ld (VDP_MIRROR_8 + 13),a
	ld b,13
	call VDP_SetRegister
	xor a
	ld hl,0C00H
	call VDP_SetWriteAddress
	xor a
	ld bc,0E02H
ClearLoop:
	out (98H),a
	djnz ClearLoop
	dec c
	jp nz,ClearLoop
	ret
	ENDP

; ahl = base address (17-bit, multiples of 200H)
VDP_SetColorTableBase:
	ld (TXTCOL),hl
	add hl,hl
	adc a,a
	add hl,hl
	adc a,a
	ld (VDP_MIRROR_8 + 10),a
	ld b,10
	call VDP_SetRegister
	ld a,h
	or 00000111B
	ld (VDP_MIRROR_0 + 3),a
	ld b,3
	call VDP_SetRegister
	ret

;
; Detect VDP version
;
; a <- 0: TMS9918A, 1: V9938, 2: V9958, x: VDP ID
;
VDP_GetVersion:
	call VDP_IsTMS9918A  ; use a different way to detect TMS9918A
	ret z
	ld a,1	 ; select s#1
	di
	out (VDP_PORT_1),a
	ld a,15 + 128
	out (VDP_PORT_1),a
	in a,(VDP_PORT_1)    ; read s#1
	and 00111110B        ; get VDP ID
	rrca
	ex af,af'
	xor a	  ; select s#0 as required by BIOS
	out (VDP_PORT_1),a
	ld a,15 + 128
	ei
	out (VDP_PORT_1),a
	ex af,af'
	ret nz	 ; return VDP ID for V9958 or higher
	inc a	  ; return 1 for V9938
	ret

;
; Test if the VDP is a TMS9918A.
;
; The VDP ID number was only introduced in the V9938, so we have to use a
; different method to detect the TMS9918A. We wait for the vertical blanking
; interrupt flag, and then quickly read status register 2 and expect bit 6
; (VR, vertical retrace flag) to be set as well. The TMS9918A has only one
; status register, so bit 6 (5S, 5th sprite flag) will return 0 in stead.
;
; f <- z: TMS9918A, nz: V99X8
;
VDP_IsTMS9918A: PROC
	di
	in a,(VDP_PORT_1)    ; read s#0
	and a
	jp p,VDP_IsTMS9918A  ; wait until interrupt flag is set
	ld a,2	 ; select s#2 on V9938
	out (VDP_PORT_1),a
	ld a,15 + 128
	out (VDP_PORT_1),a
	in a,(VDP_PORT_1)    ; read s#2 / s#0
	ex af,af'
	xor a	  ; select s#0 as required by BIOS
	out (VDP_PORT_1),a
	ld a,15 + 128
	ei
	out (VDP_PORT_1),a
	ex af,af'
	and 01000000B        ; check if bit 6 was 0 (s#0 5S) or 1 (s#2 VR)
	ret
	ENDP

; a = value
; b = register
; Modifies: af
VDP_SetRegister:
	di
	out (VDP_PORT_1),a
	ld a,b
	or VDP_REGISTER
	ei
	out (VDP_PORT_1),a
	ret

; hl = address bits 0-15
; a = address bit 16
VDP_SetReadAddress:
	rlc h
	rla
	rlc h
	rla
	srl h
	srl h
	di
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 14
	out (VDP_PORT_1),a
VDP_SetReadAddress14Bit:
	ld a,l
	out (VDP_PORT_1),a
	ld a,h
	or VDP_READ
	ei
	out (VDP_PORT_1),a
	ret

; hl = address bits 0-15
; a = address bit 16
VDP_SetWriteAddress:
	rlc h
	rla
	rlc h
	rla
	srl h
	srl h
	di
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 14
	out (VDP_PORT_1),a
VDP_SetWriteAddress14Bit:
	ld a,l
	out (VDP_PORT_1),a
	ld a,h
	or VDP_WRITE
	ei
	out (VDP_PORT_1),a
	ret

; hl = source address
; bc = byte count
; Modifies: af
VDP_Read:
	dec bc
	ld a,b
	inc a
	inc c
	ld b,c
	ld c,VDP_PORT_0
VDP_Read_Loop:
	inir
	dec a
	jp nz,VDP_Read_Loop
	ret

; hl = source address
; bc = byte count
; Modifies: af
VDP_Write:
	dec bc
	ld a,b
	inc a
	inc c
	ld b,c
	ld c,VDP_PORT_0
VDP_Write_Loop:
	otir
	dec a
	jp nz,VDP_Write_Loop
	ret
