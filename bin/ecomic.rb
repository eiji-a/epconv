#
#
#

require "open-uri"
require "rubygems"
require "nokogiri"

$pages = Array.new

def get_body(url)
  charset = nil
  body = open(url) do |f|
    charset = f.charset
    f.read
  end
  return [charset, body]
end

def child_pages(children)
  children.each do |event|
    jpg = event['href']
    $pages << jpg if /\.jpg$/ =~ jpg
  end
end

if ARGV.size != 1
  puts "Usage: ecomic.rb <url>"
  exit 1
end

url = ARGV[0]
#"http://blog.livedoor.jp/eroanimenogazou/archives/52053839.html"

charset = nil
html = open(url) do |f|
  charset = f.charset
  f.read
end

puts "HTML: #{html.class}"

div = ""
doc = Nokogiri::HTML.parse(html, nil, charset)

#doc.css("div.kiji").map do |event|
#  pg = event.at_css("a")['href']
#  puts "PG:#{pg}"
#  pages << event.at_css("a")['href']
#end

cont = doc.css("div.kiji")
cont = doc.css("div.article-body-more") if cont.children.size == 0
div = nil

cont.children.each do |ev|
  $pref = ev['title'].split(/-/)[0] if ev['title'] != nil
  jpg = ev['href']
  jpg2 = ev.children[0]['src'] if ev.children[0] != nil
  #p ev['href']
  #$pages << jpg if /\.jpg$/ =~ jpg
  $pages << jpg2 if /\.jpg$/ =~ jpg2
  if ev.children.size > 1
    child_pages(ev.children)
  end
end

$pages.each_with_index do |pg, i|
  id = sprintf("%03d", i)
  puts "#{id},#{pg}"
  pg = if /\-s.jpg$/ =~ pg then pg else pg.gsub(".jpg", "-s.jpg") end
  bd = get_body(pg)
  File.open("#{$pref}-#{id}.jpg", "w") do |f|
    f.write bd[1]
  end
end

