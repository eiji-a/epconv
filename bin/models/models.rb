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
    #@@noexist = Hash.new
  end

  def self.maxid
    @@maxid
  end

  def self.cache(im)
    @@images[im[:id]] = im
    #@@noexist[im[:id]] = nil
  end

  def self.uncache(id)
    @@images[id] = nil
    #@@noexist[id] = false
  end

  def self.ids_status(stats)
    ids = Image.select("id").where(status: stats)
    STDERR.puts "IDCLASS: #{ids[0].class}"
    ids
  end

  def self.getout(i)

    #return nil if @@noexist[i] == false
    #if @@images[i] != nil && @@images[i] != false
    if @@images[i] != nil
        STDERR.puts "D-IMG: #{i}" if @@images[i].status == ST_DISC
      return @@images[i]
    else
      begin
        im = Image.find(i)
        self.cache(im)
        if im[:status] == ST_PEND || im[:status] == ST_FILE
          im.status = ST_FILE
          im.save
        else
          im = nil
        end
        return im
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
      self.cache(im)
    end
    im
  end

  def self.status(id, stat)
    STDERR.puts "self.status: STAT #{stat}"
    im = self.getout(id)
    if im != nil
      self.cache(im)
      if stat == ST_PEND || stat == ST_FILE || stat == ST_DISC || stat == ST_DELE
        im.status = stat
        im.save
      else
        im = nil
      end
    end
    im
  end
end


