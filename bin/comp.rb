#!/usr/bin/ruby
#
#

require 'sinatra'
require 'sinatra/reloader'

require_relative 'epconvlib'

USAGE = 'Usage: comp.rb <tank dir> <ip address>'

def main
  init
  @im = load_image

  set :server, %w[webrick]
  set :bind, $IPADDR

  # for pages

  get '/' do
    redirect "/top/1"
  end

  get '/top/:nm?' do |nm|
    nm = nm.to_i
    top nm
#   "Hello world"
  end

#  get '/image/:nm?' do |nm|
#    nm = nm.to_i
#    top nm
#    "Hello world"
#  end

  get '/image/:jp?' do |jp|
    content_type :jpg
    image jp
#    "Hello World"
  end

end

def init
  if init_base(ARGV) == false
    STDERR.puts USAGE
    exit 1
  end
  $MAGDIR = $TANKDIR + MAGDIR
  $PICDIR = $TANKDIR + PICDIR
end

def load_image
  im = Array.new
  STDIN.each do |l|
    /^[(.+)]$/ =~ l
  end
end

def top(nm)
  @nm = nm
  erb :top2
end

def image(jpg)
  fn = get_imgpath(jpg)
  body = ""
  File.open(fn) do |fp|
      body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def get_imgpath(jpg)
  /^(.....)-(.+)\.jpg+$/ =~ jpg
  tp = $1
  hs = $2
  hs2 = hs[0..1]
  fn = if tp == 'emags' then
    /^(.+)-(\d+)$/ =~ hs
    magd = $MAGDIR + "#{hs2}/emags-#{$1}"
    magd + '/' + jpg
  else
    $PICDIR + "#{hs2}/" + jpg
  end
end

main
