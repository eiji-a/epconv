#!/usr/bin/ruby
#
# dedup.rb
#

require_relative 'epconvlib'

def main
  init
  
  ofn = ""
  STDIN.each do |l|
    fn, id = l.split(/\|/)
    if ofn == fn
      puts "F=#{fn}, I=#{id}"
      del_dbitem(id.to_i)
    end
    ofn = fn
  end

  db_close
end

def init
  $TANKDIR = ARGV[0]
  db_open($TANKDIR)
  puts "TANK=#{$TANKDIR}"
end

def del_dbitem(id)
  sql = "UPDATE images SET status = ? WHERE id = ?;"
  db_execute(sql, ST_DEDUP, id)
end

main
