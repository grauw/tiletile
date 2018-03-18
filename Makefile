COPY_TARGET = /Volumes/MSXDOS2

all:
	mkdir -p gen bin
	[ -d node_modules ] || npm install
	node tools/tmxtomap.js res/field/tilemap.tmx > gen/FieldMap.asm FieldMap
	java -jar tools/glass.jar -I gen -I lib/neonlib/src src/ROM.asm bin/tiletile.rom bin/tiletile.sym

copy: all
	cp bin/tiletile.rom $(COPY_TARGET)/
	diskutil umount $(COPY_TARGET)

run: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT -script openmsx.tcl

run2: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Sanyo_PHC-70FD -script openmsx.tcl
