;
; System routines
;

; a = character
; Modifies: none
System_PrintChar: equ CHPUT

; hl = string (0-terminated)
; Modifies: none
System_Print:
	push af
	push hl
System_Print_Loop:
	ld a,(hl)
	and a
	jp z,System_Print_Done
	call System_PrintChar
	inc hl
	jp System_Print_Loop
System_Print_Done:
	pop hl
	pop af
	ret

; hl = string (0-terminated)
; Modifies: none
System_PrintLn:
	push hl
	call System_Print
	ld hl,System_crlf
	call System_Print
	pop hl
	ret

; hl = value
; Modifies: none
System_PrintHexHL:
	push af
	ld a,h
	call System_PrintHexA
	ld a,l
	call System_PrintHexA
	pop af
	ret

; a = value
; Modifies: none
System_PrintHexA:
	push af
	and 0F0H
	rrca
	rrca
	rrca
	rrca
	call System_PrintHex
	pop af
	call System_PrintHex
	ret

; a = value (0 - 15)
; Modifies: none
System_PrintHex:
	push af
	and 0FH
	add a,"0"
	cp ":"
	jr c,System_PrintHex_Done
	add a,"A" - ":"
System_PrintHex_Done:
	call System_PrintChar
	pop af
	ret

	SECTION RAM

; About 21% faster alternative for large LDIRs (break-even at 20 loops)
; hl = source
; de = destination
; bc = byte count
System_LDIR: PROC
	xor a
	sub c
	and 16-1
	add a,a
	di
	ld (jumpOffset),a
	ei
	jr nz,$
jumpOffset: equ $ - 1
Loop:
	REPT 16
	ldi
	ENDM
	jp pe,Loop
	ret
	ENDP

	ENDS

System_EnableTurbo:
	ld a,(IDBYT2)
	cp 3
	ret c
	ld a,10000001B
	call CHGCPU
	ret

System_Stop:
	di
	halt
	jp System_Stop

System_ThrowException:
	IF DEBUG
	in a,(02EH)
	ENDIF
	pop de
	call System_PrintExceptionMessage
	jp System_Stop

; hl = message
System_ThrowExceptionWithMessage:
	IF DEBUG
	in a,(02EH)
	ENDIF
	pop de
	push hl
	call System_PrintExceptionMessage
	pop hl
	call System_PrintLn
	jp System_Stop

; de = address
System_PrintExceptionMessage:
	push de
	ld hl,System_exceptionMessage
	call System_Print
	pop hl
	dec hl
	dec hl
	dec hl
	call System_PrintHexHL
	ld hl,System_crlf
	call System_Print
	ret

;
System_exceptionMessage:
	db "An exception occurred on address: ", 0

System_crlf:
	db "\r\n", 0
