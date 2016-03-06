;
; Memory and slot-related routines
;
Memory_EnableROMInPage2:
	call Memory_GetSlotPage1
	call Memory_SetSlotPage2
	ret

Memory_EnableRAMInPage2:
	call Memory_GetSlotPage3
	call Memory_SetSlotPage2
	ret

Memory_GetSlot:
	ld a,h
	sub 64
	jp c,Memory_GetSlotPage0
	sub 64
	jp c,Memory_GetSlotPage1
	sub 64
	jp c,Memory_GetSlotPage2
	jp Memory_GetSlotPage3

Memory_GetSlotPage0:
	call RSLREG
	and 00000011B
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 00000011B
	rlca
	rlca
	or c
	ret

Memory_GetSlotPage1:
	call RSLREG
	and 00001100B
	rrca
	rrca
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 00001100B
	or c
	ret

Memory_GetSlotPage2:
	call RSLREG
	and 00110000B
	rrca
	rrca
	rrca
	rrca
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 00110000B
	rrca
	rrca
	or c
	ret

Memory_GetSlotPage3:
	call RSLREG
	and 11000000B
	rlca
	rlca
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 11000000B
	rrca
	rrca
	rrca
	rrca
	or c
	ret

;
; Sets a slot in page 2.
; The current interrupt enabled state is preserved.
;
; a = slot ID formatted FxxxSSPP
; Modifies: af, bc, de, hl
;
Memory_SetSlotPage2:
	ld c,a
	and 00001100B
	rlca
	rlca
	ld e,a
	ld a,c
	and 00000011B
	ld c,a
	rlca
	rlca
	rlca
	rlca
	ld b,a
	rlca
	rlca
	ld d,a
	ld h,SLTTBL >> 8
	ld a,SLTTBL & 0FFH
	add a,c
	ld l,a
	in a,(0A8H)
	ld c,a
	and 00111111B
	or d
	ld d,a
	ld a,c
	and 11001111B
	or b
	ld b,a
	ld a,(hl)
	and 11001111B
	or e
	ld e,a
	ld (hl),a
	ld c,0A8H
	ld hl,0FFFFH
	ld a,r
	di
	out (c),d
	ld (hl),e
	out (c),b
	ret po
	ei
	ret

;
; Prepares a slot selection in page 0.
;
; Note, when applying, primary slots will be set to their state when prepared.
; So when invoked, slot selection of pages 1, 2 and 3 should be the same.
;
; a = slot ID formatted FxxxSSPP
; bc <- prepared slot id (1)
; de <- prepared slot id (2)
; Modifies: af, bc, de
;
Memory_PrepareSlotPage0:
	ld c,a
	and 00001100B
	rrca
	rrca
	ld e,a
	ld a,c
	and 00000011B
	ld b,a
	rrca
	rrca
	or b
	ld d,a
	ld h,SLTTBL >> 8
	ld a,SLTTBL & 0FFH
	add a,b
	ld l,a
	in a,(0A8H)
	ld c,a
	and 00111100B
	or d
	ld d,a
	ld a,c
	and 11111100B
	or b
	ld b,a
	ld a,(hl)
	and 11111100B
	or e
	ld e,a
	ld c,l
	ret

;
; Prepares a slot selection in page 2.
;
; Note, when applying, primary slots will be set to their state when prepared.
; So when invoked, slot selection of pages 0, 1 and 3 should be the same.
;
; a = slot ID formatted FxxxSSPP
; bc <- prepared slot id (1)
; de <- prepared slot id (2)
; Modifies: af, bc, de
;
Memory_PrepareSlotPage2:
	ld c,a
	and 00001100B
	rlca
	rlca
	ld e,a
	ld a,c
	and 00000011B
	ld c,a
	rlca
	rlca
	rlca
	rlca
	ld b,a
	rlca
	rlca
	or b
	ld d,a
	ld h,SLTTBL >> 8
	ld a,SLTTBL & 0FFH
	add a,c
	ld l,a
	in a,(0A8H)
	ld c,a
	and 00001111B
	or d
	ld d,a
	ld a,c
	and 11001111B
	or b
	ld b,a
	ld a,(hl)
	and 11001111B
	or e
	ld e,a
	ld c,l
	ret

;
; Sets a prepared slot selection in page 2.
; The current interrupt enabled state is preserved.
; The original slot layout can be restored by invoking this method again.
;
; Note, when applying, primary slots will be set to their state when prepared.
; So when invoked, slot selection of pages 0, 1 and 3 should be the same.
;
; bc = Prepared slot id (1)
; de = Prepared slot id (2)
; bc <- Prepared slot id (1) to restore
; de <- Prepared slot id (2) to restore
; Modifies: af, bc, de, hl
;
Memory_SetPreparedSlotPage2:
	push bc
	ld hl,0FFFFH
	ld c,0A8H
	ld a,r
	di
	in a,(0A8H)  ; be careful not to modify p/v flag
	out (c),d
	ld (hl),e
	out (c),b
	pop bc
	ld h,SLTTBL >> 8
	ld l,c
	ld b,a
	ld a,(hl)
	ld (hl),e
	ld e,a
	ret po
	ei
	ret

;
; Reads a byte from a slot in page 0
; The current interrupt enabled state is preserved.
;
; a = slot ID
; hl = address
; a <- value
; Modifies: af, af', bc, de, hl
;
Memory_ReadSlotPage0:
	push hl
	call Memory_PrepareSlotPage0
	pop hl
	jp Memory_ReadPreparedSlotPage0

;
; Reads a byte from a prepared slot in page 0
; The current interrupt enabled state is preserved.
;
; de = prepared slot id (2)
; hl = address
; a <- value
; Modifies: af, af', bc, de, hl
;
Memory_ReadPreparedSlotPage0:
	ld c,0A8H
	ld a,r
	ex af,af'
	di
	in b,(c)
	out (c),d
	ld a,(0FFFFH)
	ex af,af'
	ld a,e
	ld (0FFFFH),a
	ld a,(hl)
	ex af,af'
	ld (0FFFFH),a
	out (c),b
	ex af,af'
	ret po
	ei
	ret

;
; Writes a byte to a slot in page 0
; The current interrupt enabled state is preserved.
;
; a = slot ID
; c = value
; hl = address
; Modifies: af, af', bc, de, hl
;
Memory_WriteSlotPage0:
	push bc
	push hl
	call Memory_PrepareSlotPage0
	pop hl
	pop bc
	jp Memory_WritePreparedSlotPage0

;
; Writes a byte to a prepared slot in page 0
; The current interrupt enabled state is preserved.
;
; c = value
; de = prepared slot id (2)
; hl = address
; Modifies: af, af', bc, de, hl
;
Memory_WritePreparedSlotPage0:
	ld a,r
	ld a,c
	ld c,0A8H
	ex af,af'
	di
	in b,(c)
	out (c),d
	ld a,(0FFFFH)
	ld d,a
	ld a,e
	ld (0FFFFH),a
	ex af,af'
	ld (hl),a
	ld a,d
	ld (0FFFFH),a
	out (c),b
	ret po
	ei
	ret

;
; Search all slots and subslots for a match.
; Invoke Continue to continue searching where a previous search left off.
;
; hl = detection routine (receives a = slot ID, can modify all)
; f <- c: found
; a <- slot number
; Modifies: af, bc, de
;
Memory_SearchSlots: PROC
	ld a,0
PrimaryLoop:
	ex de,hl
	ld hl,EXPTBL
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	ex de,hl
	and 10000000B
	or c
SecondaryLoop:
	push af
	push hl
	call CallHL
	pop hl
	jp c,Found
	pop af
Continue:
	add a,00000100B
	jp p,NextPrimary
	bit 4,a
	jp z,SecondaryLoop
NextPrimary:
	inc a
	and 00000011B
	ret z  ; not found
	jp PrimaryLoop
Found:
	pop af
	scf
	ret
CallHL:
	jp hl
	ENDP

;
; Match a string in a slot.
;
; a = slot
; bc = string length
; de = string
; hl = address
; f <- c: found
; Modifies: f, bc, de, hl
;
Memory_MatchSlotString: PROC
	push af
	push bc
	push de
	call RDSLT
	pop de
	pop bc
	ex de,hl
	cpi
	jr nz,NotFound
	jp po,Found
	inc de
	ex de,hl
	pop af
	jp Memory_MatchSlotString
Found:
	pop af
	scf
	ret
NotFound:
	pop af
	and a
	ret
	ENDP


;
; Unit tests
;
Memory_UnitTest:
	call Memory_TestSearchSlots
	ret

Memory_TestSearchSlots:
	di
	; does searching for test string yield the current slot?
	ld hl,Memory_TestSearchSlots_id
	call Memory_GetSlot
	push af
	ld hl,Memory_TestSearchSlots_Matcher
	call Memory_SearchSlots
	pop bc
	call nc,System_ThrowException
	cp b
;	call nz,System_ThrowException  ; this crashes after ROMLOADing into SCC+

	; negative test
	ld hl,Memory_TestSearchSlots_MatcherNotFound
	call Memory_SearchSlots
	call c,System_ThrowException
	ei
	ret

Memory_TestSearchSlots_Matcher:
	ld hl,Memory_TestSearchSlots_id
	ld de,Memory_TestSearchSlots_id
	ld bc,8
	call Memory_MatchSlotString
	ret

Memory_TestSearchSlots_MatcherNotFound:
	ld hl,Memory_TestSearchSlots_id + 4
	ld de,Memory_TestSearchSlots_id
	ld bc,8
	call Memory_MatchSlotString
	ret

Memory_TestSearchSlots_id:
	db "UNITTEST"
