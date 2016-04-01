#
# epconvlib: library for epconv scripts
#

require 'rubygems'
require 'sqlite3'

# CONSTANT
# --------------------------

DBFILE = 'tank.sqlite'
EXT = '.jpg'
FILETAG = 'filed'
SKETTAG = 'forsketch'
INITTAG = 'notevaluated'
EXCPTAG = 'excepting'
FPSIZE = 8
NRETRY = 20
INTERVAL = 5  # 5 sec
COVERSIZE = 100 * 1024 # 100kB

# directories
PICDIR = 'eaepc'
MAGDIR = 'emags'
TRASHDIR = 'trash'
TMPDIR = '/tmp'
DELDIR = 'deleted'

# status
ST_DELETE = 'deleted'
ST_DEDUP  = 'dedup'
ST_EXCEPT = 'excepted'

# METHODS
# -------------------------

def is_tankdir(tankdir)
  return false if Dir.exist?(tankdir) == false
  return false if Dir.exist?(tankdir + "/" + PICDIR) == false
  return false if Dir.exist?(tankdir + "/" + MAGDIR) == false
  return false if File.exist?(tankdir + "/" + DBFILE) == false
  return true
end

def db_open(tankdir)
  @DB = SQLite3::Database.new(tankdir + "/" + DBFILE)
end

def db_close
  @DB.close
end

def db_execute(sql, *args)
  NRETRY.times do |i|
    begin
      return @DB.execute(sql, *args)
    rescue => e
      STDERR.puts e
      STDERR.puts "RETRY (#{i})"
      sleep(INTERVAL)
    end
  end
  raise "can't execute SQL: #{sql}"
end

def add_tag(img, tag)
  return if File.exist?(img) == false
  system "tag -a #{tag} #{img}"
end

def get_tag(img)
  tag = `tag -l #{img}`
  #puts "T=#{tag.split(/\s/)}"
  return tag.split(/\s/)[1]
end

def get_dir(hs, tankdir, picdir)
  idx = hs[0, 2]
  dirname = "#{tankdir}/#{picdir}/#{idx}"
  Dir.mkdir(dirname) if Dir.exist?(dirname) == false
  dirname
end

def get_hash(f)
  bn = File.basename(f, EXT)
  hashsrc = bn + File.size(f).to_s + File.ctime(f).to_s + Time.now.to_s
  $DIGEST.update(hashsrc).to_s
end

