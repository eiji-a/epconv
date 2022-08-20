#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eliteld.rb <loadedlist>'
URLS = [
=begin
        'https://www.elitebabes.com/latest-alex-lynn/',
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

        # OK list (2022/08/16)
        'https://www.elitebabes.com/latest-pinup-files/'
        https://www.elitebabes.com/met-art/
        https://www.elitebabes.com/latest-femjoy/
        https://www.elitebabes.com/latest-mpl-studios/
        https://www.elitebabes.com/latest-playboy/
        https://www.elitebabes.com/latest-hegre-art/
        https://www.elitebabes.com/latest-rylsky-art/
        https://www.elitebabes.com/latest-penthouse/
        https://www.elitebabes.com/latest-sex-art/
        https://www.elitebabes.com/latest-photodromm/
        https://www.elitebabes.com/latest-errotica-archives/
        https://www.elitebabes.com/latest-domai/
        https://www.elitebabes.com/latest-erotic-beauty/
        https://www.elitebabes.com/latest-stunning-18/
        https://www.elitebabes.com/latest-goddess-nudes/
        https://www.elitebabes.com/latest-zemani/
        https://www.elitebabes.com/eternal-desire/
        https://www.elitebabes.com/ftv-girls/
        https://www.elitebabes.com/teen-dreams/
        https://www.elitebabes.com/the-emily-bloom/
        https://www.elitebabes.com/body-in-mind/
        https://www.elitebabes.com/holly-randall/
        https://www.elitebabes.com/milena-angel/
        https://www.elitebabes.com/fame-girls/
        https://www.elitebabes.com/nubile-films/
        https://www.elitebabes.com/nakety/
        https://www.elitebabes.com/test-shoots/
        https://www.elitebabes.com/mc-nudes/
        https://www.elitebabes.com/emily-bloom/

        
        
=end
        #['https://www.jpbeauties.com/', :nopage, ['ul.gallery-a'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/latest-updates/', :paging, ['ul.gallery-a.e'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/most-viewed/sort/alltime/', :nopage, ['ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/top-rated-babes/', :paging, ['ul.gallery-a.a.d', 'ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        ['https://www.elitebabes.com/model/', :paging, ['ul.gallery-a.a.d', 'ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/model-tag/big-boobs/', :paging, ['ul.gallery-a.a.d', 'ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/tag/hairy-pussy/', :paging, ['ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/tag/nipples/', :paging, ['ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/collections/?sort=2940/', :nopage, ['ul.gallery-a'], 'ul.list-gallery.a.css'],
        #['https://www.elitebabes.com/tag/big-areolas/', :paging, ['ul.gallery-a.b'], 'ul.list-gallery.a.css'],
        #['https://www.babehub.com/', :paging, 'ul.gallery-d', 'ul.gallery-e.a'],
       ]
URL = ['https://www.elitebabes.com/model/', :paging, ['ul.gallery-a.b'], 'ul.list-gallery.a.css']
MODELS = [
  'addie',
  'adeline',
  'adriana-f',
  'aida-e',
  'aislin',
  'alisa-i',
  'angely-grace',
  'anita-c',
  'anna-aj',
  'anna-tatu',
  'ariel-a',
  'ashley',
  'avery',
  'aya-beshen',
  'belka',
  'berylq',
  'calypso',
  'candice-b',
  'caramel',
  'carisha',
  'caitlin-mcswain',
  'chanel-fenn',
  'charlene-a',
  'connie-carter',
  'corinna',
  'dakota-pink',
  'daniel-sea',
  'danniela',
  'debora-a',
  'delilah-g',
  'diana-jam',
  'dita-v',
  'eden-arya',
  'elle-mira', # page2 20220819
  'elle-tan',
  'eugenia-diordiychuk',
  'eve-sweet',
  'evita-lima',
  'gabbie-carter',
  'gala',
  'georgia',
  'giulia-wylde',
  'gisella',
  'gloria-sol',
  'grace-c',
  'hazel-moora',
  'haily-sanders',
  'hayden-winters',
  'hilary-c',
  'holly-haim',
  'indiana-a',
  'innes-a',
  'irina-j',
  'izabella',
  'jeff-milton',
  'josephine-2',
  'katya-enokaeva',
  'kay-j',
  'kayla-coyote',
  'kenze-thomas',
  'kiki-cash',
  'kira-w',
  'kylie-page',
  'lady-jay',
  'lana-lane',
  'leanna-decker',
  'libby',
  'lilit-a',
  'lily-c',
  'lily-ivy',
  'luda',
  'lulya',
  'marianna-merkulova',
  'mariposa',
  'marit',
  'marta-e',
  'martina-mink',
  'marryk',
  'mila-azul',
  'mila-h',
  'milana-4',
  'milena-d',
  'monika-3',
  'nancy-a',
  'nastasy',
  'niemira-a',
  'nika-7',
  'nikia-a',
  'olga-alberti',
  'oxana-chic',
  'precious-a',
  'reliee-marks',
  'riley-anne',
  'rinna-2',
  'rosalina-2',  # last 2022-08-19
  'samadhi-amour',
  'saloma',
  'samara',
  'sanija',
  'sarah-joy',
  'scarlet',
  'serena-wood',
  'shania-a',
  'shay-laren',
  'sherice',
  'siena',
  'sienna',
  'simon',
  'skye-blue',
  'sofi-a',
  'sojie',
  'soloan-kendricks',
  'sonya-blaze',
  'sophie-4',
  'stacy-cruz',
  'stella-cox',
  'suok',
  'susann',
  'sybil-a',
  'valeria-c',
  'verona',
  'vika-c',
  'victoria-garin',
  'viola-o',
  'zerra-a',
]
CLASS_LIST = 'ul.gallery-a.e'
#CLASS_IMG  = 'ul.gallery-b'
CLASS_IMG  = 'ul.list-gallery.a.css'
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


def load_page(url, cls, lv)
  return if lv > MAXLEVEL
  #puts "LV=OK"
  return if url == '' || url == nil
  #puts "URL=OK"
  return if @nbabes > MAXBABES
  #puts "NBABES=OK"
  return if url =~ /\/video\//
  if @loaded[url] == true
    STDERR.puts "ALREADY LOADED: #{url}"
    return
  end
  puts "LP(#{lv}):#{url}"
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

  images = doc.css(cls)
  #images = doc.xpath("//ul[contains(@class, '#{CLASS_IMG}')]")
  #puts "IMG:#{images}"
  images.children.each do |ev|
    ev.children.each do |ev2|
      get_image(ev2['href'], url, base)
    end
  end
  if images.children.size > 0
    #puts "URL(#{@nbabes}):#{url}"
    loaded(url)
  end

# NOT RECURSIVE 
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

def load_gallery(doc, cls, img)
  return NOPAGE if cls.size == 0
  gallery = doc.css(cls.shift)
  puts "GAL:#{gallery.to_s.length}"
  return NOPAGE if gallery.to_s.length < 100
  gallery.children.each do |ev|
    if cls.size == 0
      #puts "LINE:#{ev['href']}"
      ev.children.each do |ev2|
        load_page(ev2['href'], img, 1)
      end
    else
      load_gallery(doc, cls)
    end
  end

end

def load_site2(url, cls, img)
  puts "LS:#{url}"
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

  #STDERR.puts "CONTSIZE: #{html.size}"
  doc = Nokogiri::HTML.parse(html, nil, charset)
  return NOPAGE if doc.title =~ /^404 at/

  gallery = doc.css(cls)
  puts "GAL:#{gallery.to_s.length}"
  return NOPAGE if gallery.to_s.length < 100
  gallery.children.each do |ev|
    #puts "LINE:#{ev['href']}"
    ev.children.each do |ev2|
      load_page(ev2['href'], img, 1)
    end
  end
  return OKPAGE
end


def load_site(url, cls, img, paging, pg)
  puts "LS:#{url}"
  page = if pg == 1 then
    ""
  elsif cls.size == 2 then
    "page/#{pg}/"
  else
    "mpage/#{pg}"
  end
  url2 = "#{url}#{page}"
  puts "PAGE:#{url2}"
  puts "==================================================================="
  return if @nbabes > MAXBABES
  charset = nil
  html = nil
  begin
    html = open(url2) do |f|
      charset = f.charset
      f.read
    end
  rescue
    return NOPAGE
  end

  #STDERR.puts "CONTSIZE: #{html.size}"
  doc = Nokogiri::HTML.parse(html, nil, charset)
  return NOPAGE if doc.title =~ /^404 at/
  gallery = doc.css(cls[0])
  puts "GAL:#{gallery.to_s.length}"
  return NOPAGE if gallery.to_s.length < 100
  gallery.children.each do |ev|
    #puts "LINE:#{ev['href']}"
    ev.children.each do |ev2|
      if cls.size > 1
        break if @nbabes > MAXBABES
        load_site(ev2['href'], cls[1..], img, paging, 1)
        sleep rand(5..10) if @nbabes == 0
      else
        load_page(ev2['href'], img, 1)
      end
    end
  end
  if paging == :paging && @nbabes <= MAXBABES
    pg += 1
    load_site(url, cls, img, paging, pg)
  end
  return OKPAGE
end


def main
  init
=begin
  URLS.shuffle.each_with_index do |u, i|
    puts "SITE(#{i+1}/#{URLS.size}): #{u}"
    1.step do |i|
      return if @nbabes > MAXBABES
      #url = u[0] + if u[1] == :paging then "page/#{i}/" else "" end
      url = u[0]
      #rc = load_site(u[0] + "page/#{i}/", u[1], u[2])
      rc = load_site(url, u[2], u[3], u[1], 1)
      break if rc == NOPAGE
    end
  end
=end

  rc = OKPAGE
  MODELS.shuffle.each_with_index do |u, i|
    break if @nbabes > MAXBABES || rc == NOPAGE
    puts "MODEL(#{i+1}/#{MODELS.size}): #{u}"
    url = "#{URL[0]}#{u}/"
    rc = load_site(url, URL[2], URL[3], URL[1], 1)
    STDERR.puts "Not Found: model #{u}" if rc == NOPAGE
  end

end

main
