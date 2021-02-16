#!/usr/bin/env node

// See https://github.com/cronvel/terminal-kit/blob/HEAD/doc/high-level.md#ref.fileInput

const term = require('terminal-kit').terminal;
const glob = require('glob');
const childProcess = require('child_process');

term.fullscreen();

term.cyan('The hall is spacious. Someone lighted few chandeliers.\n');
term.cyan('There are doorways south and west.\n');

const projects = [
	{ "id": 24245, "wo": "CGER003", "status": "en cours", "title": "COMMUNAUTE  GERM-Maintenance GESPER-GER" },
	{ "id": 10683, "wo": "NAMU001", "status": "en cours", "title": "E1952 Gestion Domaine Public" },
	{ "id": 21143, "wo": "NAMU003", "status": "en cours", "title": "E2309 Plateforme WEB-Réservation emplacements" },
	{ "id": 22722, "wo": "NAMU004", "status": "en cours", "title": "Evolution de l'outil de gestion ODP" },
	{ "id": 24503, "wo": "NAMU005", "status": "en cours", "title": "Réservation évolutions (Parking)" },
	{ "id": -1000, "wo": "GIG-001", "status": "garantie", "title": "" },
	{ "id": 20662, "wo": "GIG-004", "status": "en cours", "title": "Support en développement GIG" },
	{ "id": -1000, "wo": "GIG-006", "status": "garantie", "title": "" },
	{ "id": -1000, "wo": "GIG-007", "status": "garantie", "title": "" },
	{ "id": -1000, "wo": "GIG-008", "status": "garantie", "title": "" },
	{ "id": -1000, "wo": "GIG-009", "status": "garantie", "title": "" },
	{ "id": 24882, "wo": "GIG-010", "status": "en cours", "title": "Voiries 2 - Sprint 2" },
	{ "id": 24923, "wo": "GIG-011", "status": "en cours", "title": "Contrat cadre GIG 2018-2024" },
	{ "id": 24822, "wo": "SWCS006", "status": "en cours", "title": "consultance securite-signature type Eid & Itsme" },
	{ "id": 25223, "wo": "SPW    ", "status": "offre   ", "title": "SPW M23 Coditax" },
	{ "id": 25224, "wo": "SPW    ", "status": "offre   ", "title": "SPW M23 Aquatax" },
	{ "id": 10401, "wo": "SPW    ", "status": "en cours", "title": "OFFRE GENERALE NRB-NSI M23" },
	{ "id": 19604, "wo": "SPW-355", "status": "en cours", "title": "O4-16M23-GesPer-BIEN" },
	{ "id": 19942, "wo": "SPW-391", "status": "en cours", "title": "O4-16M23-Mnt GESPER POW" },
	{ "id": 22202, "wo": "SPW    ", "status": "en cours", "title": "Etude Application GESPER" },
	{ "id": 24643, "wo": "SPW    ", "status": "en cours", "title": "O4-16M23-Mnt GESPER 01 08 20-31 07 21" },
	{ "id": 24703, "wo": "SPW-431", "status": "en cours", "title": "O3-20M23-Coditax-signature électronique" },
	{ "id": -1000, "wo": "-      ", "status": "en cours", "title": "" },
].filter(e => e.title > '');

projects.sort((a, b) => (a.wo + a.id).localeCompare(b.wo + b.id));

process.stdout.write(` ${'id'.padStart(7, ' ')} | ${'wo'.padStart(7)} | status     | title\n`);
var items = projects.map(v => `${('' + v.id).padStart(7, ' ')} | ${v.wo.padStart(7)} | ${v.status.padEnd(10)} | ${v.title}`);

term.singleColumnMenu(items, function (error, response) {
	// response.selectedIndex
	id = projects[response.selectedIndex].id;

	const p = '\\\\' + ["portalnsi", "sites", "priam", `Project${id}`, "Documents du projet"].join('\\');
	console.log("Path: ", p);
	const child = childProcess.spawn('explorer', [p], { detached: true, stdio: 'ignore' });
	child.unref();

	// glob(p + '\\*', function (err, files) {
	// 	if (err) {
	// 		console.error(err);
	// 		return;
	// 	}
	// 	console.log(files);
	// 	console.log("done");
	// });

	// term.inputField((error, input) => {
	process.exit();
	// });
});