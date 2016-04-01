#!/usr/bin/ruby
#
# except.rb: except images not necessary to evaluate
#
# usage: except.rb <tank_dir>
#    <tank_dir> : directory of image tank
#

require 'fileutils'

require_relative 'epconvlib'

def main
  init

  Dir.glob($TANKDIR + "/" + MAGDIR + "/*/index/*.jpg") do |f|
    except_magdir(f)
  end
  db_close
end

def init
  if ARGV.size != 1 || is_tankdir(ARGV[0]) == false
    STDERR.puts "usage: except.rb <tank_dir>"
    STDERR.puts "   <tank_dir> : directory of image tank"
    exit 1
  end

  $TANKDIR = ARGV[0]
  db_open($TANKDIR)
end

def except_magdir(idx)
  tag = get_tag(idx)
  if tag == EXCPTAG
    bn = File.basename(idx)
    puts "IM=#{bn}, T=#{tag}"
  end
end


main
