#!/usr/bin/ruby
#
# epicsrv2
#

USAGE = "Usage: epicsrv2.rb <port> <dbfile>"

require 'socket'

PORT = 11081
CHILD = __dir__ + '/epiccli.rb'

def exec_child(url)
  cpid = spawn("#{CHILD} #{$dbfile} #{url}")
  puts "(#{cpid}) #{url}"
end

def service(client)
  while url = client.gets.chomp do
    break if url == "quit"
    exec_child(url)
  end
end

def init
  if ARGV.size != 2
    STDERR.puts "Invalid arguments."
    STDERR.puts USAGE
    exit 1
  end

  if ARGV[0].match(/[0-9]+/)
    $port = ARGV[0].to_i
  else
    $port = PORT
  end

  if File.exist?(ARGV[1])
    $dbfile = ARGV[1]
  else
    STDERR.puts "DB file not found."
    STDERR.puts USAGE
    exit 1
  end

  STDERR.puts "Wating connections on port #{$port}."
end

def main
  init
  server = TCPServer.open($port)
  c = server.accept
  service(c)
  server.close
  STDERR.puts "Close service."
end

main
