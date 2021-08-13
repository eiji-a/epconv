#!/usr/bin/ruby
#
# url_log2db
#

USAGE = "Usage: url_log2db.rb <dbfile> <logfile>"

require 'active_record'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'fileutils'

STAT  = 'COMPLETED'

class Page < ActiveRecord::Base
end

def init
  if ARGV.size != 2
    STDERR.puts USAGE
    exit 1
  end

  if File.exist?(ARGV[0])
    @dbfile = ARGV[0]
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: @dbfile
    )
  else
    STDERR.puts USAGE
    exit 1
  end

  if File.exist?(ARGV[1]) == false
    STDERR.puts USAGE
    exit 1
  end

  @log = ARGV[1]
end

def write_record(url)
  p = Page.where(url: url)
  if p.size == 1 && p[0].status == STAT
    STDERR.puts "URL(#{url}) is already exist."
    return
  else
    charset = nil
    html = nil
    begin
      html = OpenURI.open_uri(url) do |f|
        charset = f.charset
        f.read
      end
    rescue StandardError => e
      STDERR.puts "ERR: #{e}:  #{url}"
      return
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    if p.size == 0
      pref = Time.now.strftime("%Y%m%d%H%M%S%L")
      title = doc.title.split(/\|/)[0].gsub(/'/, '_').gsub(/\s+/, '_').gsub(/\(/, '[').gsub(/\)/, ']').gsub(/\//, '_').gsub(/&/, 'and')
      STDERR.puts "PR:#{pref}/T:#{title}"
      page = Page.new(
        pref: pref,
        url: url,
        title: title,
        status: STAT
      )
      page.save
    end
  end
end

def main
  init
  File.foreach(@log) do |l|
    write_record(l.chomp)
    sleep 0.1
  end
end

main

