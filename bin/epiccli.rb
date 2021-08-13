#!/usr/bin/ruby
#
# epiccli
#

USAGE = "Usage: epiccli.rb <dbfile> <url>"

=begin
  SQLite3 schemas

  pages:
  CREATE TABLE pages  (
    id INTEGER PRIMARY KEY,
    pref INTEGER,
    url  TEXT,
    title TEXT,
    status TEXT
  );

=end

require 'active_record'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'fileutils'

DEBUG = true
LOCKD = '/tmp/'
STAT  = 'COMPLETED'
MINSIZE = 20 * 1024;  # 50 kB
MINLEN = 400
TIMEOUT = 300
UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"

DIVNAME = [
#           "div.main-inner",
           "div.bookview-wrap",
           "div#comic-area",
           "div.mainmore",
           "div.section",
           "section.post-content",
           "div.photo-box",
           "article.article",
           "div.content___3Ig_d",
           "div.content",
           "div.kizi-body2",
           "article.post",
           "div.entrycontent",
           "div.entry-content",
           "div.mainEntryMore",
           "div.post_content clearfix",
           "div.main clearfix main_2col",
           "div#more",
           "div.ently_text",
           "div#main",
           "div.entry_more",
           "div.post_in",
           "div.entry_text",
           "div#gallery-1",
           "div.article-body-more",
           "section.entry-content description",
           "div.main_article",
           "div.create_add",
           "main#main",
           "div#picmain",
           "div#more",
           "div.article-body",
           "div#contentInner",
           "section.entry-content cf",
           "div.articles-body",
           "div.content1",
           "div.post",
           "article.post",
           "entry_img_list",
          ]

class Page < ActiveRecord::Base
end

def init
  if ARGV.size != 2
    STDERR.puts USAGE
    exit 1
  end

  if File.exist?(ARGV[0])
    @dbfile = ARGV[0]
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: @dbfile
    )
  else
    STDERR.puts USAGE
    exit 1
  end

  @url = ARGV[1]
  @lockf = LOCKD + File.basename(@dbfile) + '.lock'
  puts "LOCK: #{@lockf}"
end

def lock
  loop do
    if File.exist?(@lockf)
      sleep 5
    else
      FileUtils.touch(@lockf)
      break
    end
  end
end

def unlock
  FileUtils.rm(@lockf)
end

def record_url
  #p = Page.where.not(status: nil).where(url: @url)
  p = Page.where(url: @url)
#  if p.size > 0
  if p.size == 1 && p[0].status == STAT
    STDERR.puts "URL(#{@url}) is already loaded."
    return nil
  else
    /^(http:\/\/.+?\/)/ =~ @url
    @fqdn = $1
    charset = nil
    html = OpenURI.open_uri(@url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    if p.size == 0
      pref = Time.now.strftime("%Y%m%d%H%M%S%L")
      title = doc.title.split(/\|/)[0].gsub(/'/, '_').gsub(/\s+/, '_').gsub(/\(/, '[').gsub(/\)/, ']').gsub(/\//, '_').gsub(/&/, 'and')
      @page = Page.new(
        pref: pref,
        url: @url,
        title: title
      )
      lock
      @page.save
      unlock
    else
      #@pref = p[0].pref
      @page = p[0]
    end
    STDERR.puts "PREF: #{@page.pref}" if DEBUG
    return doc
  end
end

def get_imagepath(ev, imgs)
  jpg = if ev['href'] != nil && ev['href'] =~ /jpg$/
    ev['href']
  elsif ev['srcset'] != nil && ev['srcset'] =~ /(http:\/\/\S+?-\d+\.jpg)/
    $1
  elsif ev['srcset'] != nil && ev['srcset'] =~ /(http:\/\/\d+.jpg)/
    $1
  elsif ev['src'] != nil && ev['src'] =~ /^http/
    ev['src']
  elsif ev['li'] != nil
    nil
  end
  #puts "JPG=#{jpg}" if DEBUG && jpg != nil

  if jpg == nil
    if ev.children.size >= 1
      ev.children.each do |e|
        get_imagepath(e, imgs)
      end
    end
  else
    jpg = @fqdn + jpg if jpg !~ /^http/
    imgs << jpg  # jpgなどで終わらない場合あり
  end
end

def search_images(doc)
  imgs = Array.new
  cont = nil
  DIVNAME.each do |d|
    c = doc.css(d)
    if c.children.size > 0
      cont = c
      puts "DIVNAME=#{d}" if DEBUG
      break
    end
  end
  if cont == nil
    cont = doc.search("div[class^='post_content']")
  end

  div = nil
  cont.children.each do |ev|
    get_imagepath(ev, imgs)
  end
  puts "PAGE: #{imgs.size} img" if DEBUG
  imgs
end

def check_image(fname)
  st = true
  sz = nil
  IO.popen("identify -format \"%w,%h\" #{fname}", :err => [:child, :out]) do |io|
    while l = io.gets do
      case l
      when /Geometry: (\d+)x(\d+)\+/
        sz = [$1, $2]
      when /^identify: Not a /
        STDERR.puts "NOT A IMAGE: #{fname}" if DEBUG
        sz = [0, 0]
      when /^identify: (.+):/
        STDERR.puts "FILE IS INVALID: #{fname}: #{$1}" if DEBUG
        st = false
      else
        sz = l.split(",")
      end
    end
  end
  if st == true
    return sz
  else
    return nil
  end
end

def load_image(image, i)
  id = sprintf("%04d", i)
  fname = "#{@page.pref}-#{id}.jpg"
  if File.exist?(fname) == true && check_image(fname) != nil
    return true
  end
  puts "#{i}: #{image}"
  iurl = if image !~ /^http/ then @fqdn + "/" + image else image end
  iurl = URI.encode(iurl)
  body = ""
  succ = false
  20.times do |j|
    begin
      charset = nil
      body = open(iurl, "User-Agent" => UA, :read_timeout => TIMEOUT) do |f|
        charset = f.charset
        f.read
      end
      File.open(fname, 'w') do |f|
        f.write body
      end
      sz = check_image(fname)
      next if sz == nil
      STDERR.puts "SZ: #{sz}/#{fname}"
      if sz.size >= 2
        if sz.size > 2 || body.size < MINSIZE || sz[0].to_i < MINLEN || sz[1].to_i < MINLEN
          File.delete(fname)
        end
        succ = true
        break
      end
    rescue StandardError => e
      STDERR.puts "ERROR: #{e}"
      STDERR.puts "RETRY(#{j}) #{iurl}"
      if e.to_s == "404 Not Found"
        iurl = iurl.gsub(".jpg", ".png")
      end
    end
  end
  STDERR.puts "FALSE: #{fname}" if succ == false
  succ
end

def delete_page
  lock
  @page.destroy
  @page.save
  unlock
end

def zip_page
  zipfile = @page.title.gsub(/\[/, "\\[").gsub(/\]/, "\\]") + ".zip"
  images  = "#{@page.pref}-*.jpg #{@page.pref}-*.png"
  zippeddir = "zippedimage"
  system "zip #{zipfile} #{images}"
  if Dir.exist?(zippeddir) == false
    FileUtils.mkdir(zippeddir)
  end
  images.split.each do |im|
    system("mv #{im} #{zippeddir}/")
  end
  lock
  @page.status = STAT
  @page.save
  unlock
end

def main
  init
  doc = record_url
  if doc == nil
    exit 1
  else
    imgs = search_images(doc)
    if imgs.size == 0
      delete_page
      exit 1
    end
    @succ = true
    th = Array.new
    imgs.each_with_index do |img, i|
      th << Thread.new do
        succ = load_image(img, i)
        if succ == false
          @succ = false
        end
      end
    end
    th.each {|t| t.join}
    if @succ == true
      zip_page
    else
      #delete_page
      exit 1
    end
  end
  puts "process end. (#{@url})"
end

main
