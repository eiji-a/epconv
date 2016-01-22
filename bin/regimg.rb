#!/usr/bin/ruby
#
# regimg: register images
#
# usage: regimg.rb <tank_dir>
#    <tank_dir> : directory of image tank
#

require 'fileutils'
require 'digest/sha1'
require 'rubygems'
require 'sqlite3'

DBFILE = 'tank.sqlite'
PICDIR = 'eaepc'
MAGDIR = 'emags'
EXT = '.jpg'
INITTAG = 'notevaluated'
FPSIZE = 8

def main
  init

  Dir.glob("*.jpg") do |f|
    hs = get_hash(f)
    srcimg, dstimg = get_imgfile(f, hs)
    dirname = get_dir(hs, PICDIR)
    add_imgfile(srcimg, dstimg, dirname, INITTAG)
  end

  $DB.close
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts "usage: regimg.rb <tank_dir>"
    STDERR.puts "   <tank_dir> : directory of image tank"
    exit 1
  end

  $DIGEST = Digest::SHA1.new
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

def get_hash(f)
  bn = File.basename(f, EXT)
  hashsrc = bn + File.size(f).to_s + File.ctime(f).to_s + Time.now.to_s
  $DIGEST.update(hashsrc).to_s
end

def get_imgfile(f, hs)
  fname = ""
  if /^#{PICDIR}-.*\.jpg/.match f
    fname = f
  else
    fname = PICDIR + "-" + hs + ".jpg"
  end
  return f, fname
end

def get_dir(hs, picdir)
  idx = hs[0, 2]
  dirname = "#{$TANKDIR}/#{picdir}/#{idx}"
  Dir.mkdir(dirname) if Dir.exist?(dirname) == false
  dirname
end

def add_imgfile(simg, dimg, dirname, tag)
  dstfile = "#{dirname}/#{dimg}"
  if File.exist?(dstfile)
    STDERR.puts "FILE EXISTS!: #{dstfile}"
    return
  end
  FileUtils.copy(simg, dstfile)
  system "tag -a #{tag} #{dstfile}" if tag != false
  insert_to_db(dimg, dstfile)
end

def insert_to_db(dimg, dstfile)
  cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! #{dstfile} PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  fp = `#{cmd}`
  sql = "INSERT INTO images (filename, fingerprint) VALUES (?, ?)"
  $DB.execute(sql, dimg, fp.unpack("H*"))
end

main

