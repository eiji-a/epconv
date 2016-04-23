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

  Dir.foreach(@trashdir) do |f|
    next if f =~ /^\./
    next if File.file?(@trashdir + f) == false
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
  @trashdir = "#{$TANKDIR}/#{TRASHDIR}/"
end

def delete_mag(index)
  kind, type, cd, hash, id = analyze_file(index)
  code2 = $3
  return if type != MAGDIR
  puts "F=#{index}/T=#{type}/C=#{code}/C2=#{hash}"
  sql = "UPDATE images SET status = ? WHERE filename LIKE ?;"
  fn = "#{type}-#{hash}%"
  db_execute(sql, "deleted", fn)
  cdpath = "#{$TANKDIR}/#{type}/#{code}/"
  targetdir = cdpath + "#{type}-#{hash}"
  fullindex = cdpath + "index/#{index}"
  deldir = "#{$TANKDIR}/#{DELDIR}/"
  FileUtils.move(targetdir, deldir) if File.exist?(targetdir)
  FileUtils.move(@trashdir + index, deldir)
  FileUtils.remove(fullindex) if File.exist?(fullindex)
end

def delete_image(fname)
=begin
  fname =~ /^(.+?)-(..).+\.jpg$/
  type = $1
  code = $2
=end
  d0, type, cd, d1, d2 = analyze_file(fname)
  puts "F=#{fname}/T=#{type}/C=#{cd}"
  sql = "UPDATE images SET status = ? WHERE filename = ?;"
  db_execute(sql, "deleted", fname)
=begin
  tankfile = 
    case type
    when PICDIR
      $TANKDIR + "/#{type}/#{code}/" + fname
    when MAGDIR
      fname =~ /^(.+)-.+\.jpg$/
      $TANKDIR + "/#{type}/#{code}/" + fname
    end
=end
  d0, tankfile = get_path(fname)
  deldir = $TANKDIR + "/" + DELDIR
  FileUtils.move(tankfile, deldir) if File.exist?(tankfile)
  FileUtils.move(@trashdir + fname, deldir)
end

main


