#!/usr/bin/ruby
#
# delete images which status is 'deleted'
#
#

require 'fileutils'

require_relative 'epconvlib'

USAGE = 'Usage: del_deleted.rb <tank dir>'






def init(argv)
  exit 1 if argv.size < 1 || is_tankdir(argv[0]) == false
  $TANKDIR = argv[0] + '/'
  $TRASHDIR = $TANKDIR + 'trash'
  db_open($TANKDIR)
end

def select_deleted
  dels = Array.new
  sql = "SELECT filename FROM images where status = ?;"
  puts "S:#{sql}"
  db_execute(sql, ST_DELETE).each do |r|
    path = get_path(r[0])[2]
    if File.exist?(path)
      puts "P:#{path}"
      FileUtils.mv(path, $TRASHDIR)
    end
  end
  dels
end

def main
  init(ARGV)
  select_deleted
end

main

