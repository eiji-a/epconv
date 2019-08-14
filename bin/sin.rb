#!/usr/bin/ruby
#
#

require 'sinatra'
require 'sinatra/reloader'

require_relative 'epconvlib'

NIMG = 200
#NIMGPAGE = 50
NIMGPAGE = 30
LINEIMG = 10

def main
  init

  set :server, %w[webrick]
  set :bind, $IPADDR

  before do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
  end

  # for page

  get '/' do
    redirect "/top/n/1/all"
  end

  get '/top/:sort?/:pg?/:filter?' do |st, pg, filter|
    st = ST_NAME if st == '' || st == nil
    pg = 1 if pg.to_i == nil
    filter = 'all' if filter == nil
    top st, pg, filter
  end

  get '/mag/:st/:pg/:filter/:id/:fst?' do |st, pg, filter, id, fst|
    fst = '0' if fst == nil
    mag st, pg, filter, id, fst.to_i
  end

  get '/page/:im/:pg/:size?' do |im, pg, sz|
    sz = 'fit' if sz == nil
    page im, pg, sz
  end

  get '/same/' do
    same
  end

  get '/samedtl/:hash1/:hash2' do |hs1, hs2|
    samedtl hs1, hs2
  end

  get '/piclist/:sort?/:pg?/:filter?' do |st, pg, filter|
    st = ST_NAME if st == '' || st == nil
    pg = 1 if pg.to_i == nil
    filter = 'all' if filter == nil
    piclist st, pg, filter
  end

  # for manipulate

  get '/change/:sort/:pg/:filter/:type/:id/:stat' do |st, pg, filter, type, id, stat|
    id2 = change_stat(type, id, stat)
    case type
    when 'maglist'
      redirect "/top/#{st}/#{pg}/#{filter}"
    when 'magpage'
      redirect "/mag/#{st}/#{pg}/#{filter}/#{id2}/0"
    when 'magimage'
      redirect "/mag/#{st}/#{pg}/#{filter}/#{id2}/0"
    end
  end

  get '/setidx/:st/:pg/:filter/:id/:imid' do |st, pg, filter, id, imid|
    set_index(id, imid)
    redirect "/mag/#{st}/#{pg}/#{filter}/#{id}/0"
  end

  # for parts

  get '/image/:jpg/:small?' do |jpg, s|
    s = if s == nil then false else true end
    content_type :jpg
    image jpg, s
  end

  get '/imageno/:id' do |id|
    content_type :jpg
    imageno id.to_i
  end

  get '/imageinfo/:id' do |id|
    content_type :text
    imageinfo id.to_i
  end

  get '/index/:jpg' do |jpg|
    content_type :jpg
    index jpg
  end

  # findsame APIs

  get '/findsame/:len/:skip' do |len, skip|
    content_type :json
    findsame len.to_i, skip.to_i
  end

  get '/discardfs/:imgid/:len/:skip' do |imgid, len, skip|
    discard imgid.to_i
    content_type :json
    findsame len.to_i, skip.to_i
  end

  get '/revivefs/:imgid/:len/:skip' do |imgid, len, skip|
    revive imgid.to_i
    content_type :json
    findsame len.to_i, skip.to_i
  end

  # viewimage APIs

  get '/viewimage/:len/:skip' do |len, skip|
    content_type :json
    viewimage len.to_i, skip.to_i
  end

  # pendings APIs

  get '/pendings/:len/:skip' do |len, skip|
    content_type :json
    pendings len.to_i, skip.to_i
  end

  get '/discardpd/:imgid/:len/:skip' do |imgid, len, skip|
    discard imgid.to_i
    content_type :json
    pendings len.to_i, skip.to_i
  end

  get '/revivepd/:imgid/:len/:skip' do |imgid, len, skip|
    revive imgid.to_i
    content_type :json
    pendings len.to_i, skip.to_i
  end

  get '/confirm/:len/:skip' do |len, skip|
    confirm len.to_i, skip.to_i
    content_type :json
    pendings len.to_i, skip.to_i
  end

  get '/refresh/:len' do |len|
    content_type :json
    refresh_images
    pendings len.to_i, 0
  end

end

def init
  exit 1 if init_base(ARGV) == false
  $MAGDIR = $TANKDIR + MAGDIR
  $PICDIR = $TANKDIR + PICDIR
  $CACHE = Array.new
  "0123456789abcdef".chars.each do |c1|
    "0123456789abcdef".chars.each do |c2|
      $CACHE << "#{c1}#{c2}"
    end
  end

  $discarded_image = __dir__ + "/../doc/discarded.jpg"

  inquire_image_info
  refresh_images
  
  $fslist = Array.new
  if ARGV.size == 3
    $fsfile = ARGV[2]
    read_fslist($fsfile)
  end

end

def refresh_images
  make_viewimages
  make_pendings
end

def make_viewimages
  print "Making view images ... "
  $viewimages = Array.new
  $images.each do |k, v|
    #fn = fname_to_path(v[5])
    $viewimages << v if v[4] == ST_FILE
  end
  puts "done."
end

def make_pendings
  print "Making pending images ... "
  $pendimages = Array.new
  $images.each do |k, v|
    #fn = fname_to_path(v[5])
    $pendimages << v if v[4] == ST_PEND || v[4] == ST_DISCD
  end
  puts "done."
end

def inquire_image_info
  print "Reading all image infomations ... "
  $images = Hash.new
  db_open($TANKDIR)
  sql = "SELECT id, xreso, yreso, filesize, status, filename FROM images;"
  db_execute(sql).each do |r|
    $images[r[0].to_i] = [r[0], r[1], r[2], r[3], r[4], r[5]]
  end
  db_close
  puts "done."
end

def check_images(id0, ids)
  img0 = $images[id0.to_i]
  maghead = if img0[5] =~ /^#{FILE_MAG}/ then img0[5].slice(0, 46) else "" end
  maxarea = img0[1].to_i * img0[2].to_i
  maxfsz  = img0[3].to_i

  imgs = Array.new
  ids.each do |i|
    img = $images[i.to_i]
    next if maghead != "" && img[5] =~ /^#{maghead}/
    # next if img[4] == 'duplicated' || img[4] == 'deleted'
    next if $parent[id0] != nil
    next if img[2].to_i / img[1].to_i > 5

    $parent[i] = id0
    imgs << i.to_i
  end
  return nil if imgs.size == 0
  [id0.to_i] + imgs
end

def read_fslist(fname)
  print "making findsame list ... "
  $parent = Hash.new
  File.open(fname) do |fp|
    h = fp.gets
    @h = h

    fp.each do |l|
      img = l.split(/:/)
      img[1] =~ /^\[(.+)\]$/
      is = $1.split(/,/)

      images = check_images(img[0], is)
      next if images == nil
      $fslist << images
    end
  end
  puts "done."
end

### RESTful APIs

def top(st, cd, filter)
  db_open($TANKDIR)
  @pg = cd.to_i
  @st = st
  @filter = filter

  @tags = get_tag
  mags = get_maglist(filter)
  @listsize = mags.size
  ps = (@pg - 1) * NIMGPAGE
  pe = ps + NIMGPAGE - 1
  @displist = mags[ps..pe]
  db_close

  erb :top
end

def get_maglist(st)
  list = ""
  $CACHE.each do |l|
    if File.exist?($MAGDIR + "#{l}.list") == false
      File.open($MAGDIR + "#{l}.list", 'w') do |fp|
        sql = "SELECT filename, mags.status, mags.id FROM mags, images" +
              " WHERE mags.cover_id = images.id" +
              "   AND mags.magname LIKE 'emags-#{l}%'"
        l = ""
        db_execute(sql).each do |r|
          l += r.join('|') + "\n"
        end
        fp.write(l)
        list += l
      end
    else
      File.open($MAGDIR + "#{l}.list", 'r') do |fp|
        list += fp.read
      end
    end
  end

  stats = Array.new
  list.lines.each do |l|
    l2 = l.chomp.split(/\|/)
    next if st != ST_ALL && l2[1] != st
    stats << l2
  end
  stats
end

def get_tag
  tags = Hash.new
  sql = "SELECT tag, count(target_id) FROM tagged, tags" +
        " WHERE tagged.target = ?" +
        "   AND tagged.tag_id = tags.id" +
        " GROUP BY tag"
  db_execute(sql, TAG_MAG)
end

def put_filter_link(cd, filter, type)
  if filter == type
    type
  else
    "<a href=\"/top/#{cd}/#{type}\">#{type}</a>"
  end
end

def mag(st, pg, filter, id, fst)
  db_open($TANKDIR)
  sql = "SELECT magname, mags.status, filename FROM mags, images" +
        " WHERE mags.id = ? AND mags.cover_id = images.id"
  mag = db_execute(sql, id)[0]
  @id = id
  @stat = mag[1]
  @idxfile = mag[2]
  @st = st
  @pg = pg
  @filter = filter
  sql = "SELECT filename, status, images.id FROM images, magimage" +
        " WHERE magimage.mag_id = ? AND magimage.image_id = images.id"
  @list = db_execute(sql, id)
  @sizes, @total = read_magsize(mag[0][6..45])
  db_close
  erb :mag
end

def page(hs, pg, sz)
  @page  = pg.to_i
  @pg = sprintf("%04d", @page)
  imgbase = $MAGDIR + "#{hs[0..1]}/emags-#{hs}/emags-#{hs}"
  @npage = `ls -1 #{imgbase}*`.lines.size
  @info = get_info("#{imgbase}-#{@pg}.jpg")
  @image = hs
  @size = sz
  @slist = {'50' => 'width="50%"',
            '75' => 'width="75%"',
            '100' => 'width="100%"',
            'fit' => 'height="1050px"',
            'org' => ''}
  erb :page
end

def get_info(file)
  fsize = File.size?(file)
  info = `sips -g all #{file}`.lines
  px = 0
  py = 0
  info.each do |i|
    px = i.chomp.split(/:\s+/)[1] if /pixelWidth/ =~ i
    py = i.chomp.split(/:\s+/)[1] if /pixelHeight/ =~ i
  end
  return [fsize.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,'), px, py]
end

def read_magsize(hs)
  cd = hs[0..1]
  mag = $TANKDIR + MAGDIR + cd + "/emags-#{hs}"
  if Dir.exist?("#{mag}/s") == false
    FileUtils.mkdir("#{mag}/s")
  end
  if File.exist?("#{mag}/s/images") == false
    File.open("#{mag}/s/images", 'w') do |fp|
      `ls -l #{mag}/*.jpg`.lines.each do |l|
        info = l.split
        fp.puts "#{File.basename(info[8])} #{info[4]}"
      end
    end
  end
  h = Hash.new
  sz = 0
  File.open("#{mag}/s/images", 'r') do |fp|
    fp.each_line do |l|
      info = l.split
      h[info[0]] = info[1].gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      sz += info[1].to_i
    end
  end
  return [h, sz.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')]
end

def same()
  @sames = Array.new
  emag = $TANKDIR + MAGDIR
  File.open($TANKDIR + 'samemag.log', 'r') do |fp|
    fp.each do |l|
      if /^emags/ =~ l
        /^emags-(.+?):emags-(.+?)=(.+)$/ =~ l
        hs1 = $1
        hs2 = $2
        idx = $3
        h1, s1 = read_magsize(hs1)
        h2, s2 = read_magsize(hs2)
        idx1 = emag + hs1[0..1] + "/index/emags-#{hs1}-index.jpg"
        t1   = `tag -l #{idx1}`.split(/\s/)[1]
        idx2 = emag + hs2[0..1] + "/index/emags-#{hs2}-index.jpg"
        t2   = `tag -l #{idx2}`.split(/\s/)[1]
        sp   = split_idx(idx)
        if (s1 == s2) and
           (h1.size == h2.size) and
           (h1.size == sp.size)
          change_stat(hs2, '0', FL_DEL)
        else
          @sames << [[hs1, h1, s1, t1],
                     [hs2, h2, s2, t2],
                     sp]
        end
      end
    end
  end
  erb :same
end

def samedtl(hash1, hash2)
  @sames = Array.new
  File.open($TANKDIR + 'samemag.log', 'r') do |fp|
    fp.each do |l|
      if /^emags-#{hash1}:?emags-#{hash2}=(.+)/ =~ l
        @sames = split_idx($1)
      end
    end
  end
  @files = Array.new
  @sames.each do |s|
    f1 = $MAGDIR + "#{hash1[0..1]}/emags-#{hash1}/emags-#{hash1}-#{s[0]}.jpg"
    f2 = $MAGDIR + "#{hash2[0..1]}/emags-#{hash2}/emags-#{hash2}-#{s[1]}.jpg"
    @files << [[s[0], get_info(f1)].flatten, [s[1], get_info(f2)].flatten]
    #@files << {s[0] => f1, s[1] => f2}
  end
  @hash = [hash1, hash2]
  erb :samedtl
end

def get_maginfo(hs)
  cdpath, path, pathf = get_path("emags-" + hs)
  sz = `du -ks #{pathf}`.to_i
  ni = `ls -1 #{pathf}/`.to_i
  return [hs, sz, ni]
end

def split_idx(idxs)
  pair = Array.new
  idxs.split(/:/).each do |i|
    next if i == '' || i == nil
    /\((\d+),(\d+)\)/ =~ i
    pair << [$1, $2]
  end
  pair
end

def top_index(cd)
  files = Array.new
  Dir.glob($MAGDIR + "#{cd}/index/*.jpg") do |f|
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

def piclist(st, pg, filter)
  db_open($TANKDIR)
  @pg = pg.to_i
  @st = st
  @filter = filter

  @tags = get_tag
  pics = get_piclist(filter)
  @listsize = pics.size
  ps = (@pg - 1) * NIMGPAGE
  pe = ps + NIMGPAGE - 1
  @displist = pics[ps..pe]
  db_close

  erb :piclist
end

def get_piclist(st)
  list = ""
  $CACHE.each do |l|
    listf = "#{$PICDIR}#{l}.list"
    if File.exist?(listf) == false
      puts "CACHE: #{l}"
      sql = "SELECT filename, images.status, images.id" +
            "  FROM mags, magimage, images" +
            " WHERE mags.magname = 'pictures-#{l}'" +
            "   AND mags.id = magimage.mag_id" +
            "   AND magimage.image_id = images.id;"
      cmd = "sqlite3 #{$TANKDIR}#{DBFILE} \"#{sql}\" > #{listf}"
      system cmd
      #puts "SQL:#{cmd}"

=begin
      File.open($PICDIR + "#{l}.list", 'w') do |fp|
        sql = "SELECT filename, images.status, images.id " +
              "  FROM images, mags, magimage" +
              " WHERE mags.magname = ? AND mags.id = magimage.mag_id" +
              "   AND magimage.image_id = images.id"
        ls = ""
        db_execute(sql, VIRTUALMAG + l).each do |r|
          ls += r.join('|') + "\n"
        end
        fp.write(ls)
        list += ls
      end
=end
    end
    File.open($PICDIR + "#{l}.list", 'r') do |fp|
        list += fp.read
    end
  end

  stats = Array.new
  list.lines.each do |l|
    l2 = l.chomp.split(/\|/)
    next if l2[1] == ST_DELETE
    next if st != ST_ALL && l2[1] != st
    stats << l2
  end
  stats
end

def image(jpg, s)
  /^(.....)-(.+)\.jpg+$/ =~ jpg
  tp = $1
  hs = $2
  hs2 = hs[0..1]
  fn = if tp == 'emags' then
    /^(.+)-(\d+)$/ =~ hs
    magd = $MAGDIR + "#{hs2}/emags-#{$1}"
    if s == true then
      smdir = magd + '/s'
      FileUtils.mkdir(smdir) if File.exists?(smdir) == false
      if File.exists?(smdir + '/' + jpg) == false
        system "sips --resampleWidth 200 #{magd + '/' + jpg} --out #{smdir}"
      end
      smdir + '/' + jpg
    else
      magd + '/' + jpg
    end
  else
    $PICDIR + "#{hs2}/" + jpg
  end

  body = ""
  File.open(fn) do |fp|
      body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def imageno(id)
=begin
  sql = "SELECT filename FROM images WHERE id = ?"
  db_open($TANKDIR)
  fn0 = db_execute(sql, id)[0][0]
  db_close
=end
  fn0 = $images[id][5]
  fn = fname_to_path(fn0)
=begin
  /^(.....)-(.+)\.jpg+$/ =~ fn0
  tp = $1
  hs = $2
  hs2 = hs[0..1]
  fn = if tp =~ /^#{FILE_PIC}/ then
    $PICDIR + "#{hs2}/" + fn0
  else
    /^(.+)-(.+)/ =~ hs
    $MAGDIR + "#{hs2}/#{tp}-#{$1}/" + fn0
  end
=end

  body = ""
  fn = if File.exist?(fn) == false then $discarded_image else fn end
  File.open(fn) do |fp|
    body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def imageinfo(id)
  i = @images[id.to_i]
  return <<-EOS
{
  id:    #{i[0]}
  xreso: #{i[1]}
  yreso: #{i[2]}
  fsize: #{i[3]}
  stat:  #{i[4]}
  fname: #{i[5]}
}
  EOS
end

def index(jpg)
  /^emags-(..)/ =~ jpg
  hs2 = $1
  file = $MAGDIR + "#{hs2}/index/#{jpg}"
  body = ""
  File.open(file) do |fp|
    body = fp.read
  end
  return <<-EOS
#{body}
EOS
end

def change_stat(type, id, stat)
  id2 = id
  db_open($TANKDIR)
  case type
  when 'maglist'
    sql1 = "UPDATE mags SET status = ? WHERE id = ?"
    sql2 = "SELECT magname, id FROM mags WHERE id = ?"
  when 'magpage'
    sql1 = "UPDATE mags SET status = ? WHERE id = ?"
    sql2 = "SELECT magname, id FROM mags WHERE id = ?"
  when 'magimage'
    sql1 = "UPDATE images SET status = ? WHERE id = ?"
    sql2 = "SELECT filename, magimage.mag_id  FROM images, magimage" +
           " WHERE images.id = ? AND images.id = magimage.image_id"
  end
  db_execute(sql1, stat, id)
  fn = db_execute(sql2, id)[0]
  db_close

  del_listfile(fn[0])
  fn[1]
end

def del_listfile(fn)
  /^emags-(..)/ =~ fn
  listfile = $MAGDIR + "#{$1}.list"
  FileUtils.remove(listfile) if File.exist?(listfile)
end

def set_index(id, imid)
  db_open($TANKDIR)
  sql = "UPDATE mags SET cover_id = ? WHERE id = ?"
  db_execute(sql, imid, id)
  sql = "SELECT magname FROM mags WHERE id = ?"
  mn = db_execute(sql, id)[0][0]
  db_close
  del_listfile(mn)
end

def findsame(len, skip)
  skip = if skip < 0 then 0 else skip end
  len = if len < 1 then 1 else len end
  fslist = $fslist[skip..(skip + len - 1)]
  nsame  = $fslist.length
  
  json = <<-EOS
{
  "nimage": #{nsame},
  "images": [
  EOS
  llist = Array.new
  fslist.each do |l|
    l2 = <<-EOS
    [
    EOS
    jlist = Array.new
    l.each do |i|
      im = $images[i]
      j = <<-EOS
      {
        "id": #{im[0]},
        "filename": "#{im[5]}",
        "xreso": #{im[1]},
        "yreso": #{im[2]},
        "filesize": #{im[3]},
        "status": "#{im[4]}"
      }
      EOS
      jlist << j
    end
    l2 += jlist.join(",")
    l2 += <<-EOS
    ]
    EOS
    llist << l2
  end
  json += llist.join(",")
  json += <<-EOS
  ]
}
  EOS
end

def discard(imgid)
  change_status(imgid, ST_DISCD)
end

def revive(imgid)
  change_status(imgid, ST_FILE)
end

def change_status(imgid, st)
  db_open($TANKDIR)
  sql = "UPDATE images SET status = ? WHERE id = ?"
  db_execute(sql, st, imgid)
  db_close
  $images[imgid][4] = st
end

# viewimage APIs

def viewimage(len, skip)
  skip = if skip < 0 then 0 else skip end
  len = if len < 1 then 1 else len end
  vimages = $viewimages[skip..(skip + len - 1)]
  nimage  = $viewimages.length
    
  json = Hash.new
  json['nimage'] = nimage
  json['images'] = Array.new
  vimages.each do |i|
    img = Hash.new
    img['id'] = i[0]
    img['filename'] = i[5]
    img['xreso']    = i[1]
    img['yreso']    = i[2]
    img['filesize'] = i[3]
    img['status']   = i[4]
    json['images'] << img
  end
  json.to_json

end

# pendingimage APIs

def pendings(len, skip)
  skip = if skip < 0 then 0 else skip end
  len = if len < 1 then 1 else len end
  vimages = $pendimages[skip..(skip + len - 1)]
  nimage  = $pendimages.length
    
  json = Hash.new
  json['nimage'] = nimage
  json['images'] = Array.new
  vimages.each do |i|
    img = Hash.new
    img['id'] = i[0]
    img['filename'] = i[5]
    img['xreso']    = i[1]
    img['yreso']    = i[2]
    img['filesize'] = i[3]
    img['status']   = i[4]
    json['images'] << img
  end
  json.to_json

end

# confirm pending images APIs

def confirm(len, skip)
  skip = if skip < 0 then 0 else skip end
  len = if len < 1 then 1 else len end
  vimages = $pendimages[skip..(skip + len - 1)]
  nimage  = $pendimages.length

  vimages.each do |i|
    if i[4] == ST_PEND
      change_status(i[0], ST_FILE)
    elsif i[4] == ST_DISCD
      change_status(i[0], ST_DELETE)
    end
  end
end

main
