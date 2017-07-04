const express = require('express');
const fs = require('fs');
const sqlite = require('sql.js');

const filebuffer = fs.readFileSync('db/assets-db.sqlite3');

const db = new sqlite.Database(filebuffer);

const app = express();

app.set('port', process.env.PORT || 3001);

app.use('/media', express.static('assets/processed'));

app.get('/api/videos', (req, res) => {
  // this doesn't scale. Needs pagination, at least.
  const r = db.exec('select * from videos limit 100');
  res.json(r);
});

app.listen(app.get('port'), () => {
  console.log(`Find the server at: http://localhost:${app.get('port')}/`); // eslint-disable-line no-console
});
