"use strict"
let fs = require('fs');
let xml2js = require('xml2js');

if (process.argv.length < 4) {
	console.log("Usage: node " + process.argv[1] + " TILEMAP.TMX PREFIX");
	process.exit(1);
}

let filename = process.argv[2];
let prefix = process.argv[3];

fs.readFile(filename, function(err, data) {
	xml2js.parseString(data, function (err, result) {
		let map = result.map;

		console.log(prefix + "_dimensions:");
		console.log("\tdb " + map.$.width + ", " + map.$.height);

		console.log();
		console.log(prefix + "_data:");
		let dataCSV = map.layer[0].data[0]._.replace(/\s/g, "");
		let data = dataCSV.split(",").map(Number).map(i => i == 0 ? 255 : i - 1);
		for (let i = 0; i < data.length; i += 16) {
			console.log("\tdb " + data.slice(i, i + 16).join(", "));
		}
	});
});
