#!/usr/bin/ruby
#
# format: id|hash(384chars)

def avg(id, pixels, fname)
  r = g = b = 0.0
  pixels.each do |p|
    r += p[0].to_f
    g += p[1].to_f
    b += p[2].to_f
  end
  puts "(#{id}, (#{r/pixels.size},#{g/pixels.size},#{b/pixels.size}),\"#{fname}\")"
end

pixels = nil
STDIN.each do |l|
  /^(\d+)\|(.+)\|(.+)$/ =~ l.chomp
  id = $1.to_i
  pixels = [$2].pack("H*").unpack("C*").each_slice(3).to_a
  fname = $3
  #hash = ["c8e927"].pack("H*")
  #hash = $2.slice(/(..)/).to_i(16)
  avg(id, pixels, fname)
end
