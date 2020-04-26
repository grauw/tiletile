"use strict"
const fs = require('fs');
const path = require('path');
const { checkTypes } = require('./utils');
const { Tmx } = require('./tilemaps');
const { PNGLoader } = require('./images');
const { AsepriteSheet } = require('./sprites');
const { VGMLoader } = require('./audio');

async function main() {
	if (process.argv.length < 3) {
		console.log(`Usage: node ${process.argv[1]} resources.json`);
		process.exit(1);
	}

	const path = process.argv[2];

	const resources = await new ResourcesLoader(path).parse();
	resources.optimize();
	console.log(resources.toAsm());
}

class Resources {
	constructor(screenMode, frameRate, tileMaps, images, sprites, audio) {
		checkTypes(arguments, "number", "number", Array, Array, Array, Array);
		this.screenMode = screenMode;
		this.frameRate = frameRate;
		this.tileMaps = tileMaps;
		this.images = images;
		this.sprites = sprites;
		this.audio = audio;
	}

	optimize() {
		for (const tileMap of this.tileMaps) {
			tileMap.optimize();
		}
	}

	toAsm() {
		const lines = [];
		for (const tileMap of this.tileMaps) {
			lines.push(tileMap.toAsm(this.screenMode));
		}
		for (const image of this.images) {
			lines.push(image.toAsm(this.screenMode));
		}
		for (const sprite of this.sprites) {
			lines.push(sprite.toAsm(this.frameRate));
		}
		for (const track of this.audio) {
			lines.push(track.toAsm(this.frameRate));
		}
		return lines.join("\n\n");
	}
}

class ResourcesLoader {
	constructor(path) {
		checkTypes(arguments, "string");
		this.path = path;
	}

	async parse() {
		const json = JSON.parse(await fs.promises.readFile(this.path));
		return new Resources(
			json.screenMode,
			json.frameRate,
			...await Promise.all([
				this.parseTileMaps(json.tilemaps),
				this.parseImages(json.images),
				this.parseSprites(json.sprites),
				this.parseAudio(json.audio)
			])
		);
	}

	async parseTileMaps(jsonTileMaps) {
		checkTypes(arguments, Array);
		return Promise.all(jsonTileMaps.map(async jsonTileMap => {
			const tileMapPath = path.resolve(path.dirname(this.path), jsonTileMap.path);
			return new Tmx(jsonTileMap.name, tileMapPath).parse();
		}));
	}

	async parseImages(jsonImages) {
		checkTypes(arguments, Array);
		return Promise.all(jsonImages.map(async jsonImage => {
			const imagePath = path.resolve(path.dirname(this.path), jsonImage.path);
			const image = await new PNGLoader(imagePath).loadImage();
			image.name = jsonImage.name;
			return image;
		}));
	}

	async parseSprites(jsonSprites) {
		checkTypes(arguments, Array);
		return Promise.all(jsonSprites.map(async jsonSprite => {
			const spritePath = path.resolve(path.dirname(this.path), jsonSprite.path);
			return new AsepriteSheet(jsonSprite.name, spritePath).parse();
		}));
	}

	async parseAudio(jsonAudio) {
		checkTypes(arguments, Array);
		return Promise.all(jsonAudio.map(async jsonTrack => {
			const trackPath = path.resolve(path.dirname(this.path), jsonTrack.path);
			const track = await new VGMLoader(jsonTrack.name, trackPath).loadTrack();
			return track;
		}));
	}
}

exports.Resources = Resources;
exports.ResourcesLoader = ResourcesLoader;

main().catch(reason => { throw reason; });
