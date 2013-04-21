#!/usr/bin/ruby
#
#

require 'digest/md5'

def init
  if ARGV.size < 1
    STDERR.puts "Usage: findsame.rb <dir> [<dir> [<dir> ...]]"
    exit 1
  end
  $DIRS = ARGV
end

def get_files
  list = Hash.new
  #Dir.foreach($DIR) do |file|
  $DIRS.each do |d|
    Dir.glob(d + "/*.jpg") do |file|
      sz = File.size?(file)
      list[sz] = Array.new if list[sz] == nil
      list[sz] << file
    end
  end
  list
end

def md5sum(f)
  md5 = Digest::MD5.new
  md5.hexdigest(File.open(f).read)
end

def check_diff(list)
  list.each do |k, v|
    next if v.size <= 1
    md5 = Hash.new
    v.each do |f|
      h = md5sum(f)
      if md5[h] == nil
        md5[h] = f
      else
        puts "SAME! #{f} -> #{md5[h]}"
        bn = File.basename(f)
        pt = File.dirname(f)
        File.rename(f, pt + "/delete-" + bn)
      end
    end
  end
end

def main()
  init
  list = get_files
  check_diff list
end

main
