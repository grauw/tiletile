"use strict"
let fs = require('fs');
let path = require('path');
let xml2js = require('xml2js');
let PNG = require('png-js');

function main() {
	if (process.argv.length < 3) {
		console.log("Usage: node " + process.argv[1] + " manifest.json");
		process.exit(1);
	}

	let path = process.argv[2];

	new ManifestLoader(path).parse(manifest => {
		manifest.optimize();
		console.log(manifest.toAsm());
	});
}

class Manifest {
	constructor(tileMaps, images) {
		checkTypes(arguments, Array, Array);
		this.tileMaps = tileMaps;
		this.images = images;
	}

	optimize() {
		for (let tileMap of this.tileMaps) {
			tileMap.optimize();
		}
	}

	toAsm() {
		var lines = [];
		for (let tileMap of this.tileMaps) {
			lines.push(tileMap.toAsm());
		}
		for (let image of this.images) {
			lines.push(image.toAsm());
		}
		return lines.join("\n\n");
	}
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

	addTileByIndex(index) {
		checkTypes(arguments, "number");
		this.tiles.push(this.tileSet.getTileByIndex(index));
	}

	optimize() {
		this.tileSet.optimize(this.tiles);
	}

	toAsm() {
		var lines = [];
		lines.push(`${this.name}_instance:`)
		lines.push(`\tTileMap ${this.width}, ${this.height}, ${this.tileSet.name}_palette, ${this.name}_data`);
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN ROMMapper_BANK_SIZE");
		lines.push(`${this.name}_data:`);
		for (let tile of this.tiles) {
			lines.push(`\tdw ${this.tileSet.name}_${tile.getName()}`);
		}
		lines.push("\tENDS");
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

	getTileByIndex(index) {
		checkTypes(arguments, "number");
		if (index < 0 || index >= this.tiles.length)
			throw new Error(`Tile not found: ${index}`);
		return this.tiles[index];
	}

	optimize(tiles) {
		checkTypes(arguments, Array);
		let counts = new Array(this.tiles.length).fill(0);
		for (let tile of tiles) {
			counts[tile.index]++;
		}
		let newIndex = 0;
		let newTiles = [];
		for (let i = 0; i < counts.length; i++) {
			if (counts[i] > 0 || this.tiles[i].name) {
				this.tiles[i].index = newTiles.length;
				newTiles.push(this.tiles[i]);
			}
		}
		this.tiles = newTiles;
	}

	toAsm() {
		var lines = [];
		lines.push(`${this.name}_tiles:`);
		for (let tile of this.tiles) {
			lines.push(`${this.name}_${tile.getName()}: Tile ${this.name}_pixelData_${tile.getName()}, ${tile.collision}`);
		}
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN 100H");
		for (let tile of this.tiles) {
			lines.push(`${this.name}_pixelData_${tile.getName()}:`);
			lines.push(tile.toAsm());
		}
		lines.push("\tENDS");
		lines.push("");
		lines.push(`${this.name}_palette: ${this.palette.toAsm()}`);
		return lines.join("\n");
	}
}

class Tile {
	constructor(index, name, image, collision) {
		checkTypes(arguments, "number", ["string"], Image, "number");
		this.index = index;
		this.name = name;
		this.image = image;
		this.collision = collision;
	}

	getName() {
		return this.name || this.index.toString();
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
		this.name = null;
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

	toAsm() {
		let lines = [];
		if (this.name) {
			lines.push(`${this.name}_instance: Image ${this.width}, ${this.height}, ${this.name}_palette, ${this.name}_pixelData`);
			lines.push(`${this.name}_palette: ${this.palette.toAsm()}`);
			lines.push("\tSECTION ROM_DATA");
			lines.push(`${this.name}_pixelData:`);
			let pixelData = this.to4Bpp();
			for (let i = 0; i < pixelData.length; i += 16)
				lines.push("\tdb " + pixelData.slice(i, i + 16).join(", "));
			lines.push("\tENDS");
		}
		return lines.join("\n");
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

	toAsm() {
		return "Palette " + this.getWords().slice(0, 16).map(word => `00${word.toString(16)}H`.substr(-4)).join(", ");
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
		return this.r << 8 | this.g << 4 | this.b;
	}
}

class ManifestLoader {
	constructor(path) {
		checkTypes(arguments, "string");
		this.path = path;
	}

	parse(callback) {
		checkTypes(arguments, Function);
		fs.readFile(this.path, (err, data) => {
			let json = JSON.parse(data.toString());
			this.parseTileMaps(json.tilemaps, tileMaps => {
				this.parseImages(json.images, images => {
					callback(new Manifest(tileMaps, images));
				});
			});
		});
	}

	parseTileMaps(jsonTileMaps, callback) {
		checkTypes(arguments, Array, Function);
		let tileMaps = [];
		let parseMap = index => {
			if (index < jsonTileMaps.length) {
				let jsonTileMap = jsonTileMaps[index];
				let tileMapPath = path.resolve(path.dirname(this.path), jsonTileMap.path);
				new Tmx(jsonTileMap.name, tileMapPath).parse(tileMap => {
					tileMaps.push(tileMap);
					parseMap(index + 1);
				});
			} else {
				callback(tileMaps);
			}
		};
		parseMap(0);
	}

	parseImages(jsonImages, callback) {
		checkTypes(arguments, Array, Function);
		let images = [];
		let parseImage = index => {
			if (index < jsonImages.length) {
				let jsonImage = jsonImages[index];
				let imagePath = path.resolve(path.dirname(this.path), jsonImage.path);
				new PNGLoader(imagePath).loadImage(image => {
					image.name = jsonImage.name;
					images.push(image);
					parseImage(index + 1);
				});
			} else {
				callback(images);
			}
		};
		parseImage(0);
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
			let indices = mapXml.layer[0].data[0]._.replace(/\s/g, "").split(",").map(i => ~~i - 1);
			for (let index of indices) {
				tileMap.addTileByIndex(index);
			}
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
				let tileXml = (setXml.tile || []).find(t => t.$.id == i) || { $: { id: i } };
				tileSet.addTile(this.parseTile(tileXml, tileImages[i]));
			}
			callback(tileSet);
		});
	}

	parseTile(tileXml, image) {
		checkTypes(arguments, Object, Image);
		let name = this.parseProperty(tileXml, "name", null);
		let collision = ~~this.parseProperty(tileXml, "collision", 0);
		return new Tile(~~tileXml.$.id, name, image, collision);
	}

	parseProperty(xml, name, default_) {
		checkTypes(arguments, Object, "string");
		let properties = (xml.properties || [])[0] || {};
		let property = (properties.property || []).find(p => p.$.name == name);
		return property !== undefined ? property.$.value : default_;
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
