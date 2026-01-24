import fs from "fs";
import path from "path";
import xml2js from "xml2js";
import { Image, Palette, PNGLoader } from "./images.ts";
import { Array2D } from "./array2d.ts";

const chunkSize = 16;

export class TileMap {
	private readonly name: string;
	private readonly tiles: Array2D<Tile>;
	private readonly tileSet: TileSet;

	constructor(name: string, tiles: Array2D<Tile>, tileSet: TileSet) {
		if ((tiles.width % chunkSize) || (tiles.height % chunkSize))
			throw new Error(`Tile map ${name} size not a multiple of 16x16.`);
		this.name = name;
		this.tiles = tiles;
		this.tileSet = tileSet;
	}

	optimize() {
		this.tileSet.optimize(this.tiles.toArray());
	}

	toAsm(screenMode: number) {
		const lines = [];
		lines.push(`${this.name}_instance:`);
		lines.push(`\tTileMap ${this.tiles.width}, ${this.tiles.height}, ${this.tileSet.name}_palette, ${this.name}_tiles, ${this.name}_collisions`);
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN ROMMapper_BANK_SIZE");
		lines.push(`${this.name}_tiles:`);
		for (const tile of this.tiles.toArray()) {
			lines.push(`\tTile ${this.tileSet.name}_${tile.getName()}_pixels`);
		}
		lines.push("");
		lines.push("\tALIGN ROMMapper_BANK_SIZE");
		lines.push(`${this.name}_collisions:`);
		for (const tile of this.tiles.toArray()) {
			lines.push(`\tdb ${tile.collision}`);
		}
		lines.push("\tENDS");
		lines.push("");
		lines.push(this.tileSet.toAsm(screenMode));
		return lines.join("\n");
	}
}

export class TileSet {
	public readonly name: string;
	private tiles: readonly Tile[];
	private readonly palette: Palette;

	constructor(name: string, tiles: readonly Tile[], palette: Palette) {
		this.name = name;
		this.tiles = tiles;
		this.palette = palette;
	}

	getTileByIndex(index: number) {
		if (index < 0 || index >= this.tiles.length)
			throw new Error(`Tile not found: ${index}`);
		return this.tiles[index];
	}

	optimize(tiles: Tile[]) {
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

	toAsm(screenMode: number) {
		const lines = [];
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN 100H");
		for (const tile of this.tiles) {
			lines.push(`${this.name}_${tile.getName()}_pixels:`);
			lines.push(tile.toAsm(screenMode));
		}
		lines.push("\tENDS");
		lines.push("");
		lines.push(`${this.name}_palette: ${this.palette.toAsm()}`);
		return lines.join("\n");
	}
}

export class Tile {
	public index: number;
	public readonly name?: string;
	private readonly image: Image;
	public readonly collision: number;

	constructor(index: number, name: string | undefined, image: Image, collision: number) {
		this.index = index;
		this.name = name;
		this.image = image;
		this.collision = collision;
	}

	getName() {
		return this.name || this.index.toString();
	}

	toAsm(screenMode: number) {
		return `\tdb ${this.image.getPixelData(screenMode).join(", ")}`;
	}
}

export class Tmx {
	private readonly name: string;
	private readonly path: string;

	constructor(name: string, path: string) {
		this.name = name;
		this.path = path;
	}

	async parse(gamma: number) {
		const xml: TmxXML = await xml2js.parseStringPromise(await fs.promises.readFile(this.path));
		return this.parseMap(xml.map, gamma);
	}

	async parseMap(mapXml: TmxMapXML, gamma: number) {
		const tileSet = await this.parseSet(mapXml.tileset[0], gamma);
		const indices = mapXml.layer[0].data[0]._.replace(/\s/g, "").split(",").map(i => ~~i - 1);
		const indexMap = Array2D.ofArray(indices, ~~mapXml.$.width, ~~mapXml.$.height);
		return new TileMap(this.name, indexMap.map(index => tileSet.getTileByIndex(index)).apply(), tileSet);
	}

	async parseSet(setXml: TmxTilesetXML, gamma: number) {
		const imagepath = path.resolve(path.dirname(this.path), setXml.image[0].$.source);
		const image = await new PNGLoader(imagepath, gamma).loadImage();
		const tileImages = image.tile(~~setXml.$.tilewidth, ~~setXml.$.tileheight);
		const tiles = tileImages.toArray().map((image, index) =>
			this.parseTile((setXml.tile || []).find(t => t.$.id == index) || { $: { id: index } }, image));
		return new TileSet(setXml.$.name, tiles, image.palette);
	}

	parseTile(tileXml: TmxTileXML, image: Image) {
		const name = this.parseProperty(tileXml, "name", undefined);
		const collision = ~~this.parseProperty(tileXml, "collision", 0);
		return new Tile(~~tileXml.$.id, name, image, collision);
	}

	parseProperty<T>(xml: TmxTileXML, name: string, default_: T) {
		const properties = (xml.properties || [])[0] || {};
		const property = (properties.property || []).find(p => p.$.name == name);
		return property !== undefined ? property.$.value : default_;
	}
}

type TmxXML = {
	map: TmxMapXML;
};

type TmxMapXML = {
	$: { width: string; height: string; };
	layer: [ TmxLayerXML ];
	tileset: [ TmxTilesetXML ];
};

type TmxLayerXML = {
	data: [ { _: string; } ];
};

type TmxTilesetXML = {
	$: { name: string; tilewidth: string; tileheight: string; };
	image: [ { $: { source: string; }; } ];
	tile: TmxTileXML[];
};

type TmxTileXML = {
	$: { id: number | string; };
	properties?: [ TmxTilePropertiesXML ]
};

type TmxTilePropertiesXML = {
	property?: TmxTilePropertyXML[];
};

type TmxTilePropertyXML = {
	$: { name: string; value: string; };
};
