;
;
;
Character: MACRO ?x, ?y, ?nx, ?ny
	x:
		db ?x
	y:
		db ?y
	nx:
		db ?nx
	ny:
		db ?ny
	_size:
	ENDM

; hl = this
; iy = VDP command
Character_SetCopyHL:
	ld a,(hl)
	ld (iy + VDPCommand.sx),a
	inc hl
	ld a,(hl)
	ld (iy + VDPCommand.sy),a
	inc hl
	ld a,(hl)
	ld (iy + VDPCommand.nx),a
	inc hl
	ld a,(hl)
	ld (iy + VDPCommand.ny),a
	ret

;
Character_characters:
	Character 154, 48, 4, 8  ; <space>
	Character   0, 68, 2, 8  ; !
	Character   2, 68, 4, 8  ; "
	Character   6, 68, 6, 8  ; #
	Character  12, 68, 6, 8  ; $
	Character  18, 68, 8, 8  ; %
	Character  26, 68, 6, 8  ; &
	Character  32, 68, 2, 8  ; '
	Character  34, 68, 4, 8  ; (
	Character  38, 68, 4, 8  ; )
	Character  42, 68, 6, 8  ; *
	Character  48, 68, 6, 8  ; +
	Character  54, 68, 4, 8  ; ,
	Character  58, 68, 6, 8  ; -
	Character  64, 68, 2, 8  ; .
	Character  66, 68, 6, 8  ; /
	Character  72, 68, 6, 8  ; 0
	Character  78, 68, 4, 8  ; 1
	Character  82, 68, 6, 8  ; 2
	Character  88, 68, 6, 8  ; 3
	Character  94, 68, 6, 8  ; 4
	Character 100, 68, 6, 8  ; 5
	Character 106, 68, 6, 8  ; 6
	Character 112, 68, 6, 8  ; 7
	Character 118, 68, 6, 8  ; 8
	Character 124, 68, 6, 8  ; 9
	Character 130, 68, 2, 8  ; :
	Character 132, 68, 4, 8  ; ;
	Character 136, 68, 4, 8  ; <
	Character 140, 68, 6, 8  ; =
	Character 146, 68, 4, 8  ; >
	Character 150, 68, 6, 8  ; ?
	Character 156, 68, 6, 8  ; @
	Character   0, 48, 6, 8  ; A
	Character   6, 48, 6, 8  ; B
	Character  12, 48, 6, 8  ; C
	Character  18, 48, 6, 8  ; D
	Character  24, 48, 6, 8  ; E
	Character  30, 48, 6, 8  ; F
	Character  36, 48, 6, 8  ; G
	Character  42, 48, 6, 8  ; H
	Character  48, 48, 2, 8  ; I
	Character  50, 48, 4, 8  ; J
	Character  54, 48, 6, 8  ; K
	Character  60, 48, 6, 8  ; L
	Character  66, 48, 8, 8  ; M
	Character  74, 48, 6, 8  ; N
	Character  80, 48, 6, 8  ; O
	Character  86, 48, 6, 8  ; P
	Character  92, 48, 6, 8  ; Q
	Character  98, 48, 6, 8  ; R
	Character 104, 48, 6, 8  ; S
	Character 110, 48, 6, 8  ; T
	Character 116, 48, 6, 8  ; U
	Character 122, 48, 6, 8  ; V
	Character 128, 48, 8, 8  ; W
	Character 136, 48, 6, 8  ; X
	Character 142, 48, 6, 8  ; Y
	Character 148, 48, 6, 8  ; Z
	Character 162, 68, 4, 8  ; [
	Character 166, 68, 6, 8  ; \
	Character 172, 68, 4, 8  ; ]
	Character 176, 68, 6, 8  ; ^
	Character 182, 68, 6, 8  ; _
	Character 188, 68, 4, 8  ; `
	Character   0, 58, 6, 8  ; a
	Character   6, 58, 6, 8  ; b
	Character  12, 58, 6, 8  ; c
	Character  18, 58, 6, 8  ; d
	Character  24, 58, 6, 8  ; e
	Character  30, 58, 4, 8  ; f
	Character  34, 58, 6, 9  ; g
	Character  40, 58, 6, 8  ; h
	Character  46, 58, 2, 8  ; i
	Character  48, 58, 4, 9  ; j
	Character  52, 58, 6, 8  ; k
	Character  58, 58, 4, 8  ; l
	Character  62, 58, 8, 8  ; m
	Character  70, 58, 6, 8  ; n
	Character  76, 58, 6, 8  ; o
	Character  82, 58, 6, 9  ; p
	Character  88, 58, 6, 9  ; q
	Character  94, 58, 6, 8  ; r
	Character 100, 58, 6, 8  ; s
	Character 106, 58, 4, 8  ; t
	Character 110, 58, 6, 8  ; u
	Character 116, 58, 6, 8  ; v
	Character 122, 58, 8, 8  ; w
	Character 130, 58, 6, 8  ; x
	Character 136, 58, 6, 9  ; y
	Character 142, 58, 6, 8  ; z
	Character 192, 68, 4, 8  ; {
	Character 196, 68, 2, 8  ; |
	Character 198, 68, 4, 8  ; }
	Character 202, 68, 6, 8  ; ~
