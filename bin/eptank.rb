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
require_relative 'epconvlib.rb'

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
      :filename => img[:filename],
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
    imgs = Array.new

    while n > 0 do
      begin
        r = rand(Image.maxid)
        next if $noexist[r] == false
        im =
          if $images[r] != nil && $images[r] != false
            $images[r]
          else
            Image.find(r)
          end
        if im[:status] == 'pending' || im[:status] == 'filed'
          imgs << im
          $images[r] = im
          im.status = 'filed'
          im.save
          n -= 1
        else
          $noexist[r] = false
        end
      rescue
        $noexist[r] = false
        STDERR.puts "NOT FIND: #{r}"
      end
    end

    imgs
=begin
    n.times do
      ids << rand($images.size)
    end
    Image.find(ids)
=end
  end

  def imagedata(id)
    img = Image.find(id)
    STDERR.puts "FNAME:#{img[:filename]}|"
    /^(.....)-(..)/ =~ img[:filename]
    k = $1
    h = $2
    fname =
      if k == FILE_PIC
        "#{$TANKDIR}/#{k}/#{h}/#{img[:filename]}"
      else
        /^.....-(.+)-\d+.jpg/ =~ img[:filename]
        m = $1
        "#{$TANKDIR}/#{k}/#{h}/#{k}-#{m}/#{img[:filename]}"
      end
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
    redirect '/feed'
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
  Eptank.set(:database, {:adapter => 'sqlite3', :database => "#{$TANKDIR}/#{DBFILE}"})

  #ids = Image.select('id')
  Image.init
  $maxid = Image.maximum('id')
  $images = Hash.new
  $noexist = Hash.new
=begin
  ids = Image.where(status: 'pending').pluck(:id)
    ids.each do |i|
    #$images << i[:id]
    $images << i[0]
  end
=end

end

def main
  init

  Eptank.run! :host => HOST, :port => PORT
end

main

#
