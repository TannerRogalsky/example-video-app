Example Video App
=====

This is an basic video app. The backend maintains a DB of video assets that it can server. The frontend consumes that data and renders a basic video player. They are decoupled but a web frontend is provided.

## Components

### [Process Assets](https://github.com/TannerRogalsky/example-video-app/blob/master/scripts/process_assets.rb)
Performs video encoding and builds useful directory structure. Ready for a CDN, includes UUID in file path for cache busting. Uses `ffmpeg`.

### [Seed SQLite](https://github.com/TannerRogalsky/example-video-app/blob/master/scripts/seed_sqlite.rb)
Creates a DB and seeds it with information about the processed videos. Uses `mediainfo` to pull information from video files and `sqlite3` as a database.

### Web Client
A React app. It performs an AJAX request after load to check for video assets and renders video players for them.

## Installation
Make sure you have `ffmpeg`, `sqlite3` and `mediainfo` installed. Run `npm install` on both the root project and the `web-client` subdirectory. Place master video files in `assets/originals` and then run `./scripts/process_assets.rb` to ready the file for web and `./scripts/seed_sqlite.rb` to fill the database. `npm start` should now start your server and open a page to localhost.
