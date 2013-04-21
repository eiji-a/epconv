#!/usr/bin/ruby
#

require 'digest/sha1'

PREFIX = 'eaepc-'
EXT = '.jpg'

def init()
  if ARGV.size != 1
    STDERR.puts "Usage: epconv.rb <target dir>"
    exit(1)
  end
  $TARGETDIR = ARGV[0]
  $DIGEST = Digest::SHA1.new
end

def main() 
  init
  Dir.glob($TARGETDIR + '*' + EXT) do |jp|
    bn = File.basename(jp, EXT)
    next if bn =~ /^#{PREFIX}/
    hashsrc = bn + File.size(jp).to_s +
      File.ctime(jp).to_s + Time.now.to_s
    fname = $TARGETDIR + PREFIX + $DIGEST.update(hashsrc).to_s + EXT
    if File.exist?(fname)
      STDERR.puts "ERR: #{fname} is already exist."
    else
      puts "S:#{jp}"
      puts "D:#{fname}"
      File.rename(jp, fname)
    end
  end
end

main
