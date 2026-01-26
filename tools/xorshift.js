//
// See http://www.arklyffe.com/main/2010/08/29/xorshift-pseudorandom-number-generator/
//
if (process.argv.length != 5) {
	console.log(`Usage: node ${process.argv[1]} a b c`);
	process.exit(1);
}

const a = process.argv[2];
const b = process.argv[3];
const c = process.argv[4];

const seed = 1;
let y = seed;
let period = 0;

do {
	y ^= (y << a) & 255;
	y ^= (y >> b) & 255;
	y ^= (y << c) & 255;
	console.log(`${y.toString(2).padStart(8, "0")} ${y.toString(16).padStart(2, "0")} ${y}`);
	period++;
} while (y != seed);

console.log("\nPeriod: " + period);
