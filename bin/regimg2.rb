#!/usr/bin/ruby
#
# regimg2: register images 2
#
# usage: regimg2.rb <tank_dir>
#  <tank_dir> : directory of image tank
#

require 'fileutils'
require 'digest/sha1'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: regimg2.rb <tank_dir>
 <tank_dir> : directory of image tank
EOS

CONV1 = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! "
CONV2 = " PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
BETTER = 'better'
WORSE  = 'worse'
HOLD   = 'hold'
NEWIMG = -1
DIR_FIN   = 'fin'
DIR_TRASH = 'trash'
DIR_HOLD  = 'hold'
STAT_FILED = 'filed'
STAT_DUP   = 'duplicated'


# IMAGE
#   format: id, filename, filesize, x reso, y reso, fingreprint, status
@images = Array.new

# FINGERPRINTS
@fingerprint = Hash.new

def init
  if ARGV.size != 1
    STDERR.puts USAGE
    exit 1
  end
  $TANKDIR = ARGV[0] + '/'
  if is_tankdir($TANKDIR) == false
    STDERR.puts USAGE
    exit 1
  end
  $DIGEST = Digest::SHA1.new
  # create dirs
  FileUtils.mkdir(DIR_FIN)   if Dir.exist?(DIR_FIN)   == false
  FileUtils.mkdir(DIR_TRASH) if Dir.exist?(DIR_TRASH) == false
  FileUtils.mkdir(DIR_HOLD)  if Dir.exist?(DIR_HOLD)  == false
end

def read_tank
  sql = "SELECT id, filename, filesize, xreso, yreso, fingerprint " +
        "  FROM images WHERE status = '#{STAT_FILED}'"
  db_execute(sql).each do |i|
    @images << i
  end
end

def get_img_info(fn)
  rs = `identify -format \"%w,%h\" #{fn}`.split(",")
  fsize = File.size(fn)
  fp = `#{CONV1} #{fn} #{CONV2}`.unpack("H*")[0]
  [NEWIMG, fn, fsize.to_i, rs[0].to_i, rs[1].to_i, fp]
end

def read_files
  Dir.glob("*.jpg") do |f|
    @images << get_img_info(f)
  end
end

def better?(im1, im2)
  if im1[2] > im2[2] && im1[3] > im2[3] && im1[4] > im2[4]
    BETTER
  elsif im1[2] <= im2[2] && im1[3] <= im2[3] && im1[4] <= im2[4]
    WORSE
  else
    HOLD
  end
end

def classify_img
  @images.each_with_index do |im, i|
    puts "#{i}: #{im[1]}/#{im[2]}"
    if @fingerprint[im[5]] == nil
      #puts "REGIST: #{i}:#{im[5]}"
      @fingerprint[im[5]] = [[i, BETTER]]
    else
      st = WORSE
      @fingerprint[im[5]].each do |fp|
        next if fp[1] == WORSE
        st0 = better?(im, @images[fp[0]])
        case st0
        when BETTER
          fp[1] = WORSE
          st = st0
        when HOLD
          fp[1] = HOLD
          st = st0
        else
          #
        end
      end
      @fingerprint[im[5]] << [i, st]
      puts "#{i}:#{st}"
    end
  end
end

def insert_to_db(im, fn)
  #   format: id, filename, filesize, x reso, y reso, fingreprint, status
  sql = "INSERT INTO images (filename, filesize, xreso, yreso, fingerprint, status) " +
        "VALUES (?, ?, ?, ?, ?, ?)"
  db_execute(sql, fn, im[2], im[3], im[4], im[5], STAT_FILED)
end

def regist_newimg(im)
  fn = FILE_PIC + '-' + get_hash(im[1]) + EXT
  p = get_path(fn)
  insert_to_db(im, fn)
  FileUtils.mkdir(p[0]) if Dir.exist?(p[0]) == false
  FileUtils.move(im[1], "#{p[0]}#{fn}")
  puts "REGIST NEW: #{im[1]}/#{fn}"
end

def change_stat_on_db(im, st)
  sql = "UPDATE images SET status = ? WHERE id = ?"
  db_execute(sql, st, im[0])
end

def discard_img(im)
  if im[0] == NEWIMG
    FileUtils.move(im[1], DIR_TRASH)
    puts "TRASH NEW: #{im[1]}"
  else
    p = get_path(im[1])
    change_stat_on_db(im, STAT_DUP)
    FileUtils.move("#{p[0]}#{im[1]}", DIR_TRASH)
    puts "REMOVE DB: #{im[1]}/#{p.join(":")}"
  end
end

def hold_img(im)
  if im[0] == NEWIMG
    FileUtils.move(im[1], DIR_HOLD)
    puts "PENDING NEW: #{im[1]}"
  else
    puts "PENDING DB: #{im[1]}"
  end
end

def update_img
  @fingerprint.each do |fp, imgs|
    imgs.each do |i|
      im = @images[i[0]]
      case i[1]
      when BETTER
        if im[0] == NEWIMG
          regist_newimg(im)
        else
          #puts "KEEP DB: #{im[1]}"
        end
      when WORSE
        discard_img(im)
      when HOLD
        hold_img(im)
      end
    end
  end
end

def main
  init
  db_open($TANKDIR)

  read_tank
  read_files

  classify_img
  update_img
end

main

