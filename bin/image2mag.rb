#!/usr/bin/ruby
#
# image2mag: apply images to virtual magazine with status
#
# usage: image2mag.rb <tank_dir>
#    <tank_dir> : directory of image tank
#

require 'fileutils'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: idx2magtab.rb <tank_dir>                                               
  <tank_dir> : directory of image tank
EOS

STATUS = {'notevaluated' => ST_SUSP,
          'forsketch'    => ST_SKETCH,
          'filed'        => ST_FILE,
          'deleted'      => ST_DELETE
         }

def main
  init

  "0123456789abcdef".chars.each do |c1|
    "0123456789abcdef".chars.each do |c2|
      ch = c1 + c2
      imgdir = $TANKDIR + PICDIR + ch
      next if File.directory?(imgdir) == false
      magid = get_magid(ch)
      print "MAG: #{ch} ... "
      Dir.glob(imgdir + '/*.jpg') do |f|
        add_to_mag(f, magid)
      end
      puts "done."
    end
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

def get_magid(ch)
  sql1 = "SELECT id FROM mags WHERE magname = ?"
  mag = db_execute(sql1, VIRTUALMAG + ch)
  if mag.size == 0
    sql2 = "INSERT INTO mags (magname, cover_id, createdate, status) " +
           "VALUES (?, 1, ?, ?)"
    cdate = Time.now.strftime('%Y%m%d%H%M%S')
    db_execute(sql2, VIRTUALMAG + ch, cdate, ST_FILE)
    mag = db_execute(sql1, VIRTUALMAG + ch)
  end
  mid = if mag.size == 1 && mag[0].size == 1 then mag[0][0] else 0 end
end

def add_to_mag(fn, mid)
  tag = `tag -Nl #{fn}`.chomp
  tag = 'notevaluated' if tag == ''
  bn = File.basename(fn)
  sql1 = "SELECT id FROM images WHERE filename = ?"
  img = db_execute(sql1, bn)
  if img.size == 1
    id = img[0][0]
    sql2 = "UPDATE images SET status = ? WHERE id = ?"
    db_execute(sql2, STATUS[tag], id)
    #puts "IM: #{id}, S: #{STATUS[tag]}, T: #{tag}"
    sql3 = "INSERT INTO magimage VALUES(?, ?)"
    db_execute(sql3, mid, id)
  end
end

main
