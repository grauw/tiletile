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

if (png.palette.length > 16 * 3) {
	console.error("More than 16 colours.");
	process.exit(1);
}

png.decodePixels(function(pixels) {
	console.log(prefix + "_pixelData:");

	let pixels4bpp = to4bpp(pixels);
	for (let tile = 0; tile < 256; tile++) {
		console.log("\t; " + tile);

		let x = (tile & 15) << 4;
		let y = (tile >> 4) << 4;
		for (let line = 0; line < 16; line++) {
			let address = ((y + line << 8) + x) >> 1;
			console.log("\tdb " + pixels4bpp.slice(address, address + 8).join(", "));
		}
	}

	console.log();
	console.log(prefix + "_palette:");

	let palette = quantisePalette(png.palette);
	for (let i = 0; i < 16; i++) {
		let r = palette[i * 3] || 0;
		let g = palette[i * 3 + 1] || 0;
		let b = palette[i * 3 + 2] || 0;
		console.log("\tdb " + (r << 4 | b) + ", " + g);
	}
});

function to4bpp(pixels) {
	return new Array(pixels.length / 2).fill(0).map(
		(v, i) => pixels[i * 2] << 4 | pixels[i * 2 + 1]
	);
}

function quantisePalette(palette) {
	return palette.map(c => Math.round(c / 255 * 7));
}
