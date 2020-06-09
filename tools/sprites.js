"use strict"
const fs = require("fs");
const path = require("path");
const { checkTypes } = require("./utils");
const { Image, ImageSlice, PNGLoader } = require("./images");

class Sprite {
	constructor(name, sheet) {
		checkTypes(arguments, "string", Image);
		this.name = name;
		this.sheet = sheet;
		this.frames = [];
	}

	addFrame(frame) {
		checkTypes(arguments, SpriteFrame);
		this.frames.push(frame);
	}

	toAsm(frameRate) {
		checkTypes(arguments, "number");
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
	constructor(name, image, duration) {
		checkTypes(arguments, "string", Image, "number");
		if (image.width % 16 != 0 || image.height % 16 != 0)
			throw new Error(`Unsupported sprite dimensions .`);
		this.name = name;
		this.image = image;
		this.duration = duration;
		this.patterns = [];

		for (const tile of image.toTiles(16, 16)) {
			this.patterns.push(new SpritePattern(tile, 1));
			this.patterns.push(new SpritePattern(tile, 2));
			this.patterns.push(new SpritePattern(tile, 4));
			this.patterns.push(new SpritePattern(tile, 8));
		}
	}

	toAsm(frameRate) {
		checkTypes(arguments, "number");
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
	constructor(image, mask) {
		checkTypes(arguments, Image, "number");
		this.data = [];

		const addPatternData = image => {
			for (let y = 0; y < 8; y++) {
				let byte = 0;
				for (let x = 0; x < 8; x++) {
					if (image.getPixel(x, y).index & mask)
						byte |= 128 >> x;
				}
				this.data.push(byte);
			}
		}

		addPatternData(new ImageSlice(image, 0, 0, 8, 8));
		addPatternData(new ImageSlice(image, 0, 8, 8, 8));
		addPatternData(new ImageSlice(image, 8, 0, 8, 8));
		addPatternData(new ImageSlice(image, 8, 8, 8, 8));
	}

	toAsm() {
		return `\tSpritePattern ${this.data.join(", ")}`;
	}
}

class AsepriteSheet {
	constructor(name, path) {
		checkTypes(arguments, "string", "string");
		this.name = name;
		this.path = path;
	}

	async parse(gamma) {
		checkTypes(arguments, "number");
		const json = JSON.parse(await fs.promises.readFile(this.path));
		const sprite = await this.parseSprite(json.meta, gamma);
		this.parseFrames(json.frames, sprite);
		return sprite;
	}

	async parseSprite(jsonMeta, gamma) {
		checkTypes(arguments, Object, "number");
		const imagepath = path.resolve(path.dirname(this.path), jsonMeta.image);
		const image = await new PNGLoader(imagepath, gamma).loadImage();
		return new Sprite(this.name, image);
	}

	parseFrames(jsonFrames, sprite) {
		checkTypes(arguments, Object, Sprite);
		for (const jsonFrameName in jsonFrames) {
			const json = jsonFrames[jsonFrameName];
			const image = new ImageSlice(sprite.sheet, json.frame.x, json.frame.y, json.frame.w, json.frame.h);
			sprite.addFrame(new SpriteFrame(jsonFrameName, image, json.duration / 1000));
		}
	}
}

module.exports = { Sprite, AsepriteSheet };
