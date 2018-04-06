//
// See http://www.arklyffe.com/main/2010/08/29/xorshift-pseudorandom-number-generator/
//
if (process.argv.length != 5) {
	console.log("Usage: node " + process.argv[1] + " a b c");
	process.exit(1);
}

var a = process.argv[2];
var b = process.argv[3];
var c = process.argv[4];

var seed = 1;
var y = seed;
var period = 0;

do {
	y ^= (y << a) & 255;
	y ^= (y >> b) & 255;
	y ^= (y << c) & 255;
	console.log(
			("0000000" + y.toString(2)).substr(-8) + " " +
			("0" + y.toString(16)).substr(-2) + " " +
			y);
	period++;
} while (y != seed);

console.log("\nPeriod: " + period);