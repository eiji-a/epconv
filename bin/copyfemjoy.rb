#!/usr/bin/ruby
#
#

require 'fileutils'

if ARGV.size != 1 || File.directory?(ARGV[0]) == false
  STDERR.puts "Usage: copyfemjoy.rb <targetdir>"
  exit 1
end

p = File.basename(Dir.pwd)
/^(.+)-\d\d$/ =~ p
cvdir = "#{$1} covers"

Dir.glob("*.zip") do |d|
  fn = File.basename(d)
  bn = File.basename(fn, '.zip')
  puts "Z: #{fn}"
  system "unzip \"#{fn}\" -d \"#{ARGV[0]}/#{bn}\" >& /dev/null"
  cvjpg = "../#{cvdir}/#{bn}.jpg"
  if File.exist?(cvjpg)
    FileUtils.copy(cvjpg, "#{ARGV[0]}/#{bn}/cover.jpg")
  end
end

