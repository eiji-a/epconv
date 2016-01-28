#!/usr/bin/ruby
#
# exist: check same images in DB or not
#
# usage: exist.rb <tank_dir> <image>
#   <tank_dir> : directory of image tank
#   <image>    : image file (.jpg)
#

require 'rubygems'
require 'sqlite3'

DBFILE = 'tank.sqlite'
FPSIZE = 8
PICDIR = 'eaepc'
MAGDIR = 'emags'
EXT = '.jpg'

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
  $DB = SQLite3::Database.new($TANKDIR + "/" + DBFILE)
end

def is_tankdir(tankdir)
  return false if Dir.exist?(tankdir) == false
  return false if Dir.exist?(tankdir + "/" + PICDIR) == false
  return false if Dir.exist?(tankdir + "/" + MAGDIR) == false
  return false if File.exist?(tankdir + "/" + DBFILE) == false
  return true
end

def find_in_db(img)
  cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! #{img} PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  fp = `#{cmd}`
  sql = "SELECT id, filename FROM images where fingerprint = ?"
  $DB.execute(sql, fp.unpack("H*")) do |r|
    puts "#{r[0]}:(#{r[1]})"
  end
end

main

