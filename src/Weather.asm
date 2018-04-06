;
; Weather effects
;
Weather_SUNNY: equ 0
Weather_RAIN: equ 1
Weather_MANASHROUD: equ 2
Weather_LIGHTNING: equ 3

Weather: MACRO
	type:
		db 0
	rain:
		Rain
	manaShroud:
		ManaShroud
	lightning:
		Lightning
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
; ix <- mana shroud
Weather_GetManaShroud:
	ld de,Weather.manaShroud
	add ix,de
	ret

; ix = this
; ix <- lightning
Weather_GetLightning:
	ld de,Weather.lightning
	add ix,de
	ret

; ix = this
; iy = input
Weather_UpdateInput: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,TickRain
	ret
TickRain:
	call Weather_GetRain
	jp Rain_UpdateInput
	ENDP

; ix = this
; iy = engine
Weather_TickPrimary: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,TickRain
	cp Weather_LIGHTNING
	jr z,TickLightning
	ret
TickLightning:
	call Weather_GetLightning
	jp Lightning_TickPrimary
TickRain:
	call Weather_GetRain
	jp Rain_Tick
	ENDP

; ix = this
; iy = engine
Weather_TickSecondary: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,TickRain
	ret
TickRain:
	call Weather_GetRain
	jp Rain_Tick
	ENDP

; a = collision ID
; ix = this
Weather_UpdateTriggers:
	cp 1
	jr z,TriggerSunny
	cp 2
	jr z,TriggerRain
	cp 3
	jr z,TriggerManaShroud
	cp 4
	jr z,TriggerLightning
	ret
TriggerSunny:
	ld (ix + Weather.type),Weather_SUNNY
	ret
TriggerRain:
	ld (ix + Weather.type),Weather_RAIN
	ret
TriggerManaShroud:
	ld (ix + Weather.type),Weather_MANASHROUD
	ret
TriggerLightning:
	ld (ix + Weather.type),Weather_LIGHTNING
	ret

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite attribute table
; b <- sprites remaining
; c <- write port
Weather_DrawSpriteAttributes: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,DrawRain
	ret
DrawRain:
	call Weather_GetRain
	jp Rain_DrawSpriteAttributes
	ENDP

; b = sprites remaining
; c = write port
; ix = this
; iy = sprite color table
; b <- sprites remaining
; c <- write port
Weather_DrawSpriteColors: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,DrawRain
	ret
DrawRain:
	call Weather_GetRain
	jp Rain_DrawSpriteColors
	ENDP

; b = patterns remaining (x4)
; c = write port
; ix = this
; iy = sprite pattern table
; b <- patterns remaining (x4)
; c <- write port
Weather_InitializeSpritePatterns:
	push ix
	call Weather_GetRain
	call Rain_InitializeSpritePatterns
	pop ix
	ret

; de = palette
; ix = this
; de <- palette
Weather_UpdatePalette: PROC
	ld a,(ix + Weather.type)
	cp Weather_RAIN
	jr z,UpdateRain
	cp Weather_MANASHROUD
	jr z,UpdateManaShroud
	cp Weather_LIGHTNING
	jr z,UpdateLightning
	ret
UpdateRain:
	push de
	call Weather_GetRain
	pop de
	jp Rain_UpdatePalette
UpdateManaShroud:
	push de
	call Weather_GetManaShroud
	pop de
	jp ManaShroud_UpdatePalette
UpdateLightning:
	push de
	call Weather_GetLightning
	pop de
	jp Lightning_UpdatePalette
	ENDP
