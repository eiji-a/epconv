#

require 'graphql'
require_relative './query.rb'
#require_relative './mutation.rb'

class EptankSchema < GraphQL::Schema

  query QueryType
  #mutation MutationType

end

