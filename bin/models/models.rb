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

  def self.getout(i)
    return nil if @@noexist[i] == false
    if @@images[i] != nil && @@images[i] != false
      return @@images[i]
    else
      begin
        im = Image.find(i)
        if im[:status] == ST_PEND || im[:status] == ST_FILE
          @@images[i] = im
          im.status = ST_FILE
          im.liked = true
          im.save
          STDERR.puts "ILIKE:#{im.liked}/"
          im[:liked] =
            if im.liked == 1 then
              STDERR.puts "LIKE IS: true"
              false
            else
              STDERR.puts "LIKE IS: false"
              false
            end
          STDERR.puts "ILIKE2:#{im[:liked]}/"
          return im
        else
          @@noexist[i] = false
          return nil
        end
      rescue
        @@noexist[i] == false
        return nil
      end
    end
  end
end


