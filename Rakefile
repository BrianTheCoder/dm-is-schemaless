# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'dm-is-schemaless'

task :default => 'spec:run'

PROJ.name = 'dm-is-schemaless'
PROJ.authors = 'FIXME (who is writing this software)'
PROJ.email = 'FIXME (your e-mail)'
PROJ.url = 'FIXME (project homepage)'
PROJ.version = DmIsSchemaless::VERSION
PROJ.rubyforge.name = 'dm-is-schemaless'

PROJ.spec.opts << '--color'

# EOF
