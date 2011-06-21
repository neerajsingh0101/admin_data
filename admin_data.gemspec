# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "admin_data/version"

Gem::Specification.new do |s|
  s.name        = "admin_data"
  s.version     = AdminData::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Neeraj Singh"]
  s.email       = ["neeraj@BigBinary.com"]
  s.homepage    = ""
  s.summary     = %q{Manage data as if you own it}
  s.description = %q{Manage data as if you own it}

  s.rubyforge_project = "admin_data"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
