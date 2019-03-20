#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eliteld.rb <loadedlist>'
URLS = ['https://www.elitebabes.com/latest-alex-lynn/',
        'https://www.elitebabes.com/latest-all-gravure/',
        'https://www.elitebabes.com/latest-amour-angels/',
        'https://www.elitebabes.com/latest-body-in-mind/',
        'https://www.elitebabes.com/latest-digital-desire/',
        'https://www.elitebabes.com/latest-domai/',


        'https://www.elitebabes.com/latest-mpl-studios/',
        'https://www.elitebabes.com/latest-femjoy/',
        'https://www.elitebabes.com/latest-zishy/',
       ]
CLASS_LIST = 'ul.gallery-a'
CLASS_IMG  = 'ul.gallery-b'
MAXBABES = 100
NOPAGE = 404
OKPAGE = 0

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
  @nbabes = 1
end

def get_image(imgurl, referer, base)
  begin
    img = open(imgurl, "Referer" => referer) do |i|
      i.read
    end
    filename = imgurl.split('/')[-1]
    #puts "FILE:#{base}#{filename} / SIZE: #{img.size}"
    File.open("#{base}#{filename}", "w") do |fp|
      fp.write(img)
    end
  rescue
    puts "IMG: #{imgurl} can't be loaded."
  end
end

def loaded(url)
  File.open(@loadedfile, 'a') do |fp|
    fp.puts url
  end
  @nbabes += 1
end

def load_page(url)
  return if @nbabes > MAXBABES
  return if @loaded[url] == true
  puts "URL(#{@nbabes}):#{url}"
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

def load_site(url)
  return if @nbabes >= MAXBABES
  charset = nil
  html = nil
  begin
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
  rescue
    return NOPAGE
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)
  return NOPAGE if doc.title =~ /^404 at/
  gallery = doc.css(CLASS_LIST)
  gallery.children.each do |ev|
    #puts "LINE:#{ev['href']}"
    ev.children.each do |ev2|
      load_page(ev2['href'])
    end
  end
  return OKPAGE
end


def main
  init
  URLS.shuffle.each_with_index do |u, i|
    puts "SITE(#{i+1}/#{URLS.size}): #{u}"
    1.step do |i|
      return if @nbabes >= MAXBABES
      rc = load_site(u + "page/#{i}/")
      break if rc == NOPAGE
    end
  end
end

main
