import { readFile } from "node:fs/promises";

if (process.argv.length < 4) {
	console.log(`Usage: node ${process.argv[1]} SYMBOL_FILE HEX_ADDRESS...`);
	process.exit(1);
}

const filename = process.argv[2];

const data = await readFile(filename, "utf8");
const lines = data.replace(/[ \t]+/g, " ").split("\n");

for (const arg of process.argv.slice(3)) {
	const address = parseInt(arg, 16);
	if (isNaN(address)) {
		console.log(`Unable to parse argument: ${arg}`);
		continue;
	}

	let labelName = "*** Not Found";
	let labelDistance = Infinity;
	for (const line of lines) {
		const labelAndAddress = line.split(" equ ");
		if (labelAndAddress.length < 2 || labelAndAddress[0][0] == "0")
			continue;
		const distance = address - parseInt(labelAndAddress[1].substring(0, 5), 16);
		if (distance >= 0 && distance < labelDistance) {
			labelName = labelAndAddress[0].trim();
			labelDistance = distance;
		}
	}
	console.log(`${address.toString(16).toUpperCase().padStart(4, "0")}H: ${labelName} + ` +
		`${labelDistance.toString(16).toUpperCase()}H (${labelDistance})`);
}
