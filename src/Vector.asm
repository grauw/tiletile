;
;
;
Vector2: MACRO ?x = 0, ?y = 0
	x:
		db ?x
	y:
		db ?y
	ENDM

Vector2W: MACRO ?x = 0, ?y = 0
	x:
		dw ?x
	y:
		dw ?y
	ENDM
