#/usr/bin/ruby
#

require_relative 'epconvlib'

USAGE = 'Usage: findsame2html.rb [<dispsize> [<skipsize>]]'
URL = 'http://192.168.11.50:4567/imageno/'
TANK = '/Volumes/eahd2/pictures/hptank/tank.sqlite'

def init

  if ARGV.size >= 1
    @disp = ARGV[0].to_i
  else
    @disp = 200
  end
  if ARGV.size >= 2
    @skip = ARGV[1].to_i
  else
    @skip = 0
  end

  @images = Hash.new
  sql = "SELECT id, xreso, yreso, filesize, status, filename FROM images;"
  cmd = "echo \"#{sql}\" | sqlite3 #{TANK}"
  #puts "CMD:#{cmd}"
  `#{cmd}`.lines.each do |l|
    l2 = l.chomp.split('|')
    @images[l2[0].to_i] = l2
  end
  
end

def check_images(id0, ids)
  img0 = @images[id0.to_i]
  maghead = if img0[5] =~ /^#{FILE_MAG}/ then img0[5].slice(0, 46) else "" end
  maxarea = img0[1].to_i * img0[2].to_i
  maxfsz  = img0[3].to_i

  imgs = Array.new
  ids.each do |i|
    img = @images[i.to_i]
    next if maghead != "" && img[5] =~ /^#{maghead}/
    next if img[4] == 'duplicated'
    next if @parent[id0] != nil
    next if img[2].to_i / img[1].to_i > 5

    @parent[i] = id0
    area = img[1].to_i * img[2].to_i
    maxarea = if area > maxarea then area else maxarea end
    maxfsz  = if img[3].to_i > maxfsz then img[3].to_i else maxfsz end
    imgs << i.to_i
  end
  return nil if imgs.size == 0
  [maxarea, maxfsz] + [id0.to_i] + imgs
end

def info_html(id, maxarea, maxfsz)
  im = @images[id]
  id = im[0]
  xr = im[1]
  yr = im[2]
  fs = im[3].gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  st = im[4]
  nm = im[5]
  area = im[1].to_i * im[2].to_i
  szhtml = "#{xr} x #{yr}"
  szhtml = "<strong>#{szhtml}</strong>" if area >= maxarea
  fshtml = "#{fs}"
  fshtml = "<strong>#{fshtml}</strong>" if im[3].to_i >= maxfsz

  "#{nm}<br/>(#{id}) #{szhtml} / #{fshtml} bytes [#{st}]"
end

def put_result(l)
  puts "#{l.chomp}"
end

def put_header
  print <<-"EOS"
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>findsame: results</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.1.2/css/bulma.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css">
  </head>
  <body>
  <section class="hero is-info is-bold">
  <div class="hero-body">
    <div class="container">
      <h1 class="title">findsame: results</h1>
      <h2 class="subtitle">#{@h}</h2>
    </div>
  </div>
  </section>
  <section class="section">
  <div class="container is-fluid">
  EOS
end

def put_footer
  print <<-"EOS"
  </div>
  </section>
  </body>
</html>
  EOS

end

def read_list
  h = STDIN.gets
  @h = h

  @list = Hash.new
  @parent = Hash.new
  cnt = 0
  skip = 0
  STDIN.each do |l|
    if skip < @skip
      skip += 1
      next
    end
    break if cnt >= @disp

    img = l.split(/:/)
    img[1] =~ /^\[(.+)\]$/
    is = $1.split(/,/)

    images = check_images(img[0], is)
    next if images == nil

    @list[img[0]] = images
    #is.each do |i|
    #  info = info_html(i)
    #  next if info =~ /deleted/
    #end

    cnt += 1
  end
end

def main
  init

  read_list

  put_header

  idx = 1
  @list.each do |k, v|
    print <<-"EOS"
    <div class="box">
    No. #{@skip + idx}
    <div class="columns is-gapless">
    EOS

    maxarea = v.shift
    maxfsz  = v.shift
    v.each do |i|
      info = info_html(i, maxarea, maxfsz)
      print <<-"EOS"
      <div class="column is-3 is-marginless">
        #{info}
        <br/>
        <a href="#{URL}#{i}">
          <figure class="image">
            <img src="#{URL}#{i}">
          </figure>  
        </a>
      </div>
      EOS
    end

    print <<-"EOS"
    </div>
    </div>
    EOS
    idx += 1
  end

  put_footer
end

main


