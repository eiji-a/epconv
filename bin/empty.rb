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

  $TANKDIR = ARGV[0] + '/'
  db_open($TANKDIR)
  @trashdir = $TANKDIR + TRASHDIR
  @deldir   = $TANKDIR + DELDIR
end

def delete_mag(index)
  kind, type, cd, hash, id = analyze_file(index)
  return if type != FILE_INDEX
  puts "F=#{index}/T=#{type}/C=#{cd}/C2=#{hash}"
  sql = "UPDATE images SET status = ? WHERE filename LIKE ?;"
  fn = "#{kind}-#{hash}"
  db_execute(sql, "deleted", fn + '%')
  cdpath = $TANKDIR + "#{kind}/#{cd}/"
  targetdir = cdpath + fn
  fullindex = cdpath + "index/#{index}"
  delete_file(index)
  FileUtils.move(targetdir, @deldir) if File.exist?(targetdir)
  FileUtils.remove(fullindex) if File.exist?(fullindex)
end

def delete_image(fname)
  d0, type, cd, d1, d2 = analyze_file(fname)
  puts "F=#{fname}/T=#{type}/C=#{cd}"
  sql = "UPDATE images SET status = ? WHERE filename = ?;"
  db_execute(sql, "deleted", fname)
  d0, tankfile = get_path(fname)
  delete_file(fname)
end

def delete_file(file)
  FileUtils.move(@trashdir + file, @deldir)
end

main


