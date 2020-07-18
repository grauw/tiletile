;
; Konami SCC ROM mapper
;
ROMMapper_BANK_SIZE: equ 2000H
ROMMapper_BANK_SIZE_LOG2: equ 13

ROMMapper: MACRO
	page4000:
		ROMPage 4000H, 5000H, 0
	page6000:
		ROMPage 6000H, 7000H, 1
	page8000:
		ROMPage 8000H, 9000H, 2
	pageA000:
		ROMPage 0A000H, 0B000H, 3
	ENDM

ROMPage: MACRO ?base, ?bankSelect, ?initialValue = 0
	BANK_SELECT: equ ?bankSelect
	bank:
		db ?initialValue
	bankSelect:
		db ?bankSelect >> 8
	base:
		db ?base >> 8
	ENDM

; ix = this
ROMMapper_Construct:
	ld a,(ix + ROMMapper.page4000.bank)
	ld (ROMMapper.page4000.BANK_SELECT),a
	ld a,(ix + ROMMapper.page6000.bank)
	ld (ROMMapper.page6000.BANK_SELECT),a
	ld a,(ix + ROMMapper.page8000.bank)
	ld (ROMMapper.page8000.BANK_SELECT),a
	ld a,(ix + ROMMapper.pageA000.bank)
	ld (ROMMapper.pageA000.BANK_SELECT),a
	ret

; hl = page base
; a <- bank
ROMMapper_GetBank:
	push hl
	call ROMMapper_GetPage
	call ROMPage_GetBank
	pop hl
	ret

; a = bank
; hl = page base
ROMMapper_SetBank:
	push hl
	call ROMMapper_GetPage
	call ROMPage_SetBank
	pop hl
	ret

; hl = page base
; hl <- bank select register mirror
ROMMapper_GetPage: PROC
	bit 7,h
	jr nz,UpperHalf
	bit 6,h
	jr z,PageOutOfRange
	bit 5,h
	jr nz,Page6000
Page4000:
	ld hl,ROM_mapper.page4000
	ret
Page6000:
	ld hl,ROM_mapper.page6000
	ret
UpperHalf:
	bit 6,h
	jr nz,PageOutOfRange
	bit 5,h
	jr nz,PageA000
Page8000:
	ld hl,ROM_mapper.page8000
	ret
PageA000:
	ld hl,ROM_mapper.pageA000
	ret
PageOutOfRange:
	call System_ThrowException
	ENDP

; hl = this
; a <- bank
ROMPage_GetBank:
	ld a,(hl)
	ret

; a = bank
; hl = this
; Modifies: hl
ROMPage_SetBank:
	ld (hl),a
	inc hl
	ld h,(hl)
	ld (hl),a
	ret
