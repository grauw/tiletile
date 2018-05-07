;
;
;
Glyph: MACRO ?x, ?y, ?nx, ?ny
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
Glyph_SetCopyHL:
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
Glyph_glyphs:
	Glyph 154, 48, 4, 10  ; <space>
	Glyph   0, 72, 2, 10  ; !
	Glyph   2, 72, 4, 10  ; "
	Glyph   6, 72, 6, 10  ; #
	Glyph  12, 72, 6, 10  ; $
	Glyph  18, 72, 8, 10  ; %
	Glyph  26, 72, 6, 10  ; &
	Glyph  32, 72, 2, 10  ; '
	Glyph  34, 72, 4, 10  ; (
	Glyph  38, 72, 4, 10  ; )
	Glyph  42, 72, 6, 10  ; *
	Glyph  48, 72, 6, 10  ; +
	Glyph  54, 72, 4, 10  ; ,
	Glyph  58, 72, 6, 10  ; -
	Glyph  64, 72, 2, 10  ; .
	Glyph  66, 72, 6, 10  ; /
	Glyph  72, 72, 6, 10  ; 0
	Glyph  78, 72, 4, 10  ; 1
	Glyph  82, 72, 6, 10  ; 2
	Glyph  88, 72, 6, 10  ; 3
	Glyph  94, 72, 6, 10  ; 4
	Glyph 100, 72, 6, 10  ; 5
	Glyph 106, 72, 6, 10  ; 6
	Glyph 112, 72, 6, 10  ; 7
	Glyph 118, 72, 6, 10  ; 8
	Glyph 124, 72, 6, 10  ; 9
	Glyph 130, 72, 2, 10  ; :
	Glyph 132, 72, 4, 10  ; ;
	Glyph 136, 72, 4, 10  ; <
	Glyph 140, 72, 6, 10  ; =
	Glyph 146, 72, 4, 10  ; >
	Glyph 150, 72, 6, 10  ; ?
	Glyph 156, 72, 6, 10  ; @
	Glyph   0, 48, 6, 10  ; A
	Glyph   6, 48, 6, 10  ; B
	Glyph  12, 48, 6, 10  ; C
	Glyph  18, 48, 6, 10  ; D
	Glyph  24, 48, 6, 10  ; E
	Glyph  30, 48, 6, 10  ; F
	Glyph  36, 48, 6, 10  ; G
	Glyph  42, 48, 6, 10  ; H
	Glyph  48, 48, 2, 10  ; I
	Glyph  50, 48, 4, 10  ; J
	Glyph  54, 48, 6, 10  ; K
	Glyph  60, 48, 6, 10  ; L
	Glyph  66, 48, 8, 10  ; M
	Glyph  74, 48, 6, 10  ; N
	Glyph  80, 48, 6, 10  ; O
	Glyph  86, 48, 6, 10  ; P
	Glyph  92, 48, 6, 10  ; Q
	Glyph  98, 48, 6, 10  ; R
	Glyph 104, 48, 6, 10  ; S
	Glyph 110, 48, 6, 10  ; T
	Glyph 116, 48, 6, 10  ; U
	Glyph 122, 48, 6, 10  ; V
	Glyph 128, 48, 8, 10  ; W
	Glyph 136, 48, 6, 10  ; X
	Glyph 142, 48, 6, 10  ; Y
	Glyph 148, 48, 6, 10  ; Z
	Glyph 162, 72, 4, 10  ; [
	Glyph 166, 72, 6, 10  ; \
	Glyph 172, 72, 4, 10  ; ]
	Glyph 176, 72, 6, 10  ; ^
	Glyph 182, 72, 6, 10  ; _
	Glyph 188, 72, 4, 10  ; `
	Glyph   0, 60, 6, 10  ; a
	Glyph   6, 60, 6, 10  ; b
	Glyph  12, 60, 6, 10  ; c
	Glyph  18, 60, 6, 10  ; d
	Glyph  24, 60, 6, 10  ; e
	Glyph  30, 60, 4, 10  ; f
	Glyph  34, 60, 6, 11  ; g
	Glyph  40, 60, 6, 10  ; h
	Glyph  46, 60, 2, 10  ; i
	Glyph  48, 60, 4, 11  ; j
	Glyph  52, 60, 6, 10  ; k
	Glyph  58, 60, 4, 10  ; l
	Glyph  62, 60, 8, 10  ; m
	Glyph  70, 60, 6, 10  ; n
	Glyph  76, 60, 6, 10  ; o
	Glyph  82, 60, 6, 11  ; p
	Glyph  88, 60, 6, 11  ; q
	Glyph  94, 60, 6, 10  ; r
	Glyph 100, 60, 6, 10  ; s
	Glyph 106, 60, 4, 10  ; t
	Glyph 110, 60, 6, 10  ; u
	Glyph 116, 60, 6, 10  ; v
	Glyph 122, 60, 8, 10  ; w
	Glyph 130, 60, 6, 10  ; x
	Glyph 136, 60, 6, 11  ; y
	Glyph 142, 60, 6, 10  ; z
	Glyph 192, 72, 4, 10  ; {
	Glyph 196, 72, 2, 10  ; |
	Glyph 198, 72, 4, 10  ; }
	Glyph 202, 72, 6, 10  ; ~
