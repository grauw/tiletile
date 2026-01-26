function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

const array = [];
for (let i = 0; i < 256; i++) {
	array[i] = i;
}
shuffleArray(array);

console.log(array.join(", "));
