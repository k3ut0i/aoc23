const re2 = /[a-z]*([0-9])[a-z0-9]*([0-9])[a-z]*/i;
const re1 = /[a-z]*([0-9])[a-z]*/i;
const numwords = /one|two|three|four|five|six|seven|eight|nine|zero/g;
export const r = /one|two|three|four|five|six|seven|eight|nine|zero|[0-9]/g;
const word2num = {'one':'1'}
export function toDigit(word) {
    switch(word) {
    case 'one':
        return '1';
    case 'two':
        return '2';
    case 'three':
        return '3';
    case 'four':
        return '4';
    case 'five':
        return '5';
    case 'six':
        return '6';
    case 'seven':
        return '7';
    case 'eight':
        return '8';
    case 'nine':
        return '9';
    case 'zero':
        return '0';
    }
}
export function calibrationValue(instr) {
    const match = instr.match(re2);
    if (match) {
        return Number(match[1] + match[2]);
    } else {
        const digit = instr.match(re1)[1];
        return Number(digit + digit);
    }
}

export function cV2(instr){
    const match = instr.match(r);
    const nums = match.map((num) => isNaN(num) ? toDigit(num) : num);
    const ans = Number(nums[0] + nums[nums.length-1]);
    console.log(`${instr} -> ${ans}`)
    return ans;
}

const fs = require('node:fs');

export function mainLoop(filename){
    fs.readFile(filename, 'utf8', (err, data) => {
        if (err) {
            console.error(err);
            return;
        } else {
            var lines = data.split("\n");
            if (lines[lines.length - 1] == '') {
                lines.pop();
            }
            const ans1 = lines.reduce(
                (acc, cur) => acc + calibrationValue(cur), 0
            );
            const ans2 = lines.reduce(
                (acc, cur) => acc + cV2(cur), 0
            );
            console.log(`part1: ${ans1}, part2: ${ans2}`);
        }
    });
}
