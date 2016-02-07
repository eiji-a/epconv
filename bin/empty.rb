#!/usr/bin/ruby
#
# empty: empty trashed images
#
# usage: empty.rb <tank_dir>
#   <tank_dir> : directory of image tank
#

require 'fileutils'

require_relative 'epconvlib'

def main
  init

  trashdir = $TANKDIR + "/" + TRASHDIR
  Dir.foreach(trashdir) do |f|
    next if f =~ /^\./
    next if File.file?(trashdir + "/" + f) == false
    if f =~ /-index\.jpg$/
      delete_mag(f)
    else
      delete_image(f)
    end
  end

  db_close
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts "usage: empty.rb <tank_dir>"
    STDERR.puts "   <tank_dir> : directory of image tank"
    exit 1
  end

  $TANKDIR = ARGV[0]
  db_open($TANKDIR)
end

def delete_mag(fname)
  fname =~ /^(.+?)-(..)(.+)-index\.jpg$/
  type = $1
  code = $2
  code2 = $3
  return if type != MAGDIR
  puts "F=#{fname}/T=#{type}/C=#{code}/C2=#{code2}"
  sql = "UPDATE images SET status = ? WHERE filename LIKE ?;"
  fn = type + "-" + code + code2 + '%'
  db_execute(sql, "deleted", fn)
  targetdir = $TANKDIR + "/#{type}/#{code}/#{type}-#{code}#{code2}"
  index     = $TANKDIR + "/#{type}/#{code}/index/#{fname}"
  deldir = $TANKDIR + "/" + DELDIR
  FileUtils.move(targetdir, deldir) if File.exist?(targetdir)
  FileUtils.move($TANKDIR + "/" + TRASHDIR + "/" + fname, deldir)
  FileUtils.remove(index) if File.exist?(index)
end

def delete_image(fname)
  fname =~ /^(.+?)-(..).+\.jpg$/
  type = $1
  code = $2
  puts "F=#{fname}/T=#{type}/C=#{$2}"
  sql = "UPDATE images SET status = ? WHERE filename = ?;"
  db_execute(sql, "deleted", fname)
  tankfile = 
    case type
    when PICDIR
      $TANKDIR + "/#{type}/#{code}/" + fname
    when MAGDIR
      fname =~ /^(.+)-.+\.jpg$/
      $TANKDIR + "/#{type}/#{code}/" + fname
    end
  deldir = $TANKDIR + "/" + DELDIR
  FileUtils.move(tankfile, deldir) if File.exist?(tankfile)
  FileUtils.move($TANKDIR + "/" + TRASHDIR + "/" + fname, deldir)
end

main


