require 'dm-is-schemaless/is/schemaless'
require 'dm-is-schemaless/is/index'
gem 'dm-types', '0.10.0'
require 'dm-types'
require 'guid'

module DataMapper
  module Model
    include DataMapper::Is::Schemaless
  end
end
