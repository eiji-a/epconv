#!/usr/bin/ruby

require 'fileutils'

PATTERN = '*.jpg'

def init
  @comics = Hash.new
end

def zip_images(pref)
  pref2 = pref.gsub(/\[/, "\\[").gsub(/\]/, "\\]")
  puts "CN:#{pref2}"
  zipfile = pref2 + ".zip"
  images  = "#{pref2}-*.jpg #{pref2}-*.png"
  zippeddir = "zippedimage"
  system "zip #{zipfile} #{images}"
  if Dir.exist?(zippeddir) == false
    FileUtils.mkdir(zippeddir)
  end
  images.split.each do |im|
    system("mv #{im} #{zippeddir}/")
  end
end

def main
  init

  Dir.glob(PATTERN) do |f|
    #next if f =~ /^\d/
    f =~ /(.+)-\d\d\d\d*.jpg$/
    comname = $1
    next if comname == nil || comname == ''
    if @comics[comname] == nil
      @comics[comname] = 1
    end
  end

  @comics.keys.each do |c|
    puts "#{c}"
    if File.exist?("#{c}.zip") == true
      FileUtils.move("#{c}.zip", "#{c}.zip-bak")
    end
    zip_images(c)
  end
end

main

#
