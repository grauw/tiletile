;
; Weather effects
;
Weather_SUNNY: equ 0
Weather_RAIN: equ 1
Weather_MOONLIT: equ 2
Weather_LIGHTNING: equ 3

Weather: MACRO
	type:
		db 0
	rain:
		Rain
	ENDM

; ix = this
Weather_Construct:
	ret

; ix = this
; ix <- rain
Weather_GetRain:
	ld de,Weather.rain
	add ix,de
	ret

; ix = this
Weather_Sunny:
	ld (ix + Weather.type),Weather_SUNNY
	ret

; ix = this
Weather_Rain:
	ld (ix + Weather.type),Weather_RAIN
	ret

; ix = this
Weather_Moonlit:
	ld (ix + Weather.type),Weather_MOONLIT
	ret

; ix = this
Weather_Lightning:
	ld (ix + Weather.type),Weather_LIGHTNING
	ret

; ix = this
Weather_Tick: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,TickRain
TickSunny:
	ret
TickRain:
	call Weather_GetRain
	jp Rain_Tick
	ENDP

; c = write port
; ix = this
; iy = sprite attribute table
Weather_DrawSpriteAttributes: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,DrawRain
DrawSunny:
	ret
DrawRain:
	call Weather_GetRain
	jp Rain_DrawSpriteAttributes
	ENDP

; c = write port
; ix = this
; iy = sprite color table
Weather_DrawSpriteColors: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,DrawRain
DrawSunny:
	ret
DrawRain:
	call Weather_GetRain
	jp Rain_DrawSpriteColors
	ENDP

; ix = this
; iy = sprite pattern table
Weather_InitializeSpritePatterns:
	push ix
	call Weather_GetRain
	call Rain_InitializeSpritePatterns
	pop ix
	ret
