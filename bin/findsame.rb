#!/usr/bin/ruby
#
#

require 'digest/md5'
require 'fileutils'

CONVERT = 'convert -resize'
OPT2 = '+level 0,7 -level 0,7'
RESO1 = 4
RESO2 = 16
RATIO = 10.0 / 100 # parcentage of difference
TMPDIR = '/var/tmp/.epconv.cache'

def init
  if ARGV.size < 2
    STDERR.puts "Usage: findsame.rb <dir> [<dir> [<dir> ...]]"
    exit 1
  end
  $DIRS = ARGV
  $KEY = 1
  if !File.exist?(TMPDIR)
    FileUtils.mkdir(TMPDIR)
  end
end

def calc_characteristic(f, sz)
  bytes = sz * sz * 3
  `#{CONVERT} #{sz}x#{sz}! #{f} #{OPT2} PPM:- | tail -c #{bytes}`
end

def get_characteristic(f, sz)
  chara = ''
  if sz == RESO1
    cache = TMPDIR + '/' + File.basename(f)
    if File.exist?(cache)
      File.open(cache, 'r') do |fp|
        chara = fp.read      
      end
    else
      chara = calc_characteristic(f, sz)
      File.open(cache, 'w') do |fp|
        fp.print chara
      end
    end
  else
    chara = calc_characteristic(f, sz)
  end
  chara
end

def get_files
  list = Hash.new
  #Dir.foreach($DIR) do |file|
  $DIRS.each do |d|
    puts "=== DIR: #{d}"
    Dir.glob(d + "/*.jpg") do |file|
      #sz = File.size?(file)
      cv = get_characteristic(file, RESO1)
      list[cv] = Array.new if list[cv] == nil
      list[cv] << file
    end
  end
  list
end

def operation1(f1, f2)
  puts "SAME! #{f2} -> #{f1}"
  bn = File.basename(f2)
  pt = File.dirname(f2)
  FileUtils.mv(f2, pt + "/delete-" + bn)
end

def operation2(f1, f2)
  puts "SAME? #{f2} -> #{f1}"
  key = sprintf("%04d", $KEY)
  bn1 = File.basename(f1)
  pt1 = File.dirname(f1)
  FileUtils.mv(f1, pt1 + "/same?#{key}-" + bn1) if File.exist?(f1)
  bn2 = File.basename(f2)
  pt2 = File.dirname(f2)
  #FileUtils.mv(f2, pt2 + "/same?#{key}-" + bn2) if File.exist?(f2)
  FileUtils.mv(f2, pt1 + "/same?#{key}-" + bn2) if File.exist?(f2)
  if File.exist?(TMPDIR + '/' + bn1)
    FileUtils.mv(TMPDIR + '/' + bn1, TMPDIR + "/same?#{key}-" + bn1)
  end
  if File.exist?(TMPDIR + '/' + bn2)
    FileUtils.mv(TMPDIR + '/' + bn2, TMPDIR + "/same?#{key}-" + bn2)
  end
end

def comp_hash(files)
  hs = Hash.new
  files.each do |f|
    md5 = Digest::MD5.new
    h = md5.hexdigest(File.open(f).read)
    if hs[h] == nil
      hs[h] = f
    else
      operation1(hs[h], f)
    end
  end
end

def near(cv1, cv2)
  diff = 0
  cv1.size.times do |i|
    diff += 1 if cv1[i] != cv2[i]
  end
  diff <= (RESO2 * RESO2 * 3 * RATIO).truncate
end

def comp_characteristic(files)
  ar = Array.new
  files.each do |f|
    cv = calc_characteristic(f, RESO2)
    ar << [f, cv.unpack("C*")]
  end
  ar.size.times do |i|
    (i + 1).upto(ar.size - 1) do |j|
      operation2(ar[i][0], ar[j][0]) if near(ar[i][1], ar[j][1])
    end
  end
  $KEY += 1
end

def check_diff(list)
  list.each do |k, v|
    next if v.size <= 1
    comp_characteristic(v)
  end
end

def main()
  init
  puts "GET FILES..."
  list = get_files
  puts "CHECK DIFF..."
  check_diff list
end

main
