#!/usr/bin/ruby
#
# samemag: find same mags in DB
#
# usage: samemag.rb <tank_dir>
#   <tank_dir> : directory of image tank
#

require 'fileutils'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: samemag.rb <tank_dir> 
  <tank_dir> : directory of image tank
EOS

def main
  init

  make_list.each_value do |v|
    put_same(v) if v.length > 1
  end
  @magpairs.each do |k, v|
    puts_pair(k, v)
  end
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts USAGE
    exit 1
  end

  $TANKDIR = ARGV[0] + '/'
  db_open($TANKDIR)
  @magpairs = Hash.new
end

def make_list
  list = Hash.new
  sql = "SELECT fingerprint, filename FROM images WHERE status IS NOT 'deleted'"
  db_execute(sql).each do |r|
    list[r[0]] = Array.new if list[r[0]] == nil
    list[r[0]] << r[1]
  end
  puts "LEN:#{list.size}"
  list
end

def put_same(files)
  list = Array.new
  hash = ""
  files.each do |f|
    /-(.{40})/ =~ f
    if hash != $1
      hash = $1
      list << f
    end
  end
  if list.size > 1  
    if list.size == 2
      proc_2files(files)
    else
      proc_2files(files[0..2])
    end
  end
end

def proc_2files(files)
  k0 = files[0].split(/-/)[0]
  k1 = files[1].split(/-/)[0]
  if k0 == FILE_PIC && k1 == FILE_PIC
    proc_pics(files, k0, k1)
  elsif k0 == FILE_MAG && k1 == FILE_MAG
    proc_mags(files)
  else
    proc_pics(files, k0, k1)
  end
end

def proc_pics(files, kind0, kind1)
  f0 = get_fullpath(files[0])
  f1 = get_fullpath(files[1])
  puts "where: #{f0}: #{f1}"
  delflg = false
  if File.exist?(f0) == false
    delete_from_db(files[0])
    delflg = true
  end
  if File.exist?(f1) == false
    delete_from_db(files[1])
    delflg = true
  end
  return if delflg == true
  sz0 = File.size(f0)
  sz1 = File.size(f1)
  tg0 = `tag -l #{f0}`.split(/\s+/)[1]
  tg1 = `tag -l #{f1}`.split(/\s+/)[1]
  if kind0 == kind1
    dfile = f1
    dfile = f0 if tg1 == FILETAG || tg0 == INITTAG
    if (sz0 - sz1).abs < 1024
      FileUtils.move(dfile, $TANKDIR + TRASHDIR)
    else
      puts "same:"
      puts files.join("\n")
    end
  else
    tag = if tg1 == FILETAG || tg0 == INITTAG then tg1 else tg0 end
    change_tag(f0, tag)
    change_tag(f1, tag)
    dfile = if kind1 == FILE_MAG then f0 else f1 end
    FileUtils.move(dfile, $TANKDIR + TRASHDIR)
  end
end

def delete_from_db(file)
  sql = "UPDATE images SET status = ? WHERE filename = ?;"
  db_execute(sql, "deleted", file)
  puts "DELETED(DB): #{file}"
end

def proc_mags(files)
  h0 = files[0].match(%r/^(.+)-(\d+)\.jpg/)
  h1 = files[1].match(%r/^(.+)-(\d+)\.jpg/)
  key = [h0[1], h1[1]]
  val = [h0[2], h1[2]]
  @magpairs[key] = Array.new if @magpairs[key] == nil
  @magpairs[key] << val
end

def get_fullpath(file)
  kind = file.split(/-/)[0]
  /#{kind}-(..)/ =~ file
  hs = $1
  if kind == FILE_PIC
    "#{$TANKDIR}/#{kind}/#{hs}/#{file}"
  else
    /^(.+)-\d+\.jpg/ =~ file
    "#{$TANKDIR}/#{kind}/#{hs}/#{$1}/#{file}"
  end
end

def change_tag(file, tag)
  system "tag -r #{FILETAG},#{SKETTAG},#{INITTAG} #{file}"
  system "tag -a #{tag} #{file}"
end

def puts_pair(key, val)
  print "#{key[0]}:#{key[1]}="
  val.each do |a|
    print "(#{a[0]},#{a[1]}):"
  end
  puts ""
end

main
