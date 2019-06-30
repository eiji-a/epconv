#/usr/bin/ruby
#

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

def info_html(id)
  im = @images[id.to_i]
  i = im[0]
  x = im[1]
  y = im[2]
  f = im[3].gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  s = im[4]
  n = im[5]
  "#{n}<br/>(#{i}) #{x} x #{y} / <strong>#{f}</strong> bytes [#{s}]"
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
  <div class="container is-fluid">
  EOS
end

def put_footer
  print <<-"EOS"
  </div>
  </body>
</html>
  EOS

end

def read_list
  h = STDIN.gets
  @h = h

  @list = Hash.new
  cnt = 0
  skip = 0
  STDIN.each do |l|
    if skip < @skip
      skip += 1
      next
    end
    break if cnt > @disp

    img = l.split(/:/)
    img[1] =~ /^\[(.+)\]$/
    is = $1.split(/,/)
    @list[img[0]] = is

          #{info_html(img[0])}
    is.each do |i|
      info = info_html(i)
      next if info =~ /deleted/
    end

    cnt += 1
  end
end

def main
  init

  read_list

  put_header

  @list.each do |k, v|
    print <<-"EOS"
    <div class="columns">
      <div class="column is-3 is-marginless">
      <div class="box">
        #{info_html(k)}
        <br/>
        <a href="#{URL}#{k}">
          <figure class="image">
            <img src="#{URL}#{k}">
          </figure>  
        </a>
      </div>
      </div>
    EOS

    v.each do |i|
      info = info_html(i)
      #next if info =~ /deleted/
      print <<-"EOS"
      <div class="column is-3 is-marginless">
      <div class="box">
        #{info}
        <br/>
        <a href="#{URL}#{i}">
          <figure class="image">
            <img src="#{URL}#{i}">
          </figure>  
        </a>
      </div>
      </div>
      EOS
    end

    print <<-"EOS"
    </div>
    EOS
  end

  put_footer
end

main


