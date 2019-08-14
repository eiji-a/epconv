#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eliteld.rb <loadedlist>'
UAGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15"
HQURL = 'https://www.hqbabes.com/'
URLS = [
  #'http://bakufu.jp/archives/category/%E3%81%8A%E5%B0%BB',
  #'http://bakufu.jp/',
  #'http://bakufu.jp/archives/date/2019/03',
  'http://bakufu.jp/archives/category/%e3%81%8a%e3%81%a3%e3%81%b1%e3%81%84',
       ]


CLASS_LIST = 'div#content'
CLASS_IMG  = 'div.entry-content'
MAXBABES = 10
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
    img = open(imgurl) do |i|
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
  #puts "IMG:#{images}"
  images.children.each do |ev|
    img = ev['href']
    next if img !~ /jpg$/
    get_image(img, url, base)
  end
  #loaded(url)
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
  #puts html
  doc = Nokogiri::HTML.parse(html, nil, charset)
  return NOPAGE if doc.title =~ /^404 at/
  #gallery = doc.css(CLASS_LIST)
  #puts "DOC:#{gallery}"
  #gallery.children.each do |ev|
  #  ev.children.each do |ev2|
  #    puts "EV2:#{ev2['header']}"
  #  end
    #puts "EV:#{ev['article']}"
#    /\/b><a href=\"(.+)"><img/ =~ ev.children.to_s
    #puts "HREF:#{$1.class}"
#    if $1 != nil
#      url = HQURL + $1
#      load_page(url)
#    end
  #end
  doc.xpath('//h1[@class="entry-title"]').each do |at|
    #p at
    load_page(at.children.css('a').attribute('href'))
    #p "L:#{at.children.css('a').inner_text}"
  end

  return OKPAGE
end

def main
  init
  URLS.shuffle.each_with_index do |u, i|
    puts "SITE(#{i+1}/#{URLS.size}): #{u}"
    1.step do |i|
      return if @nbabes >= MAXBABES
      rc = load_site(u + "page/#{i}")
      break if rc == NOPAGE
    end
  end
end

main
