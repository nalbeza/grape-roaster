# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grape_roaster/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'grape-roaster'
  gem.authors       = ['Nicolas Albeza', 'Jérémy Lecerf']
  gem.email         = ['n.albeza@gmail.com', 'redpist.com@gmail.com']
  gem.description   = %q{Fill this someday}
  gem.summary       = %q{And this}
  gem.homepage      = 'https://github.com/pause/grape-roaster'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.version       = GrapeRoaster::VERSION

  #gem.add_runtime_dependency 'roaster', '~> 0.0.6'
  gem.add_runtime_dependency 'grape'

  gem.add_development_dependency "activerecord", "~> 4.1"
  gem.add_development_dependency "activesupport", "~> 4.1"
  gem.add_development_dependency 'minitest', '~> 5.1'
  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rack-test', '~> 0.6'
  gem.add_development_dependency 'sqlite3', '~> 1.3'
  gem.add_development_dependency 'database_cleaner', '~> 1.3'
  gem.add_development_dependency 'json_expressions'
  gem.add_development_dependency 'byebug'

end
