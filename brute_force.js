const imei1 = "862624055623767";
const target1 = "dA5nzSYa";
const imei2 = "862624056036563";
const target2 = "fG2srAKC";

const AMBIGUOUS = '1ILil';

function alphabetChar(m) {
  return m < 10 ? 48 + m : m < 36 ? 55 + m : 61 + m;
}

function testParams(a, b, c, op1, op2, base, initSeed, mult1, mult2, moduloSize) {
    const dataStr1 = imei1;
    const dataStr2 = imei2;

    function generate(dataStr) {
        const len = dataStr.length;
        const out = new Array(8);
        for (let i = 0; i < 8; i++) {
            let seed = initSeed;
            for (let j = 0; j < len; j++) {
                while (seed > 0xffffff) seed = ~seed & 0xffffff;
                const idx = (i + j + a) % len;
                const product = ((i + mult1) * (j + mult2)) & 0xff;
                
                let term1 = dataStr.charCodeAt(idx);
                if (op1 === 1) term1 -= 48; // numerical value
                else if (op1 === 2) term1 = term1 * product;

                if (op2 === 0) seed = seed + term1 * product;
                else if (op2 === 1) seed = seed + term1 + product;
                else if (op2 === 2) seed = seed * term1 + product;
                else if (op2 === 3) seed = (seed ^ term1) + product;
            }
            while (seed > 0xffffff) seed = ~seed & 0xffffff;
            
            let ch = alphabetChar(seed % base);
            if (base === 52) { // check ambiguous
                if (AMBIGUOUS.includes(String.fromCharCode(ch))) ch += 1;
            }
            out[i] = ch;
        }
        return String.fromCharCode(...out);
    }

    if (generate(imei1) === target1) {
        if (generate(imei2) === target2) {
            console.log(`MATCH FOUND: a=${a}, op1=${op1}, op2=${op2}, base=${base}, initSeed=${initSeed}, mult1=${mult1}, mult2=${mult2}`);
            return true;
        }
    }
    return false;
}

console.log("Starting brute force...");

let count = 0;
for (let initSeed of [0, 1, 2, 0xffffff]) {
    for (let base of [52, 62]) {
        for (let mult1 of [0, 1, 2]) {
            for (let mult2 of [0, 1, 2]) {
                for (let a of [0, 1]) {
                    for (let op1 of [0, 1, 2]) {
                        for (let op2 of [0, 1, 2, 3]) {
                            testParams(a, 0, 0, op1, op2, base, initSeed, mult1, mult2, 0);
                            count++;
                        }
                    }
                }
            }
        }
    }
}

console.log(`Finished ${count} tests.`);
