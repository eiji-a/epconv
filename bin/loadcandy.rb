#!/usr/bin/ruby
#
# usage: loadcandy.rb <site> <#day>

require "open-uri"
require "rubygems"
require "nokogiri"
require "fileutils"

#STARTDATE = Date.new(2011, 12, 8)
URLS = {"candypleasure" => "http://www.candypleasure.com/archive/",
        "sexybabe" => "http://www.sexy-babe-pics.com/archive/",
        "anotherbabe" => "http://www.anotherbabe.com/archive/"}
PATTERN = Regexp.new("href=(.+)")

def init
  if ARGV.size != 3
    STDERR.puts "usage: loadcandy.rb <site> <startdate> <enddate>"
    STDERR.puts "  site: candypleasure sexybabe anotherbabe"
    STDERR.puts "  startdate, enddate: yyyy-mm-dd"
    exit 1
  end

  $SITE = ARGV.shift
  dy = ARGV.shift.split(/\-/)
  $STARTDATE = Date.new(dy[0].to_i, dy[1].to_i, dy[2].to_i) - 1
  dy = ARGV.shift.split(/\-/)
  $ENDDATE = Date.new(dy[0].to_i, dy[1].to_i, dy[2].to_i)
  $URL = URLS[$SITE]
end


def get_body(url)
  charset = nil
  body = nil
  begin
    body = open(url) do |f|
      charset = f.charset
      f.read
    end
  rescue StandardError
    return nil
  end
  return [charset, body]
end

def put_links(links)
  links.each do |l|
    href = l.attribute("href")
    next if href == "/" || href == "/paysite/" || href == "/pornstar/" || href == "/tag/"
    next if /^http/ =~ href
    next if /^\/archive/ =~ href
    next if /^javascript/ =~ href
    puts href
  end
end

def trial(date)
  datestr = date.strftime("%Y%m%d")
  return if File.exist?("#{$SITE}-#{datestr}.txt")
  body = get_body($URL + date.strftime("%Y/%m/%d/"))
  if body != nil
    doc = Nokogiri::HTML.parse(body[1])
    #puts "TITLE: #{doc.title}"
    return if doc.title !~ /^Archive for/
    put_links(doc.css("a"))
  else
    STDERR.puts "URL = #{$URL + date.strftime("%Y/%m/%d/")}"
  end
end

def main
  init
  date = $STARTDATE
  while date <= $ENDDATE do
    trial(date)
    date += 1
  end
end


main
