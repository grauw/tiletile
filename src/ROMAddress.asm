;
;
;
ROMAddress: MACRO ?physicalAddress, ?base = 0
	IF ?base & ROMMapper_BANK_SIZE - 1
		ERROR "Invalid base."
	ENDIF
	bank:
		db ?physicalAddress >> ROMMapper_BANK_SIZE_LOG2
	address:
		dw ?physicalAddress & ROMMapper_BANK_SIZE - 1 | ?base & -ROMMapper_BANK_SIZE
	ENDM

; c = port
; de = size
ROMAddress_OTIR_M: MACRO ?this
	ld l,(?this + ROMAddress.address)
	ld h,(?this + ROMAddress.address + 1)
	ld b,(?this + ROMAddress.bank)
	call ROMAddress_OTIR.Start
	ENDM

; c = port
; de = size
; ix = this
ROMAddress_OTIR: PROC
	ld l,(ix + ROMAddress.address)
	ld h,(ix + ROMAddress.address + 1)
	ld b,(ix + ROMAddress.bank)
Start:
	ld a,d
	or e
	jr nz,Loop
	set 7,d
	call Loop
	set 7,d
Loop:
	ld a,b
	call ROMMapper_SetBank
	push de
	push hl
	ld a,h
	or -ROMMapper_BANK_SIZE >> 8
	ld h,a
	push hl
	add hl,de
	jr nc,NoClamp
	ld hl,0
	and a
NoClamp:
	pop de
	sbc hl,de
	ex de,hl
	pop hl
	push bc
	push de
	ld b,e
	dec de
	inc d
OTIRLoop:
	otir
	dec d
	jr nz,OTIRLoop
	ld de,-ROMMapper_BANK_SIZE
	add hl,de
	pop de
	pop bc
	inc b
	ex (sp),hl
	and a
	sbc hl,de
	ex de,hl
	pop hl
	jr nz,Loop
	ret
	ENDP
