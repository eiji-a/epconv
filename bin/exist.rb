#!/usr/bin/ruby
#
# exist: check same images in DB or not
#
# usage: exist.rb <tank_dir> <image>
#   <tank_dir> : directory of image tank
#   <image>    : image file (.jpg)
#

require_relative 'epconvlib'

USAGE = <<-EOS
usage: exist.rb <tank_dir> [<image> [<image>] ...]
  <tank_dir> : directory of image tank
  <image>    : image file (.jpg)
  * if you don't enumerate images, the directry is searched.
EOS

HEIGHT = "100px"
IMGPATH = "http://192.168.11.50:4567/imageno/"
IMGLIMIT = 10000

def main
  init

  STDERR.puts Time.now
  images = read_images($TARGETS)
  STDERR.puts Time.now
  images = match_with_db(images)
  STDERR.puts Time.now

  header
  images.each do |k, v|
    im = v.shift
    img = im[0]
    imgline = ""
    v.each do |i|
      imgline += <<-"EOS"
      <a href="#{IMGPATH}#{i[0]}">
        <img src="#{IMGPATH}#{i[0]}" height="#{HEIGHT}">
      </a>
      #{i[2]} |
      EOS
    end

    line = <<-"EOS"
    <tr>
      <td>
      <img src="file://#{$CDIR}/#{img}" height="#{HEIGHT}">
      #{imgline}
      </td>
    </tr>
    EOS
    puts line
  end

  footer
end

def init
  if ARGV.size < 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts USAGE
    exit 1
  end

  $TANKDIR = ARGV.shift + '/'
  db_open($TANKDIR)
  STDERR.puts "TANK: #{$TANKDIR}"

  $CDIR = Dir.pwd
  if ARGV.size >= 1
    $TARGETS = ARGV
  else
    $TARGETS = Dir.glob("*#{EXT}")
  end
end

def read_images(targets)
  images = Hash.new
  i = 0
  targets.each do |t|
    #cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! '#{t}' PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
    cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! '#{t}' PPM:-"
    len = FPSIZE * FPSIZE * 6  # 文字数
    fp = `#{cmd}`.unpack("H*")[0][-len..-1]
    if images[fp] == nil
      images[fp] = [[t]]
    else
      images[fp][0] << t
    end
    break if i >= IMGLIMIT
    i += 1
  end
  images
end

def match_with_db(images)
  sql = "SELECT id, filename, status, fingerprint FROM images"
  db_execute(sql).each do |r|
    if images[r[3]] != nil
      images[r[3]] << [r[0], r[1], r[2]]
    end
  end
  images
end

def find_in_db(img)
  if File.exist?(img) == false
    STDERR.puts "File not found: #{img}"
    return
  end
  cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! '#{img}' PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  fp = `#{cmd}`
  sql = "SELECT id, filename, status FROM images WHERE fingerprint = ?"
  dbimg = []
  db_execute(sql, fp.unpack("H*")).each do |r|
    dbimg[0] = r[0]
    dbimg[1] = r[1]
    dbimg[2] = r[2]
    #puts "#{r[0]}:(#{r[1]})"
  end
  dbimg
end

def header
  hd_str = <<-"EOS"
<html>
  <title> epconv: exist check </title>
  <body>
  <table>
  EOS
  puts hd_str
end

def footer
  ft_str = <<-"EOS"
  </table>
  </body>
</html>
  EOS
  puts ft_str
end

main

