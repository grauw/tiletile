;
; Audio subsystem
;
	INCLUDE "AudioTrack.asm"
	INCLUDE "PSG.asm"
	INCLUDE "MSXMusic.asm"

Audio: MACRO
	; Modifies: af, bc, de, hl
	Tick:
	playing: ret
		ld hl,0
	address: equ $ - 2
		ld de,1 >> 8
	bank: equ $ - 2
	wait: equ $ - 1
		ld a,e
		ld (ROM_mapper.page4000.BANK_SELECT),a
		dec d
		call z,Process
		ld (bank),de
		ld (address),hl
		ld a,(ROM_mapper.page4000.bank)
		ld (ROM_mapper.page4000.BANK_SELECT),a
		ret

	; ehl = command list
	; d <- wait
	; ehl <- next command
	Process:
		ld a,(hl)
		cp 40H
		jr c,ProcessPSG
		cp 80H
		jr c,ProcessOPLL
		jr z,ProcessJump
		sub 80H
		ld d,a
		inc hl
		ret

	; ehl = command list
	; ehl <- next command
	ProcessPSG:
		ld c,PSG_DATA
		inc hl
		out (PSG_ADDRESS),a
		outi
		jr Process

	; ehl = command list
	; ehl <- next command
	ProcessOPLL:
		sub 40H
		inc hl
		ld c,MSXMusic_DATA
		out (MSXMusic_ADDRESS),a  ; wait 12 cycles
		outi                      ; wait 84 cycles
		jr Process

	; ehl = command list
	; ehl <- next command
	ProcessJump:
		inc hl
		ld e,(hl)
		inc hl
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
		ld a,e
		ld (ROM_mapper.page4000.BANK_SELECT),a
		jr Process

	psg:
		PSG
	msxMusic:
		MSXMusic
	ENDM

; ix = this
Audio_Construct:
	push ix
	call Audio_GetPSG
	call PSG_Construct
	pop ix
	push ix
	call Audio_GetMSXMusic
	call MSXMusic_Construct
	pop ix
	ret

; ix = this
Audio_Destruct:
	call Audio_Stop
	push ix
	call Audio_GetPSG
	call PSG_Destruct
	pop ix
	push ix
	call Audio_GetMSXMusic
	call MSXMusic_Destruct
	pop ix
	ret

; ix = this
Audio_GetPSG:
	ld de,Audio.psg
	add ix,de
	ret

; ix = this
Audio_GetMSXMusic:
	ld de,Audio.msxMusic
	add ix,de
	ret

; de = track
; ix = this
Audio_SetTrack:
	push iy
	ld iyl,e
	ld iyh,d
	ld a,(iy + AudioTrack.commands.bank)
	ld (ix + Audio.bank),a
	ld a,(iy + AudioTrack.commands.address)
	ld (ix + Audio.address),a
	ld a,(iy + AudioTrack.commands.address + 1)
	ld (ix + Audio.address + 1),a
	pop iy
	ld (ix + Audio.wait),1
	ret

; ix = this
Audio_Play:
	ld (ix + Audio.playing),00H  ; nop
	ret

; ix = this
Audio_Stop:
	ld (ix + Audio.playing),0C9H  ; ret
	ret

; ix = this
Audio_Tick:
	jp ix
