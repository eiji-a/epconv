#!/usr/bin/ruby
#
# idx2magtab: migration from index jpeg to mags table
#
# usage: idx2magtab.rb <tank_dir>
#    <tank_dir> : directory of image tank
#

require 'fileutils'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: idx2magtab.rb <tank_dir>                                               
  <tank_dir> : directory of image tank
EOS

STATUS = {'notevaluated' => 'suspended',
          'forsketch'    => 'sketch',
          'filed'        => 'filed',
          'deleted'      => 'deleted'
         }

def main
  init

  Dir.glob("*/index/*.jpg").each do |i|
    migrate(i)
  end
  db_close
end

def init
  $TANKDIR = ARGV[0] + '/'
  if ARGV.size != 1 || is_tankdir($TANKDIR) == false
    STDERR.puts USAGE
    exit 1
  end
  db_open($TANKDIR)
end

def migrate(fn)
  stat = STATUS[`tag -l #{fn}`.split[1]]
  images, cover, bn = get_magimages(fn)
  create_mag(images, cover, bn, stat)
end

def get_magimages(fn)
  sz = FileTest.size(fn)
  fn =~ /^(..)\/index\/(.+)-index.jpg$/
  dir = $1 + '/' + $2
  imgs = Hash.new
  cv = ""
  Dir.foreach(dir) do |f|
    next if f !~ /\.jpg$/
    imgs[f] = FileTest.size(dir + '/' + f)
    cv = f if imgs[f] == sz
  end
  return imgs, cv, File.basename(dir)
end
  
def select_cover(fn, images)
  fn =~ /^(..)\/index\/(.+)-index.jpg$/
  dir = $1 + '/' + $2
  cv = ""
  Dir.foreach(dir) do |f|
    next if f !~ /jpg$/
    if FileTest.size(dir + '/' + f) == sz
      cv = f
    end
  end
  cv
end

def create_mag(imgs, cv, bn, st)
  sql = "SELECT id FROM images WHERE filename = ?"
  cv_id = 1
  db_execute(sql, cv).each do |r|
    cv_id = r[0]
  end
  STDERR.puts "Can't select cover image: #{cv}" if cv_id == 1
  
  cdate = Time.now.strftime('%Y%m%d%H%M%S')
  sql = "INSERT INTO mags (magname, cover_id, createdate, status) VALUES (?, ?, ?, ?)"
  mn = bn
  db_execute(sql, mn, cv_id, cdate, st)

  sql = "SELECT id FROM mags WHERE magname = ?"
  mid = db_execute(sql, mn)[0][0]

  fn = Array.new
  imgs.each_key do |k|
    fn << "'#{k}'"
  end
  sql = "SELECT id FROM images WHERE filename IN (#{fn.join(',')})"
  ids = db_execute(sql).flatten
  ids.each do |i|
    sql = "INSERT INTO magimage VALUES (?, ?)"
    db_execute(sql, mid, i)
  end
  puts "Created: #{mn}"
end

main

