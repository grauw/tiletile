source lib/neonlib/tools/symbols.tcl
source lib/neonlib/tools/profile.tcl

symbols::load bin/tiletile.sym

ext debugdevice
set debugoutput stdout
debug set_watchpoint read_io 0x2E
debug set_watchpoint write_mem 0x0000 {([debug read ioports 0xA8] & 0x0C) == 0x04}
debug set_watchpoint read_mem 0x0000 {([debug read ioports 0xA8] & 0x0C) == 0x04}

proc dihaltcallback {} {
	message "DI; HALT detected, which means a hang. You can just as well reset the machine now..." warning
	debug break
}
set di_halt_callback dihaltcallback

proc cpuspeed {x} {
	variable z80_freq [expr 3579545 * $x]
	variable z80_freq_locked false
	variable cmdtiming broken
	set z80_freq
}

proc my_slot_pc {} {
	address_in_slot [reg pc] 1 0
}

debug set_bp -once [symbol Scene_Run] {[my_slot_pc]} {
	set throttle on

	profile::section_scope_bp frame [symbol Scene_Update] {[my_slot_pc]}
	profile::section_scope_bp input [symbol Scene_UpdateInput] {[my_slot_pc]}
	profile::section_scope_bp tick [symbol Scene_TickPrimary] {[my_slot_pc]}
	profile::section_scope_bp tick [symbol Scene_TickSecondary] {[my_slot_pc]}
	profile::section_scope_bp gamef [symbol Scene_UpdateGameFrame] {[my_slot_pc]}
	profile::section_scope_bp spt [symbol Scene_DrawSpritePatterns] {[my_slot_pc]}
	profile::section_scope_bp sct [symbol Scene_DrawSpriteColors] {[my_slot_pc]}
	profile::section_scope_bp sct [symbol Engine_CopySpriteColorToSecondary] {[my_slot_pc]}
	profile::section_scope_bp sat [symbol Scene_DrawSpriteAttributes] {[my_slot_pc]}
	profile::section_scope_bp pal [symbol Scene_UpdatePalette] {[my_slot_pc]}
	profile::section_scope_bp bmp [symbol Scene_DrawBitmapPrimary] {[my_slot_pc]}
	profile::section_scope_bp bmp [symbol Scene_DrawBitmapSecondary] {[my_slot_pc]}
	# profile::section_scope_bp copy [symbol VDPCommand_ExecuteS2HL] {[my_slot_pc]}
	# profile::section_begin_bp vdprdy [expr [symbol VDPCommand_ExecuteS2HL.WaitReady] - 2] {[my_slot_pc]}
	# profile::section_end_bp vdprdy [expr [symbol VDPCommand_ExecuteS2HL.WaitReady] + 5] {[my_slot_pc]}
	profile::section_scope_bp trig [symbol Scene_UpdateTriggers] {[my_slot_pc]}
	profile::section_scope_bp mus [symbol Scene_UpdateMusic] {[my_slot_pc]}
	profile::section_scope_bp sync [symbol SplitHandler_WaitIY] {[my_slot_pc]}
	profile::section_irq_bp int
	profile::section_vdp_bp vdp

	profile::section_exclude int [profile::section_list {int vdp frame}]
	profile::section_exclude sync frame
}

profile_osd
set maxframeskip 100
set throttle off
