#!/usr/bin/env ruby

require 'sqlite3'
require 'nokogiri'
require 'chronic_duration'

COLUMNS = {
  name: 'varchar(100)',
  uuid: 'varchar(36)',
  format: 'varchar(100)',
  file_size_MiB: 'real',
  duration_seconds: 'int',
}


db_folder = File.join(__dir__, '..', 'db')
assets_folder = File.join(__dir__, '..', 'assets')

db = SQLite3::Database.new(File.join(db_folder, 'assets-db.sqlite3'))

res = db.execute('SELECT name FROM sqlite_master WHERE type = "table"')

if res.flatten.include?('videos')
  puts 'table `videos` already exists — dropping'
  db.execute 'DROP TABLE videos'
end

columns = COLUMNS.inject('') do |memo, pair|
  name, type = pair
  memo += "\n#{name} #{type},"
end.chomp(',')

db.execute <<-SQL
  create table videos (
    #{columns}
  );
SQL

p "Working..."

Dir.glob(File.join(assets_folder, 'originals', '*.{mpg,mpeg,mov,avi,mkv,flv,mp4,webm}')).each {|file|
  xml = Nokogiri::XML(`mediainfo --Output=XML #{file}`)

  # p xml.xpath('//track[@type="General"]').map(&:content)
  # p xml.xpath('//track[@type="Video"]').map(&:content)
  # p xml.xpath('//track[@type="Audio"]').map(&:content)

  # pulling the uuid off of the file path is sort of janky but we want it to reconstruct the file path anyway so it should be fine
  output_path = Dir.glob(File.join(assets_folder, 'processed', "#{File.basename(file, File.extname(file))}-*")).first
  uuid = output_path.match('([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$$')[0]

  row = [
    File.basename(file, File.extname(file)), # name
    uuid,
    xml.xpath('//track[@type="General"]//Format').first.content, # format
    xml.xpath('//track[@type="General"]//File_size').first.content.to_f, # file_size_MiB
    ChronicDuration.parse(xml.xpath('//track[@type="General"]//Duration').first.content), # duration_seconds
  ]

  sql = <<-SQL
    INSERT INTO videos (#{COLUMNS.keys.join(', ')})
    VALUES (#{(['?'] * COLUMNS.size).join(', ')})
SQL
  db.execute sql, row
}

p "done."


# <?xml version="1.0" encoding="UTF-8"?>
# <Mediainfo version="0.7.97">
# <File>
# <track type="General">
# <Complete_name>../../assets/originals/anni002.mpg</Complete_name>
# <Format>MPEG-PS</Format>
# <File_size>14.3 MiB</File_size>
# <Duration>1 min 23 s</Duration>
# <Overall_bit_rate_mode>Constant</Overall_bit_rate_mode>
# <Overall_bit_rate>1 445 kb/s</Overall_bit_rate>
# <Writing_library>Tailor (C)FutureTel Inc. 1997. Engineered by Andrew Palfreyman</Writing_library>
# </track>

# <track type="Video">
# <ID>224 (0xE0)</ID>
# <Format>MPEG Video</Format>
# <Format_version>Version 1</Format_version>
# <Format_settings__BVOP>Yes</Format_settings__BVOP>
# <Format_settings__Matrix>Default</Format_settings__Matrix>
# <Format_settings__GOP>M=3, N=9</Format_settings__GOP>
# <Duration>1 min 23 s</Duration>
# <Bit_rate_mode>Constant</Bit_rate_mode>
# <Bit_rate>1 300 kb/s</Bit_rate>
# <Width>320 pixels</Width>
# <Height>240 pixels</Height>
# <Display_aspect_ratio>1.185</Display_aspect_ratio>
# <Frame_rate>29.970 (30000/1001) FPS</Frame_rate>
# <Color_space>YUV</Color_space>
# <Chroma_subsampling>4:2:0</Chroma_subsampling>
# <Bit_depth>8 bits</Bit_depth>
# <Scan_type>Progressive</Scan_type>
# <Compression_mode>Lossy</Compression_mode>
# <Bits__Pixel_Frame_>0.565</Bits__Pixel_Frame_>
# <Time_code_of_first_frame>00:00:00;00</Time_code_of_first_frame>
# <Time_code_source>Group of pictures header</Time_code_source>
# <Stream_size>12.8 MiB (89%)</Stream_size>
# <Writing_library>Tailor (C)FutureTel Inc. 1997. Engineered by Andrew Palfreyman</Writing_library>
# </track>

# <track type="Audio">
# <ID>192 (0xC0)</ID>
# <Format>MPEG Audio</Format>
# <Format_version>Version 1</Format_version>
# <Format_profile>Layer 2</Format_profile>
# <Duration>1 min 23 s</Duration>
# <Bit_rate_mode>Constant</Bit_rate_mode>
# <Bit_rate>128 kb/s</Bit_rate>
# <Channel_s_>1 channel</Channel_s_>
# <Sampling_rate>32.0 kHz</Sampling_rate>
# <Compression_mode>Lossy</Compression_mode>
# <Stream_size>1.27 MiB (9%)</Stream_size>
# </track>

# </File>
# </Mediainfo>
