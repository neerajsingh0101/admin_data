require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test admin_data plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for admin_data plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AdminData'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  require './lib/admin_data/version'
  Jeweler::Tasks.new do |s|
    s.name = "admin_data"
    s.version = AdminData::VERSION
    s.summary = s.description = "Dynamic scaffolding for Rails"
    s.email = "neerajdotname@gmail.com"
    s.homepage = "http://github.com/neerajdotname/admin_data"
    s.authors = ['Neeraj Singh']
    s.files = FileList["[A-Z]*", "{app,config,lib,test}/**/*", 'init.rb']
    s.add_dependency 'will_paginate'
    s.add_development_dependency 'flexmock'
    s.add_development_dependency 'shoulda'
    s.add_development_dependency 'factory_girl'
    s.add_development_dependency 'nokogiri'
    s.add_development_dependency 'will_paginate'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => le
  puts "Jeweler not available. Install it for jeweler-related tasks with: gem install jeweler: #{le.message}"
end
