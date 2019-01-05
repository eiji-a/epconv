#
# epconvlib: library for epconv scripts
#

require 'rubygems'
require 'sqlite3'

# CONSTANT
# --------------------------

DBFILE = 'tank.sqlite'
EXT = '.jpg'
PICMAG  = 'pictures-'
FILETAG = 'filed'
SKETTAG = 'forsketch'
INITTAG = 'notevaluated'
EXCPTAG = 'excepting'
FPSIZE = 8
NRETRY = 20
INTERVAL = 5  # 5 sec
COVERSIZE = 300 * 1024 # 100kB
VIRTUALMAG = 'pictures-'

# file type
FILE_PIC   = 'eaepc'
FILE_MAG   = 'emags'
FILE_PAGE  = 'magpage'
FILE_INDEX = 'magindex'

# tag type
TAG_PIC    = 'pic'
TAG_MAG    = 'mag'

# directories
PICDIR = FILE_PIC + '/'
MAGDIR = FILE_MAG + '/'
TRASHDIR = 'trash/'
TMPDIR = '/tmp/'
DELDIR = 'deleted/'

# status
ST_ALL    = 'all'
ST_FILE   = 'filed'
ST_SKETCH = 'sketch'
ST_PEND   = 'pending'
ST_DEPEN  = 'depended'
ST_DELETE = 'deleted'
ST_DEDUP  = 'duplicated'
ST_EXCEPT = 'excepted'

STS = {ST_FILE => 'FIL', ST_SKETCH => 'SKE', ST_DEPEN => 'DEP', ST_DELETE => 'DEL', ST_DEDUP => 'DUP', ST_EXCEPT => 'EXT', ST_PEND => 'PND'}
STBTN = {ST_FILE => 'FIL', ST_SKETCH => 'SKE', ST_EXCEPT => 'EXT'}
STBTN2 = {ST_FILE => 'FIL', ST_SKETCH => 'SKE', ST_DEPEN => 'DEPE', ST_EXCEPT => 'EXT'}

# filters
FL_ALL = 'all'
FL_FIL = 'filed'
FL_SKE = 'forsketch'
FL_NEV = 'notevaluated'
FL_DEL = 'delete'
TYPE = {FL_FIL => 'FIL', FL_SKE => 'SKE', FL_NEV => 'NEV', FL_DEL => 'DEL'}

# sort
ST_NAME = 'n'
ST_TIME = 't'

# METHODS
# -------------------------

def init_base(argv)
  return false if ARGV.size < 2 || is_tankdir(argv[0]) == false
  $TANKDIR = argv[0] + '/'
  $IPADDR  = argv[1]
  db_open($TANKDIR)
  #puts "#{$TANKDIR}, #{@DB}"
  true
end

def is_tankdir(tankdir)
  return false if Dir.exist?(tankdir) == false
  tdir = tankdir + '/'
  return false if Dir.exist?(tdir  + PICDIR) == false
  return false if Dir.exist?(tdir  + MAGDIR) == false
  return false if Dir.exist?(tdir  + TRASHDIR) == false
  return false if Dir.exist?(tdir  + DELDIR) == false
  return false if File.exist?(tdir + DBFILE) == false
  return true
end

def db_open(tankdir)
  puts "OPEN DATABASE"
  @DB = SQLite3::Database.new(tankdir + DBFILE)
  puts "DATABASE OPENED: #{@DB}"
end

def db_close
  @DB.close
end

def db_execute(sql, *args)
  NRETRY.times do |i|
    begin
      #puts "SQL: #{sql}, ID:#{args[0]}, DB:#{@DB}"
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
  dirname = tankdir + picdir + idx + '/'
  Dir.mkdir(dirname) if Dir.exist?(dirname) == false
  dirname
end

def get_hash(f)
  bn = File.basename(f, EXT)
  hashsrc = bn + File.size(f).to_s + File.ctime(f).to_s + Time.now.to_s
  $DIGEST.update(hashsrc).to_s
end

def get_path(f)
  kind, type, cd, hash, id = analyze_file(f)
  cdpath = $TANKDIR + "#{type}/#{cd}/"
  path = case type
         when FILE_INDEX
           cdpath + 'index/'
         when FILE_MAG
           cdpath
         when FILE_PAGE
           cdpath + "#{type}-#{hash}/"
         when FILE_PIC
           cdpath
         else
           ""
         end
  return cdpath, path, path + f
end

def analyze_file(f)
  kind = FILE_MAG
  type = cd = hash = id = nil
  case f
  when /^eaepc-(..)(.+)\.jpg$/
    kind = FILE_PIC
    type = FILE_PIC
    cd   = $1
    hash = $1 + $2
  when /^emags-(..)(.*?)-index\.jpg$/
    type = FILE_INDEX
    cd   = $1
    hash = $1 + $2
  when /^emags-(..)(.*?)-(\d+)\.jpg$/
    type = FILE_PAGE
    cd   = $1
    hash = $1 + $2
    id   = $3
  when /^emags-(..)(.+)$/
    type = FILE_MAG
    cd   = $1
    hash = $1 + $2
  else
    kind = 'non'
  end
  return kind, type, cd, hash, id
end
