"use strict"
let PNG = require('png-js');

if (process.argv.length < 4) {
	console.log("Usage: node " + process.argv[1] + " WIDTH256_PNG PREFIX");
	process.exit(1);
}

let filename = process.argv[2];
let prefix = process.argv[3];
let palette = [];

let png = PNG.load(filename);

if (png.width != 256 || png.height != 256) {
	console.error("Image size is not 256x256.");
	process.exit(1);
}

if (png.colorType != 3) {
	console.error("Not indexed RGB.");
	process.exit(1);
}

//if (png.palette.length > 16 * 3) {
//	console.error("More than 16 colours.");
//	process.exit(1);
//}

png.decodePixels(function(pixels) {
	console.log("\tSECTION RAM");
	console.log();
	console.log(prefix + "_instance: TileSet ROM_" + prefix + "_BANK, " + prefix + "_palette");
	console.log();
	console.log("\tENDS");
	console.log();
	console.log("\tSECTION ROM_" + prefix);
	console.log();
	console.log(prefix + "_pixelData:");

	let tiles = toTiles(pixels);
	for (let tile of tiles) {
		console.log("\tdb " + tile.join(", "));
	}

	console.log();
	console.log("\tENDS");

	let paletteWords = toPaletteWords(png.palette);

	console.log();
	console.log(prefix + "_palette: Palette " + paletteWords.join(", "));
});

function toTiles(pixels) {
	let pixels4bpp = to4bpp(pixels);
	var tiles = [];
	for (let i = 0; i < 256; i++) {
		let x = (i & 15) << 4;
		let y = (i >> 4) << 4;
		let tile = tiles[i] = [];
		for (let line = 0; line < 16; line++) {
			let address = ((y + line << 8) + x) >> 1;
			tile.push.apply(tile, pixels4bpp.slice(address, address + 8));
		}
	}
	return tiles;
}

function to4bpp(pixels) {
	return new Array(pixels.length / 2).fill(0).map(
		(v, i) => (pixels[i * 2] & 15) << 4 | (pixels[i * 2 + 1] & 15)
	);
}

function toPaletteWords(palette) {
	let paletteWords = [];
	let palette3bit = quantisePalette(palette);
	for (let i = 0; i < 16; i++) {
		let r = palette3bit[i * 3] || 0;
		let g = palette3bit[i * 3 + 1] || 0;
		let b = palette3bit[i * 3 + 2] || 0;
		paletteWords.push(("00" + (g << 8 | r << 4 | b).toString(16)).substr(-3) + "H");
	}
	return paletteWords;
}

function quantisePalette(palette) {
	return palette.map(c => Math.round(c / 255 * 7));
}
