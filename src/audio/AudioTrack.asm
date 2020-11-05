;
; Audio track
;
AudioTrack: MACRO ?commands
	commands:
		ROMAddress ?commands, 8000H
	ENDM

AudioCommand: MACRO ?command
	command:
		db ?command
	ENDM

AudioCommandPSG: MACRO ?address, ?value
	command:
		AudioCommand ?address
	value:
		db ?value
	ENDM

AudioCommandOPLL: MACRO ?address, ?value
	command:
		AudioCommand 40H + ?address
	value:
		db ?value
	ENDM

AudioCommandWait: MACRO ?time
	command:
		AudioCommand 80H + ?time
	ENDM

AudioCommandJump: MACRO ?address
	command:
		AudioCommand 80H
	address:
		dw ?address & 1FFFH | 8000H
	ENDM
