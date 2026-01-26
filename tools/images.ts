import { readFile } from "node:fs/promises";
import PNG from "png-js";
import { Array2D } from "./array2d.ts";

export type PixelsPerUnit = {
	x: number;
	y: number;
};

export class Image {
	public readonly pixels: Array2D<Color>;
	public readonly palette: Palette;
	public readonly pixelsPerUnit: PixelsPerUnit;
	public name?: string;

	constructor(pixels: Array2D<Color>, palette: Palette, pixelsPerUnit: PixelsPerUnit) {
		this.pixels = pixels;
		this.palette = palette;
		this.pixelsPerUnit = pixelsPerUnit;
	}

	getPixel(x: number, y: number) {
		return this.pixels.get(x, y);
	}

	getPixelData(screenMode: number) {
		const pixelData = [];
		const getIndex = (pixel: Color, range: number, fallback = 0) =>
			pixel instanceof PaletteColor && pixel.index >= 0 && pixel.index < range ? pixel.index : fallback;
		if (screenMode == 5 || screenMode == 7) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x += 2) {
					pixelData.push(
						getIndex(this.pixels.get(x, y), 16) << 4 |
						getIndex(this.pixels.get(x + 1, y), 16)
					);
				}
			}
		} else if (screenMode == 6) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x += 4) {
					pixelData.push(
						getIndex(this.pixels.get(x, y), 4) << 6 |
						getIndex(this.pixels.get(x + 1, y), 4) << 4 |
						getIndex(this.pixels.get(x + 2, y), 4) << 2 |
						getIndex(this.pixels.get(x + 3, y), 4)
					);
				}
			}
		} else if (screenMode == 8) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x++) {
					const pixel = this.pixels.get(x, y).project(7).round();
					pixelData.push(
						pixel.g << 5 | pixel.r << 2 | pixel.b >> 1
					);
				}
			}
		} else if (screenMode >= 10 && screenMode <= 11) {
			for (let y = 0; y < this.pixels.height; y++) {
				for (let x = 0; x < this.pixels.width; x++) {
					pixelData.push(
						getIndex(this.pixels.get(x, y), 16) << 4 | 8
					);
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
		const pixels: Color[] = [];
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

export class Color {
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

	static fromColor(index: number, color: Color) {
		return new PaletteColor(index, color.r, color.g, color.b, color.w);
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
		const gamma = new ScalarColor(this.gamma / 2.2);
		const colorLookup = new Map<number, Color>();

		const palette = new Palette();
		for (let i = 0; i < png.palette.length; i += 3) {
			const color = new Color(png.palette[i], png.palette[i + 1], png.palette[i + 2], 255);
			const paletteColor = PaletteColor.fromColor(i / 3, color.power(gamma));
			const key = color.r << 16 | color.g << 8 | color.b;
			if (!colorLookup.has(key)) {
				colorLookup.set(key, paletteColor);
			}
			palette.addColor(paletteColor);
		}

		const pngPixels = await new Promise<Buffer>(resolve => png.decodePixels(pixels => resolve(pixels)));

		const pixels = [];
		if (png.colorType == 3) {
			for (const index of pngPixels) {
				pixels.push(palette.getColor(index));
			}
		} else {
			const bytesPerPixel = png.colors + (png.hasAlphaChannel ? 1 : 0);
			const step = png.colors == 1 ? 0 : 1;
			for (let i = 0; i < pngPixels.length; i += bytesPerPixel) {
				const color = new Color(pngPixels[i], pngPixels[i + step], pngPixels[i + step + step], 255);
				const key = color.r << 16 | color.g << 8 | color.b;
				if (!colorLookup.has(key)) {
					colorLookup.set(key, color.power(gamma));
				}
				pixels.push(colorLookup.get(key)!);
			}
		}

		return new Image(Array2D.ofArray(pixels, png.width, png.height), palette, this.pixelsPerUnit);
	}
}
