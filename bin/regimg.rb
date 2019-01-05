#!/usr/bin/ruby
#
# regimg: register images
#
# usage: regimg.rb <tank_dir>
#    <tank_dir> : directory of image tank
#

require 'fileutils'
require 'digest/sha1'

require_relative 'epconvlib'

USAGE = <<-EOS
usage: regimg.rb <tank_dir>
  <tank_dir> : directory of image tank
EOS

SAME_NOCHANGE = 0
SAME_EXCHANGE = 1
SAME_PENDING  = 2
SAME_NEWIMAGE = 3

NM_FINISH = "fin_"
NM_TRASH = "trash_"
NM_PENDING = "pending_"

FSIZEDIFFRATE = 101  # under 101%

def main
  init
  db_open($TANKDIR)

#=begin
  Dir.glob("*.jpg") do |f|
    next if File.directory?(f) == true
    hs = get_hash(f)
    srcimg, dstimg = get_imgfile(f, hs)
    dirname = get_dir(hs, $TANKDIR, PICDIR)
    sql = "SELECT id FROM mags WHERE magname like ?"
    #magid = db_execute(sql, PICMAG + hs[0..1] + '%')[0][0]
    add_imgfile(srcimg, dstimg, dirname, ST_PEND, nil)
    listfile = $TANKDIR + PICDIR + "#{hs[0..1]}.list"
    FileUtils.remove(listfile) if File.exist?(listfile)
  end
#=end

  Dir.foreach(".") do |f|
    next if f =~ /^\./
    if File.directory?(f) == true
      add_imgdir(f, get_hash(f))
    elsif f =~ /\.zip$/i
      tname = TMPDIR + Time.now.strftime("%Y%m%d%H%M%S")
      if File.exist?(tname) == false
        FileUtils.mkdir(tname)
        FileUtils.copy(f, tname + '.zip')
        system "unzip -d #{tname} #{tname}.zip > /dev/null"
        add_imgdir(tname, get_hash(f))
        FileUtils.remove_entry_secure(tname)
        FileUtils.rm(tname + '.zip')
      else
        STDERR.puts "Can't extract zip: #{f}"
      end
    end
  end

  db_close
end

def init
  if ARGV.size != 1
    STDERR.puts USAGE
    exit 1
  end

  $TANKDIR = ARGV[0] + '/'
  if is_tankdir($TANKDIR) == false
    STDERR.puts USAGE
    exit 1
  end

  $DIGEST = Digest::SHA1.new

end

def reg_dir(f, hs)
  dirname = get_dir(hs, $TANKDIR, FILE_MAG)
  add_imgdir(f, hs, dirname)
end

def get_imgfile(f, hs)
  fname = ""
  if /^#{FILE_PIC}-.*\.jpg/.match f
    fname = f
  else
    fname = FILE_PIC + "-" + hs + ".jpg"
  end
  return f, fname
end

def add_imgdir(sdir, hs)
  #puts "SDIR:#{sdir}"
  dirname = get_dir(hs, $TANKDIR, MAGDIR)
  magname = FILE_MAG + "-" + hs
  magid   = 0
  num     = 1

  Dir.foreach(sdir) do |f|
    next if f =~ /^\./
    sdir2 = sdir + "/" + f
    if File.directory?(sdir2) == true
      add_imgdir(sdir2, get_hash(sdir2))
    elsif f =~ /\.jpg$/i
      dimg = magname + "-" + sprintf("%04d", num) + ".jpg"
      magdir = get_magdir(dirname, magname)
      magid = get_mag(magname)
      add_imgfile(sdir + "/" + f, dimg, magdir, ST_DEPEN, magid)
      set_cover(sdir, f, magid, dimg)
      num += 1
    end
  end
  listfile = $TANKDIR + MAGDIR + "#{hs[0..1]}.list"
  FileUtils.remove(listfile) if File.exist?(listfile)
end

def get_magdir(dirname, magname)
  magdir = dirname + magname
  if File.exist?(magdir) == false
    Dir.mkdir(magdir)
    sql = "INSERT INTO mags (magname, cover_id, createdate, status) " +
          "VALUES (?, ?, ?, ?)"
    db_execute(sql, magname, 1, Time.now.strftime("%Y%m%d%H%M%S"), ST_PEND)
  end
  magdir
end

def get_mag(magname)
  sql = "SELECT id FROM mags WHERE magname = ?"
  db_execute(sql, magname)[0][0]
end

def add2mag(magid, dimg)
  sql = "SELECT id FROM images WHERE filename = ?"
  imid = db_execute(sql, dimg)[0][0]
  if imid == nil || imid == ''
    STDERR.puts StandardError "image not found: #{dimg}"
  else
    sql = "INSERT INTO magimage (mag_id, image_id) VALUES (?, ?)"
    db_execute(sql, magid, imid)
  end
end

def set_cover(sdir, img, magid, dimg)
  simg = sdir + '/' + img
  bdir = File.basename(sdir)
  if simg =~ /cover/i ||
     simg =~ /_lg\.jpg/i ||
     File.size(simg) < COVERSIZE ||
     img.gsub(/\([xX]\d+\)/, '') == bdir.gsub(/\([xX]\d+\)/, '') + EXT
    sql = "SELECT id FROM images WHERE filename = ?"
    cid = db_execute(sql, dimg)[0][0]
    if cid != nil && cid != ''
      sql = "UPDATE mags SET cover_id = ? WHERE id = ?"
      db_execute(sql, cid, magid)
    end
  end
end

# ALREADY
# EXCHANGE
#
def exist_same?(fp, xr, yr, fsize)
  sql = "SELECT id, xreso, yreso, filesize FROM images WHERE fingerprint = ?"
  res = db_execute(sql, fp.unpack("H*"))
  return [SAME_NEWIMAGE] if res.size == 0
  chk = if res[0][1] >= xr && res[0][2] >= yr && (res[0][3] * FSIZEDIFFRATE / 100) >= fsize then
      [SAME_NOCHANGE, res[0][0]]
    elsif res[0][1] <= xr && res[0][2] <= yr && res[0][3] < fsize then
      [SAME_EXCHANGE, res[0][0]]
    else
      [SAME_PENDING, res[0][0]]
    end
end

def add_imgfile(simg, dimg, dirname, stat, magid)
  dstfile = "#{dirname}/#{dimg}"
  #STDERR.puts "ADD_IMGFILE: #{simg}, #{dstfile}, #{stat}"
  if File.exist?(dstfile)
    STDERR.puts "#{simg}: FILE EXISTS!: #{dstfile}"
    return
  end
  #cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! #{dstfile} PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  cmd = "convert -filter Cubic -resize #{FPSIZE}x#{FPSIZE}! #{simg} PPM:- | tail -c #{FPSIZE * FPSIZE * 3}"
  fp = `#{cmd}`
  #rs = `identify -format \"%w,%h\" #{dstfile}`.split(",")
  rs = `identify -format \"%w,%h\" #{simg}`.split(",")
  #fsize = File.size(dstfile)
  fsize = File.size(simg)
  chk = exist_same?(fp, rs[0].to_i, rs[1].to_i, fsize)
  case chk[0]
  when SAME_NOCHANGE then
    FileUtils.mv(simg, "#{NM_TRASH}#{simg}")
    puts "#{simg}: already exist same image: #{chk[1]}"
  when SAME_EXCHANGE then
    write_image(simg, dimg, dstfile, fp, stat, rs[0].to_i, rs[1].to_i, fsize, magid)
    delete_image(chk[1])
    puts "#{simg}: exchange image successfully: #{chk[1]}"
  when SAME_PENDING then
    FileUtils.mv(simg, "#{NM_PENDING}#{simg}")
    puts "#{simg}: cannot decide to change: #{chk[1]}"
  when SAME_NEWIMAGE then
    write_image(simg, dimg, dstfile, fp, stat, rs[0].to_i, rs[1].to_i, fsize, magid)
    puts "#{simg}: regist as new image:"
  else
    puts "#{simg}: error status=#{chk[0]}: #{chk[1]}"
  end
end

def delete_image(id)
  sql = "UPDATE images SET status = 'deleted' WHERE id = ?"
  db_execute(sql, id)
end

def write_image(simg, dimg, dstfile, fp, stat, xr, yr, sz, magid)
  FileUtils.copy(simg, dstfile)
  insert_to_db(dimg, dstfile, fp, stat, xr, yr, sz)
  FileUtils.mv(simg, "#{NM_FINISH}#{simg}")
  add2mag(magid, dimg) if magid != nil
end

def insert_to_db(dimg, dstfile, fp, stat, xr, yr, sz)
  sql = "INSERT INTO images (filename, fingerprint, status, xreso, yreso, filesize) VALUES (?, ?, ?, ?, ?, ?)"
  db_execute(sql, dimg, fp.unpack("H*"), stat, xr, yr, sz)
end

main
