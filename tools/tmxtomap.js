"use strict"
let fs = require('fs');
let path = require('path');
let xml2js = require('xml2js');
let PNG = require('png-js');

function main() {
	if (process.argv.length < 4) {
		console.log("Usage: node " + process.argv[1] + " TILEMAP.TMX NAME");
		process.exit(1);
	}

	let path = process.argv[2];
	let name = process.argv[3];

	new Tmx(name, path).parse((tileMap) => {
		console.log(tileMap.toAsm());
	});
}

class TileMap {
	constructor(name, width, height, tileSet) {
		checkTypes(arguments, "string", "number", "number", TileSet);
		this.name = name;
		this.width = width;
		this.height = height;
		this.tileSet = tileSet;
		this.tiles = [];
	}

	addTileIndices(tileIndices) {
		checkTypes(arguments, Array);
		for (let index of tileIndices) {
			this.tiles.push(this.tileSet.getTile(index));
		}
	}

	toAsm() {
		var lines = [];
		lines.push(`${this.name}_instance:`)
		lines.push(`\tTileMap ${this.width}, ${this.height}, ${this.name}_data, ${this.name}_dataRows`);
		lines.push("");
		lines.push(`\tSECTION ROM_${this.name}`);
		lines.push(`${this.name}_data:`);
		for (let tile of this.tiles) {
			lines.push(`\tdw ${this.tileSet.name}_tile${tile.index}`);
		}
		lines.push("\tENDS");
		lines.push("");
		lines.push(`${this.name}_dataRows:`);
		for (let y = 0; y < this.height; y++) {
			lines.push(`\tdw ${this.name}_data + ${y * this.width << 1}`);
		}
		lines.push("");
		lines.push(this.tileSet.toAsm());
		return lines.join("\n");
	}
}

class TileSet {
	constructor(name, width, height, palette) {
		checkTypes(arguments, "string", "number", "number", Palette);
		this.name = name;
		this.width = width;
		this.height = height;
		this.palette = palette;
		this.tiles = [];
	}

	addTile(tile) {
		checkTypes(arguments, Tile);
		this.tiles.push(tile);
	}

	getTile(index) {
		checkTypes(arguments, "number");
		if (index < 0 || index >= this.tiles.length)
			throw new Error(`Tile not found: ${index}`);
		return this.tiles[index];
	}

	toAsm() {
		var lines = [];
		lines.push(`${this.name}_instance: TileSet ${this.name}_tiles, ${this.tiles.length}, ROM_${this.name}_BANK, ${this.name}_palette`);
		lines.push("");
		lines.push(`${this.name}_tiles:`);
		for (let tile of this.tiles)
			lines.push(`${this.name}_tile${tile.index}: Tile ${tile.index}, ROM_${this.name}_BANK`);
		lines.push("");
		lines.push(`\tSECTION ROM_${this.name}`);
		lines.push(`${this.name}_pixelData:`);
		lines.push(...this.tiles.map(tile => tile.toAsm()));
		lines.push("\tENDS");
		lines.push("");
		lines.push(`${this.name}_palette: Palette ` + this.palette.getWords()
			.slice(0, 16).map(word => `00${word.toString(16)}H`.substr(-4)).join(", "));
		return lines.join("\n");
	}
}

class Tile {
	constructor(index, image) {
		checkTypes(arguments, "number", Image);
		this.index = index;
		this.image = image;
	}

	toAsm() {
		return "\tdb " + this.image.to4Bpp().join(", ");
	}
}

class Image {
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

		let image = new Image(width, height, this.palette);
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

class Tmx {
	constructor(name, path) {
		checkTypes(arguments, "string", "string");
		this.name = name;
		this.path = path;
	}

	parse(callback) {
		checkTypes(arguments, Function);
		fs.readFile(this.path, (err, data) => {
			let xmlString = data.toString();
			new xml2js.Parser().parseString(xmlString, (err, result) => {
				this.parseMap(result.map, callback);
			});
		});
	}

	parseMap(mapXml, callback) {
		checkTypes(arguments, Object, Function);
		this.parseSet(mapXml.tileset[0], tileSet => {
			var tileMap = new TileMap(this.name, ~~mapXml.$.width, ~~mapXml.$.height, tileSet);
			let indicesCSV = mapXml.layer[0].data[0]._.replace(/\s/g, "");
			let indices = indicesCSV.split(",").map(i => ~~i - 1);
			tileMap.addTileIndices(indices);
			callback(tileMap);
		});
	}

	parseSet(setXml, callback) {
		checkTypes(arguments, Object, Function);
		let imagepath = path.resolve(path.dirname(this.path), setXml.image[0].$.source);
		new PNGLoader(imagepath).loadImage(image => {
			let tileSet = new TileSet(setXml.$.name, ~~setXml.$.tilewidth, ~~setXml.$.tileheight, image.palette);
			let tileImages = image.toTiles(tileSet.width, tileSet.height);
			for (let i = 0; i < tileImages.length; i++) {
				tileSet.addTile(new Tile(i, tileImages[i]));
			}
			callback(tileSet);
		});
	}
}

class PNGLoader {
	constructor(path) {
		checkTypes(arguments, "string");
		this.path = path;
	}

	loadImage(callback) {
		checkTypes(arguments, Function);
		let png = PNG.load(this.path);

		if (png.colorType != 3)
			throw new Error("Not indexed RGB.");

		let image = new Image(png.width, png.height, this.toPalette(png.palette));

		png.decodePixels(pixels => {
			for (let index of pixels)
				image.addPixel(index);

			callback(image);
		});
	}

	toPalette(palette8bit) {
		checkTypes(arguments, Array);
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
