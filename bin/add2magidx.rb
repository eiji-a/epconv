#!/usr/bin/ruby
#
# add2magidx: add magazine index
#
# usage: add2magidx.rb <tank_dir> <hash> <imagefile>
#    <tank_dir> : directory of image tank
#    <hash>     : hash code for addition
#    <imagefile>: image file name to add
#

require 'fileutils'
require 'digest/sha1'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: add2magidx.rb <tank_dir> <hash> <imagefile>"
  <tank_dir> : directory of image tank"
  <hash>     : hash code for addition"
  <imagefile>: image file name to add"
EOS

def main
  init

  dirname = get_dir($HASH, MAGDIR)
  ddirname = dirname + "/" + MAGDIR + "-" + $HASH
  if File.exist?(ddirname) == false
    STDERR.puts "Invalid directory: #{ddirname}"
    STDERR.puts USAGE
    exit 1
  end
  
  n = Dir.glob(ddirname + "/*.jpg").size
  dimg = MAGDIR + "-" + $HASH + "-" + sprintf("%04d", n+1) + ".jpg"
  index_img($SDIR, $IMGFILE, $HASH, dirname)
  add_imgfile($SDIR + "/" + $IMGFILE, dimg, ddirname, false)
  
  db_close
end

def init
  if ARGV.size != 3 || is_tankdir(ARGV[0]) == false ||
     File.exist?(ARGV[2]) == false
    STDERR.puts USAGE
    exit 1
  end

  $DIGEST = Digest::SHA1.new
  $TANKDIR = ARGV[0]
  db_open($TANKDIR)

  $HASH = ARGV[1]
  $SDIR = File.dirname(ARGV[2])
  $IMGFILE = File.basename(ARGV[2])
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

def add_imgdir(sdir, hs)
  dirname = get_dir(hs, MAGDIR)
  num = 1
  puts "SDIR:#{sdir}"
  Dir.foreach(sdir) do |f|
    next if f =~ /^\./
    sdir2 = sdir + "/" + f
    if File.directory?(sdir2) == true
      add_imgdir(sdir2, get_hash(sdir2))
    elsif f =~ /\.jpg$/i
      dimg = MAGDIR + "-" + hs + "-" + sprintf("%04d", num) + ".jpg"
      index_img(sdir, f, hs, dirname)
      ddirname = dirname + "/" + MAGDIR + "-" + hs
      Dir.mkdir(ddirname) if File.exist?(ddirname) == false
      add_imgfile(sdir + "/" + f, dimg, ddirname, false)
      num += 1
    end
  end

end

def index_img(sdir, img, hs, dirname)
  simg = sdir + "/" + img
  bdir = File.basename(sdir)
  #puts "BDIR=#{bdir}, IMG=#{img}"
  idirname = dirname + "/index"
  Dir.mkdir(idirname) if Dir.exists?(idirname) == false
  idximg = MAGDIR + "-" + hs + "-index.jpg"
  img0  = 
  bdir0 = 
  dstfile = "#{idirname}/#{idximg}"
  FileUtils.copy(simg, dstfile)
  add_tag(dstfile, INITTAG)
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
  db_execute(sql, dimg, fp.unpack("H*"))
end

main

