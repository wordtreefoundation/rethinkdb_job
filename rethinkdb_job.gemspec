# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'rethinkdb_job/version'

Gem::Specification.new do |s|
  s.name          = "rethinkdb_job"
  s.version       = RethinkdbJob::VERSION
  s.authors       = ["Duane Johnson"]
  s.email         = ["duane.johnson@gmail.com"]
  s.homepage      = "https://github.com//rethinkdb_job"
  s.summary       = "Stores job queue data in rethinkdb"
  s.description   = "Stores job queue data in rethinkdb"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'

  s.add_dependency 'rethinkdb', '~>1.13.0'

  s.add_development_dependency 'debugger'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
end
