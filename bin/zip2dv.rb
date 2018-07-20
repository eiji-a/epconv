#!/usr/bin/ruby
#

require 'fileutils'

ARGV.each do |z|
  bname = File.basename(z, ".zip")
  bname2 = bname.gsub(/Met-Art/, "ma")
  FileUtils.mv(z, bname2 + '.dv')
  puts "#{z}/#{bname2}.dv"
end

