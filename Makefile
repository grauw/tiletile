COPY_TARGET = /Volumes/MSXDOS2

all: node_modules
	mkdir -p gen bin
	node tools/buildres.js res/manifest.json > gen/Resources.asm
	java -Xss160K -jar tools/glass.jar -I gen -I lib/neonlib/src src/ROM.asm bin/tiletile.rom bin/tiletile.sym

node_modules: package.json
	npm install
	touch -m node_modules

copy: all
	cp bin/tiletile.rom $(COPY_TARGET)/
	diskutil umount $(COPY_TARGET)

run: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT -script openmsx.tcl

run2: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Sanyo_PHC-70FD -script openmsx.tcl

run3: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Sony_HB-F1XV -script openmsx.tcl

run4: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Al_Alamiah_AX370 -script openmsx.tcl
