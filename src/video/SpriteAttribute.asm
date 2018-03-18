;
; Sprite attribute
;
SpriteAttribute: MACRO ?x = 0, ?y = 0, ?pattern = 0, ?color = 0
	y:
		db ?y
	x:
		db ?x
	pattern:
		db ?pattern
	color:
		db ?color
	_size:
	ENDM
