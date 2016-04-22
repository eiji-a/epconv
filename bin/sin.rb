#!/usr/bin/ruby
#
#

require 'sinatra'
require 'sinatra/reloader'

require_relative 'epconvlib'

NIMG = 200
NIMGPAGE = 50
LINEIMG = 5

# sort
ST_NAME = 'n'
ST_TIME = 't'

# filters
FL_ALL = 'all'
FL_FIL = 'filed'
FL_SKE = 'forsketch'
FL_NEV = 'notevaluated'
FL_DEL = 'delete'
TYPE = {FL_FIL => 'FIL', FL_SKE => 'SKE', FL_NEV => 'NEV', FL_DEL => 'DEL'}

def main
  init

  set :server, %w[webrick]
  set :bind, '192.168.11.111'
  
  get '/top/:sort/:code?/:filter?' do |st, cd, filter|
    st = ST_NAME if st == '' || st == nil
    top st, cd, filter
  end
  
  get '/mag/:st/:pg/:filter/:hash/:fst?' do |st, pg, filter, hs, fst|
    fst = '0' if fst == nil
    mag st, pg, filter, hs, fst.to_i
  end

  get '/page/:im/:pg/:size?' do |im, pg, sz|
    sz = 'fit' if sz == nil
    page im, pg, sz
  end
  
  get '/change/:sort/:code/:filter/:hs/:tag' do |st, cd, filter, hs, tag|
    change_tag(hs, tag)
    redirect "/top/#{st}/#{cd}/#{filter}"
  end

  get '/setidx/:pg/:filter/:jpg' do |pg, filter, jpg|
    /emags-(.+)-(\d\d\d\d).jpg/ =~ jpg
    hash = $1
    fst = ($2.to_i / 50) * 50
    set_index(hash, jpg)
    redirect "/mag/#{pg}/#{filter}/#{hash}/#{fst}"
  end
  
  get '/image/:jpg/:small?' do |jpg, s|
    s = if s == nil then false else true end
    content_type :jpg
    image jpg, s
  end

  get '/index/:jpg' do |jpg|
    content_type :jpg
    index jpg
  end
end

def init
  $TANKDIR = ARGV[0]
end

def top(st, cd, filter)
  magdir = $TANKDIR + '/' + MAGDIR
  @pg = cd.to_i
  @st = st
  @filter = filter
  tags = Hash.new
  "0123456789abcdef".chars.each do |c|
    tags.merge!(get_taglist(c, filter))
  end

  @displist = Array.new
  keys = tags.keys
  keys[@pg, NIMGPAGE].each do |k|
    @displist << [k, tags[k]]
  end
  @listsize = keys.size
  erb :top
end

def get_taglist(dir, tag)
  magdir = "#{$TANKDIR}/#{MAGDIR}"
  ldir = "#{magdir}/#{dir}"
  list = ""
  if File.exist?(ldir + '.list') == false
    File.open("#{ldir}.list", 'w') do |fp|
      l = `tag -l #{ldir}*/index/*.jpg`
      fp.write(l)
      list = l
    end
  else
    File.open("#{ldir}.list", 'r') do |fp|
      list = fp.read
    end
  end

  tags = Hash.new
  list.lines.each do |l|
    next if tag != FL_ALL && /#{tag}/ !~ l
    a = l.split(/\s+/)
    tags[a[0]] = a[1]
  end
  tags
end

def put_filter_link(cd, filter, type)
  if filter == type
    type
  else
    "<a href=\"/top/#{cd}/#{type}\">#{type}</a>"
  end
end

def mag(st, pg, filter, hs, fst)
  magdir = "#{$TANKDIR}/emags/#{hs[0..1]}"
  @idxfile = "#{magdir}/index/emags-#{hs}-index.jpg"
  @tag = `tag -l #{@idxfile}`.split(/\s/)[1]
  @st = st
  @pg = pg
  @filter = filter
  @hash = hs
  @list = Array.new
  `tag -l #{magdir}/emags-#{hs}/*.jpg`.lines.each do |l|
    @list << l.split(/\s/)
  end
  erb :mag
end

def page(im, pg, sz)
  @page  = pg.to_i
  @pg = sprintf("%04d", @page)
  imgbase = "#{$TANKDIR}/emags/#{im[0..1]}/emags-#{im}/emags-#{im}"
  @npage = `ls -1 #{imgbase}*`.lines.size
  info = `sips -g all #{imgbase}-#{@pg}.jpg`.lines
  @px = 0
  @py = 0
  info.each do |i|
    @px = i.split(/:\s+/)[1] if /pixelWidth/ =~ i
    @py = i.split(/:\s+/)[1] if /pixelHeight/ =~ i
  end
  @image = im
  @size = sz
  @slist = {'50' => 'width="50%"',
            '75' => 'width="75%"',
            '100' => 'width="100%"',
            'fit' => 'height="1050px"',
            'org' => ''}
  erb :page
end

def top_index(cd)
  files = Array.new
  Dir.glob("#{$TANKDIR}/emags/#{cd}/index/*.jpg") do |f|
    files << f
  end
  files
end

def mag_index(hs)
  dir = get_dir(hs, $TANKDIR, MAGDIR)
  files = Array.new
  Dir.glob(dir + '/emags-' + hs + '/*.jpg') do |f|
    files << f
  end
  files
end

def code_list(codes, filter)
  html = ""
  codes.each do |c|
    html += <<-EOF
    <a href="/top/#{c}/#{filter}">#{c}</a>|
EOF
  end
  html
end

def list_html_top(list, filter)
  return "" if list == nil
  html = "<table border=0>\n"
  lcnt = 0
  list.each do |f|
    html += "<tr>\n" if lcnt % LINEIMG == 0
    bn = File.basename(f)
    /emags-(.+)-index\.jpg/ =~ f
    hs = $1
    html += <<-EOF
<td valign="top">
  <br/>
  #{put_change_link(hs, filter, FL_FIL)} |
  #{put_change_link(hs, filter, FL_SKE)} |
  #{put_change_link(hs, filter, FL_NEV)} |
  #{put_change_link(hs, filter, FL_DEL)} <br/>
  <a href="/mag/#{hs}/#{filter}/0"><img src="/index/#{bn}" width="200px"></a><br/>
</td>
EOF
    html += "</tr>\n" if lcnt % LINEIMG == LINEIMG - 1
    lcnt += 1
  end
  html += "</table>\n"
end

def list_html1(list, filter)
  html = "<table border=0>\n"
  lcnt = 0
  list.each do |f|
    tag = `tag -l #{f}`.split(/\s/)[1]
    next if filter != FL_ALL && filter != tag
    if lcnt % LINEIMG == 0
      html += "<tr>\n"
    end
    bn = File.basename(f)
    /emags-(.+)-index\.jpg/ =~ f
    hs = $1
    html += <<-EOF
<td valign="top">
  <br/>
  #{put_change_link(hs, tag, FL_FIL)} |
  #{put_change_link(hs, tag, FL_SKE)} |
  #{put_change_link(hs, tag, FL_NEV)} |
  #{put_change_link(hs, tag, FL_DEL)} <br/>
  <a href="/mag/#{hs}/0"><img src="/index/#{bn}" width="200px"></a><br/>
</td>
EOF
    if lcnt % LINEIMG == LINEIMG - 1
      html += "</tr>\n"
    end
    lcnt += 1
  end
  html += "</table>\n"
end

def list_html2(list, fst)
  list2 = list[fst, NIMG]
  html = "<table border=0>\n"
  lcnt = 0
  list2.each do |f|
    if lcnt % LINEIMG == 0
      html += "<tr>\n"
    end
    jpg = File.basename(f)
    /emags-.+-(\d+).jpg/ =~ jpg
    id = $1
    html += <<-EOF
<td valign="top">
#{id} <a href="/setidx/#{jpg}">IDX</a> / <a href="/delimage/#{jpg}">DEL</a><br/>
<a href="/image/#{jpg}/" target="_view"><img src="/image/#{jpg}/s"></a>
</td>
EOF
    if lcnt % LINEIMG == LINEIMG - 1
      html += "</tr>\n"
    end
    lcnt += 1
  end
  html += "</table>\n"
end

def put_change_link(hash, tag, type)
  if tag == type
    TYPE[tag]
  else
    "<a href=\"/change/#{hash}/#{type}\">#{TYPE[type]}</a>"
  end
end

def image(jpg, s)
  /^emags-(.+)-\d\d\d\d\.jpg+$/ =~ jpg
  hs2 = $1[0..1]
  magd = "#{$TANKDIR}/emags/#{hs2}/emags-#{$1}"
  f = magd + '/' + jpg
  if s == true
    smdir = magd + '/s'
    FileUtils.mkdir(smdir) if File.exists?(smdir) == false
    if File.exists?(smdir + '/' + jpg) == false
      system "sips --resampleWidth 200 #{magd + '/' + jpg} --out #{smdir}"
    end
    f = smdir + '/' + jpg
  end
  body = ""
  File.open(f) do |fp|
    body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def index(jpg)
  /^emags-(..)/ =~ jpg
  hs2 = $1
  file = "#{$TANKDIR}/emags/#{hs2}/index/#{jpg}"
  body = ""
  File.open(file) do |fp|
    body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def change_tag(hs, tag)
  cd = hs[0..1]
  magdir = "#{$TANKDIR}/emags"
  idxfile = "#{magdir}/#{cd}/index/emags-#{hs}-index.jpg"
  system "tag -r #{FL_FIL},#{FL_SKE},#{FL_NEV} #{idxfile}"
  case tag
  when FL_FIL, FL_SKE, FL_NEV then
    system "tag -a #{tag} #{idxfile}"
  when FL_DEL then
  end
  listfile = "#{magdir}/#{hs[0]}.list"
  FileUtils.remove(listfile) if File.exist?(listfile)
end

def set_index(hs, jpg)
  cd = hs[0..1]
  idxfile = "#{$TANKDIR}/emags/#{cd}/index/emags-#{hs}-index.jpg"
  tag = `tag -l #{idxfile}`.split(/\s/)[1]
  srcfile = "#{$TANKDIR}/emags/#{cd}/emags-#{hs}/#{jpg}"
  FileUtils.copy(srcfile, idxfile)
  system "tag -a #{tag} #{idxfile}"
end

main

