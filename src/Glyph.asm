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
	Glyph 154, 48, 4, 8  ; <space>
	Glyph   0, 68, 2, 8  ; !
	Glyph   2, 68, 4, 8  ; "
	Glyph   6, 68, 6, 8  ; #
	Glyph  12, 68, 6, 8  ; $
	Glyph  18, 68, 8, 8  ; %
	Glyph  26, 68, 6, 8  ; &
	Glyph  32, 68, 2, 8  ; '
	Glyph  34, 68, 4, 8  ; (
	Glyph  38, 68, 4, 8  ; )
	Glyph  42, 68, 6, 8  ; *
	Glyph  48, 68, 6, 8  ; +
	Glyph  54, 68, 4, 8  ; ,
	Glyph  58, 68, 6, 8  ; -
	Glyph  64, 68, 2, 8  ; .
	Glyph  66, 68, 6, 8  ; /
	Glyph  72, 68, 6, 8  ; 0
	Glyph  78, 68, 4, 8  ; 1
	Glyph  82, 68, 6, 8  ; 2
	Glyph  88, 68, 6, 8  ; 3
	Glyph  94, 68, 6, 8  ; 4
	Glyph 100, 68, 6, 8  ; 5
	Glyph 106, 68, 6, 8  ; 6
	Glyph 112, 68, 6, 8  ; 7
	Glyph 118, 68, 6, 8  ; 8
	Glyph 124, 68, 6, 8  ; 9
	Glyph 130, 68, 2, 8  ; :
	Glyph 132, 68, 4, 8  ; ;
	Glyph 136, 68, 4, 8  ; <
	Glyph 140, 68, 6, 8  ; =
	Glyph 146, 68, 4, 8  ; >
	Glyph 150, 68, 6, 8  ; ?
	Glyph 156, 68, 6, 8  ; @
	Glyph   0, 48, 6, 8  ; A
	Glyph   6, 48, 6, 8  ; B
	Glyph  12, 48, 6, 8  ; C
	Glyph  18, 48, 6, 8  ; D
	Glyph  24, 48, 6, 8  ; E
	Glyph  30, 48, 6, 8  ; F
	Glyph  36, 48, 6, 8  ; G
	Glyph  42, 48, 6, 8  ; H
	Glyph  48, 48, 2, 8  ; I
	Glyph  50, 48, 4, 8  ; J
	Glyph  54, 48, 6, 8  ; K
	Glyph  60, 48, 6, 8  ; L
	Glyph  66, 48, 8, 8  ; M
	Glyph  74, 48, 6, 8  ; N
	Glyph  80, 48, 6, 8  ; O
	Glyph  86, 48, 6, 8  ; P
	Glyph  92, 48, 6, 8  ; Q
	Glyph  98, 48, 6, 8  ; R
	Glyph 104, 48, 6, 8  ; S
	Glyph 110, 48, 6, 8  ; T
	Glyph 116, 48, 6, 8  ; U
	Glyph 122, 48, 6, 8  ; V
	Glyph 128, 48, 8, 8  ; W
	Glyph 136, 48, 6, 8  ; X
	Glyph 142, 48, 6, 8  ; Y
	Glyph 148, 48, 6, 8  ; Z
	Glyph 162, 68, 4, 8  ; [
	Glyph 166, 68, 6, 8  ; \
	Glyph 172, 68, 4, 8  ; ]
	Glyph 176, 68, 6, 8  ; ^
	Glyph 182, 68, 6, 8  ; _
	Glyph 188, 68, 4, 8  ; `
	Glyph   0, 58, 6, 8  ; a
	Glyph   6, 58, 6, 8  ; b
	Glyph  12, 58, 6, 8  ; c
	Glyph  18, 58, 6, 8  ; d
	Glyph  24, 58, 6, 8  ; e
	Glyph  30, 58, 4, 8  ; f
	Glyph  34, 58, 6, 9  ; g
	Glyph  40, 58, 6, 8  ; h
	Glyph  46, 58, 2, 8  ; i
	Glyph  48, 58, 4, 9  ; j
	Glyph  52, 58, 6, 8  ; k
	Glyph  58, 58, 4, 8  ; l
	Glyph  62, 58, 8, 8  ; m
	Glyph  70, 58, 6, 8  ; n
	Glyph  76, 58, 6, 8  ; o
	Glyph  82, 58, 6, 9  ; p
	Glyph  88, 58, 6, 9  ; q
	Glyph  94, 58, 6, 8  ; r
	Glyph 100, 58, 6, 8  ; s
	Glyph 106, 58, 4, 8  ; t
	Glyph 110, 58, 6, 8  ; u
	Glyph 116, 58, 6, 8  ; v
	Glyph 122, 58, 8, 8  ; w
	Glyph 130, 58, 6, 8  ; x
	Glyph 136, 58, 6, 9  ; y
	Glyph 142, 58, 6, 8  ; z
	Glyph 192, 68, 4, 8  ; {
	Glyph 196, 68, 2, 8  ; |
	Glyph 198, 68, 4, 8  ; }
	Glyph 202, 68, 6, 8  ; ~
