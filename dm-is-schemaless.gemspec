# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-is-schemaless}
  s.version = "0.9.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["brianthecoder"]
  s.date = %q{2009-05-08}
  s.default_executable = %q{dm-is-schemaless}
  s.email = %q{wbsmith83@gmail.com}
  s.executables = ["dm-is-schemaless"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "History.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "bin/dm-is-schemaless",
    "lib/dm-is-schemaless.rb",
    "lib/dm-is-schemaless/index.rb",
    "lib/dm-is-schemaless/is/schemaless.rb",
    "lib/dm-is-schemaless/is/version.rb",
    "spec/dm-is-schemaless_spec.rb",
    "spec/integration/schemaless_spec.rb",
    "spec/models.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/BrianTheCoder/dm-is-schemaless}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{A way to store schemaless data in any supported adapter}
  s.test_files = [
    "spec/dm-is-schemaless_spec.rb",
    "spec/integration/schemaless_spec.rb",
    "spec/models.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
