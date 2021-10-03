#
# models
#

require 'active_record'

class Image < ActiveRecord::Base

  LIKE = 1

  ST_PEND  = 'pending'
  ST_FILE  = 'filed'
  ST_DISC  = 'discarded'
  ST_DELE  = 'deleted'

  def self.init
    @@maxid = Image.maximum('id')
    @@images = Hash.new
    @@noexist = Hash.new
  end

  def self.maxid
    @@maxid
  end

  def self.cache(id, im)
    @@images[id] = im
    @@noexist[id] = nil
  end

  def self.uncache(id)
    @@images[id] = nil
    @@noexist[id] = false
  end

  def self.getout(i)
    return nil if @@noexist[i] == false
    if @@images[i] != nil && @@images[i] != false
      STDERR.puts "D-IMG: #{i}" if @@images[i].status == ST_DISC
      return @@images[i]
    else
      begin
        im = Image.find(i)
        if im[:status] == ST_PEND || im[:status] == ST_FILE
          im.status = ST_FILE
          im.save
          self.cache(i, im)
          return im
        else
          self.uncache(i)
          return nil
        end
      rescue
        self.uncache(i)
        return nil
      end
    end
  end

  def self.like(id, lk)
    return nil if lk != true && lk != false
    im = self.getout(id)
    if im != nil
      im.liked = lk
      im.save
      self.cache(id, im)
    end
    im
  end

  def self.status(id, stat)
    im = self.getout(id)
    if im != nil
      if stat == ST_PEND || stat == ST_FILE || stat == ST_DISC || stat == ST_DELE
        im.status = stat
        im.save
        if stat == ST_DISC || stat == ST_DELE
          self.uncache(id, im)
        else
          self.cache(id)
        end
      else
        im = nil
      end
    end
    im
  end
end


