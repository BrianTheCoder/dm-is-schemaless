require 'dm-is-schemaless/is/schemaless'
require 'dm-is-schemaless/is/index'
require 'dm-types'
require 'guid'

module DataMapper::Model
  include DataMapper::Is::Schemaless
end
