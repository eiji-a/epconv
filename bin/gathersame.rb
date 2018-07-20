#!/usr/bin/ruby
#
#

require 'digest/md5'
require 'fileutils'

TMPDIR = '/var/tmp/.epconv.cache'

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

def main()
  $KEY = 1
  STDIN.each do |l|
    /probably same: (.+)\s*$/ =~ l
    f = $1.split(/,\s*/)
    puts f.join(":")
    f.size.times do |i|
      (i + 1).upto(f.size - 1) do |j|
        operation2(f[i], f[j])
      end
    end
    $KEY += 1
  end
end

main
