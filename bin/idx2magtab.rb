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
  cover = select_cover(fn)
  create_mag(cover, stat)
end

def select_cover(fn)
  sz = FileTest.size(fn)
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

def create_mag(cv, st)
  sql = "SELECT id FROM images WHERE filename LIKE ?"
  cv_id = 0
  db_execute(sql, cv + '%').each do |r|
    cv_id = r[0]
  end
  cdate = Time.now.strftime('%Y%m%d%H%M%S')
  sql = "INSERT INTO mags (magname, cover_id, createdate, status) VALUES (?, ?, ?, ?)"
  /^(.+)-\d+\.jpg$/ =~ cv
  mn = $1
  #puts "#{sql}, #{$1} id = #{cv_id}, #{cdate}"
  db_execute(sql, mn, cv_id, cdate, st)
  puts "Created: #{mn}"
end

main
