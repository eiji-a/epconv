#
# models
#

require 'active_record'

class Image < ActiveRecord::Base

  def self.init
    @@maxid = Image.maximum('id')
    @@images = Hash.new
    @@noexist = Hash.new
  end

  def self.maxid
    @@maxid
  end

  def self.getout(i)
    return nil if @@noexist[i] == false

  end


end


