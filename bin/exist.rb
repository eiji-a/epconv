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

def main
  init

  header
  $TARGET.each do |t|
    dbimg = find_in_db(t)
    puts "#{t}: #{dbimg[0]}/#{dbimg[1]}"
    line = <<-"EOS"
    <tr>
      <td><img src="file://#{$CDIR}/a.jpg"></td>
      <td><img src="#{IMGPATH}#{dbimg[0]}" height="#{HEIGHT}"></td>
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
  puts "TANK: #{$TANKDIR}"

  $CDIR = Dir.pwd
  if ARGV.size >= 1
    $TARGET = ARGV
  else
    $TARGET = Dir.glob("*#{EXT}")
  end
end

def find_in_db(img)
  if File.exist?(img) == false
    STDERR.puts "File not found: #{img}"
    return
  end
  cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! '#{img}' PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  fp = `#{cmd}`
  sql = "SELECT id, filename FROM images WHERE fingerprint = ?"
  dbimg = []
  db_execute(sql, fp.unpack("H*")).each do |r|
    dbimg[0] = r[0]
    dbimg[1] = r[1]
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

