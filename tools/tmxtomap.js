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
		checkTypes(arguments, "string", "number", "number");
		this.name = name;
		this.width = width;
		this.height = height;
		this.tiles = [];
	}

	addTileInstance(tile) {
		checkTypes(arguments, TileInstance);
		this.tiles.push(tile);
	}

	static fromTmx(name, mapXml) {
		checkTypes(arguments, "string", Object);
		var tileMap = new TileMap(name, ~~mapXml.$.width, ~~mapXml.$.height);
		let indicesCSV = mapXml.layer[0].data[0]._.replace(/\s/g, "");
		let indices = indicesCSV.split(",").map(i => ~~i - 1);
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
		checkTypes(arguments, "number");
		this.index = index;
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
