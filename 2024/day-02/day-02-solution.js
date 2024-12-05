#!/usr/bin/env node

const path = require('path');
const { open } = require('node:fs/promises');

const filePath = path.join(__dirname, 'day-02-inputs.txt');

const solveProblem = async (useDampener = false) => {
  const file = await open(filePath);

  let safeLines = 0;

  for await (const line of file.readLines()) {
    const lineValues = line.trim().split(' ').map(Number);
    if (isSafeLine(lineValues)) {
      safeLines++;
    } else if (useDampener) {
      for (let i = 0; i < lineValues.length; i++) {
        if (isSafeLine([...lineValues.slice(0, i), ...lineValues.slice(i + 1)])) {
          safeLines++;
          break;
        }
      }
    }
  }

  return safeLines;
};

const isSafeLine = (line) => {
  let currDiff = line[1] - line[0];

  for (let i = 0; i < line.length - 1; i++) {
    let diff = line[i + 1] - line[i];

    if (diff === 0 || Math.abs(diff) > 3 || (diff > 0) !== (currDiff > 0)) {
      return false;
    }

    currDiff = diff;
  }

  return true;
};

const solutions = async () => {
  console.log('Safe levels: ', await solveProblem());
  console.log('Safe levels with dampener: ', await solveProblem(true));

}

solutions();