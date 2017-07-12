import React, { Component } from 'react';
import './App.css';

import VideoPanel from './VideoPanel.js';

class App extends Component {
  render() {
    const videos = this.props.videos;
    return (
      <div className="App">
        <div className="App-header">
          <h2>Videos</h2>
        </div>
        <div className="App-content">
          {
            videos.map(function(row) {
              return <VideoPanel key={row.uuid} {...row} />
            })
          }
        </div>
      </div>
    );
  }
}

export default App;
