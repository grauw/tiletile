"use strict"
const fs = require('fs');
const PNG = require('png-js');
const { checkTypes } = require('./utils');

class Image {
	constructor(width, height, palette) {
		checkTypes(arguments, "number", "number", Palette);
		this.width = width;
		this.height = height;
		this.palette = palette;
	}

	getPixel() {
		throw new Error("Not implemented.");
	}

	getPixelData(screenMode) {
		if (this.width & 1)
			throw new Error("Image width is not even.");

		const pixelData = [];
		if (screenMode >= 5 && screenMode <= 6) {
			for (let y = 0; y < this.height; y++) {
				for (let x = 0; x < this.width; x += 2) {
					pixelData.push((this.getPixel(x, y).index & 15) << 4 | (this.getPixel(x + 1, y).index & 15));
				}
			}
		} else if (screenMode == 7) {
			for (let y = 0; y < this.height; y++) {
				for (let x = 0; x < this.width; x++) {
					const pixel = this.getPixel(x, y);
					pixelData.push((pixel.index & 15) << 4 | (pixel.index & 15));
				}
			}
		} else if (screenMode == 8) {
			for (let y = 0; y < this.height; y++) {
				for (let x = 0; x < this.width; x++) {
					const pixel = this.getPixel(x, y);
					pixelData.push(pixel.g << 5 | pixel.r << 2 | pixel.b >> 1);
				}
			}
		} else if (screenMode >= 10 && screenMode <= 11) {
			for (let y = 0; y < this.height; y++) {
				for (let x = 0; x < this.width; x++) {
					const pixel = this.getPixel(x, y);
					pixelData.push((pixel.index & 15) << 4 | 8);
				}
			}
		}
		return pixelData;
	}

	toTiles(width, height) {
		checkTypes(arguments, "number", "number");
		const tiles = [];
		for (let y = 0; y < this.height; y += height)
			for (let x = 0; x < this.width; x += width)
				tiles.push(new ImageSlice(this, x, y, width, height));
		return tiles;
	}

	toAsm(screenMode) {
		checkTypes(arguments, "number");
		const lines = [];
		if (this.name) {
			lines.push(`${this.name}_instance: Image ${this.width}, ${this.height}, ${this.name}_palette, ${this.name}_pixelData`);
			lines.push(`${this.name}_palette: ${this.palette.toAsm()}`);
			lines.push("\tSECTION ROM_DATA");
			lines.push(`${this.name}_pixelData:`);
			const pixelData = this.getPixelData(screenMode);
			for (let i = 0; i < pixelData.length; i += 16)
				lines.push(`\tdb ${pixelData.slice(i, i + 16).join(", ")}`);
			lines.push("\tENDS");
		}
		return lines.join("\n");
	}
}

class ImageData extends Image {
	constructor(pixels, width, height, palette) {
		checkTypes(arguments, Array, "number", "number", Palette);
		if (pixels.length != width * height)
			throw new Error("Pixel data incomplete.");
		super(width, height, palette);
		this.pixels = pixels;
		this.name = null;
	}

	getPixel(x, y) {
		checkTypes(arguments, "number", "number");
		if (x < 0 || x >= this.width || y < 0 || y >= this.height)
			throw new Error("Coordinates out of range.");
		return this.pixels[y * this.width + x];
	}
}

class ImageSlice extends Image {
	constructor(image, x, y, width, height) {
		checkTypes(arguments, Image, "number", "number", "number", "number");
		if (x < 0 || (x + width) > image.width || y < 0 || (y + height) > image.height)
			throw new Error("Slice coordinates out of range.");
		super(width, height, image.palette);
		this.image = image;
		this.x = x;
		this.y = y;
	}

	getPixel(x, y) {
		checkTypes(arguments, "number", "number");
		if (x < 0 || x >= this.width || y < 0 || y >= this.height)
			throw new Error("Coordinates out of range.");
		return this.image.getPixel(this.x + x, this.y + y);
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

	toAsm() {
		return `Palette ${this.colors.slice(0, 16).map(color => color.toAsm()).join(", ")}`;
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

	toAsm() {
		return `00${this.getWord().toString(16)}H`.substr(-4);
	}
}

class PNGLoader {
	constructor(path) {
		checkTypes(arguments, "string");
		this.path = path;
	}

	async loadImage() {
		const png = new PNG(await fs.promises.readFile(this.path));

		if (png.colorType != 3)
			throw new Error("Not indexed RGB.");

		const palette = this.toPalette(png.palette);

		const pngPixels = await new Promise(resolve => png.decodePixels(pixels => resolve(pixels)));

		const pixels = [];
		for (const index of pngPixels)
			pixels.push(palette.getColor(index));

		return new ImageData(pixels, png.width, png.height, palette);
	}

	toPalette(palette8bit) {
		checkTypes(arguments, Array);
		const palette = new Palette();
		const palette3bit = palette8bit.map(c => Math.round(c / 255 * 7));
		for (let i = 0; i < palette3bit.length / 3; i++) {
			const r = palette3bit[i * 3] || 0;
			const g = palette3bit[i * 3 + 1] || 0;
			const b = palette3bit[i * 3 + 2] || 0;
			palette.addColor(new PaletteColor(i, r, g, b));
		}
		return palette;
	}
}

exports.Image = Image;
exports.ImageData = ImageData;
exports.ImageSlice = ImageSlice;
exports.Palette = Palette;
exports.PaletteColor = PaletteColor;
exports.PNGLoader = PNGLoader;
