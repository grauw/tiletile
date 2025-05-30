import fs from "fs";
import path from "path";
import { checkTypes } from "./utils.js";
import { TileMap, Tmx } from "./tilemaps.js";
import { Image, PNGLoader } from "./images.js";
import { Sprite, AsepriteSheet } from "./sprites.js";
import { AudioTrack, VGMLoader } from "./audio.js";

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

export class Resources {
	constructor(screenMode, frameRate, gamma) {
		checkTypes(arguments, "number", "number", "number");
		this.screenMode = screenMode;
		this.frameRate = frameRate;
		this.gamma = gamma;
		this.tileMaps = [];
		this.images = [];
		this.sprites = [];
		this.audio = [];
	}

	addTileMap(tileMap) {
		checkTypes(arguments, TileMap);
		this.tileMaps.push(tileMap);
	}

	addImage(image) {
		checkTypes(arguments, Image);
		this.images.push(image);
	}

	addSprite(sprite) {
		checkTypes(arguments, Sprite);
		this.sprites.push(sprite);
	}

	addAudioTrack(track) {
		checkTypes(arguments, AudioTrack);
		this.audio.push(track);
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

export class ResourcesLoader {
	constructor(path) {
		checkTypes(arguments, "string");
		this.path = path;
	}

	async parse() {
		const json = JSON.parse(await fs.promises.readFile(this.path, { encoding: "utf8" }));

		const resources = new Resources(
			json.screenMode,
			json.frameRate,
			json.gamma
		);

		const tileMaps = Promise.all(json.tilemaps.map(async jsonTileMap => {
			const tileMapPath = path.resolve(path.dirname(this.path), jsonTileMap.path);
			return new Tmx(jsonTileMap.name, tileMapPath).parse(resources.gamma);
		}));

		const images = Promise.all(json.images.map(async jsonImage => {
			const imagePath = path.resolve(path.dirname(this.path), jsonImage.path);
			const image = await new PNGLoader(imagePath, resources.gamma).loadImage();
			image.name = jsonImage.name;
			return image;
		}));

		const sprites = Promise.all(json.sprites.map(async jsonSprite => {
			const spritePath = path.resolve(path.dirname(this.path), jsonSprite.path);
			return new AsepriteSheet(jsonSprite.name, spritePath).parse(resources.gamma);
		}));

		const audio = Promise.all(json.audio.map(async jsonTrack => {
			const trackPath = path.resolve(path.dirname(this.path), jsonTrack.path);
			return new VGMLoader(jsonTrack.name, trackPath).loadTrack();
		}));

		for (const tileMap of await tileMaps)
			resources.addTileMap(tileMap);
		for (const image of await images)
			resources.addImage(image);
		for (const sprite of await sprites)
			resources.addSprite(sprite);
		for (const track of await audio)
			resources.addAudioTrack(track);

		return resources;
	}
}

main().catch(reason => { throw reason; });
