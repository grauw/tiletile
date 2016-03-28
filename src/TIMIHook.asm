;
; Timer interrupt hook
;
TIMIHook: MACRO
	super: Hook H.TIMI, Entry, OldHook
	suspend:
		db 0
	Entry:
		push af
		ld a,(suspend)
		and a
		jr nz,Return
		dec a
		ei
		ld (suspend),a
		ld ix,0
	object: equ $ - 2
		call System_ThrowException
	address: equ $ - 2
		xor a
		di
		ld (suspend),a
	Return:
		pop af
	OldHook:
		ds 5
	ENDM

; de = callback object (ix)
; hl = callback
; ix = this
TIMIHook_Construct:
	ld (ix + TIMIHook.object),e
	ld (ix + TIMIHook.object + 1),d
	ld (ix + TIMIHook.address),l
	ld (ix + TIMIHook.address + 1),h
	ret
