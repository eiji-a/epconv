!#/usr/bin/ruby

require 'socket'
require "open-uri"
require "rubygems"
#require "nokogiri"
require "fileutils"
require "selenium-webdriver"
require "sqlite3"

USAGE = "pixivload.rb <uid/pwd>"
DEBUG = true
TIMEOUT = 300
#UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'

PIXIVHOST      = 'https://www.pixiv.net/'
PIXIVLOGIN     = 'https://accounts.pixiv.net/'
PIXIVFOLLOWURL = 'https://www.pixiv.net/users/97368061/following'
PIXIVARTISTURL = 'https://www.pixiv.net/users/'
PIXIVIMGURL    = 'https://i.pximg.net/img-original/img'
PIXIVARTISTOPT = '/illustrations/R-18'
PIXIVOPEID = '11'
PIXIVMAXPOST = 50
PIXIVMAXPAGE = 100
PIXIVSELECT = [
  91191937,  # MAIK09 (UP画像多数、無修正)
  88129804,  # DeepFlowAI (超リアル)
  57876684,  # WetLady （乳集団）
  34361103,  # DryAI (超リアル)
  1244958,   # Maitake (超リアル)
  96329393,  # armpitmania2 （綺麗なお姉さん、腋）
  97079130,  # coco （リアル系イラスト、乳綺麗）
  13979832,  # AI OFUG （リアルお姉さん）
  92621256,  # eroai （超綺麗なヌード）
  74032681,  # Zeroling91 （エロ乳お姉さん）
  91897081,  # MACHOKING （お姉さんヌード、股多い）
  2068607,   # satankun  （調乳娘）
  6046076,   # StudioZue （お股多い可愛い系イラスト）
  49365915,  # nanairo52 （超リアルのお姉さんヌード）
  140507,    # rei25 (超リアル、年増あり)
  92629620,  # momiji0920@AI （リアルお姉さん）
  94484133,  # AI Artmage （リアルお姉さん）
  93842479,  # re-fan （リアルお姉さん）
  87784294,  # CudaSmoke （美女！）
  2094820,   # SDI （リアルお姉さん）
  91598121,  # さんなり （リアルお姉さん、今後に期待）
  90748889,  # AIbot （綺麗系巨乳）
  #4090481,   # AkaTsuki
  #92200178,  # Harui
  #18866024,  # 鸽鸽下面羊死了
  #36972434,  # Kote_party

  #94624609,  # AI_Engine
  #94077908,  # SUNNY
  #92650235,  # ai_sakura
  #95912810,  # MIA
  #92580782,  # AI Beauty
]

# Patreon
# AIART                  10 -> 0    生々しくエロいがアソコがリアルじゃない
# AI ENA IZUMI           5 -> 0     アソコがリアルじゃない
# AI Factory             5 -> 0     えぐいが細部はあまり。。でもやっぱりいいのある
# AI Porn Gravure Girls  10 -> 0    全部モザイクあり
# AI_R18                 5
# Asian Girl             6          超リアルお姉さん
# Bukker                 ? -> ?     顔の比率が多い
# Eroai                  7 -> 0     非常に綺麗だが当たり少ない（綺麗系はImagined...で）
# GikoKitune             5          食傷気味
# HAL-sexyグラドル部     30 -> 0    モザイクあり、残念
# Imagined Cosplay       5
# Lote.                  8 -> 0     ありきたり
# ozin007                6
# PinkKirby              5
# realis_g               5 -> 0     画像がほとんどなかった、取得できなかった
# studio Zue             5 -> 0     モザイクあり、残念
# unclear                7 -> 0     アソコがリアルじゃない

MAXARTISTLINE = 25
MAXIMG = 1000
MAXPOST = 50
MAXPOSTARTIST = 2
MAXWAIT = 5          # wait seconds for page navigation

def init
  if ARGV.size != 1 && ARGV.size != 2
    STDERR.puts USAGE
    exit 1
  end

  user = ARGV[0].split("/")
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  #@session = Selenium::WebDriver.for :chrome,options: options
  @session = Selenium::WebDriver.for :chrome
  @session.manage.window.maximize
  
  # 初期ページ
  @session.navigate.to PIXIVLOGIN
  sleep MAXWAIT
  # 「同意」ボタンを押す（特別な時だけ？）
  link = @session.find_element(:xpath, '//*[@id="js-privacy-policy-banner"]/div/div/button')
  link.click
  sleep MAXWAIT
  link = @session.find_element(:xpath, '/html/body/div[2]/div/div/div[3]/div[1]/a[2]')
  link.click
  sleep MAXWAIT
  
  # ログイン
  ele_user = @session.find_element(:xpath, '//*[@id="app-mount-point"]/div/div/div[3]/div[1]/div[2]/div/div/div/form/fieldset[1]/label/input')
  ele_user.send_keys(user[0])
  ele_pass = @session.find_element(:xpath, '//*[@id="app-mount-point"]/div/div/div[3]/div[1]/div[2]/div/div/div/form/fieldset[2]/label/input')
  ele_pass.send_keys(user[1])
  link = @session.find_element(:xpath, '//*[@id="app-mount-point"]/div/div/div[3]/div[1]/div[2]/div/div/div/form/button')
  link.click
  sleep 5

  # サイドメニューを消す
  #sleep 60
  #link = @session.find_element(:xpath, '/html/body/div[7]/div/div[2]/div/div[1]/div[1]/div/button')
  #link.click
  #sleep 5

  #uid = session.find_element(:xpath, '/html/body/span[1]')
  #STDERR.puts "USER ID: #{uid.tag_name}, #{uid.text}" if DEBUG

  @artists = Array.new
  post_id = ARGV[1]
  return post_id
end

def create_db(dbfile)
  db = SQLite3::Database.new(dbfile)
  sql = <<-SQL
    CREATE TABLE pixivpost (
      post_id TEXT,
      artist_id TEXT,
      url TEXT,
      post_time TEXT,
      ext TEXT,
      nimage INT,
      dldate DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX pixivpostindex on pixivpost (
      post_id
    );
    CREATE TABLE pixivartist (
      artist_id TEXT,
      artist_name TEXT,
      url TEXT,
      level_real INT,
      level_ps INT,
      anotherurl TEXT,
      fee INT,
      regdate DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX pixivartistindex on pixivartist (
      artist_id
    );
  SQL
  db.execute(sql)

  db
end

def exist_post?(post_id)
  e = false
  begin
    sql = <<-SQL
      SELECT COUNT(post_id) FROM pixivpost WHERE post_id = ?;
    SQL
    row = @db.execute(sql, post_id)
    if row.size > 0 && row[0][0] == 1
      e = true
    else
      e = false
    end
  rescue => e
    STDERR.puts "DB ERROR: #{e}" if DEBUG
  end
  e
end

def regist_post(post_id, artist_id, url, post_time, ext, nimage)
  begin
    sql = <<-SQL
      INSERT INTO pixivpost (post_id, artist_id, url, post_time, ext, nimage)
      VALUES (?, ?, ?, ?, ?, ?);
    SQL
    @db.execute(sql, post_id, artist_id, url, post_time, ext, nimage)
  rescue => e
    STDERR.puts "REGIST POST ERROR: #{e}"
  end
end

def read_artist
  @artists = Hash.new
  begin
    sql = <<-SQL
      SELECT artist_id FROM pixivartist;
    SQL
    rows = @db.execute(sql)
    rows.each do |r|
      @artists[r[0]] = r[1]
    end
  rescue => e
    STDERR.puts "READ ARTIST ERROR: #{e}"
  end
end

def exist_artist?(artist_id)
  e = false
  begin
    sql = <<-SQL
      SELECT COUNT(artist_id) FROM pixivartist WHERE artist_id = ?;
    SQL
    row = @db.execute(sql, artist_id)
    STDERR.puts "ROW: #{row}, AID=#{artist_id}"
    e =  if row.size > 0 && row[0][0] == 1 then true else false end
  rescue => e
    STDERR.puts "DB ERROR (ARTIST): #{e}" if DEBUG
  end
  e
end

def update_db_artists(diff_artists)
  diff_artists.each do |k, v|
    begin
      if v == nil # nil は削除対象
        sql = <<-SQL
          DELETE FROM pixivartist WHERE artist_id = ?;
        SQL
        @db.execute(sql, k)
      else
        if exist_artist?(k) == false
          STDERR.puts "REGIST ARTIST: #{k}/#{v}" if DEBUG
          sql = <<-SQL
            INSERT INTO pixivartist (artist_id, artist_name, url)
            VALUES (?, ?, ?);
          SQL
          url = "#{PIXIVARTISTURL}#{k}"
          @db.execute(sql, k, v, url)
        end
      end
    rescue => e
      STDERR.puts "REGIST ARTIST ERROR: #{e}" if DEBUG
    end
  end
end

def open_db(dbfile)
  if File.exist?(dbfile)
    sql = <<-SQL
      SELECT COUNT(post_id) FROM pixivpost;
    SQL
    @db = SQLite3::Database.new(dbfile)
    begin
      res = @db.execute(sql)
    rescue => e
      STDERR.puts "SELECTED ERROR: #{e}" if DEBUG
      create_db(dbfile)
    end
  else
    puts "CREATE"
    @db = create_db(dbfile)
  end
  #e = exist_post?('1111')
  #STDERR.puts "POST 1111: #{e}" if DEBUG
end

def close_db
  @db.close
end

#-------------------
#  POST DOWNLOAD
#-------------------

def load_image(prefix, date, imgfile)
  url = "#{PIXIVIMGURL}#{date}#{imgfile}"
  STDERR.puts "URL: #{url}" if DEBUG
  charset = nil
  succ = false
  begin
    body = URI.open(url, "User-Agent" => UA, :read_timeout => TIMEOUT, "Referer" => PIXIVHOST) do |f|
      charset = f.charset
      f.read
    end
    fname = "#{prefix}-#{imgfile}"
    if body != ""
      File.open(fname, 'w') do |fp|
        fp.write(body)
      end
    end
    succ = true
  rescue => e
    STDERR.puts "LOAD ERROR: #{e}" if DEBUG
    succ = false
  end
  succ
end  

def load_page_sel(post_id)
  return 0 if exist_post?(post_id)

  # 対象ページへ遷移
  url = "https://www.pixiv.net/artworks/#{post_id}"
  @session.navigate.to url
  sleep 5
  element = nil
  artisturl = @session.find_element(:xpath, '//*[@id="root"]/div[2]/div/div[3]/div/div/div[1]/aside/section[1]/h2/div/div/a')
  artist_id = artisturl.attribute('href').split("/")[-1]
  begin
    begin
      # "すべて見る"ボタンをクリック
      link = @session.find_element(:xpath, '//*[@id="root"]/div[2]/div/div[3]/div/div/div[1]/main/section/div[1]/div/div[4]/div/div[2]/button/div[2]')
      link.click
      #sleep 5
      element = @session.find_element(:xpath, '//*[@id="root"]/div[2]/div/div[3]/div/div/div[1]/main/section/div[1]/div/figure/div[1]/div[2]/div[2]/a')
    rescue
      element = @session.find_element(:xpath, '//*[@id="root"]/div[2]/div/div[3]/div/div/div[1]/main/section/div[1]/div/figure/div[1]/div[1]/div/a')
    end
  rescue => e
    STDERR.puts "PAGE NOT IMAGE?: #{e}" if DEBUG
    return 0
  end

  html = element.attribute('href')
  STDERR.puts "HREF: #{html}" if DEBUG
  html =~ /img-original\/img(\/\d\d\d\d\/\d\d\/\d\d\/\d\d\/\d\d\/\d\d\/)#{post_id}_p\d+\.(\S+)$/
  date = $1
  ext  = $2

  pages = Array.new
  prefix = Time.now.strftime("%Y%m%d%H%M%S%L") + "-#{artist_id}"

  nimg = 0
  while nimg < MAXIMG do
    imgfile = "#{post_id}_p#{nimg}.#{ext}"
    break unless load_image(prefix, date, imgfile)
    nimg += 1
  end
  if nimg > 0
    regist_post(post_id, artist_id, url, date, ext, nimg)
  end
  nimg
end


def update_artists
  p = 1
  @session.navigate.to "#{PIXIVFOLLOWURL}?p=1"
  element = @session.find_element(:xpath, '//*[@id="root"]/div[2]/div/div[3]/div/div/div[2]/div[2]/div[2]/div/section/div[1]/div/div/div/span')
  nfollow = element.text.to_i
  STDERR.puts "FOLLOWS: #{nfollow}" if DEBUG

  read_artist
  return if (nfollow - @artists.size).abs < 20  #差が10未満なら許容する
  #return if nfollow == @artists.size

  curr_artists = Hash.new
  loop do # loop per following page
    begin
      MAXARTISTLINE.times do |al|
        begin
          artist = @session.find_element(:xpath, "//*[@id=\"root\"]/div[2]/div/div[3]/div/div/div[2]/div[2]/div[2]/div/section/div[2]/div[#{al+1}]/div/div[1]/div/a")
          artist_id = artist.attribute('href').split("/")[-1]
          artist_name = @session.find_element(:xpath, "//*[@id=\"root\"]/div[2]/div/div[3]/div/div/div[2]/div[2]/div[2]/div/section/div[2]/div[#{al+1}]/div/div[1]/div/div/div[1]/a").text

          curr_artists[artist_id] = artist_name
          STDERR.puts "ARTIST: #{artist_id} / #{artist_name} (#{p})" if DEBUG
        rescue => e
          STDERR.puts "MAXLINE: #{al} / #{e}" if DEBUG
          break
        end
      end
    rescue => e
      STDERR.puts "ARTIST LIST ERROR: #{e}" if DEBUG
    end

    nextbutton = @session.find_elements(:xpath, "//*[@id=\"root\"]/div[2]/div/div[3]/div/div/div[2]/nav/a")[-1]
    break if nextbutton.attribute('hidden') == 'true'
    nextbutton.click
    sleep MAXWAIT

  end

  diff_artists = Hash.new
  # フォロワーが増えていたら追加
  curr_artists.each do |a, n|
    STDERR.puts "EXIST ARTIST? #{@artists[a]}" if DEBUG
    next if @artists[a] != nil
    @artists[a] = n
    diff_artists[a] = n
    STDERR.puts "ADD ARTIST: #{a} / #{n}" if DEBUG
  end
  # フォロワーから削除されていたらDBも削除
  @artists.each do |a, n|
    next if curr_artists[a] != nil
    @artists.delete(a)
    diff_artists[a] = nil
    STDERR.puts "DELETE ARTIST: #{a} / #{n}"
  end

  update_db_artists(diff_artists)
end

def select_posts
  post_list = Array.new
  npost = 0
  artist_list = @artists.keys
  loop do
    break if npost >= MAXPOST
    artist_id = artist_list.sample
    next if artist_id == PIXIVOPEID # IDがPIXIV事務局ならスキップ

    STDERR.puts "ARTISTID: #{artist_id}" if DEBUG
    @session.navigate.to "#{PIXIVARTISTURL}#{artist_id}#{PIXIVARTISTOPT}"  # R-18のみ抽出
    #@session.navigate.to "#{PIXIVARTISTURL}#{artist_id}"
    sleep 5
=begin
    begin
      # "すべて見る"ボタンを押す
      link = @session.find_element(:xpath, '//*[@id="root"]/div[2]/div/div[3]/div/div/div[2]/div[3]/div/div/section/div[3]/a')
      link.click
      sleep 10
    rescue => e
      STDERR.puts "CLICK ERROR: #{e}"
    end
=end
    pcount = 0 # アーティスト毎の取得ポスト数
    loop do
      break if npost >= MAXPOST || pcount >= MAXPOSTARTIST
      PIXIVMAXPOST.times do |i|
        break if npost >= MAXPOST || pcount >= MAXPOSTARTIST
        begin
          element = @session.find_element(:xpath, "//*[@id=\"root\"]/div[2]/div/div[3]/div/div/div[2]/div[3]/div/div/section/div[3]/div/ul/li[#{i+1}]/div/div[1]/div/a")
          post_id = element.attribute('href').split("/")[-1]
          unless exist_post?(post_id)
            STDERR.puts "POSTID: #{post_id}/#{artist_id}"
            post_list << post_id
            npost += 1
            pcount += 1
          end
        rescue => e
          STDERR.puts "PAGEID: ELEMENT IS NIL: #{e}" if DEBUG
          STDERR.puts "ARTIST MAY NOT BE DISABLED: artist=#{artist_id}/post=#{post_id}" if post_id == nil
          pcount = MAXPOSTARTIST
        end
      end

      begin
        # アーティスト取得ポスト数に満たないなら次ページへ
        break if pcount >= MAXPOSTARTIST
        nextbutton = @session.find_elements(:xpath, "//*[@id=\"root\"]/div[2]/div/div[3]/div/div/div[2]/nav/a")[-1]
        break if nextbutton.attribute('hidden') == 'true'
        # 最終ページならbreak
        nextbutton.click
        sleep MAXWAIT
      rescue => e
        STDERR.puts "NEXT PAGE ERROR: #{e}" if DEBUG
      end
    end
  end

  post_list
end

def main
  post_id = init
  begin
    dbfile = "test.sqlite"
    open_db(dbfile)

    if post_id != nil
      nimage = load_page_sel(post_id)
      STDERR.puts "#IMAGE: #{nimage} images are downloaded."
    else
      update_artists
      posts = select_posts
      nimage = 0
      posts.each_with_index do |post_id, i|
        STDERR.print "(#{i+1}/#{posts.size}) POST #{post_id}: "
        nimg = load_page_sel(post_id)
        STDERR.puts "#{nimg} images are downloaded"
        nimage += nimg
      end
      STDERR.puts "#IMAGE: #{nimage} images are downloaded."
    end
  rescue => e
    STDERR.puts "ERROR: #{e}" if DEBUG
  ensure
    close_db
  end
end

main


#---
