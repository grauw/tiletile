"use strict"
let fs = require('fs');
let xml2js = require('xml2js');

function main() {
	if (process.argv.length < 4) {
		console.log("Usage: node " + process.argv[1] + " TILEMAP.TMX NAME");
		process.exit(1);
	}

	let filename = process.argv[2];
	let name = process.argv[3];

	fs.readFile(filename, function(err, data) {
		xml2js.parseString(data, function (err, result) {
			var tileMap = TileMap.fromTmx(name, result.map);

			console.log(tileMap.toAsm());
		});
	});
}

class TileMap {
	constructor(name, width, height) {
		this.name = name;
		this.width = width;
		this.height = height;
		this.tiles = [];
	}

	addTileInstance(tile) {
		this.tiles.push(tile);
	}

	static fromTmx(name, mapXml) {
		var tileMap = new TileMap(name, mapXml.$.width, mapXml.$.height);
		let indicesCSV = mapXml.layer[0].data[0]._.replace(/\s/g, "");
		let indices = indicesCSV.split(",").map(Number).map(i => i == 0 ? 255 : i - 1);
		for (let index of indices) {
			tileMap.addTileInstance(new TileInstance(index));
		}
		return tileMap;
	}
	
	toAsm() {
		var lines = [];
		lines.push(`${this.name}_instance:`)
		lines.push(`\tTileMap ${this.width}, ${this.height}, ${this.name}_data, ${this.name}_dataRows`);
		lines.push("");
		lines.push(`${this.name}_data:`);
		for (let i = 0; i < this.tiles.length; i += 16) {
			lines.push("\tdb " + this.tiles.slice(i, i + 16).map(ti => ti.index).join(", "));
		}
		lines.push("");
		lines.push(`${this.name}_dataRows:`);
		for (let y = 0; y < this.height; y++) {
			lines.push(`\tdw ${this.name}_data + ${y * this.width}`);
		}
		return lines.join("\n");
	}
}

class TileInstance {
	constructor(index) {
		this.index = index;
	}
}

main();
