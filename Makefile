all:
	node tools/pngtosc5.js res/tileset.png > gen/TileSet.asm TileSet
	node tools/tmxtomap.js res/tilemap.tmx > gen/TileMap.asm TileMap
	java -jar tools/glass.jar -I gen src/ROM.asm bin/tiletile.rom bin/tiletile.sym

run: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT -script openmsx.tcl

run2: all
	openmsx -cart bin/tiletile.rom -romtype KonamiSCC -machine Sanyo_PHC-70FD -script openmsx.tcl
