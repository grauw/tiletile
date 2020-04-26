"use strict"
const fs = require('fs');
const { checkTypes, toAsmHex } = require('./utils');

class AudioTrack {
	constructor(name) {
		checkTypes(arguments, "string");
		this.name = name;
		this.commands = [];
		this.loop = -1;
	}

	addCommand(command) {
		checkTypes(arguments, AudioCommand);
		if (command instanceof AudioCommandWait && this.commands.length > 0) {
			const lastCommand = this.commands[this.commands.length - 1];
			if (lastCommand instanceof AudioCommandWait) {
				lastCommand.time += command.time;
				return;
			}
		} else if (command instanceof AudioCommandLoop) {
			this.loop = this.commands.length;
		}
		this.commands.push(command);
	}

	toAsm(frameRate) {
		checkTypes(arguments, "number");
		const lines = [];
		lines.push(`${this.name}_track:`);
		lines.push(`\tAudioTrack ${this.name}_commands`);
		lines.push("");
		lines.push("\tSECTION ROM_DATA");
		lines.push("\tALIGN 2000H");
		lines.push(`${this.name}_commands:`);
		let time = 0.5 / 44100 * frameRate;  // slight offset to avoid rounding errors
		for (const command of this.commands) {
			if (command instanceof AudioCommandPSG) {
				lines.push(`\tAudioCommandPSG ${toAsmHex(command.address)}, ${toAsmHex(command.value)}`);
			} else if (command instanceof AudioCommandOPLL) {
				lines.push(`\tAudioCommandOPLL ${toAsmHex(command.address)}, ${toAsmHex(command.value)}`);
			} else if (command instanceof AudioCommandWait) {
				const lastTime = time;
				time += command.time * frameRate;
				for (let frames = Math.floor(time) - Math.floor(lastTime); frames > 0; frames -= 0x7F) {
					lines.push(`\tAudioCommandWait ${Math.min(frames, 0x7F)}`);
				}
			} else if (command instanceof AudioCommandLoop) {
				lines.push(`${this.name}_commands_loop:`);
			} else if (command instanceof AudioCommandEnd) {
				if (this.loop < 0) {
					lines.push(`${this.name}_commands_loop:`);
					lines.push(`\tAudioCommandWait 1`);
				}
				lines.push(`\tAudioCommandEnd ${this.name}_commands_loop`);
			} else {
				throw new Error("Unrecognised command.");
			}
		}
		lines.push("\tENDS");
		return lines.join("\n");
	}
}

class AudioCommand {
	constructor() {
	}
}

class AudioCommandPSG extends AudioCommand {
	constructor(address, value) {
		checkTypes(arguments, "number", "number");
		if (address >= 0x0E)
			throw new Error("Invalid PSG register.");
		super();
		this.address = address;
		this.value = value;
	}
}

class AudioCommandOPLL extends AudioCommand {
	constructor(address, value) {
		checkTypes(arguments, "number", "number");
		if (address >= 0x40)
			throw new Error("Invalid OPLL register.");
		super();
		this.address = address;
		this.value = value;
	}
}

class AudioCommandWait extends AudioCommand {
	constructor(time) {
		checkTypes(arguments, "number");
		super();
		this.time = time;
	}
}

class AudioCommandLoop extends AudioCommand {
	constructor() {
		super();
	}
}

class AudioCommandEnd extends AudioCommand {
	constructor() {
		super();
	}
}

class VGMLoader {
	constructor(name, path) {
		checkTypes(arguments, "string", "string");
		this.name = name;
		this.path = path;
	}

	async loadTrack() {
		const vgm = await fs.promises.readFile(this.path);
		const getByte = address => vgm[address];
		const getWord = address => getByte(address) | getByte(address + 1) << 8;
		const getDoubleWord = address => getWord(address) | getWord(address + 2) << 16;
		if (getDoubleWord(0x00) != 0x206d6756)
			throw new Error("Not a VGM file.");
		const version = getDoubleWord(0x08);
		const loop = getDoubleWord(0x1C) ? getDoubleWord(0x1C) + 0x1C : 0;
		const headerSize = version >= 0x150 ? getDoubleWord(0x34) + 0x34 : 0x40;
		const frequency = 44100;
		const track = new AudioTrack(this.name);
		let address = headerSize;
		while (address < vgm.length) {
			if (address == loop)
				track.addCommand(new AudioCommandLoop());
			const type = getByte(address++);
			if (type == 0x51) {
				const register = getByte(address++);
				const value = getByte(address++);
				if (register < 0x3F) {
					track.addCommand(new AudioCommandOPLL(register, value));
				}
			} else if (type == 0xA0) {
				const register = getByte(address++);
				let value = getByte(address++);
				if (register < 0x0E) {
					if (register == 0x07)
						value = value & 0x3F | 0x80;
					track.addCommand(new AudioCommandPSG(register, value));
				}
			} else if (type == 0x61) {
				const time = getWord(address) / frequency;
				address += 2;
				track.addCommand(new AudioCommandWait(time));
			} else if (type == 0x62) {
				track.addCommand(new AudioCommandWait(735 / frequency));
			} else if (type == 0x63) {
				track.addCommand(new AudioCommandWait(882 / frequency));
			} else if (type == 0x66) {
				track.addCommand(new AudioCommandEnd());
				break;
			} else if (type >= 0x70 && type < 0x80) {
				track.addCommand(new AudioCommandWait(((type & 15) + 1) / frequency));
			} else {
				throw new Error(`Unsupported command ${type.toString(16)} at address ${(address - 1).toString(16)}`);
			}
		}
		return track;
	}
}

exports.AudioTrack = AudioTrack;
exports.AudioCommand = AudioCommand;
exports.AudioCommandPSG = AudioCommandPSG;
exports.AudioCommandOPLL = AudioCommandOPLL;
exports.AudioCommandWait = AudioCommandWait;
exports.AudioCommandLoop = AudioCommandLoop;
exports.AudioCommandEnd = AudioCommandEnd;
exports.VGMLoader = VGMLoader;
