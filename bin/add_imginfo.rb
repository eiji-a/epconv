#!/usr/bin/ruby
#

require 'rubygems'
require 'sqlite3'

USAGE = "Usage: add_imginfo.rb <tankdir>"
TANKFILE = "tank.sqlite"

#$tank = "/Users/eiji/tmp/tank"
$sql = "SELECT id, filename FROM images WHERE filesize is null AND status <> 'deleted';"

def init
  if ARGV.size != 1 || !File.exist?("#{ARGV[0]}/#{TANKFILE}")
    STDERR.puts USAGE
    exit 1
  end
  $tank = ARGV[0]
  @DB = SQLite3::Database.new("#{$tank}/#{TANKFILE}")
end

def get_info(fn)
  #puts "fn:|#{fn}|"
  return nil if !File.exist?(fn)
  size = File.size(fn)
  rs = `identify -format \"%w,%h\" #{fn}`.split(",")
  #puts "#{rs}"
  [fn, size, rs[0].to_i, rs[1].to_i]
end

def update_info(id, info)
  sql = "UPDATE images SET xreso = ?, yreso = ?, filesize = ? WHERE id = ?"
  @DB.execute(sql, info[2], info[3], info[1], id)
end

def delete_img(ids)
  sql = "UPDATE images SET status = \"deleted\" where id = ?"
  ids.each do |i|
    @DB.execute(sql, i)
  end
end

def close_db
  @DB.close
end

def main

  init

  cmd = "echo \"#{$sql}\" | sqlite3 #{$tank}/#{TANKFILE}"
  #puts "CMD:#{cmd}"
  images = Hash.new
  deleted = Array.new
  n = 0
  res = `#{cmd}`.lines
  puts "RES: #{res.length} images"
  res.each do |l|
    break if n >= 10000
    puts "N: #{n}" if n % 1000 == 0
    im = l.chomp.split("|")
    d = im[1].match("(e.+?)-(..)")
    img_id = im[0].to_i
    #info = [im[0].to_i]
    fname =
      if d[1] == 'eaepc'
        fname = "#{$tank}/#{d[1]}/#{d[2]}/#{im[1]}"
      elsif d[1] == 'emags'
        mf = im[1].match("^(.+)-")
        fname = "#{$tank}/#{d[1]}/#{d[2]}/#{mf[1]}/#{im[1]}"
      else
        nil
      end
    if fname
      i = get_info(fname)
      #puts "I: #{im[0]}, #{i}"
      #images[im[0].to_i] = i if i != nil
      if i != nil
        update_info(img_id, i)
      else
        deleted << img_id
      end
      n += 1
    end
  end
  #puts "IM SIZE: #{images.size}"
  puts "UPDATE #{n} images."

  delete_img(deleted)
  close_db
end

main
