#!/usr/bin/ruby
#
#

require 'fileutils'

require_relative 'epconvlib'

def main
  init
  
  STDIN.each do |l|
    id, related = get_related(l)
    add_relation(id, related)
  end

  db_close
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts "Usage: cat <relation> | addrel.rb <tank_dir>"
    STDERR.puts "   <relation> : information of relation"
    STDERR.puts "   <tank_dir> : directory of image tank"
    exit 1
  end

  $TANKDIR = ARGV[0]
  db_open($TANKDIR)
end

def get_related(l)
  l =~ /^\("(\d+)"\,\"(.*)\"\)$/
  return $1.to_i, $2
end

def add_relation(id, related)
  sql = "UPDATE images SET checkdate = ?, related_id = ? WHERE id = ?;"
  date = Time.now.strftime "%Y%m%d%H%M%S"
  db_execute(sql, date, related, id)
  puts "ID=#{id},REL=#{related},DT=#{date}"
end

main

