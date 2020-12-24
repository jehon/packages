#!/usr/bin/env node

// See https://github.com/cronvel/terminal-kit/blob/HEAD/doc/high-level.md#ref.fileInput

const term = require('terminal-kit').terminal;
const childProcess = require('child_process');

term.fullscreen();

term.cyan('The hall is spacious. Someone lighted few chandeliers.\n');
term.cyan('There are doorways south and west.\n');

const projects = [
	{ "id": 10683, "wo": "NAMU001", "status": "en cours", "title": "E1952 Gestion Domaine Public" },
	{ "id": 21143, "wo": "NAMU003", "status": "en cours", "title": "E2309 Plateforme WEB-Réservation emplacements" },
	{ "id": 22722, "wo": "NAMU004", "status": "en cours", "title": "Evolution de l'outil de gestion ODP" },
	{ "id": 24503, "wo": "NAMU005", "status": "en cours", "title": "Réservation évolutions (Parking)" },
	{ "id": 0, "wo": "GIG-001", "status": "garantie", "title": "" },
	{ "id": 20662, "wo": "GIG-004", "status": "en cours", "title": "Support en développement GIG" },
	{ "id": 0, "wo": "GIG-006", "status": "garantie", "title": "" },
	{ "id": 0, "wo": "GIG-007", "status": "garantie", "title": "" },
	{ "id": 0, "wo": "GIG-008", "status": "garantie", "title": "" },
	{ "id": 0, "wo": "GIG-009", "status": "garantie", "title": "" },
	{ "id": 24882, "wo": "GIG-010", "status": "en cours", "title": "Voiries 2 - Sprint 2" },
	{ "id": 24923, "wo": "GIG-011", "status": "en cours", "title": "Contrat cadre GIG 2018-2024" },
	{ "id": 24822, "wo": "SWCS006", "status": "en cours", "title": "consultance securite-signature type Eid & Itsme" },
]



var items = projects.map(v => v.wo + " - " + v.title + '(' + v.status + ')');

term.singleColumnMenu(items, function (error, response) {
	// response.selectedIndex
	id = projects[response.selectedIndex].id;

	const p = '\\\\' + ["portalnsi", "sites", "priam", `Project${id}`, "Documents du projet"].join('\\');
	console.log("Path: ", p);
	const child = childProcess.spawn('explorer', [p], { detached: true, stdio: 'ignore' });
	child.unref();
	process.exit();
});