"use strict"
const fs = require("fs");
const path = require("path");
const xml2js = require("xml2js");
const { checkTypes } = require("./utils");
const { Image, Palette, PNGLoader } = require("./images");
const { Array2D } = require("./array2d");

class TileMap {
	constructor(name, tiles, tileSet) {
		checkTypes(arguments, "string", Array2D, TileSet);
		this.name = name;
		this.tiles = tiles;
		this.tileSet = tileSet;
	}

	optimize() {
		this.tileSet.optimize(this.tiles.toArray());
	}

	toAsm(screenMode) {
		checkTypes(arguments, "number");
		const lines = [];
		lines.push(`${this.name}_instance:`)
		lines.push(`\tTileMap ${this.tiles.width}, ${this.tiles.height}, ${this.tileSet.name}_palette, ${this.name}_data`);
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN ROMMapper_BANK_SIZE");
		lines.push(`${this.name}_data:`);
		for (const tile of this.tiles.toArray()) {
			lines.push(`\tdw ${this.tileSet.name}_${tile.getName()}`);
		}
		lines.push("\tENDS");
		lines.push("");
		lines.push(this.tileSet.toAsm(screenMode));
		return lines.join("\n");
	}
}

class TileSet {
	constructor(name, tiles, palette) {
		checkTypes(arguments, "string", Array, Palette);
		this.name = name;
		this.tiles = tiles;
		this.palette = palette;
	}

	getTileByIndex(index) {
		checkTypes(arguments, "number");
		if (index < 0 || index >= this.tiles.length)
			throw new Error(`Tile not found: ${index}`);
		return this.tiles[index];
	}

	optimize(tiles) {
		checkTypes(arguments, Array);
		const counts = new Array(this.tiles.length).fill(0);
		for (const tile of tiles) {
			counts[tile.index]++;
		}
		const newTiles = [];
		for (let i = 0; i < counts.length; i++) {
			if (counts[i] > 0 || this.tiles[i].name) {
				this.tiles[i].index = newTiles.length;
				newTiles.push(this.tiles[i]);
			}
		}
		this.tiles = newTiles;
	}

	toAsm(screenMode) {
		checkTypes(arguments, "number");
		const lines = [];
		lines.push(`${this.name}_tiles:`);
		for (const tile of this.tiles) {
			lines.push(`${this.name}_${tile.getName()}: Tile ${this.name}_pixelData_${tile.getName()}, ${tile.collision}`);
		}
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN 100H");
		for (const tile of this.tiles) {
			lines.push(`${this.name}_pixelData_${tile.getName()}:`);
			lines.push(tile.toAsm(screenMode));
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

	toAsm(screenMode) {
		checkTypes(arguments, "number");
		return `\tdb ${this.image.getPixelData(screenMode).join(", ")}`;
	}
}

class Tmx {
	constructor(name, path) {
		checkTypes(arguments, "string", "string");
		this.name = name;
		this.path = path;
	}

	async parse(gamma) {
		checkTypes(arguments, "number");
		const xml = await xml2js.parseStringPromise(await fs.promises.readFile(this.path));
		return this.parseMap(xml.map, gamma);
	}

	async parseMap(mapXml, gamma) {
		checkTypes(arguments, Object, "number");
		const tileSet = await this.parseSet(mapXml.tileset[0], gamma);
		const indices = mapXml.layer[0].data[0]._.replace(/\s/g, "").split(",").map(i => ~~i - 1);
		const indexMap = Array2D.ofArray(indices, ~~mapXml.$.width, ~~mapXml.$.height);
		return new TileMap(this.name, indexMap.map(index => tileSet.getTileByIndex(index)).apply(), tileSet);
	}

	async parseSet(setXml, gamma) {
		checkTypes(arguments, Object, "number");
		const imagepath = path.resolve(path.dirname(this.path), setXml.image[0].$.source);
		const image = await new PNGLoader(imagepath, gamma).loadImage();
		const tileImages = image.tile(~~setXml.$.tilewidth, ~~setXml.$.tileheight);
		const tiles = tileImages.toArray().map((image, index) =>
			this.parseTile((setXml.tile || []).find(t => t.$.id == index) || { $: { id: index } }, image));
		return new TileSet(setXml.$.name, tiles, image.palette);
	}

	parseTile(tileXml, image) {
		checkTypes(arguments, Object, Image);
		const name = this.parseProperty(tileXml, "name", null);
		const collision = ~~this.parseProperty(tileXml, "collision", 0);
		return new Tile(~~tileXml.$.id, name, image, collision);
	}

	parseProperty(xml, name, default_) {
		checkTypes(arguments, Object, "string");
		const properties = (xml.properties || [])[0] || {};
		const property = (properties.property || []).find(p => p.$.name == name);
		return property !== undefined ? property.$.value : default_;
	}
}

module.exports = { TileMap, TileSet, Tile, Tmx };
