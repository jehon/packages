
const path = require('path');
const express = require('express');

const app = express();
const port = 1080;

app.use('/', express.static(path.join(__dirname, '../')));

app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}/web`);
})
