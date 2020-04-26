;
; Interrupt handler (IM2 mode)
;
Interrupt_HEAPBLOCK_SIZE: equ 200H
Interrupt_HOOK_SIZE: equ 5

Interrupt: MACRO
	table:
		dw 0
	entry:
		dw 0
	Handler:
		push af
		push bc
		push de
		push hl
		ld bc,(15 | VDP_REGISTER) << 8 | VDP_PORT_1
		ld a,1
		out (c),a
		out (c),b  ; select s#1
		in a,(c)
		rra
		jp c,Return
	lineHandler: equ $ - 2
		xor a
		out (c),a
		out (c),b  ; select s#0
		ld (INTCNT),a  ; disable part of the BIOS ISR
		ld (SCNCNT),a
		rst 38H
		di  ; small window for reentrant interrupt to occur
	Return:
		ld bc,(15 | VDP_REGISTER) << 8 | VDP_PORT_1
		ld a,(VDP_MIRROR_8 + 15)
		out (c),a
		out (c),b
		pop hl
		pop de
		pop bc
		pop af
		ei
		ret
	ENDM

; ix = this
Interrupt_Construct:
	ld de,Interrupt_table
	ld a,d
	cp 0C0H
	call c,System_ThrowException
	cp 100H - Interrupt_HOOK_SIZE
	call nc,System_ThrowException
	ld (ix + Interrupt.table),e
	ld (ix + Interrupt.table + 1),d
	ld a,d
	inc a
	ld (ix + Interrupt.entry),a
	ld (ix + Interrupt.entry + 1),a
	ld (de),a
	ld l,e
	ld h,d
	inc de
	ld bc,100H
	ldir
	ld e,ixl
	ld d,ixh
	ld hl,Interrupt.Handler
	add hl,de
	ex de,hl
	ld l,a
	ld h,a
	ld (hl),0C3H  ; jp
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	ld a,(ix + Interrupt.table + 1)
	ld i,a
	im 2
	ld a,2
	ld b,15
	ld (VDP_MIRROR_8 + 15),a
	call VDP_SetRegister  ; select s#2
	ret

; ix = this
Interrupt_Destruct:
	di
	im 1
	ld a,0
	ld b,15
	ld (VDP_MIRROR_8 + 15),a
	call VDP_SetRegister  ; select s#0
	ei
	ret

; iy = this
; de <- return address
; hl <- line handler pointer address
Interrupt_GetAddressesIY:
	ld c,iyl
	ld b,iyh
	ld hl,Interrupt.Return
	add hl,bc
	ex de,hl
	ld hl,Interrupt.lineHandler
	add hl,bc
	ret

; de = line handler
; iy = this
Interrupt_SetLineHandlerIY:
	di
	ld (iy + Interrupt.lineHandler),e
	ei
	ld (iy + Interrupt.lineHandler + 1),d
	ret

; iy = this
Interrupt_ResetLineHandlerIY:
	call Interrupt_GetAddressesIY
	jp Interrupt_SetLineHandlerIY

;
	SECTION RAM

	ALIGN 100H
Interrupt_table:
	ds Interrupt_HEAPBLOCK_SIZE

	ENDS
