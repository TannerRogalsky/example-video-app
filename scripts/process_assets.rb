#!/usr/bin/env ruby

require 'fileutils'
require 'securerandom'

assets_folder = File.join(__dir__, '..', 'assets')
originals_folder = File.join(assets_folder, 'originals')
processed_folder = File.join(assets_folder, 'processed')

transcode_options = {
  mp4: { # x264 & aac
    :"codec:v" => 'libx264',
    :"b:v" => '500k',
    :"maxrate" => '500k',
    :"vf" => 'scale=-2:480',
    :"threads" => 0,

    :"b:a" => '128k',
    :"codec:a" => 'libfdk_aac',
  },
  webm: { # vp8 & vorbis
    :"codec:v" => 'libvpx',
    :"b:v" => '500k',
    :"maxrate" => '500k',
    :"vf" => 'scale=-2:480',
    :"threads" => 0,

    :"b:a" => '128k',
    :"codec:a" => 'libvorbis',
  }
}

Dir.glob(File.join(originals_folder, '*.{mpg,mpeg,mov,avi,mkv,flv,mp4,webm}')).each {|file|
  extension = File.extname(file)
  filename = File.basename(file, extension)
  processed_path = File.join(processed_folder, "#{filename}-#{SecureRandom.uuid}")
  FileUtils.mkdir_p(processed_path)

  transcode_options.each { |ext, options|
    options_string = options.reduce('') { |sum, (key, value)|
      sum + " -#{key} #{value} "
    }
    `ffmpeg -i #{file} #{options_string} #{File.join(processed_path, filename)}.#{ext}`
  }

  # `ffmpeg -i #{file} -codec:v libx264 -profile:v high -preset slow -b:v 500k -maxrate 500k -bufsize 1000k -vf scale=-1:480 -threads 0 -codec:a libfdk_aac -b:a 128k #{File.join(processed_path, filename)}.mp4`
  # `ffmpeg -i #{file} -codec:v libvpx                               -b:v 500k -maxrate 500k -bufsize 1000k -vf scale=-1:480 -threads 0 -codec:a libvorbis  -b:a 128k #{File.join(processed_path, filename)}.webm`
}
