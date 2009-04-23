require 'pathname'
require 'rubygems'

gem 'dm-core', '~>0.9.10'
require 'dm-core'
require 'dm-types'
require 'extlib'
require 'guid'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-schemaless' / 'is' / 'schemaless'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-schemaless' / 'index'

DataMapper::Model.append_extensions DataMapper::Is::Schemaless
