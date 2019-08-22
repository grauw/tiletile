;
;
;
Glyph_CAPITAL: equ 128
Glyph_ASCENDER: equ 64
Glyph_DESCENDER: equ 32
Glyph_X_HEIGHT: equ 6
Glyph_CAP_HEIGHT: equ 9
Glyph_ASCENDER_HEIGHT: equ 2
Glyph_DESCENDER_HEIGHT: equ 2

Glyph: MACRO ?x, ?y, ?nx, ?metrics = 0
	source:
		Vector2 ?x, ?y
	nx:
		db ?nx
	metrics:
		db ?metrics
	_size:
	ENDM

; hl = this
; iy = VDP command
; a <- metrics
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
	ld (iy + VDPCommand.ny),Glyph_CAP_HEIGHT
	bit 5,a
	ret z
	ld (iy + VDPCommand.ny),Glyph_CAP_HEIGHT + Glyph_DESCENDER_HEIGHT
	ret

;
Glyph_glyphs:
	Glyph 154, 48, 4                   ; <space>
	Glyph   0, 72, 2, Glyph_ASCENDER   ; !
	Glyph   2, 72, 4, Glyph_ASCENDER   ; "
	Glyph   6, 72, 6, Glyph_ASCENDER   ; #
	Glyph  12, 72, 6, Glyph_ASCENDER   ; $
	Glyph  18, 72, 8, Glyph_ASCENDER   ; %
	Glyph  26, 72, 6, Glyph_ASCENDER   ; &
	Glyph  32, 72, 2, Glyph_ASCENDER   ; '
	Glyph  34, 72, 4, Glyph_ASCENDER   ; (
	Glyph  38, 72, 4, Glyph_ASCENDER   ; )
	Glyph  42, 72, 6, Glyph_ASCENDER   ; *
	Glyph  48, 72, 6                   ; +
	Glyph  54, 72, 4, Glyph_DESCENDER  ; ,
	Glyph  58, 72, 6                   ; -
	Glyph  64, 72, 2                   ; .
	Glyph  66, 72, 6, Glyph_ASCENDER   ; /
	Glyph  72, 72, 6, Glyph_CAPITAL    ; 0
	Glyph  78, 72, 4, Glyph_CAPITAL    ; 1
	Glyph  82, 72, 6, Glyph_CAPITAL    ; 2
	Glyph  88, 72, 6, Glyph_CAPITAL    ; 3
	Glyph  94, 72, 6, Glyph_CAPITAL    ; 4
	Glyph 100, 72, 6, Glyph_CAPITAL    ; 5
	Glyph 106, 72, 6, Glyph_CAPITAL    ; 6
	Glyph 112, 72, 6, Glyph_CAPITAL    ; 7
	Glyph 118, 72, 6, Glyph_CAPITAL    ; 8
	Glyph 124, 72, 6, Glyph_CAPITAL    ; 9
	Glyph 130, 72, 2                   ; :
	Glyph 132, 72, 4, Glyph_DESCENDER  ; ;
	Glyph 136, 72, 4                   ; <
	Glyph 140, 72, 6                   ; =
	Glyph 146, 72, 4                   ; >
	Glyph 150, 72, 6, Glyph_ASCENDER   ; ?
	Glyph 156, 72, 6, Glyph_ASCENDER   ; @
	Glyph   0, 48, 6, Glyph_CAPITAL    ; A
	Glyph   6, 48, 6, Glyph_CAPITAL    ; B
	Glyph  12, 48, 6, Glyph_CAPITAL    ; C
	Glyph  18, 48, 6, Glyph_CAPITAL    ; D
	Glyph  24, 48, 6, Glyph_CAPITAL    ; E
	Glyph  30, 48, 6, Glyph_CAPITAL    ; F
	Glyph  36, 48, 6, Glyph_CAPITAL    ; G
	Glyph  42, 48, 6, Glyph_CAPITAL    ; H
	Glyph  48, 48, 2, Glyph_CAPITAL    ; I
	Glyph  50, 48, 4, Glyph_CAPITAL    ; J
	Glyph  54, 48, 6, Glyph_CAPITAL    ; K
	Glyph  60, 48, 6, Glyph_CAPITAL    ; L
	Glyph  66, 48, 8, Glyph_CAPITAL    ; M
	Glyph  74, 48, 6, Glyph_CAPITAL    ; N
	Glyph  80, 48, 6, Glyph_CAPITAL    ; O
	Glyph  86, 48, 6, Glyph_CAPITAL    ; P
	Glyph  92, 48, 6, Glyph_CAPITAL    ; Q
	Glyph  98, 48, 6, Glyph_CAPITAL    ; R
	Glyph 104, 48, 6, Glyph_CAPITAL    ; S
	Glyph 110, 48, 6, Glyph_CAPITAL    ; T
	Glyph 116, 48, 6, Glyph_CAPITAL    ; U
	Glyph 122, 48, 6, Glyph_CAPITAL    ; V
	Glyph 128, 48, 8, Glyph_CAPITAL    ; W
	Glyph 136, 48, 6, Glyph_CAPITAL    ; X
	Glyph 142, 48, 6, Glyph_CAPITAL    ; Y
	Glyph 148, 48, 6, Glyph_CAPITAL    ; Z
	Glyph 162, 72, 4, Glyph_ASCENDER   ; [
	Glyph 166, 72, 6, Glyph_ASCENDER   ; \
	Glyph 172, 72, 4, Glyph_ASCENDER   ; ]
	Glyph 176, 72, 6, Glyph_ASCENDER   ; ^
	Glyph 182, 72, 6                   ; _
	Glyph 188, 72, 4, Glyph_ASCENDER   ; `
	Glyph   0, 60, 6                   ; a
	Glyph   6, 60, 6, Glyph_ASCENDER   ; b
	Glyph  12, 60, 6                   ; c
	Glyph  18, 60, 6, Glyph_ASCENDER   ; d
	Glyph  24, 60, 6                   ; e
	Glyph  30, 60, 4, Glyph_ASCENDER   ; f
	Glyph  34, 60, 6, Glyph_DESCENDER  ; g
	Glyph  40, 60, 6, Glyph_ASCENDER   ; h
	Glyph  46, 60, 2, Glyph_ASCENDER   ; i
	Glyph  48, 60, 4, Glyph_ASCENDER   ; j
	Glyph  52, 60, 6, Glyph_ASCENDER   ; k
	Glyph  58, 60, 2, Glyph_ASCENDER   ; l
	Glyph  60, 60, 8                   ; m
	Glyph  68, 60, 6                   ; n
	Glyph  74, 60, 6                   ; o
	Glyph  80, 60, 6, Glyph_DESCENDER  ; p
	Glyph  86, 60, 6, Glyph_DESCENDER  ; q
	Glyph  92, 60, 6                   ; r
	Glyph  98, 60, 6                   ; s
	Glyph 104, 60, 4, Glyph_ASCENDER   ; t
	Glyph 108, 60, 6                   ; u
	Glyph 114, 60, 6                   ; v
	Glyph 120, 60, 8                   ; w
	Glyph 128, 60, 6                   ; x
	Glyph 134, 60, 6, Glyph_DESCENDER  ; y
	Glyph 140, 60, 6                   ; z
	Glyph 190, 72, 4                   ; {
	Glyph 194, 72, 2                   ; |
	Glyph 196, 72, 4                   ; }
	Glyph 200, 72, 6                   ; ~
