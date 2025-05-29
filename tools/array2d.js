import { checkTypes } from "./utils.js";

export class Array2D {
	constructor(width, height, getter) {
		checkTypes(arguments, "number", "number", Function);
		this.width = width;
		this.height = height;
		this.getter = getter;
	}

	get(x, y) {
		checkTypes(arguments, "number", "number");
		if (x < 0 || x >= this.width || y < 0 || y >= this.height)
			throw new Error("Coordinates out of range.");
		return this.getter(x, y);
	}

	static ofArray(array, width, height) {
		checkTypes(arguments, Array, "number", "number");
		if (array.length != width * height)
			throw new Error("Array data incomplete.");
		return new Array2D(width, height, (x, y) => array[y * width + x]);
	}

	toArray() {
		const array = [];
		for (let y = 0; y < this.height; y++) {
			for (let x = 0; x < this.width; x++) {
				array.push(this.get(x, y));
			}
		}
		return array;
	}

	apply() {
		return Array2D.ofArray(this.toArray(), this.width, this.height);
	}

	map(mapFunction) {
		checkTypes(arguments, Function);
		return new Array2D(this.width, this.height, (x, y) => mapFunction(this.get(x, y), x, y));
	}

	tile(width, height) {
		checkTypes(arguments, "number", "number");
		if (this.width % width != 0 || this.height % height != 0)
			throw new Error("Not an integer multiple of tile dimensions.");
		const tiles = [];
		for (let y = 0; y < this.height; y += height) {
			for (let x = 0; x < this.width; x += width) {
				tiles.push(this.slice(x, y, width, height));
			}
		}
		return Array2D.ofArray(tiles, Math.floor(this.width / width), Math.floor(this.height / height));
	}

	slice(xOffset, yOffset, width, height) {
		checkTypes(arguments, "number", "number", "number", "number");
		if (xOffset < 0 || (xOffset + width) > this.width || yOffset < 0 || (yOffset + height) > this.height)
			throw new Error("Slice coordinates out of range.");
		return new Array2D(width, height, (x, y) => this.get(xOffset + x, yOffset + y));
	}
}
