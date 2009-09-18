require 'pathname'

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-is-schemaless/is/version'

AUTHOR = 'Brian Smith'
EMAIL  = 'brian@memoryreel.com'
GEM_NAME = 'dm-is-schemaless'
GEM_VERSION = DataMapper::Is::Schemaless::VERSION
GEM_DEPENDENCIES = [['dm-core', GEM_VERSION], ['dm-types', GEM_VERSION], ['guid']]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.rdoc LICENSE TODO History.rdoc ] }

PROJECT_NAME = 'dm is schemaless'
PROJECT_URL  = "http://github.com/datamapper/dm-more/tree/master/#{GEM_NAME}"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'A plugin for datamapper that allows you to use rdbms\'s like a schemaless storage system'

[ ROOT, ROOT.parent ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
