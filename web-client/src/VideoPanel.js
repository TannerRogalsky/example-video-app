import React, { Component } from 'react';

import Panel from 'react-bootstrap/lib/Panel';
import ListGroup from 'react-bootstrap/lib/ListGroup';
import ListGroupItem from 'react-bootstrap/lib/ListGroupItem';

import ReactPlayer from 'react-player';

class VideoPanel extends Component {
  constructor(...args) {
    super(...args);
    this.state = {
      open: false
    };
  }

  render() {
    const row = this.props;
    const videoUrls = ['.mp4', '.webm'].map(function(ext) {
      return {
        src: `/media/${row.name}-${row.uuid}/${row.name}${ext}`
      };
    });

    const player = this.state.open ? (
      <center>
        <ReactPlayer url={videoUrls} controls playing />
      </center>
    ) : undefined;

    return (
      <Panel collapsible header={row.name} expanded={this.state.open} onClick={ ()=> this.setState({ open: !this.state.open })}>
        {player}
        <ListGroup fill>
          <ListGroupItem>Format: {row.format}</ListGroupItem>
          <ListGroupItem>Size: {row.file_size_MiB} MiB</ListGroupItem>
          <ListGroupItem>Duration: {row.duration_seconds} secs</ListGroupItem>
        </ListGroup>
      </Panel>
    );
  }
}

export default VideoPanel;
