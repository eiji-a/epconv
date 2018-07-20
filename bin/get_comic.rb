#! /usr/bin/ruby
#

require 'open-uri'
require 'rubygems'
require 'nokogiri'

def saveimg(title, url)
  p "page"
  p title
  p url
end

url = ARGV.shift
charset = nil
html = open(url) do |f|
  charset = f.charset
  f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)

kiji = doc.css('.kiji')
#p kiji
kiji.css('a').each do |node|
  #p node
  next if node.attributes["title"] == nil
  saveimg(node.attributes["title"].value, node.children[0].attributes["src"].value)
end


