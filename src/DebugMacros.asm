;
; Profiling macros
;
PROFILE_BEGIN: MACRO ?id
	ld a,?id
	in a,(2ch)
	ENDM

PROFILE_END: MACRO ?id
	ld a,?id
	out (2ch),a
	ENDM

PROFILE_FRAME_BEGIN: MACRO
	in a,(2dh)
	ENDM

PROFILE_FRAME_END: MACRO
	out (2dh),a
	ENDM
