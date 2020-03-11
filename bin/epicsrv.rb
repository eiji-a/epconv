#!/usr/bin/ruby
#

require 'socket'
require "open-uri"
require "rubygems"
require "nokogiri"

USAGE = 'Usage: epicsrv.rb <port> <logfile>'

DEBUG = true
MINSIZE = 20 * 1024   # 20kB
MINLEN  = 500
TIMEOUT = 30
PORT = 11081
DIVNAME = [
#           "div.main-inner",
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

#UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36"
UA = "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko"

def get_body(url)
  charset = nil
  url2 = URI.encode url
  #opt = {}
  #opt['User-Agent'] = UA
  #opt[:read_timeout] = TIMEOUT
  body = ""
  5.times do |i|
    begin
      body = open(url2, "User-Agent" => UA, :read_timeout => TIMEOUT) do |f|
        charset = f.charset
        f.read
      end
      break
    rescue StandardError => e
      STDERR.puts "ERROR: #{e}"
      STDERR.puts "RETRY(#{i}) #{url2}"
    end
  end
  return [charset, body]
end

def child_pages(children)
  children.each do |event|
    jpg = event['href']
    $pages << jpg if /\.jpg$/ =~ jpg
  end
end

def drilldown(ev)
  #puts "EVCLASS: #{ev.class}"
  begin
    while ev['href'] == nil do
      ev = ev.children[0]
    end
    ev
  rescue
    return nil
  end
end

def save_img(fname)

end

def get_img(ev, cpath, pages)
  #puts "EV:#{ev}/#{ev['href'].class}"
  #ev = drilldown(ev)
  return [] if ev == nil
  puts "EV2:#{ev}" if DEBUG
  #$pref = ev['title'].split(/-/)[0] if ev['title'] != nil
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
  puts "JPG=#{jpg}" if DEBUG && jpg != nil
  #if jpg !~ /^http/ && jpg != nil
  #  jpg = cpath + "/" + jpg
  if jpg == nil
    if ev.children.size >= 1
      ev.children.each do |e|
        get_img(e, cpath, pages)
      end
    end
  else
    jpg = @fqdn + jpg if jpg !~ /^http/
    puts "JPG: #{jpg}" if DEBUG
    #pages << jpg if /\.jpg/ =~ jpg || /\.jpeg/ =~ jpg
    pages << jpg  # jpgなどで終わらない場合あり
    puts "add image"
  end
end

def load(url)
  cpath = File.dirname url
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  /^(http:\/\/.+?\/)/ =~ url
  @fqdn = $1
  puts "FQDN=#{@fqdn}" if DEBUG
  #puts "HTML: #{html.class} / #{cpath}"

  div = ""
  doc = Nokogiri::HTML.parse(html, nil, charset)
  cont = nil
  DIVNAME.each do |d|
    #puts "D:#{d}-----------------------------"
    c = doc.css(d)
    if c.children.size > 0
      cont = c
#      puts "DIVNAME=#{d}/C=#{c}" if DEBUG
      puts "DIVNAME=#{d}" if DEBUG
      break
    end
  end
  if cont == nil
    cont = doc.search("div[class^='post_content']")
  end

  div = nil

  pages = Array.new
  cont.children.each do |ev|
    get_img(ev, cpath, pages)
  end
  puts "PAGE: #{pages.size} img" if DEBUG

  pref = Time.now.strftime("%Y%m%d%H%M%S%L")
  puts "#{url}:#{pref}(#{pages.size} pics): loading start"
  pages.each_with_index do |pg, i|
    id = sprintf("%03d", i)
    pg2 = if pg !~ /^http/ then cpath + "/" + pg else pg end
    puts "#{Thread.current.object_id}/#{id},#{pg2}"
    #pg = if /\-s.jpg$/ =~ pg then pg else pg.gsub(".jpg", "-s.jpg") end
    bd = get_body(pg2)
    next if bd[1].size < MINSIZE
    fname = "#{pref}-#{id}.jpg"
    if bd[1] != ""
      File.open(fname, "w") do |f|
        f.write bd[1]
      end
    end
    rs = `identify -format \"%w,%h\" #{fname}`.split(",")
    if rs[0].to_i < MINLEN || rs[1].to_i < MINLEN
      File.delete(fname)
    end
  end
  puts "#{pref}: end"
end

def log_url(url)
  if $logs[url] == true
    STDERR.puts "URL(#{url}) is already downloaded."
    return false
  else
    $logs[url] = true
    File.open($logfile, 'a') do |fp|
      fp.puts(url)
    end
  end
  true
end

def service(client)
  while url = client.gets do
    if log_url(url.chomp) == true
      Thread.start(url) do |u|  
        load(url.chomp)
      end
    end
  end
  client.close
end

def init
  if ARGV.size != 2
    STDERR.puts USAGE
    exit 1
  end

  if ARGV[0].match(/[0-9]+/)
    $port = ARGV[0].to_i
  else
    $port = PORT
  end

  if File.exist?(ARGV[1])
    $logfile = ARGV[1]
  else
    STDERR.puts USAGE
    exit 1
  end

  $logs = Hash.new
  File.open($logfile) do |fp|
    fp.each do |l|
      $logs[l.chomp.strip] = true
    end
  end

  puts "Waiting connections on port #{$port}."
end

def main
  init
  server = TCPServer.open($port)
  loop do
    c = server.accept
    service(c)
  end
  server.close
  puts "Close service."
end

main
