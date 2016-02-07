#!/usr/bin/ruby
#
# exist: check same images in DB or not
#
# usage: exist.rb <tank_dir> <image>
#   <tank_dir> : directory of image tank
#   <image>    : image file (.jpg)
#

require_relative 'epconvlib'

def main
  init

  find_in_db($TARGET)
end

def init
  if ARGV.size != 2 || is_tankdir(ARGV[0]) == false
    STDERR.puts "usage: exist.rb <tank_dir> <image>"
    STDERR.puts "   <tank_dir> : directory of image tank"
    STDERR.puts "   <image>    : image file (.jpg)"
    STDERR.puts "   <tank_dir> : directory of image tank"
    exit 1
  end

  $TANKDIR = ARGV[0]
  $TARGET = ARGV[1]
  db_open($TANKDIR)
end

def find_in_db(img)
  if File.exist?(img) == false
    STDERR.puts "File not found: #{img}"
    return
  end
  cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! '#{img}' PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  fp = `#{cmd}`
  sql = "SELECT id, filename FROM images where fingerprint = ?"
  db_execute(sql, fp.unpack("H*")).each do |r|
    puts "#{r[0]}:(#{r[1]})"
  end
end

main

