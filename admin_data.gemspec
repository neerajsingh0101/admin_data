# -*- encoding: utf-8 -*-
require File.expand_path('../lib/admin_data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Neeraj Singh"]
  gem.email         = ["neerajdotname@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "admin_data"
  gem.require_paths = ["lib"]
  gem.version       = AdminData::VERSION

  gem.add_dependency "rails", "~> 3.2"
  gem.add_dependency "will_paginate"
end
