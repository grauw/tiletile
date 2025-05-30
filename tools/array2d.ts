export class Array2D<T> {
	public readonly width: number;
	public readonly height: number;
	private readonly getter: (x: number, y: number) => T;

	constructor(width: number, height: number, getter: (x: number, y: number) => T) {
		this.width = width;
		this.height = height;
		this.getter = getter;
	}

	get(x: number, y: number) {
		if (x < 0 || x >= this.width || y < 0 || y >= this.height)
			throw new Error("Coordinates out of range.");
		return this.getter(x, y);
	}

	static ofArray<T>(array: readonly T[], width: number, height: number) {
		if (array.length != width * height)
			throw new Error("Array data incomplete.");
		return new Array2D(width, height, (x, y) => array[y * width + x]);
	}

	toArray(): T[] {
		const array: T[] = [];
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

	map<U>(mapFunction: (value: T, x: number, y: number) => U) {
		return new Array2D<U>(this.width, this.height, (x, y) => mapFunction(this.get(x, y), x, y));
	}

	tile(width: number, height: number) {
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

	slice(xOffset: number, yOffset: number, width: number, height: number) {
		if (xOffset < 0 || (xOffset + width) > this.width || yOffset < 0 || (yOffset + height) > this.height)
			throw new Error("Slice coordinates out of range.");
		return new Array2D(width, height, (x, y) => this.get(xOffset + x, yOffset + y));
	}
}
