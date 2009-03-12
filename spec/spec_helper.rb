require 'pathname'
require 'rubygems'

gem 'rspec', '~>1.1.11'
require 'spec'

ROOT = Pathname(__FILE__).dirname.parent.expand_path

require ROOT + 'lib/dm-is-schemaless'

require ROOT + 'spec/models'

DataMapper.setup(:default, 'sqlite3::memory:')