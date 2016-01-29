#!/usr/bin/ruby
#
# empty: empty trashed images
#
# usage: empty.rb <tank_dir>
#   <tank_dir> : directory of image tank
#

require 'fileutils'
#require 'digest/sha1'
require 'rubygems'
require 'sqlite3'

DBFILE = 'tank.sqlite'
PICDIR = 'eaepc'
MAGDIR = 'emags'
TRASHDIR = 'trash'
EXT = '.jpg'
INITTAG = 'notevaluated'
FPSIZE = 8


def main
  init

  Dir.foreach($TANKDIR + "/" + TRASHDIR) do |f|
    next if f =~ /^\./
    fname = $TANKDIR + "/" + TRASHDIR + "/" + f
    next if File.file?(fname) == false
    if f =~ /index\.jpg$/
      delete_mag(f)
    else
      delete_image(f)
      File.delete(fname)
    end
  end
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts "usage: empty.rb <tank_dir>"
    STDERR.puts "   <tank_dir> : directory of image tank"
    exit 1
  end

  $TANKDIR = ARGV[0]
  $DB = SQLite3::Database.new($TANKDIR + "/" + DBFILE)
end

def is_tankdir(tankdir)
  return false if Dir.exist?(tankdir) == false
  return false if Dir.exist?(tankdir + "/" + PICDIR) == false
  return false if Dir.exist?(tankdir + "/" + MAGDIR) == false
  return false if File.exist?(tankdir + "/" + DBFILE) == false
  return true
end

def delete_mag(fname)

end

def delete_image(fname)
  fname =~ /^(.+)-(..).+\.jpg$/
  type = $1
  code = $2
  puts "F=#{fname}/T=#{type}/C=#{$2}"
  sql = "UPDATE images SET checkdate = ? WHERE filename = ?;"
  $DB.execute(sql, "deleted", fname)
  tankfile = $TANKDIR + "/#{type}/#{code}/" + fname
  File.delete(tankfile) if File.exist?(tankfile);
end


main


