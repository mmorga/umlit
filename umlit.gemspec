# -*- encoding: utf-8 -*-
require File.expand_path('../lib/umlit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mark Morga"]
  gem.email         = ["mmorga@rackspace.com"]
  gem.description   = %q{UML Diagrams from Text description files}
  gem.summary       = %q{UML Diagrams from Text description files}
  gem.homepage      = "https://github.com/mmorga/umlit"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "umlit"
  gem.require_paths = ["lib"]
  gem.version       = Umlit::VERSION
  gem.add_runtime_dependency "thor"
  gem.add_runtime_dependency "ttfunk"
  gem.add_runtime_dependency "rmagick"
end
