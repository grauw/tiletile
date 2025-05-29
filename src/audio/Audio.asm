;
; Audio subsystem
;
	INCLUDE "AudioTrack.asm"
	INCLUDE "PSG.asm"
	INCLUDE "MSXMusic.asm"

Audio: MACRO
	; Modifies: af, bc, de, hl
	Tick: PROC
	playing:
		ld hl,0
	address: equ $ - 2
		ld a,0
	bank: equ $ - 1
		ld (ROM_mapper.page4000.BANK_SELECT),a
		ld a,1
	wait: equ $ - 1
		dec a
		jr nz,Wait
	Loop:
		ld a,(hl)
		inc hl
		cp 40H
		jr c,PSG
		cp 80H
		jr c,OPLL
		jr z,Jump
		sub 80H
	Wait:
		ld (wait),a
		ld (address),hl
		ld a,(ROM_mapper.page4000.bank)
		ld (ROM_mapper.page4000.BANK_SELECT),a
		ret
	PSG:
		ld c,PSG_DATA
		out (PSG_ADDRESS),a
		outi
		jp Loop
	OPLL:
		sub 40H
		ld c,MSXMusic_DATA
		out (MSXMusic_ADDRESS),a  ; wait 18 cycles (min 12)
		outi                      ; wait 91 cycles (min 84)
		jp Loop
	Jump:
		ld a,(hl)
		inc hl
		ld b,(hl)
		inc hl
		ld h,(hl)
		ld l,b
		ld (bank),a
		ld (ROM_mapper.page4000.BANK_SELECT),a
		jp Loop
		ENDP
	psg:
		PSG
	msxMusic:
		MSXMusic
	ENDM

; ix = this
Audio_Construct:
	call Audio_Stop
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
	ld (ix + Audio.Tick.bank),a
	ld a,(iy + AudioTrack.commands.address)
	ld (ix + Audio.Tick.address),a
	ld a,(iy + AudioTrack.commands.address + 1)
	ld (ix + Audio.Tick.address + 1),a
	pop iy
	ld (ix + Audio.Tick.wait),1
	ret

; ix = this
Audio_Play:
	ld (ix + Audio.Tick.playing),021H  ; ld hl,nn
	ret

; ix = this
Audio_Stop:
	ld (ix + Audio.Tick.playing),0C9H  ; ret
	ret

; ix = this
Audio_Tick:
	jp ix
