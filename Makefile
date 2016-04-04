all:
	node tools/pngtosc5.js res/field/tileset.png > gen/FieldSet.asm FieldSet
	node tools/tmxtomap.js res/field/tilemap.tmx > gen/FieldMap.asm FieldMap
	java -jar tools/glass.jar -I gen src/ROM.asm bin/tiletile.rom bin/tiletile.sym

run: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT -script openmsx.tcl

run2: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Sanyo_PHC-70FD -script openmsx.tcl
