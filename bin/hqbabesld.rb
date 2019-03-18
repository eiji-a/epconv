#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eliteld.rb <loadedlist>'
HQURL = 'https://www.hqbabes.com/'
URLS = ['https://www.hqbabes.com/sponsors/abbyleebrazil.com/',
        'https://www.hqbabes.com/sponsors/alisonangel.com/',
        'https://www.hqbabes.com/sponsors/amourangels.com/',
        'https://www.hqbabes.com/sponsors/anastasia-harris.com/',
        'https://www.hqbabes.com/sponsors/art-lingerie.com/',
        'https://www.hqbabes.com/sponsors/autumnriley.com/',
        'https://www.hqbabes.com/sponsors/averotica.com/',
        'https://www.hqbabes.com/sponsors/bellaquinn.com/',
        'https://www.hqbabes.com/sponsors/best-ladies.com/',
        'https://www.hqbabes.com/sponsors/bikiniriot.com/',
        'https://www.hqbabes.com/sponsors/bodyinmind.com/',
        'https://www.hqbabes.com/sponsors/breath-takers.com/',
        'https://www.hqbabes.com/sponsors/brettrossi.com/',
        'https://www.hqbabes.com/sponsors/brianaleecams.com/',
        'https://www.hqbabes.com/sponsors/britneyamber.com/',
        'https://www.hqbabes.com/sponsors/brookesplayhouse.com/',
        'https://www.hqbabes.com/sponsors/candicebrielle.com/',
        'https://www.hqbabes.com/sponsors/candymoune.com/',
        'https://www.hqbabes.com/sponsors/carlotta-champagne.com/',
        'https://www.hqbabes.com/sponsors/charley-s.com/',
        'https://www.hqbabes.com/sponsors/cosmid.net/',
        'https://www.hqbabes.com/sponsors/devineones.com/',
        'https://www.hqbabes.com/sponsors/digitaldesire.com/',
        'https://www.hqbabes.com/sponsors/dillionharperexclusive.com/',
        

        'https://www.hqbabes.com/sponsors/queenkira.com/',
        'https://www.hqbabes.com/sponsors/emeliapaige.com/',
        'https://www.hqbabes.com/sponsors/tahliaparis.com/',
        'https://www.hqbabes.com/sponsors/socialglamour.com/',
        'https://www.hqbabes.com/sponsors/sophiawinters.com/',
        'https://www.hqbabes.com/sponsors/rachelerichey.com/',
        'https://www.hqbabes.com/sponsors/sarah-mcdonald.com/',
        'https://www.hqbabes.com/sponsors/photodromm.com/',
        'https://www.hqbabes.com/sponsors/pinupfiles.com/',
        'https://www.hqbabes.com/sponsors/playboy.com/',
        'https://www.hqbabes.com/sponsors/playboyplus.com/',
        'https://www.hqbabes.com/sponsors/psychohenessy.com/',
        'https://www.hqbabes.com/sponsors/puremature.com/',
       ]

CLASS_LIST = 'ul.set'
CLASS_IMG  = 'ul.set'
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
  #puts "IMG: #{imgurl}"
  img = open(imgurl) do |i|
    i.read
  end
  filename = imgurl.split('/')[-1]
  #puts "FILE:#{base}#{filename} / SIZE: #{img.size}"
  File.open("#{base}#{filename}", "w") do |fp|
    fp.write(img)
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
    ev.children.each do |ev2|
      img = ev2['href']
      next if img !~ /jpg$/
      img = 'https:' + img
      get_image(img, url, base)
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
  #puts html
  doc = Nokogiri::HTML.parse(html, nil, charset)
  return NOPAGE if doc.title =~ /^404 at/
  gallery = doc.css(CLASS_LIST)
  gallery.children.each do |ev|
    #puts "EV:#{ev.children.to_s}"
    /\/b><a href=\"(.+)"><img/ =~ ev.children.to_s
    #puts "HREF:#{$1.class}"
    if $1 != nil
      url = HQURL + $1
      load_page(url)
    end
  end
  return OKPAGE
end

def main
  init
  URLS.each_with_index do |u, i|
    puts "SITE(#{i+1}/#{URLS.size}): #{u}"
    1.step do |i|
      return if @nbabes >= MAXBABES
      rc = load_site(u + "page_#{i}/")
      break if rc == NOPAGE
    end
  end
end

main
