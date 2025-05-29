import fs from "fs";

if (process.argv.length < 4) {
	console.log("Usage: node " + process.argv[1] + " SYMBOL_FILE HEX_ADDRESS...");
	process.exit(1);
}

const filename = process.argv[2];

fs.readFile(filename, "ascii", function(err, data) {
	if (err)
		throw err;

	data = data.replace(/[ \t]+/g, " ");
	const lines = data.split("\n");

	for (let i = 3; i < process.argv.length; i++) {
		const address = parseInt(process.argv[i], 16);
		if (isNaN(address)) {
			console.log("Unable to parse argument: " + process.argv[i]);
			continue;
		}

		let labelName = "*** Not Found";
		let labelDistance = Infinity;
		for (let j = 0; j < lines.length; j++) {
			const labelAndAddress = lines[j].split(" equ ");
			if (labelAndAddress.length < 2 || labelAndAddress[0][0] == "0")
				continue;
			const distance = address - parseInt(labelAndAddress[1].substr(0, 5), 16);
			if (distance >= 0 && distance < labelDistance) {
				labelName = labelAndAddress[0].trim();
				labelDistance = distance;
			}
		}
		console.log(("000" + address.toString(16).toUpperCase()).slice(-4) + "H: " + labelName + " + " +
			labelDistance.toString(16).toUpperCase() + "H (" + labelDistance + ")");
	}
});
