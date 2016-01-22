#!/usr/bin/ruby
#
#

require 'fileutils'
require 'rubygems'
require 'sqlite3'

DBFILE = 'tank.sqlite'
PICDIR = 'eaepc'
MAGDIR = 'emags'

def main
  init
  
  STDIN.each do |l|
    id, related = get_related(l)
    add_relation(id, related)
  end
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts "Usage: cat <relation> | addrel.rb <tank_dir>"
    STDERR.puts "   <relation> : information of relation"
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

def get_related(l)
  l =~ /^\("(\d+)"\,\"(.*)\"\)$/
  return $1.to_i, $2
end

def add_relation(id, related)
  sql = "UPDATE images SET checkdate = ?, related_id = ? WHERE id = ?;"
  date = Time.now.strftime "%Y%m%d%H%M%S"
  $DB.execute(sql, date, related, id)
  puts "ID=#{id},REL=#{related},DT=#{date}"
end

main

