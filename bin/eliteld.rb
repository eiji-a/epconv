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
        'https://www.elitebabes.com/latest-erotic-beauty/',
        'https://www.elitebabes.com/latest-errotica-archives/',
        'https://www.elitebabes.com/latest-eternal-desire/',
        'https://www.elitebabes.com/latest-femjoy/',
        'https://www.elitebabes.com/latest-ferr-art/',



        'https://www.elitebabes.com/latest-fitting-room/',
        'https://www.elitebabes.com/latest-ftv-girls/',
        'https://www.elitebabes.com/latest-goddess-nudes/',
        'https://www.elitebabes.com/latest-hegre-art/',
        'https://www.elitebabes.com/latest-holly-randall/',
        'https://www.elitebabes.com/latest-joymii/',
        'https://www.elitebabes.com/latest-mc-nudes/',
        'https://www.elitebabes.com/latest-met-art/',
        'https://www.elitebabes.com/latest-metart-x/',
        'https://www.elitebabes.com/latest-milena-angel/',
        'https://www.elitebabes.com/latest-morey-studio/',
        'https://www.elitebabes.com/latest-mpl-studios/',
        'https://www.elitebabes.com/latest-nakety/',
        'https://www.elitebabes.com/latest-nubiles/',
        'https://www.elitebabes.com/latest-penthouse/',
        'https://www.elitebabes.com/latest-photodromm/',
        'https://www.elitebabes.com/latest-pinup-files/',
        'https://www.elitebabes.com/latest-playboy/',
        'https://www.elitebabes.com/latest-rylsky-art/',
        'https://www.elitebabes.com/latest-sex-art/',
        'https://www.elitebabes.com/latest-showy-beauty/',
        'https://www.elitebabes.com/latest-skokoff/',
        'https://www.elitebabes.com/latest-stasyq/',
        'https://www.elitebabes.com/latest-stunning-18/',
        'https://www.elitebabes.com/latest-teen-dreams/',
        'https://www.elitebabes.com/latest-the-emily-bloom/',
        #'https://www.elitebabes.com/latest-the-life-erotic/',
        'https://www.elitebabes.com/latest-this-years-model/',
        'https://www.elitebabes.com/latest-viv-thomas/',
        'https://www.elitebabes.com/latest-watch-4-beauty/',
        'https://www.elitebabes.com/latest-wow-girls/',
        'https://www.elitebabes.com/latest-wow-porn/',
        'https://www.elitebabes.com/latest-x-art/',
        'https://www.elitebabes.com/latest-yonitale/',
        'https://www.elitebabes.com/latest-zemani/',
        'https://www.elitebabes.com/latest-zishy/',
        #'https://www.jperotica.com/',
        'https://www.jpbeauties.com/',
        'https://www.gravurehunter.com/',
        'https://www.mplhunter.com/',

       ]
CLASS_LIST = 'ul.gallery-a'
#CLASS_IMG  = 'ul.gallery-b'
CLASS_IMG  = 'ul.list-justified2'
CLASS_IMGURL  = 'gallery-'
MAXBABES = 100
MAXLEVEL = 2
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
  #puts "imgurl=#{imgurl}"
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
    ev.children.each do |ev2|
      get_image(ev2['href'], url, base)
    end
  end
  if images.children.size > 0
    puts "URL(#{@nbabes}):#{url}"
    loaded(url)
  end

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
  gallery = doc.css(CLASS_LIST)
  gallery.children.each do |ev|
    #puts "LINE:#{ev['href']}"
    ev.children.each do |ev2|
      load_page(ev2['href'], 1)
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
      rc = load_site(u + "page/#{i}/")
      break if rc == NOPAGE
    end
  end
end

main
