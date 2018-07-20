#!/usr/bin/ruby
#

require "open-uri"

NPICS = 30

def load_data(url)
  body = open(url) do |f|
    charset = f.charset
    f.read
  end
  body
end

def get_body(url)
  charset = nil
  body = nil
  loop do
    begin
      body = load_data(url)
      break
    rescue => e
      case e
      when OpenURI::HTTPError
        return nil
      else
        puts "retry #{url}"
      end
    end
  end
  return [charset, body]
end

def mk_base(site, item)
  basedir = "Pic_candy"
  case site
  when 'metart' then
    ["http://metart.qruq.com/#{item[0]}/#{item[1]}/m",
     basedir + "/metart_#{item[0]}_#{item[1]}-"]
  when '21naturals' then
    ["http://21naturals.oldax.com/#{item[0]}/m",
     basedir + "/21naturals_#{item[0]}-"]
  when 'euroteenerotica' then
    ["http://euroteenerotica.oldax.com/#{item[0]}/m",
     basedir + "/euroteenerotica_#{item[0]}-"]
  else
    nil
  end
end

def dl_metart(site, item)
  puts "SITE:#{site}, ITEM:#{item[0]}"
  baseurl, basejpg = mk_base(site, item)
  return nil if baseurl == nil
  return nil if File.exist?(basejpg + "01.jpg")
  NPICS.times do |i|
    num = sprintf("%02d", i)
    url = baseurl + num + ".jpg"
    bd = get_body(url)
    next if bd == nil
    puts url
    File.open(basejpg + num + ".jpg", "w") do |f|
      f.write bd[1]
    end
  end
end

nitem = 0
ARGF.each do |l|
  break if nitem >= 20
  item = l.split('/')
  ret = nil
  case item[1]
  when 'metart' then
    ret = dl_metart('metart', item[2..-1])
  when 'galleries' then
    ret = dl_metart(item[3], item[4..-1])
  end
  nitem += 1 if ret != nil
end
