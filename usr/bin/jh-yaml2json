#!/usr/bin/env node

const fs = require('fs');

const YAML = require('yaml');
const input = require('yargs')
	.argv
	._;

if (input.length == 0) {
	input.push('/dev/stdin');
}

const str = fs.readFileSync(input[0]).toString();

console.info(JSON.stringify(YAML.parse(str)));
