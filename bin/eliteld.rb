#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eliteld.rb <loadedlist>'
URL = 'https://www.elitebabes.com/latest-body-in-mind/'
#URL = 'https://www.elitebabes.com/latest-mpl-studios/'
#URL = 'https://www.elitebabes.com/latest-femjoy/'
#URL = 'https://www.elitebabes.com/latest-zishy/'
CLASS_LIST = 'ul.gallery-a'
CLASS_IMG  = 'ul.gallery-b'

def get_loadedlist(lf)
  ll = Hash.new
  File.open(lf, 'r') do |fp|
    fp.each do |l|
      ll[l.chomp] = true
    end
  end
  ll
end

def init
  if ARGV.size != 1
    STDERR.puts USAGE
    exit 1
  end
  
  @loadedfile = ARGV[0]
  @loaded = get_loadedlist(@loadedfile)
end

def get_image(imgurl, referer, base)
  #puts "IMG: #{imgurl}"
  img = open(imgurl, "Referer" => referer) do |i|
    i.read
  end
  filename = imgurl.split('/')[-1]
  puts "FILE:#{base}#{filename} / SIZE: #{img.size}"
  File.open("#{base}#{filename}", "w") do |fp|
    fp.write(img)
  end
end

def loaded(url)
  File.open(@loadedfile, 'a') do |fp|
    fp.puts url
  end
end

def load_page(url)
  return if @loaded[url] == true
  #puts "URL:#{url}"
  base = Time.now.strftime("%Y%m%d%H%M%S-")
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, charset)
  images = doc.css(CLASS_IMG)
  images.children.each do |ev|
    ev.children.each do |ev2|
      get_image(ev2['href'], url, base)
    end
  end
  loaded(url)
end

def main
  init
  charset = nil
  html = open(URL) do |f|
    charset = f.charset
    f.read
  end
  #puts html
  doc = Nokogiri::HTML.parse(html, nil, charset)
  gallery = doc.css(CLASS_LIST)
  gallery.children.each do |ev|
    #puts "LINE:#{ev['href']}"
    ev.children.each do |ev2|
      load_page(ev2['href'])
    end
  end
  #puts gallery

end

main
