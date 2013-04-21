#!

require 'digest/md5'
str = 'hoge'
hoge = Digest::MD5.new.update(str)
puts hoge
hoge = Digest::SHA1.new.update(str)
puts hoge
hoge = Digest::SHA256.new.update(str)
puts hoge
hoge = Digest::SHA512.new.update(str)
puts hoge

