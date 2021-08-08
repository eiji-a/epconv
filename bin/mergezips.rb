#!/usr/bin/ruby
#
#
#

require 'yaml'
require 'fileutils'

USAGE = "Usage: mergezips.rb \n" + "  you need 'info.yml' file"
INFOFILE = "info.yml"


def init
  if File.exist?("info.yml") == false
    STDERR.puts USAGE
    exit 1
  end

  @info = YAML.load_file(INFOFILE)
end


def zip_images
  type = if @info["type"] == "comic" then "CM-" else "CG-" end
  zipfile = "../#{type}[#{@info["author"]}]#{@info["title"]}.zip"
  if File.exist?(zipfile) == true
    zipfile = zipfile.gsub(/\.zip/, "-2.zip")
  end
  puts "CN:#{zipfile}"
  images  = "*.jpg *.png"
  system "zip #{zipfile} #{images}"
  zippeddir = "zippeddir"
  if Dir.exist?(zippeddir) == false
    FileUtils.mkdir(zippeddir)
  end
  images.split.each do |im|
    system("mv #{im} #{zippeddir}/")
  end
end

def main
  init

  Dir.glob("*.zip").each do |fn|
    system "unzip #{fn}"
  end

  zip_images
end

main

#--
