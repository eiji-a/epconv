#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#

require 'fileutils'

EXT = '.jpg'

def init
  if ARGV.size < 1 || ARGV.size > 2
    STDERR.puts "Usage: samerecov.rb <src> [<dst>]"
    exit 1
  end
  $SRC = ARGV.shift
  $DST = if ARGV.size > 0 then ARGV.shift else $SRC end
  puts "SRC:#{$SRC}, DST:#{$DST}"
end

def move(file)
  bn = File.basename(file)
  pt = File.dirname(file)
  nn = bn.scan(/^same.*?-(.*)$/x)
  puts nn[0][0]
  puts $DST
  FileUtils.mv(pt + '/' + bn, $DST + '/' + nn[0][0])
end

def main
  init
  Dir.glob($SRC + '/same*' + EXT) do |f|
    move(f)
  end
end

main
