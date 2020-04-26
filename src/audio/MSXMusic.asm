;
; MSX-MUSIC YM2413 OPLL driver
;
MSXMusic_ADDRESS: equ 7CH
MSXMusic_DATA: equ 7DH
MSXMusic_ID_ADDRESS: equ 4018H
MSXMusic_ENABLE_ADDRESS: equ 7FF6H

MSXMusic: MACRO
	found:
		db 0
	slot:
		db 0
	internal:
		db 0
	ENDM

; ix = this
MSXMusic_Construct:
	call MSXMusic_Detect
	ret nc
	ld (ix + MSXMusic.found),1
	ld (ix + MSXMusic.slot),a
	ld (ix + MSXMusic.internal),b
	call MSXMusic_Enable
	jr MSXMusic_Reset

; ix = this
MSXMusic_Destruct:
	bit 0,(ix + MSXMusic.found)
	ret z
	call MSXMusic_Mute
	jr MSXMusic_Disable

; e = register
; d = value
; ix = this
MSXMusic_WriteRegister:
	ld a,e
	out (MSXMusic_ADDRESS),a  ; wait 12 cycles
	ld a,d
	out (MSXMusic_DATA),a     ; wait 84 cycles
	ex (sp),ix
	ex (sp),ix
	ret

; ix = this
MSXMusic_Enable:
	bit 0,(ix + MSXMusic.internal)
	ret nz
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_ReadSlot
	set 0,a
	ld e,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	jp Memory_WriteSlot

; ix = this
MSXMusic_Disable:
	bit 0,(ix + MSXMusic.internal)
	ret nz
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_ReadSlot
	res 0,a
	ld e,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	jp Memory_WriteSlot

; b = count
; e = register base
; d = value
; ix = this
MSXMusic_FillRegisters:
	push bc
	push de
	call MSXMusic_WriteRegister
	in a,(09AH)  ; R800 wait: ~62 cycles - 5 (ret)
	pop de
	pop bc
	inc e
	djnz MSXMusic_FillRegisters
	ret

; ix = this
MSXMusic_Mute:
	ld de,000EH
	call MSXMusic_WriteRegister  ; rhythm off
	ld de,0F07H
	call MSXMusic_WriteRegister  ; max carrier release rate
	ld b,9
	ld de,0F30H
	call MSXMusic_FillRegisters  ; instrument 0, min volume
	ld b,9
	ld de,0010H
	call MSXMusic_FillRegisters  ; frequency 0
	ld b,9
	ld de,0020H
	jr MSXMusic_FillRegisters    ; key off

; ix = this
MSXMusic_Reset:
	ld b,39H
	ld de,0000H
	jr MSXMusic_FillRegisters

; ix = this
; f <- c: found
; a <- slot
; b <- 0: external, -1: internal
MSXMusic_Detect:
	ld hl,MSXMusic_MatchInternalID
	call Memory_SearchSlots
	ld b,-1
	ret c
	ld hl,MSXMusic_MatchExternalID
	call Memory_SearchSlots
	ld b,0
	ret

; a = slot id
; f <- c: found
MSXMusic_MatchInternalID:
	ld de,MSXMusic_internalId
	ld hl,MSXMusic_ID_ADDRESS
	ld bc,8
	jp Memory_MatchSlotString

; a = slot id
; ix = this
; f <- c: found
MSXMusic_MatchExternalID:
	ld de,MSXMusic_externalId
	ld hl,MSXMusic_ID_ADDRESS + 4
	ld bc,4
	jp Memory_MatchSlotString

;
MSXMusic_internalId:
	db "APRLOPLL"

MSXMusic_externalId:
	db "OPLL"
