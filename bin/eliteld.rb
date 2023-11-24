#!/usr/bin/ruby
#

require 'open-uri'
require 'nokogiri'


USAGE = 'Usage: eliteld.rb <loadedlist> [<modelname>]'
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
  # URL: https://www.elitebabes.com/model-tag/big-boobs/ -> - page3
  # URL: https://www.elitebabes.com/top-rated-babes/
  'abigail-b',
  'addie',
  'adelia-b',
  'adeline',
  'adriana-2',
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
  'alissa-arden',
  'alyssa-a',
  'alyx-star',
  'amber-sym',
  'amberleigh-west-nude',
  'ami-ayukawa',
  'an-arisawa',
  'an-naba',
  'ana-cheri-nude',
  'ana-lucia',
  'anastasiia-2',
  'anastasya',
  'anatali-a',
  'angel-a',
  'angel-f',
  'angel-youngs',
  'angelina-ash-2',
  'angely-grace',
  'anita-c',
  'anita-queen',
  'anna-aj',
  'anna-rose-ii',
  'anna-tatu',
  'annie',
  'annis-a',
  'anri-okita',
  'anri-sugihara',
  'antonia',
  'aphina-a',
  'arcadia',
  'aria-sky',
  'arianna',
  'ariel-a',
  'arina-c',
  'arisa-kuroki',
  'arizona-wild',
  'ashley',
  'astrid-2',
  'asuwakana-kirara',
  'aurelia-a',
  'aurelia-lu',
  'avery',
  'aya-beshen',
  'aya-hirai',
  'ayami-shunbun',
  'ayami-shunka',
  'ayumi-kinoshita',
  'azumi-harusaki',
  'azumi-kinoshita',
  'azusa-nagasawa',
  'baiba',
  'bailey-rayne',
  'beba',
  'belka',
  'berylq',
  'blake-blossom',
  'bianca-y',
  'bibi-jones',
  'blake-blossom',
  'caitlin-mcswain',
  'calypso',
  'camilla-stan',
  'candice-b',
  'candice-lauren',
  'candy-d',
  'cara-mell',
  'cara-rose',
  'caramel',
  'carisha',
  'carlotta-champagne',
  'carlye-denise',
  'cassidy-banks',
  'cathy',
  'chanel-fenn',
  'chantel-a',
  'charlene-a',
  'charlize',
  'china-matsuoka',
  'chloe-b',
  'chloe-d-2',
  'cikita-a',
  'clara-2',
  'clary',
  'cleo-marie',
  'clover',
  'connie-carter',
  'corinna',
  'dakota-a',
  'dakota-pink',
  'dakota-rae',
  'dalia-dayze',
  'danae-a',
  'danica',
  'daniel-sea',
  'danniela',
  'darcie-dolce',
  'darerca-a',
  'darisha',
  'darsi-a',
  'davina-p',
  'debora-a',
  'delilah-g',
  'delina-g',
  'delphina',
  'diana-jam',
  'dillion-harper',
  'dina-divine',
  'dionisia',
  'dita-v',
  'dominique-b',
  'dylan-voxe',
  'eden-arya',
  'ela',
  'elizabeth-marxs',
  'elle-mira',
  'elle-tan',
  'ellie-p',
  'emerald-ocean',
  'emi-harukaze',
  'emma-mae',
  'erin-k',
  'estelle-a',
  'eufrat-a',
  'eugenia-diordiychuk',
  'eve-sweet',
  'evita-lima',
  'fabiana',
  'faith',
  'first-meisha',
  'flavia-a',
  'freda',
  'gabbie-carter',
  'gala',
  'genesys',
  'georgia',
  'geraldine',
  'gillian-barnes',
  'gina-3',
  'ginger-jolie',
  'giulia-wylde',
  'gisella',
  'gloria-davis',
  'gloria-sol',
  'goldie-4',
  'grace-c',
  'gyana-a',
  'hailey',
  'haleen',
  'hara-saori',
  'hazel-moora',
  'haily-sanders',
  'hana-haruna',
  'hanano-nono',
  'hannah-5',
  'hara-saori',
  'haruka-sanada',
  'hayden-w',
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
  'iga-a',
  'indiana-a',
  'innes-a',
  'irina-j',
  'irishka-a',
  'isabele',
  'izabel-a',
  'izabella',
  'isabella-d',
  'iva-4',
  'jackie-b',
  'jaclyn-swedberg',
  'jacqueline-a',
  'jade-a',
  'jade-baker',
  'jay-marie',
  'jazlyn-ray',
  'jeff-milton',
  'jelena-jensen',
  'jessica-kizaki',
  'jordana-ryan',
  'josephine',
  'josephine-2',
  'julia',
  'julia-8',
  'julia-aa',
  'julia-k',
  'jun-seto',
  'kaede-matshushima',
  'kaera-uehara',
  'kamilla-j',
  'kana-tsuruta',
  'kanon-ohzora',
  'karina-b',
  'katarina-meis',
  'katie-vernola',
  'katja-b',
  'katy-gold',
  'katya-enokaeva',
  'katya-v',
  'kay-2',
  'kay-j',
  'kayla-coyote',
  'kaylee-a',
  'kazuki-asou',
  'keira-a',
  'keita',
  'kendra-p',
  'kendra-sunderland', # page 5 20220918
  'kenze-thomas',
  'kiere',
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
  'ksenia-wegner',
  'ksucha-c',
  'kylie-page',
  'kyoko-nakajima',
  'lady-jay',
  'lainet',
  'lana-i',
  'lana-lane',
  'lana-rhoades',
  'lara-maiser',
  'laura-christina',
  'laury',
  'leanna-decker',
  'ledona',
  'leona-c',
  'leona-e',
  'libby',
  'lija',
  'lil-pie',
  'lili-5',
  'lilit-a',
  'lillie',
  'lily-c',
  'lily-ivy',
  'liz-ashley',
  'liza-loo',
  'lola-a-2',
  'lola-marron',
  'lolly-gartner',
  'loraine',
  'loren-strawberry',
  'love-saotome',
  'luce-a',
  'lucille-b',
  'luda',
  'lulya',
  'madoka-ozawa',
  'madi-meadows',
  'mai-hanano',
  'mai-haruna',
  'mai-nadasaka',
  'maible',
  'maiko-kazano',
  'makoto-okunaka',
  'makoto-sakura',
  'malena',
  'mana-sakura',
  'mandy-tee',
  'marciana',
  'margaret-a',
  'margarita-b',
  'mari-misaki',
  'maria-antonella',
  'maria-ozawa',
  'maria-takagi',
  'marianna-merkulova',
  'marie-duval',
  'marina-6',
  'marina-shiraishi',
  'marina-visconti',
  'mariposa',
  'marisa-nicole',
  'marit',
  'marjana',
  'marryk',
  'marta-e',
  'martina-mink',
  'martisha',
  'mary-moody',
  'mashenka',
  'maxa-z',
  'maya-c',
  'mayu-nozomi',
  'meaghan-stanfill',
  'megu-fujiura',
  'megumi-haruka',
  'meguru',
  'mei-matsumoto',
  'melisa-c',
  'melissa-lolita',
  'melony-a',
  'mia-valentine',
  'michelle-f',
  'mie-matsuoka',
  'miela-a',
  'mika-kayama',
  'mila-amour',
  'mila-azul',
  'mila-h',
  'mila-m',
  'milana-4',
  'milena-d',
  'milla-d',
  'millis-a',
  'minami-aikaw',
  'minami-kojima',
  'minori-hatsune',
  'mio-komori',
  'mirelle-a',
  'misa-kikouden',
  'misha-d',
  'missa',
  'monika-3',
  'monika-a',
  'mur',
  'muriel',
  'muse',
  'nadin-a',
  'nadya-nabakova',
  'naho-hazuki',
  'nami-ogawa',
  'namie-koshino',
  'nana-aoyama',
  'nana-ogura',
  'nanako-mori',
  'nancy-a',
  'nao-yoshizaki',
  'narkiss',
  'naruse-yumi',
  'nasita-a',
  'nastasy',
  'natalia-e',
  'natalie-3',
  'natsumi-mitsu', 
  'nene-ogawa',
  'niemira-a',
  'night-a',
  'nika-7',
  'nikia-a',
  'nina-3',
  'nina-james',
  'nina-north',
  'noa-aoki',
  'noora',
  'nozomi-aso',
  'octavia-red',
  'olga-alberti',
  'olga-s',
  'ora-young',
  'oriana',
  'oxana-chic',
  'paloma-b',
  'pammie-lee',
  'penelope-b',
  'penelope-kay',
  'perla-a',
  'polina-d',
  'polly-pure',
  'precious-a',
  'priscilla-huggins',
  'rachel-dee',
  'regina-5',
  'reliee-marks',
  'remi',
  'rena',
  'reon-kosaka',
  'rhian-sugden-nude',
  'rika-aiuchi',
  'rika-kijima',
  'riku-minato',
  'riley-anne',
  'rimi-mayumi',
  'rin-suzuka',
  'rinna',
  'rinna-2',
  'rio-hamasaki',
  'risa-kasumi',
  'risa-misaki',
  'rishka-a',
  'rosalina-2',
  'rose',
  'roxi',
  'ryo-uehara',
  'rua-mochiduki',
  'rubie',
  'ruby',
  'ruka-kanae',
  'ruru-anoa',
  'ruth',
  'ruth-2',
  'sabrina-nichole',
  'sakura-kokomi',
  'sakura-mana',
  'sakura-shiratori',
  'samadhi-amour',
  'salma-c',
  'saloma',
  'samara',
  'sanija',
  'sanita',
  'saori-hara',
  'sarah-joy',
  'sarika',
  'sasa-handa',
  'sasha-bonilova',
  'saskia-a',
  'sato-haruki',
  'savannah-sixx',
  'sayuki-kanno',
  'scarlet',
  'scarlett-a',
  'scarlett-jones',
  'selina',
  'semija',
  'serena-j',
  'serena-wood',
  'shaky',
  'shania-a',
  'sharona',
  'shay-laren',
  'sheela-a',
  'shelby-chesnes',
  'sherice',
  'shiori-kamisaki',
  'shiraishi-mariana-2',
  'shizuku-natsukawa',
  'siena',
  'sienna',
  'sierra-2',
  'simon',
  'simone',
  'simonia-a',
  'skye-blue',
  'sofi-a',
  'sofie',
  'sofie-s',
  'sojie',
  'soloan-kendricks',
  'sonya-blaze',
  'sophie-4',
  'sophie-gem',
  'sora-aoi',
  'stacy-cruz',
  'stasey',
  'stella-barry',
  'stella-cox',
  'steorra-a',
  'sumire',
  'sumire-aida',
  'sunshine-a',
  'suok',
  'surime-a',
  'susann',
  'suzuka-ishikawa',
  'sybil-a',
  'takako-kitahara',
  'takane-hirayama',
  'terry',
  'tessa-fowler',
  'theodora',
  'tianhai-tsubasa',
  'tracey-ly',
  'tsubasa-aizawa',
  'tsubasa-amami',
  'valentine-a',
  'valeria-c',
  'vasilisa',
  'velana',
  'vera',
  'veralin',
  'verona',
  'veronika-3',
  'veronika-i',
  'veronika-zemanova',
  'victoria-rae-black',
  'vienna',
  'vika-ag',
  'vika-c',
  'vika-p',
  'vika-r',
  'victoria-garin',
  'vila-a',
  'viola-o',
  'violla-a',
  'wendy-5',
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
  'zita-b',
  'zoelle-frick',
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
  if ARGV.size < 1 && ARGV.size > 2
    STDERR.puts USAGE
    exit 1
  end
  
  @loadedfile = ARGV[0]
  @loaded = get_loadedlist(@loadedfile)
  @nbabes = 1

  @modelname = ARGV[1] if ARGV.size == 2
end

def get_image(imgurl, referer, base)
  #puts "imgurl=#{imgurl}"
  begin
    #img = open(imgurl, "Referer" => referer) do |i|
    img = URI.open(imgurl, "Referer" => referer) do |i|    # from Ruby 3.0
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
  #html = open(url) do |f|
  html = URI.open(url) do |f|   # from Ruby 3.0
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
  # html = open(url) do |f|
  html = URI.open(url) do |f|     # from Ruby 3.0
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
    #html = open(url) do |f|
    html = URI.open(url) do |f|   # from Ruby 3.0
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
    # html = open(url2) do |f|
    html = URI.open(url2) do |f|     # from Ruby 3.0
        charset = f.charset
      f.read
    end
  rescue StandardError => e
    STDERR.puts "CANT OPEN: #{e}"
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
  
  models = if @modelname != nil then [@modelname] else MODELS end
  models.shuffle.each_with_index do |u, i|
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
