require 'rubygems'

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'
require 'faker'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-is-schemaless'
load File.join(File.dirname(__FILE__), 'models.rb')

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

ENV['ADAPTER'] ||= 'postgres'

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/schemaless_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/schemaless_test')
