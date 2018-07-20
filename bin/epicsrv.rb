#!/usr/bin/ruby
#

require 'socket'
require "open-uri"
require "rubygems"
require "nokogiri"

MINSIZE = 20 * 1024   # 20kB
TIMEOUT = 30
PORT = 11081
DIVNAME = ["div.kizi-body2",
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
           "div.post"
          ]


def get_body(url)
  charset = nil
  url2 = URI.encode url
  body = ""
  5.times do |i|
    begin
      body = open(url2, :read_timeout=>TIMEOUT) do |f|
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
  #puts "EV2:#{ev}"
  #$pref = ev['title'].split(/-/)[0] if ev['title'] != nil
  jpg = if ev['href'] != nil
          ev['href']
        elsif ev['src'] != nil
          ev['src']
        end

  #if jpg !~ /^http/ && jpg != nil
  #  jpg = cpath + "/" + jpg
  if jpg =~ /^http/ && jpg != nil
    #puts "JPG: #{jpg}"
    pages << jpg if /\.jpg$/ =~ jpg
  else
    if ev.children.size >= 1
      ev.children.each do |e|
        get_img(e, cpath, pages)
      end
    end
  end
end

def load(url)
  cpath = File.dirname url
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  #puts "HTML: #{html.class} / #{cpath}"

  div = ""
  doc = Nokogiri::HTML.parse(html, nil, charset)
  cont = nil
  DIVNAME.each do |d|
    c = doc.css(d)
    if c.children.size > 0
      cont = c
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

  pref = Time.now.strftime("%Y%m%d%H%M%S%L")
  puts "#{url}:#{pref}(#{pages.size} pics): loading start"
  pages.each_with_index do |pg, i|
    id = sprintf("%03d", i)
    pg2 = if pg !~ /^http/ then cpath + "/" + pg else pg end
    #puts "#{Thread.current.object_id}/#{id},#{pg2}"
    #pg = if /\-s.jpg$/ =~ pg then pg else pg.gsub(".jpg", "-s.jpg") end
    bd = get_body(pg2)
    next if bd[1].size < MINSIZE
    if bd[1] != ""
      File.open("#{pref}-#{id}.jpg", "w") do |f|
        f.write bd[1]
      end
    end
  end
  puts "#{pref}: end"
end

def service(client)
  while url = client.gets do
    Thread.start(url) do |u|
      load(url.chomp)
    end
  end
  client.close
end

def main
  $port = if ARGV[0] == nil then PORT else ARGV[0].to_i end
  puts "Waiting connections on port #{$port}."
  server = TCPServer.open($port)
  loop do
    c = server.accept
    service(c)
  end
  server.close
  puts "Close service."
end

main
