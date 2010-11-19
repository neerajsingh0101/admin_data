require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test admin_data gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for admin_data gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AdminData'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  require './lib/admin_data/version'
  Jeweler::Tasks.new do |s|
    s.name = "admin_data"
    s.version = AdminData::VERSION
    s.summary = s.description = "Manage database using browser"
    s.email = "neerajdotname@gmail.com"
    s.homepage = "http://github.com/neerajdotname/admin_data"
    s.authors = ['Neeraj Singh']
    s.files = FileList["[A-Z]*", "{app,config,lib,test}/**/*", 'init.rb']

    s.add_dependency('will_paginate', '>= 3.0.pre2')

    s.add_development_dependency 'flexmock', '>= 0.8.7'
    s.add_development_dependency 'shoulda', '>= 2.11.3'
    s.add_development_dependency 'factory_girl_rails'
    s.add_development_dependency 'nokogiri', '>= 1.4.3.1'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => le
  puts "Jeweler not available. Install it for jeweler-related tasks with: gem install jeweler: #{le.message}"
end



#TODO delete and destroy from show page do not provide any feedback
