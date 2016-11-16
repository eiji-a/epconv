#!/usr/bin/ruby
#
# regimg: register images
#
# usage: regimg.rb <tank_dir>
#    <tank_dir> : directory of image tank
#

require 'fileutils'
require 'digest/sha1'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: regimg.rb <tank_dir>
  <tank_dir> : directory of image tank
EOS

def main
  init

#=begin
  Dir.glob("*.jpg") do |f|
    next if File.directory?(f) == true
    hs = get_hash(f)
    srcimg, dstimg = get_imgfile(f, hs)
    dirname = get_dir(hs, $TANKDIR, PICDIR)
    add_imgfile(srcimg, dstimg, dirname, INITTAG)
  end
#=end

  Dir.foreach(".") do |f|
    next if f =~ /^\./
    if File.directory?(f) == true
      add_imgdir(f, get_hash(f))
    elsif f =~ /\.zip$/i
      tname = TMPDIR + Time.now.strftime("%Y%m%d%H%M%S")
      if File.exist?(tname) == false
        FileUtils.mkdir(tname)
        FileUtils.copy(f, tname + '.zip')
        system "unzip -d #{tname} #{tname}.zip > /dev/null"
        add_imgdir(tname, get_hash(f))
        FileUtils.remove_entry_secure(tname)
        FileUtils.rm(tname + '.zip')
      else
        STDERR.puts "Can't extract zip: #{f}"
      end
    end
  end
  
  db_close
end

def init
  $TANKDIR = ARGV[0] + '/'
  if ARGV.size != 1 || is_tankdir($TANKDIR) == false
    STDERR.puts USAGE
    exit 1
  end

  $DIGEST = Digest::SHA1.new
  db_open($TANKDIR)
end

def reg_dir(f, hs)
  dirname = get_dir(hs, $TANKDIR, FILE_MAG)
  add_imgdir(f, hs, dirname)
end

def get_imgfile(f, hs)
  fname = ""
  if /^#{FILE_PIC}-.*\.jpg/.match f
    fname = f
  else
    fname = FILE_PIC + "-" + hs + ".jpg"
  end
  return f, fname
end

def add_imgdir(sdir, hs)
  dirname = get_dir(hs, $TANKDIR, MAGDIR)
  num = 1
  puts "SDIR:#{sdir}"
  Dir.foreach(sdir) do |f|
    next if f =~ /^\./
    sdir2 = sdir + "/" + f
    if File.directory?(sdir2) == true
      add_imgdir(sdir2, get_hash(sdir2))
    elsif f =~ /\.jpg$/i
      dimg = FILE_MAG + "-" + hs + "-" + sprintf("%04d", num) + ".jpg"
      index_img(sdir, f, hs, dirname)
      ddirname = dirname + FILE_MAG + "-" + hs
      Dir.mkdir(ddirname) if File.exist?(ddirname) == false
      add_imgfile(sdir + "/" + f, dimg, ddirname, false)
      num += 1
    end
  end
  listfile = $TANKDIR + MAGDIR + "#{hs[0]}.list"
  FileUtils.remove(listfile) if File.exist?(listfile)
end

def index_img(sdir, img, hs, dirname)
  simg = sdir + "/" + img
  bdir = File.basename(sdir)
  #puts "BDIR=#{bdir}, IMG=#{img}"
  idirname = dirname + "/index"
  Dir.mkdir(idirname) if Dir.exists?(idirname) == false
  idximg = FILE_MAG + "-" + hs + "-index.jpg"
  dstfile = "#{idirname}/#{idximg}"
  if simg =~ /cover/i ||
     simg =~ /_lg\.jpg/i ||
     File.size(simg) < COVERSIZE ||
     img.gsub(/\([xX]\d+\)/, '') == bdir.gsub(/\([xX]\d+\)/, '') + EXT ||
     File.exists?(dstfile) == false
    FileUtils.copy(simg, dstfile)
    add_tag(dstfile, INITTAG)
  end
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

