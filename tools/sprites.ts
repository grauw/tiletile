import fs from "fs";
import path from "path";
import { Image, PNGLoader } from "./images.ts";

export class Sprite {
	private readonly name: string;
	public readonly sheet: Image;
	private readonly frames: SpriteFrame[];

	constructor(name: string, sheet: Image) {
		this.name = name;
		this.sheet = sheet;
		this.frames = [];
	}

	addFrame(frame: SpriteFrame) {
		this.frames.push(frame);
	}

	toAsm(frameRate: number) {
		const lines = [];
		lines.push(`${this.name}_frames:`);
		for (const frame of this.frames) {
			lines.push(frame.toAsm(frameRate));
		}
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN 80H");
		for (const frame of this.frames) {
			lines.push(frame.toAsmData());
		}
		lines.push("\tENDS");
		return lines.join("\n");
	}
}

class SpriteFrame {
	private readonly name: string;
	private readonly image: Image;
	private readonly duration: number;
	private readonly patterns: SpritePattern[];

	constructor(name: string, image: Image, duration: number) {
		this.name = name;
		this.image = image;
		this.duration = duration;
		this.patterns = [];

		for (const tile of image.tile(16, 16).toArray()) {
			this.patterns.push(new SpritePattern(tile, 1));
			this.patterns.push(new SpritePattern(tile, 2));
			this.patterns.push(new SpritePattern(tile, 4));
			this.patterns.push(new SpritePattern(tile, 8));
		}
	}

	toAsm(frameRate: number) {
		const duration = Math.round(this.duration * frameRate);
		return `${this.name}: SpriteFrame ${duration}, ${this.patterns.length}, ${this.name}_patterns`;
	}

	toAsmData() {
		const lines = [];
		lines.push(`${this.name}_patterns:`);
		for (const pattern of this.patterns) {
			lines.push(pattern.toAsm());
		}
		return lines.join("\n");
	}
}

class SpritePattern {
	private readonly data: number[];

	constructor(image: Image, mask: number) {
		this.data = [];

		const images = image.tile(8, 8);
		for (const image of [images.get(0, 0), images.get(0, 1), images.get(1, 0), images.get(1, 1)]) {
			for (let y = 0; y < 8; y++) {
				let byte = 0;
				for (let x = 0; x < 8; x++) {
					if (image.getPixel(x, y).index & mask)
						byte |= 128 >> x;
				}
				this.data.push(byte);
			}
		}
	}

	toAsm() {
		return `\tSpritePattern ${this.data.join(", ")}`;
	}
}

export class AsepriteSheet {
	private readonly name: string;
	private readonly path: string;

	constructor(name: string, path: string) {
		this.name = name;
		this.path = path;
	}

	async parse(gamma: number) {
		const json: AsepriteSheetJSON = JSON.parse(await fs.promises.readFile(this.path, { encoding: "utf8" }));
		const sprite = await this.parseSprite(json.meta, gamma);
		this.parseFrames(json.frames, sprite);
		return sprite;
	}

	async parseSprite(jsonMeta: AsepriteSheetMetaJSON, gamma: number) {
		const imagepath = path.resolve(path.dirname(this.path), jsonMeta.image);
		const image = await new PNGLoader(imagepath, gamma).loadImage();
		return new Sprite(this.name, image);
	}

	parseFrames(jsonFrames: AsepriteSheetFramesJSON, sprite: Sprite) {
		for (const jsonFrameName in jsonFrames) {
			const json = jsonFrames[jsonFrameName];
			const image = sprite.sheet.slice(json.frame.x, json.frame.y, json.frame.w, json.frame.h);
			sprite.addFrame(new SpriteFrame(jsonFrameName, image, json.duration / 1000));
		}
	}
}

type AsepriteSheetJSON = {
	meta: AsepriteSheetMetaJSON;
	frames: AsepriteSheetFramesJSON;
};

type AsepriteSheetMetaJSON = {
	image: string;
};

type AsepriteSheetFramesJSON = {
	[key: string]: AsepriteSheetFrameJSON;
};

type AsepriteSheetFrameJSON = {
	frame: AsepriteSheetRectJSON;
	duration: number;
};

type AsepriteSheetRectJSON = {
	x: number;
	y: number;
	w: number;
	h: number;
};
