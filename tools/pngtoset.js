"use strict"
let PNG = require('png-js');

function main() {
	if (process.argv.length < 4) {
		console.log("Usage: node " + process.argv[1] + " WIDTH256_PNG NAME");
		process.exit(1);
	}

	let filename = process.argv[2];
	let name = process.argv[3];

	new PNGLoader(filename).loadImage(image => {
		let tileSet = new TileSet(name, 16, 16, image);
		console.log(tileSet.toAsm());
	});
}

class TileSet {
	constructor(name, width, height, image) {
		checkTypes(arguments, "string", "number", "number", ImageIndexed);
		this.name = name;
		this.width = width;
		this.height = height;
		this.palette = image.palette;
		this.tiles = image.toTiles(width, height);
	}

	toAsm() {
		var lines = [];
		lines.push("\tSECTION RAM");
		lines.push();
		lines.push(`${this.name}_instance: TileSet ROM_${this.name}_BANK, ${this.name}_palette`);
		lines.push();
		lines.push("\tENDS");
		lines.push();
		lines.push(`\tSECTION ROM_${this.name}`);
		lines.push();
		lines.push(`${this.name}_pixelData:`);
		for (let tile of this.tiles) {
			lines.push("\tdb " + tile.to4Bpp().join(", "));
		}
		lines.push();
		lines.push("\tENDS");
		lines.push();
		lines.push(`${this.name}_palette: Palette ` + this.palette.getWords()
			.slice(0, 16).map(word => `00${word.toString(16)}H`.substr(-4)).join(", "));
		return lines.join("\n");
	}
}

class ImageIndexed {
	constructor(width, height, palette) {
		checkTypes(arguments, "number", "number", Palette);
		this.width = width;
		this.height = height;
		this.palette = palette;
		this.pixels = [];
	}

	addPixel(index) {
		checkTypes(arguments, "number");
		this.pixels.push(this.palette.getColor(index));
	}

	getSlice(x, y, width, height) {
		checkTypes(arguments, "number", "number", "number", "number");
		if (x < 0 || (x + width) > this.width || y < 0 || (y + width) > this.width)
			throw new Error("Slice coordinates out of range.");
		if (this.pixels.length != this.width * this.height)
			throw new Error("Image incomplete.");

		let image = new ImageIndexed(width, height, this.palette);
		for (let cy = y; cy < y + height; cy++)
			for (let cx = x; cx < x + width; cx++)
				image.addPixel(this.pixels[cy * this.width + cx].index);
		return image;
	}

	to4Bpp() {
		let pixels4bpp = new Array(this.pixels.length / 2);
		for (let i = 0; i < this.pixels.length; i += 2) {
			let left = this.pixels[i].index & 15;
			let right = this.pixels[i + 1].index & 15;
			pixels4bpp[i >> 1] = left << 4 | right;
		}
		return pixels4bpp;
	}

	toTiles(width, height) {
		checkTypes(arguments, "number", "number");
		var tiles = [];
		for (let y = 0; y < this.height; y += height)
			for (let x = 0; x < this.width; x += width)
				tiles.push(this.getSlice(x, y, width, height));
		return tiles;
	}
}

class Palette {
	constructor() {
		this.colors = [];
	}

	addColor(color) {
		checkTypes(arguments, PaletteColor);
		this.colors.push(color);
	}

	getColor(index) {
		checkTypes(arguments, "number");
		return this.colors[index];
	}

	getWords() {
		return this.colors.map(color => color.getWord());
	}
}

class PaletteColor {
	constructor(index, r, g, b) {
		checkTypes(arguments, "number", "number", "number", "number");
		this.index = index;
		this.r = r;
		this.g = g;
		this.b = b;
	}

	getWord() {
		return this.g << 8 | this.r << 4 | this.b;
	}
}

class PNGLoader {
	constructor(filename) {
		checkTypes(arguments, "string");
		this.filename = filename;
	}

	loadImage(callback) {
		let png = PNG.load(this.filename);

		if (png.colorType != 3)
			throw new Error("Not indexed RGB.");

		let image = new ImageIndexed(png.width, png.height, this.toPalette(png.palette));

		png.decodePixels(pixels => {
			for (let index of pixels)
				image.addPixel(index);

			callback(image);
		});
	}

	toPalette(palette8bit) {
		let palette = new Palette();
		let palette3bit = palette8bit.map(c => Math.round(c / 255 * 7));
		for (let i = 0; i < palette3bit.length / 3; i++) {
			let r = palette3bit[i * 3] || 0;
			let g = palette3bit[i * 3 + 1] || 0;
			let b = palette3bit[i * 3 + 2] || 0;
			palette.addColor(new PaletteColor(i, r, g, b));
		}
		return palette;
	}
}

/**
 * Type checker, intended for use at the start of any function.
 * Primitive types are checked by a string, objects by their constructor.
 * Use an array to denote optionality. Example:
 * 
 * function myFunction(aNumber, aFunction, anOptionalString) {
 *     checkTypes(arguments, "number", Function, ["string"])
 * }
 * 
 * @param {Array} args An array-like list of arguments.
 * @param {string|Function|Array} types... The types to check against.
 */
function checkTypes(args) {
	for (var i = 1; i < arguments.length; i++) {
		var type = arguments[i], arg = args[i - 1];
		if (!(type instanceof Array && (type = type[0]) && arg == null) &&
				!(typeof type == "string" && typeof arg == type && arg == arg) &&
				!(type instanceof Function && arg instanceof type)) {
			if (typeof type != "string" && !(type instanceof Function))
				throw new Error("Unsupported type " + type + ".");
			throw new Error("Argument of type " + (typeof type != "string" && type.constructor.name || type) + " expected at index " + (i - 1) + ". " +
					"Was: " + (arg && typeof arg != "string" && arg.constructor && arg.constructor.name || arg) + ".");
		}
	}
}

main();
