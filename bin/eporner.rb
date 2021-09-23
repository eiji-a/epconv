#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eponer.rb <loadedlist>'
URLS = ['https://www.eporner.com/pics/',

       ]
CLASS_LIST = 'div#container'
#CLASS_IMG  = 'ul.gallery-b'
CLASS_IMG  = 'div#gridphoto'
CLASS_IMGURL  = 'gallery-'
MAXBABES = 100
MAXLEVEL = 2
NOPAGE = 404
OKPAGE = 0
MINLEN = 1000

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
  puts "imgurl=#{imgurl}"
  begin
    img = open(imgurl, "Referer" => referer) do |i|
      i.read
    end
    filename = imgurl.split('/')[-1]
    #puts "FILE:#{base}#{filename} / SIZE: #{img.size}"
    File.open("#{base}#{filename}", "w") do |fp|
      fp.write(img)
    end

    rs = `identify -format \"%w,%h\" #{base}#{filename}`.split(",")
    if rs[0].to_i < MINLEN || rs[1].to_i < MINLEN
      File.delete("#{base}#{filename}")
    end

  rescue
    #puts "IMG: #{imgurl} can't be loaded."
  end
end

def loaded(url, tf = true)
  #STDERR.puts "LOADED:#{url}"
  @loaded[url] = true
  File.open(@loadedfile, 'a') do |fp|
    fp.puts url
  end
  @nbabes += 1 if tf == true
end

def load_page2(url)
  #puts "LP2:#{url}"
  return if @nbabes > MAXBABES
  if @loaded[url] == true
    STDERR.puts "ALREADY LOADED: #{url}"
    return
  end
  #puts "URL(#{@nbabes}):#{url}"
  base = Time.now.strftime("%Y%m%d%H%M%S-")
  charset = nil
  return if url == nil
  #puts "OK:#{CLASS_IMG}"
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, charset)
  images = doc.css(CLASS_IMG)
  #images = doc.xpath("//ul[contains(@class, '#{CLASS_IMG}')]")
  #puts "IMG:#{images}"
  images.children.each do |ev|
    ev.children.each do |ev2|
      get_image(ev2['href'], url, base)
    end
  end
  loaded(url, false)
end


def load_page(url, lv)
  #puts "LP(#{lv}):#{url}"
  return if lv > MAXLEVEL
  #puts "LV=OK"
  return if url == '' || url == nil
  #puts "URL=OK"
  return if @nbabes > MAXBABES
  #puts "NBABES=OK"
  return if url =~ /\/video\//
  if @loaded[url] == true
    #STDERR.puts "ALREADY LOADED: #{url}"
    return
  end
  #puts "UNLOADED"
  #puts "URL(#{@nbabes}):#{url}"
  base = Time.now.strftime("%Y%m%d%H%M%S-")
  charset = nil
  return if url == nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, charset)

  images = doc.css(CLASS_IMG)
  #images = doc.xpath("//ul[contains(@class, '#{CLASS_IMG}')]")
  #puts "IMG:#{images}"
  images.children.each do |ev|
    #ev.children.each do |ev2|
      href = ev['href']
      next if href == nil
      if href =~ /jpg$/
        get_image(href, url, base)
      end
    #end
  end
  if images.children.size > 0
    puts "URL(#{@nbabes}):#{url}"
    loaded(url)
  end

=begin
  images = doc.xpath("//ul[contains(@class, '#{CLASS_IMGURL}')]")
  #puts "IMG:#{images}"
  images.children.each do |ev|
    #puts "EV-a(#{lv}):#{ev}"
    ev.children.each do |ev2|
      load_page(ev2['href'], lv + 1) if lv <= MAXLEVEL
    end
  end

  images = doc.css(CLASS_LIST)
  #puts "IMG:#{images}"
  images.children.each do |ev|
    #puts "EV-b(#{lv}):#{ev}"
    ev.children.each do |ev2|
      #puts "EV2-b(#{lv}):#{ev2}"
      #puts "EV2-b(#{lv})-HREF:#{ev2['href']}"
      load_page(ev2['href'], lv + 1) if lv <= MAXLEVEL
    end
  end
=end

end

def load_site(url)
  #puts "LS:#{url}"
  return if @nbabes > MAXBABES
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
  url =~ /^(https\:\/\/.+?)\//
  url2 = $1
  gallery = doc.css(CLASS_LIST)
  gallery.children.each do |ev|
    #puts "LINE:#{ev['href']}"
    ev.children.each do |ev2|
      next if ev2['href'] == nil
      #puts "HREF=#{url2 + ev2['href']}"
      load_page(url2 + ev2['href'], 1)
    end
  end
  return OKPAGE
end


def main
  init
  URLS.shuffle.each_with_index do |u, i|
    puts "SITE(#{i+1}/#{URLS.size}): #{u}"
    1.step do |i|
      return if @nbabes > MAXBABES
      u2 = if i == 1 then u else u + "#{i}/" end
      rc = load_site(u2)
      break if rc == NOPAGE
    end
  end
end

main
