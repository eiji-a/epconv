#!/usr/bin/ruby
#
# eptank : EP data tank server
#
# CREATE: E.Akagi 2021-09-25

USAGE = 'Usage: eptank.rb <tank dir>'

require 'sinatra'
require 'rack/contrib'
require 'sinatra/json'
require 'sinatra/activerecord'
require_relative './models/models.rb'

HOST = 'localhost'
PORT = 4567
LIKE = 1

class Eptank < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  #set :database, {:adapter => 'sqlite3', :database => "#{$TANKDIR}/tank.sqlite"}
  use Rack::PostBodyContentTypeParser

  before do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
  end

  def format_image(img)
    {
      :id => img[:id],
      :url => "http://#{HOST}:#{PORT}/image/#{img[:id]}",
      :status => img[:status],
      :xreso => img[:xreso],
      :yreso => img[:yreso],
      :filesize => img[:filesize],
      :liked => if img[:liked] == LIKE then true else false end,
      :tags => [],
    }
  end

  def get_nimages_randomly(n)
    ids = Array.new
    n.times do
      ids << rand($images.size)
    end
    Image.find(ids)
  end

  def imagedata(id)
    img = Image.find(id)
    STDERR.puts "FNAME:#{img[:filename]}|"
    /^(.....)-(..)/ =~ img[:filename]
    k = $1
    h = $2
    fname = "#{$TANKDIR}/#{k}/#{h}/#{img[:filename]}"
    body = ""
    if File.exist?(fname)
      File.open(fname, 'rb') do |fp|
        body = fp.read
      end
    end
    STDERR.puts "FILE:#{fname}, IMSIZE:#{body.size}"
    body
  end

  #------------------------

  get '/' do
    i = rand($images.size)
    image = Image.find(i)
    json image
  end

  get '/feed' do
    images = Array.new
    get_nimages_randomly(4).each do |img|
      images << format_image(img)
    end
    json images
  end

  get '/image/:id' do |id|
    content_type 'image/jpeg'
    b = imagedata(id.to_i)
    STDERR.puts "#{b.size}"
    b
  end

end

def init
  if ARGV.size != 1
    STDERR.puts USAGE
    exit 1
  end
  $TANKDIR = ARGV[0]
  Eptank.set(:database, {:adapter => 'sqlite3', :database => "#{$TANKDIR}/tank.sqlite"})

  ids = Image.select('id')
  $images = Array.new
  ids.each do |i|
    $images << i[:id]
  end
end

def main
  init

  Eptank.run! :host => HOST, :port => PORT
end

main

#
