#!/usr/bin/ruby
#
# saveortrash.rb
#

require 'sinatra'
require 'sinatra/reloader'

require_relative 'epconvlib'

MAXHEIGHT = 1000

def main
  init
  $im = load_image
  puts "IM:#{$im.size}"

  set :server, %w[webrick]
  set :bind, $IPADDR

  # for pages

  get '/' do
    redirect "/page/0"
  end

  get '/page/:nm?' do |nm|
    nm = nm.to_i
    page nm
#   "Hello world"
  end

  get '/save/:nm?' do |nm|
    nm = nm.to_i
    move 'save', nm
  end

  get '/trash/:nm?' do |nm|
    nm = nm.to_i
    move 'trash', nm
  end

#  get '/image/:nm?' do |nm|
#    nm = nm.to_i
#    top nm
#    "Hello world"
#  end

  get '/image/:nm?' do |nm|
    content_type :jpg
    image nm.to_i
#    "Hello World"
  end

end

def page(nm)
  @nm = nm
  @image = $im[nm]
  unless FileTest.exist?(@image)
    if FileTest.exist?("save/#{@image}")
      FileUtils.mv("save/#{@image}", @image)
    elsif FileTest.exist?("trash/#{@image}")
      FileUtils.mv("trash/#{@image}", @image)
    end
  end
  rs = `identify -format \"%w,%h\" #{@image}`.split(",")
  @width = rs[0].to_i
  @height = rs[1].to_i
  @ratio = if @height > MAXHEIGHT then MAXHEIGHT * 100 / @height else 100 end
  erb :saveortrash
end

def move(dir, nm)
  FileUtils.mkdir(dir) unless FileTest.exist?(dir)
  FileUtils.mv($im[nm], "#{dir}/#{$im[nm]}")
  redirect "/page/#{nm+1}"
end

def image(nm)
  fn = $im[nm]
  body = ""
  File.open(fn) do |fp|
      body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def init
end

def load_image
  im = Array.new
  Dir.glob("*.jpg\0*.jpeg").each do |f|
    im << f
  end
  im
end

main
