import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(<App />, document.getElementById('root'));
registerServiceWorker();

fetch('/api/videos/').then(function(response) {
  if(response.ok) {
    return response.json();
  }
  throw new Error('Network response was not ok.');
}).then(function(json) {
  // convert the bandwidth efficient db format into a more usable JS object
  const columns = json[0].columns;
  const videos = json[0].values.map(function(row) {
    const out = {};
    for (var i = 0; i < columns.length; i++) {
      out[columns[i]] = row[i];
    }
    return out;
  });

  ReactDOM.render(<App videos={videos} />, document.getElementById('root'));
}).catch(function(error) {
  console.log('There has been a problem with your fetch operation: ' + error.message);
});
