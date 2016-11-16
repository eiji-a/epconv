#!/usr/bin/ruby
#
#

require 'fileutils'

require_relative 'epconvlib'

USAGE = <<-EOS
Usage: cat <relation> | addrel.rb <tank_dir>
  <relation> : information of relation
  <tank_dir> : directory of image tank
EOS

def main
  init
  
  STDIN.each do |l|
    id, related = get_related(l)
    add_relation(id, related)
  end

  db_close
end

def init
  $TANKDIR = ARGV[0] + '/'
  if ARGV.size != 1 || is_tankdir($TANKDIR) == false
    STDERR.puts USAGE
    exit 1
  end

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

