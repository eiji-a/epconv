#

require 'graphql'

module Types

  class BaseObject < GraphQL::Schema::Object
  end

  class BaseEnum < GraphQL::Schema::Enum
  end

  class ImageStatus < BaseEnum
    value "pending"
    value "filed"
    value "discarded"
    value "deleted"
  end

  class Types::Image < BaseObject
    description 'Image object type'
  
    field :id, Int, null: false
    field :filename, String, null: false
    #field :url, String, null: false
    field :status, ImageStatus, null: false
    field :xreso, Int, null: false
    field :yreso, Int, null: false
    field :filesize, Int, null: false
    field :liked, Boolean, null: false
  end

  class ImageResult < BaseObject
    description 'One Image Result Object Type'

    field :success, Boolean, null: false
    field :errors, [String], null: false
    field :image, Image, null: true
  end

  class ImagesResult < BaseObject
    description 'One Image Result Object Type'

    field :success, Boolean, null: false
    field :errors, [String], null: false
    field :images, [Image], null: true
  end



end
