#OAOA
#
#

require 'sinatra'
require 'sinatra/reloader'

require_relative 'epconvlib'

NIMG = 200
LINEIMG = 5

# filters
FL_ALL = 'all'
FL_FIL = 'filed'
FL_SKE = 'forsketch'
FL_NEV = 'notevaluated'
FL_DEL = 'delete'
TYPE = {FL_FIL => 'FIL', FL_SKE => 'SKE', FL_NEV => 'NEV', FL_DEL => 'DEL'}

def main
  init

  #set :server, %w[webrick]
  set :bind, '192.168.11.111'
  
  get '/top/:code?/:filter?' do |cd, filter|
    top cd, filter
  end
  
  get '/mag/:hash/:fst?' do |hs, fst|
    fst = '0' if fst == nil
    mag hs, fst.to_i
  end

  get '/change/:hs/:tag' do |hs, tag|
    change_tag(hs, tag)
    cd = hs[0..1]
    redirect "/top/#{cd}/"
  end

  get '/setidx/:jpg' do |jpg|
    /emags-(.+)-(\d\d\d\d).jpg/ =~ jpg
    hash = $1
    fst = ($2.to_i / 50) * 50
    set_index(hash, jpg)
    redirect "/mag/#{hash}/#{fst}"
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

def top(cd, filter)
  cd = '00' if cd == nil
  filter = FL_ALL if filter == nil
  codes = Array.new
  Dir.glob($TANKDIR + '/' + MAGDIR + '/??') do |c|
    codes << File.basename(c)
  end
  return <<-EOF
<html>
<head>
  <title>MAG INDEX</title>
</head>
<body>
  HASH: #{cd}<br/>
  CODE: #{code_list(codes, filter)}<br/>
  FILTER: #{put_filter_link(cd, filter, FL_ALL)} |
          #{put_filter_link(cd, filter, FL_FIL)} |
          #{put_filter_link(cd, filter, FL_SKE)} |
          #{put_filter_link(cd, filter, FL_NEV)} </br>
#{list_html1(top_index(cd), filter)}
</body>
</html>

EOF
end

def put_filter_link(cd, filter, type)
  if filter == type
    type
  else
    "<a href=\"/top/#{cd}/#{type}\">#{type}</a>"
  end
end

def mag(hs, fst)
  cd = hs[0..1]
  idxfile = "#{$TANKDIR}/emags/#{cd}/index/emags-#{hs}-index.jpg"
  tag = `tag -l #{idxfile}`.split(/\s/)[1]

  return <<-EOS
<html>
<head>
  <title>MAGS:#{hs}</title>
</head>
<body>
  <a href="/top/#{hs[0, 2]}/">TOP</a><br/>
  <table>
    <tr>
    <td>
    <img src="/index/#{File.basename(idxfile)}" width="200px">
    </td>
    <td valign="top">
  HASH:#{hs} <br/>
  TAG:
  #{put_change_link(hs, tag, FL_FIL)} |
  #{put_change_link(hs, tag, FL_SKE)} |
  #{put_change_link(hs, tag, FL_NEV)} |
  #{put_change_link(hs, tag, FL_DEL)} <br/>
    </td>
    </tr>
  </table>
  <!-- <a href="/mag/#{hs}/#{fst - NIMG}">PREV</a> |
  <a href="/mag/#{hs}/#{fst + NIMG}">NEXT</a> <br/> -->
#{list_html2(mag_index(hs), fst)}
  <a href="/top/#{hs[0, 2]}/">TOP</a><br/>
  <!-- <a href="/mag/#{hs}/#{fst - NIMG}">PREV</a> |
  <a href="/mag/#{hs}/#{fst + NIMG}">NEXT</a><br/> -->
</body>
</html>
EOS
  
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
  idxfile = "#{$TANKDIR}/emags/#{cd}/index/emags-#{hs}-index.jpg"
  system "tag -r #{FL_FIL},#{FL_SKE},#{FL_NEV} #{idxfile}"
  case tag
  when FL_FIL, FL_SKE, FL_NEV then
    system "tag -a #{tag} #{idxfile}"
  when FL_DEL then
  end
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
