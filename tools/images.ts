import { readFile } from "node:fs/promises";
import PNG from "png-js";
import { Array2D } from "./array2d.ts";

export type PixelsPerUnit = {
	x: number;
	y: number;
};

export class Image {
	public readonly pixels: Array2D<PaletteColor>;
	public readonly palette: Palette;
	public readonly pixelsPerUnit: PixelsPerUnit;
	public name?: string;

	constructor(pixels: Array2D<PaletteColor>, palette: Palette, pixelsPerUnit: PixelsPerUnit) {
		this.pixels = pixels;
		this.palette = palette;
		this.pixelsPerUnit = pixelsPerUnit;
	}

	getPixel(x: number, y: number) {
		return this.pixels.get(x, y);
	}

	getPixelData(screenMode: number) {
		const pixelData = [];
		if (screenMode == 5 || screenMode == 7) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x += 2) {
					const pixel1 = this.pixels.get(x, y);
					const pixel2 = this.pixels.get(x + 1, y);
					pixelData.push((pixel1.index & 15) << 4 | (pixel2.index & 15));
				}
			}
		} else if (screenMode == 6) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x += 4) {
					const pixel1 = this.pixels.get(x, y);
					const pixel2 = this.pixels.get(x + 1, y);
					const pixel3 = this.pixels.get(x + 2, y);
					const pixel4 = this.pixels.get(x + 3, y);
					pixelData.push((pixel1.index & 3) << 6 | (pixel2.index & 3) << 4 | (pixel3.index & 3) << 2 | (pixel4.index & 3));
				}
			}
		} else if (screenMode == 8) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x++) {
					const pixel = this.pixels.get(x, y).project(7).round();
					pixelData.push(pixel.g << 5 | pixel.r << 2 | pixel.b >> 1);
				}
			}
		} else if (screenMode >= 10 && screenMode <= 11) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x++) {
					const pixel = this.pixels.get(x, y);
					pixelData.push((pixel.index & 15) << 4 | 8);
				}
			}
		}
		return pixelData;
	}

	toPixelsPerUnit(pixelsPerUnit: PixelsPerUnit) {
		if (this.pixelsPerUnit.x == pixelsPerUnit.x && this.pixelsPerUnit.y == pixelsPerUnit.y)
			return this;

		const width = Math.floor(this.pixels.width / this.pixelsPerUnit.x) * pixelsPerUnit.x;
		const height = Math.floor(this.pixels.height / this.pixelsPerUnit.y) * pixelsPerUnit.y;
		const pixels: PaletteColor[] = [];
		for (let y = 0; y < height; y++) {
			const srcY = Math.floor(y * this.pixelsPerUnit.y / pixelsPerUnit.y);
			for (let x = 0; x < width; x++) {
				const srcX = Math.floor(x * this.pixelsPerUnit.x / pixelsPerUnit.x);
				pixels.push(this.pixels.get(srcX, srcY));
			}
		}

		const converted = new Image(Array2D.ofArray(pixels, width, height), this.palette, pixelsPerUnit);
		converted.name = this.name;
		return converted;
	}

	toScreenMode(screenMode: number) {
		return this.toPixelsPerUnit({ x: screenMode == 6 || screenMode == 7 ? 2 : 1, y: 1 });
	}

	tile(width: number, height: number) {
		return this.pixels.tile(width, height).map(pixels => new Image(pixels, this.palette, this.pixelsPerUnit)).apply();
	}

	slice(x: number, y: number, width: number, height: number) {
		return new Image(this.pixels.slice(x, y, width, height), this.palette, this.pixelsPerUnit);
	}

	toAsm(screenMode: number) {
		const lines: string[] = [];
		if (this.name) {
			const width = Math.floor(this.pixels.width / this.pixelsPerUnit.x);
			const height = Math.floor(this.pixels.height / this.pixelsPerUnit.y);
			lines.push(`${this.name}_instance: Image ${width}, ${height}, ${this.name}_palette, ${this.name}_pixelData`);
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

export class Palette {
	public readonly colors: PaletteColor[];

	constructor() {
		this.colors = [];
	}

	addColor(color: PaletteColor) {
		this.colors.push(color);
	}

	getColor(index: number) {
		return this.colors[index];
	}

	toAsm() {
		return `Palette ${this.colors.slice(0, 16).map(color => color.toAsm()).join(", ")}`;
	}
}

class Color {
	public readonly r: number;
	public readonly g: number;
	public readonly b: number;
	public readonly w: number;

	constructor(r: number, g: number, b: number, w: number) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.w = w;
	}

	multiply(other: Color) {
		return new Color(this.r * other.r, this.g * other.g, this.b * other.b, this.w * other.w);
	}

	power(exponent: Color) {
		return new Color(this.r ** exponent.r, this.g ** exponent.g, this.b ** exponent.b, this.w ** exponent.w);
	}

	dot(other: Color) {
		return this.r * other.r + this.g * other.g + this.b * other.b + this.w * other.w;
	}

	project(scale: number) {
		return new Color(this.r * scale / this.w, this.g * scale / this.w, this.b * scale / this.w, scale);
	}

	round() {
		return new Color(Math.round(this.r), Math.round(this.g), Math.round(this.b), Math.round(this.w));
	}
}

class ScalarColor extends Color {
	constructor(scalar: number) {
		super(scalar, scalar, scalar, scalar);
	}
}

export class PaletteColor extends Color {
	public readonly index: number;

	constructor(index: number, r: number, g: number, b: number, w: number) {
		super(r, g, b, w);
		this.index = index;
	}

	getWord() {
		const color = this.project(7).round();
		return color.r << 8 | color.g << 4 | color.b;
	}

	toAsm() {
		return `${this.getWord().toString(16).padStart(3, "0")}H`;
	}
}

export class PNGLoader {
	private readonly path: string;
	private readonly gamma: number;
	private readonly pixelsPerUnit: PixelsPerUnit;

	constructor(path: string, gamma: number, pixelsPerUnit: PixelsPerUnit) {
		this.path = path;
		this.gamma = gamma;
		this.pixelsPerUnit = pixelsPerUnit;
	}

	async loadImage() {
		const png = new PNG(await readFile(this.path));

		if (png.colorType != 3)
			throw new Error("Not indexed RGB.");

		const palette = this.toPalette(png.palette);

		const pngPixels = await new Promise<Buffer>(resolve => png.decodePixels(pixels => resolve(pixels)));

		const pixels = [];
		for (const index of pngPixels)
			pixels.push(palette.getColor(index));

		return new Image(Array2D.ofArray(pixels, png.width, png.height), palette, this.pixelsPerUnit);
	}

	toPalette(palette8bit: readonly number[]) {
		const palette = new Palette();
		for (let i = 0; i < palette8bit.length / 3; i++) {
			const color = new Color(palette8bit[i * 3] ?? 0, palette8bit[i * 3 + 1] ?? 0, palette8bit[i * 3 + 2] ?? 0, 255);
			const gammaColor = color.power(new ScalarColor(this.gamma / 2.2));
			palette.addColor(new PaletteColor(i, gammaColor.r, gammaColor.g, gammaColor.b, gammaColor.w));
		}
		return palette;
	}
}
