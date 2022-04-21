function construct(sets, ways, blocksize) {
    let cache = { setSize: sets, waySize: ways, blockSize: blocksize, sets: [] };
    for (let s = 0; s < sets; ++s) {
        let set = [];
        for (let w = 0; w < ways; ++w) {
            let block = { age: 0, words: [] };
            for (let w = 0; w < blocksize; ++w) {
                block.words.push("--");
            }
            set.push(block);
        }
        cache.sets.push(set);
    }
    return cache;
}

function draw(cache, element) {
    let div = document.getElementById(element);
    div.innerHTML = '';
    let table = document.createElement('table');
    let setIndex = 0;
    cache.sets.forEach(set => {
        let tr = document.createElement('tr');
        tr.id = setIndex;
        setIndex++;
        let blockIndex = 0;
        set.forEach(block => {
            let td = document.createElement('td');
            td.id = setIndex + "-" + blockIndex;
            blockIndex++;
            block.words.forEach(word => {
                td.innerText += word + " ";
            });
            tr.append(td);
        });
        table.append(tr);
    });
    div.append(table);
}

function insertAddress(cache, address, element) {
    let wordIndexSize = Math.log2(cache.blockSize);
    let setIndexSize = Math.log2(cache.setSize);
    console.log(address);
    let addressBinary = address.toString(2).padStart(wordIndexSize + setIndexSize, '0');
    console.log(addressBinary);
    let addressLength = addressBinary.length;

    let setIndex = -1;
    let wordIndex = -1;

    if (wordIndexSize === 0) {
        wordIndex = 0;
    } else {
        wordIndex = parseInt(addressBinary.substring(addressLength - wordIndexSize, addressLength), 2);
    }

    setIndex = parseInt(addressBinary.substring(addressLength - wordIndexSize - setIndexSize, addressLength - wordIndexSize), 2);

    let selectedSet = cache.sets[setIndex];

    let hit = false;
    let hitIndex = -1;

    for (let i = 0; i < selectedSet.length; ++i) {
        let block = selectedSet[i];
        if (block.words[wordIndex] == address) {
            hit = true;
            hitIndex = i;
        }
    }

    let maxAge = 0;
    let maxIndex = 0;
    for (let i = 0; i < selectedSet.length; ++i) {
        let block = selectedSet[i];
        block.age += 1;
        if (block.age > maxAge) {
            maxAge = block.age;
            maxIndex = i;
        }
    }

    if (hit) {
        selectedSet[hitIndex].age = 0;
    } else {
        for (let i = 0; i < selectedSet[maxIndex].words.length; ++i) {
            selectedSet[maxIndex].words[i] = address - wordIndex + i;
        }
        selectedSet[maxIndex].age = 0;
    }

    draw(cache, element);

    return hit;
}
