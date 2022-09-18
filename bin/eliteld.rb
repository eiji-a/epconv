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
URL1 = ['https://www.elitebabes.com/model/', :paging, ['ul.gallery-a.b'], 'ul.list-gallery.a.css']
URL2 = ['https://www.jperotica.com/model/', :paging, ['ul.gallery-a.b'], 'ul.list-gallery.a.css']
MODELS = [
  # URL: https://www.jperotica.com/top-rated-models/
  # URL: https://www.elitebabes.com/top-rated-babes/
  'abigail-b',
  'addie',
  'adeline',
  'adriana-f',
  'adrijana',
  'agatha-2',
  'ai-sayama',
  'ai-takeuti',
  'ai-uehara',
  'aida-e',
  'aika-yumeno',
  'aislin',
  'akari-hoshino',
  'akiho-yoshizawa',
  'alexandra-d',
  'ali-rose',
  'alice-kelly',
  'alisa-i',
  'alyssa-a',
  'alyx-star',
  'amber-sym',
  'amberleigh-west-nude',
  'ami-ayukawa',
  'an-arisawa',
  'an-naba',
  'anastasiia-2',
  'anastasya',
  'anatali-a',
  'angel-f',
  'angel-youngs',
  'angelina-ash-2',
  'angely-grace',
  'anita-c',
  'anna-aj',
  'anna-tatu',
  'anri-okita',
  'anri-sugihara',
  'aria-sky',
  'arianna',
  'ariel-a',
  'arina-c',
  'arisa-kuroki',
  'ashley',
  'astrid-2',
  'asuwakana-kirara',
  'avery',
  'aya-beshen',
  'aya-hirai',
  'ayami-shunbun',
  'ayami-shunka',
  'ayumi-kinoshita',
  'azumi-harusaki',
  'azumi-kinoshita',
  'azusa-nagasawa',
  'bailey-rayne',
  'belka',
  'berylq',
  'blake-blossom',
  'bianca-y',
  'calypso',
  'candice-b',
  'cara-mell',
  'cara-rose',
  'caramel',
  'carisha',
  'caitlin-mcswain',
  'chanel-fenn',
  'charlene-a',
  'charlize',
  'china-matsuoka',
  'chloe-d-2',
  'cikita-a',
  'cleo-marie',
  'connie-carter',
  'corinna',
  'dakota-a',
  'dakota-pink',
  'danae-a',
  'daniel-sea',
  'danniela',
  'darisha',
  'darsi-a',
  'debora-a',
  'delilah-g',
  'delina-g',
  'diana-jam',
  'dillion-harper',
  'dina-divine',
  'dionisia',
  'dita-v',
  'eden-arya',
  'ela',
  'elizabeth-marxs',
  'elle-mira',
  'elle-tan',
  'emerald-ocean',
  'emi-harukaze',
  'emma-mae',
  'estelle-a',
  'eufrat-a',
  'eugenia-diordiychuk',
  'eve-sweet',
  'evita-lima',
  'fabiana',
  'first-meisha',
  'flavia-a',
  'gabbie-carter',
  'gala',
  'genesys',
  'georgia',
  'geraldine',
  'gillian-barnes',
  'gina-3',
  'giulia-wylde',
  'gisella',
  'gloria-sol',
  'goldie-4',
  'grace-c',
  'gyana-a',
  'hailey',
  'hara-saori',
  'hazel-moora',
  'haily-sanders',
  'hana-haruna',
  'hanano-nono',
  'hannah-5',
  'hara-saori',
  'haruka-sanada',
  'hayden-winters',
  'hayley-marie',
  'hazel-moore',
  'heather-2',
  'hibiki-otsuki',
  'hikari-hino',
  'hilary-c',
  'hinme-minori',
  'holly-haim',
  'holly-peers',
  'hopelesssofrantic',
  'indiana-a',
  'innes-a',
  'irina-j',
  'isabele',
  'izabel-a',
  'izabella',
  'isabella-d',
  'iva-4',
  'jackie-b',
  'jeff-milton',
  'jessica-kizaki',
  'josephine-2',
  'julia',
  'julia-aa',
  'julia-k',
  'jun-seto',
  'kaede-matshushima',
  'kaera-uehara',
  'kana-tsuruta',
  'kanon-ohzora',
  'katarina-meis',
  'katya-enokaeva',
  'kay-j',
  'kayla-coyote',
  'kaylee-a',
  'kazuki-asou',
  'kendra-sunderland', # page 5 20220918
  'kenze-thomas',
  'kiki-cash',
  'kinky',
  'kira-w',
  'kirara-asuka',
  'kizuna-sakura',
  'koharu-suzuki',
  'kokomi-naruse',
  'kokomi-sakura',
  'konatsu-aozora',
  'kotono',
  'kristel-a',
  'kylie-page',
  'kyoko-nakajima',
  'lady-jay',
  'lainet',
  'lana-lane',
  'lana-rhoades',
  'lara-maiser',
  'leanna-decker',
  'libby',
  'lija',
  'lil-pie',
  'lilit-a',
  'lily-c',
  'lily-ivy',
  'liz-ashley',
  'lola-marron',
  'love-saotome',
  'luce-a',
  'luda',
  'lulya',
  'madoka-ozawa',
  'mai-hanano',
  'mai-haruna',
  'mai-nadasaka',
  'maiko-kazano',
  'makoto-okunaka',
  'makoto-sakura',
  'mana-sakura',
  'mandy-tee',
  'marciana',
  'mari-misaki',
  'maria-ozawa',
  'maria-takagi',
  'marianna-merkulova',
  'marina-shiraishi',
  'marina-visconti',
  'mariposa',
  'marit',
  'marryk',
  'marta-e',
  'martina-mink',
  'martisha',
  'marryk',
  'mayu-nozomi',
  'meaghan-stanfill',
  'megu-fujiura',
  'megumi-haruka',
  'meguru',
  'mei-matsumoto',
  'mia-valentine',
  'mie-matsuoka',
  'miela-a',
  'mika-kayama',
  'mila-azul',
  'mila-h',
  'mila-m',
  'milana-4',
  'milena-d',
  'minami-aikaw',
  'minami-kojima',
  'minori-hatsune',
  'mio-komori',
  'mirelle-a',
  'misa-kikouden',
  'monika-3',
  'muriel',
  'muse',
  'nadya-nabakova',
  'naho-hazuki',
  'nami-ogawa',
  'namie-koshino',
  'nana-aoyama',
  'nana-ogura',
  'nanako-mori',
  'nancy-a',
  'nao-yoshizaki',
  'naruse-yumi',
  'nasita-a',
  'nastasy',
  'natalie-3',
  'natsumi-mitsu', 
  'nene-ogawa',
  'niemira-a',
  'night-a',
  'nika-7',
  'nikia-a',
  'nina-james',
  'nina-north',
  'noa-aoki',
  'noora',
  'nozomi-aso',
  'olga-alberti',
  'ora-young',
  'oxana-chic',
  'paloma-b',
  'pammie-lee',
  'penelope-b',
  'penelope-kay',
  'polly-pure',
  'precious-a',
  'regina-5',
  'reliee-marks',
  'remi',
  'reon-kosaka',
  'rhian-sugden-nude',
  'rika-aiuchi',
  'rika-kijima',
  'riku-minato',
  'riley-anne',
  'rimi-mayumi',
  'rin-suzuka',
  'rinna-2',
  'rio-hamasaki',
  'risa-kasumi',
  'risa-misaki',
  'rosalina-2',
  'ryo-uehara',
  'rua-mochiduki',
  'ruka-kanae',
  'ruru-anoa',
  'ruth-2',
  'sakura-kokomi',
  'sakura-mana',
  'sakura-shiratori',
  'samadhi-amour',
  'saloma',
  'samara',
  'sanija',
  'sanita',
  'saori-hara',
  'sarah-joy',
  'sarika',
  'sasa-handa',
  'sato-haruki',
  'sayuki-kanno',
  'scarlet',
  'serena-wood',
  'shaky',
  'shania-a',
  'shay-laren',
  'sheela-a',
  'sherice',
  'shiori-kamisaki',
  'shiraishi-mariana-2',
  'shizuku-natsukawa',
  'siena',
  'sienna',
  'sierra-2',
  'simon',
  'skye-blue',
  'sofi-a',
  'sofie',
  'sojie',
  'soloan-kendricks',
  'sonya-blaze',
  'sophie-4',
  'sora-aoi',
  'stacy-cruz',
  'stasey',
  'stella-cox',
  'sumire',
  'sumire-aida',
  'sunshine-a',
  'suok',
  'susann',
  'suzuka-ishikawa',
  'sybil-a',
  'takako-kitahara',
  'takane-hirayama',
  'terry',
  'theodora',
  'tianhai-tsubasa',
  'tsubasa-aizawa',
  'tsubasa-amami',
  'valentine-a',
  'valeria-c',
  'velana',
  'vera',
  'verona',
  'veronika-3',
  'vika-c',
  'victoria-garin',
  'vila-a',
  'viola-o',
  'violla-a',
  'yasakazaki-jessica-2',
  'yelena',
  'yosakazaki-jessica',
  'yoshikazu-jessica',
  'yua-aida',
  'yui-aoyama',
  'yui-hatano',
  'yuka-hata',
  'yuki',
  'yuma-asami',
  'yumi-aida',
  'yuuko-shiraki', # page 5 20220918
  'zelda-b',
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

def url2page(url)
  url =~ /^https:\/\/.*(\/.+\/)$/
  $1
end

def get_loadedlist(lf)
  ll = Hash.new
  File.open(lf, 'r') do |fp|
    fp.each do |l|
      ll[url2page(l.chomp)] = true
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
  @loaded[url2page(url)] = true
  File.open(@loadedfile, 'a') do |fp|
    fp.puts url
  end
  @nbabes += 1 if tf == true
end

def load_page2(url)
  #puts "LP2:#{url}"
  return if @nbabes > MAXBABES
  if @loaded[url2page(url)] == true
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
  if @loaded[url2page(url)] == true
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
    break if @nbabes > MAXBABES
    puts "MODEL(#{i+1}/#{MODELS.size}): #{u}"
    url = "#{URL1[0]}#{u}/"
    rc = load_site(url, URL1[2], URL1[3], URL1[1], 1)
    STDERR.puts "Not Found: model #{u}: #{URL1[0]}#{u}" if rc == NOPAGE
    url = "#{URL2[0]}#{u}/"
    rc = load_site(url, URL2[2], URL2[3], URL2[1], 1)
    STDERR.puts "Not Found: model #{u}: #{URL2[0]}#{u}" if rc == NOPAGE
  end

end

main
