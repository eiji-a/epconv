#

require 'graphql'
require_relative './types.rb'
require_relative '../models/models.rb'

class QueryType < GraphQL::Schema::Object
  description "the query root of this schema"

  field :image, Types::ImageResult, null: false do
    description "get one image"
    argument :id, Int, required: true
  end

  def image(**arg)
    img = Image.getout(arg[:id])
    if img == nil
      {
        success: false,
        errors: ["Image not found: ID=#{arg[:id]}"],
        image: nil
      }
    else
      img.liked = if img.liked == 1 then true else false end
        STDERR.puts "GS:LIKE: #{img.to_json}/"
      {
        success: true,
        errors: [],
        image: img
      }
    end
  end

  field :images, Types::ImagesResult, null: false do
    description "get multiple image"
    argument :nimg, Int, required: true
  end

  def images(**arg)
    imgs = Array.new

    n = arg[:nimg]
    while n > 0 do
      r = rand(Image.maxid)
      im = Image.getout(r)
      if im != nil
        imgs << im
        n -= 1
      end
    end

    {
      success: true,
      errors: [],
      images: imgs
    }
  end

end
