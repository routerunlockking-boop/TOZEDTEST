const AMBIGUOUS = '1ILil';

function alphabetChar(m) {
  return m < 10 ? 48 + m : m < 36 ? 55 + m : 61 + m;
}

function generateFrom(dataStr, filterAmbiguous = true) {
  const data = new Array(dataStr.length);
  for (let i = 0; i < dataStr.length; i++) data[i] = dataStr.charCodeAt(i);
  
  const len = data.length;
  if (!len) return '';
  const out = new Array(8);
  for (let i = 0; i < 8; i++) {
    let seed = 1;
    for (let j = 0; j < len; j++) {
      while (seed > 0xffffff) seed = ~seed & 0xffffff;
      const idx = (i + j) % len;
      const product = ((i + 1) * (j + 1)) & 0xff;
      seed = seed + data[idx] * product;
    }
    while (seed > 0xffffff) seed = ~seed & 0xffffff;
    let ch;
    ch = alphabetChar(seed % 52);
    if (filterAmbiguous && AMBIGUOUS.includes(String.fromCharCode(ch))) ch += 1;
    out[i] = ch;
  }
  return String.fromCharCode(...out);
}

const imei1 = "862624055623767";
const mac1 = "D842F7B23A8C";
const target1 = "dA5nzSYa";

const imei2 = "862624056036563";
const target2 = "fG2srAKC";

console.log("Original algorithm on imei1:", generateFrom(imei1));
console.log("Original algorithm on imei2:", generateFrom(imei2));

// Brute-force combinations
let found1 = false;
let found2 = false;

// 1. Try slicing IMEI
for (let i = 0; i < imei1.length; i++) {
  for (let j = i + 1; j <= imei1.length; j++) {
    if (generateFrom(imei1.substring(i, j)) === target1) console.log("Match 1 slice:", i, j);
    if (generateFrom(imei2.substring(i, j)) === target2) console.log("Match 2 slice:", i, j);
  }
}

// 2. Try prefix/suffix to IMEI
const prefixes = ["", "S50", "Dialog", "ZLT", "Tozed", "router", "admin", "operator", "P", "S50_"];
const suffixes = ["", "S50", "Dialog", "ZLT", "Tozed", "router", "admin", "operator"];

for (let p of prefixes) {
  for (let s of suffixes) {
    if (generateFrom(p + imei1 + s) === target1) console.log("Match 1: prefix/suffix:", p, s);
    if (generateFrom(p + imei2 + s) === target2) console.log("Match 2: prefix/suffix:", p, s);
    
    // Reverse IMEI
    const r1 = imei1.split('').reverse().join('');
    const r2 = imei2.split('').reverse().join('');
    if (generateFrom(p + r1 + s) === target1) console.log("Match 1: prefix/suffix on reversed:", p, s);
    if (generateFrom(p + r2 + s) === target2) console.log("Match 2: prefix/suffix on reversed:", p, s);
  }
}

// 3. Try transforming IMEI digits (e.g., adding 1 to each digit)
for (let offset = -5; offset <= 5; offset++) {
  let mod1 = ""; let mod2 = "";
  for (let i = 0; i < imei1.length; i++) {
    mod1 += String.fromCharCode(imei1.charCodeAt(i) + offset);
    mod2 += String.fromCharCode(imei2.charCodeAt(i) + offset);
  }
  if (generateFrom(mod1) === target1) console.log("Match 1: offset", offset);
  if (generateFrom(mod2) === target2) console.log("Match 2: offset", offset);
}

console.log("Done testing common string manipulations.");
