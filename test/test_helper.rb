$:.unshift(File.join(File.dirname(__FILE__) + '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__) + '..', 'app'))
$:.unshift(File.join(File.dirname(__FILE__) + '..', 'app','controllers'))
$:.unshift(File.join(File.dirname(__FILE__) + '..', 'app','controllers','admin_data'))

module AdminData
end

ENV['RAILS_ENV'] = 'test'

rails_root = File.join(File.dirname(__FILE__) , 'rails_root')

# start rails
require "#{rails_root}/config/environment.rb"

#require all the lib items plugin needs
f = File.join(File.dirname(__FILE__), '..', 'lib', 'admin_data', '*.rb')
Dir.glob(f).each {|file| require file }


#require validation code
f = File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')
Dir.glob(f).each {|file| require file }

#require all the controllers plugins needs
f = File.join(File.dirname(__FILE__), '..', 'app', 'controllers','admin_data', '*.rb')
Dir.glob(f).each {|controller| require controller }

# make sure that plugin views have access to helpers
ActionView::Base.send :include, AdminData::Helpers

#require plugin routes
require "#{rails_root}/../../config/routes.rb"


#require all the controllers from the test controllers
f = File.join(File.dirname(__FILE__), 'rails_root', 'app', 'controllers', '*.rb')
Dir.glob(f).each {|controller| require controller }

require 'test/unit'
#require 'test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{rails_root}/db/migrate")


gem 'thoughtbot-shoulda','>= 2.10.2'
require 'shoulda'

gem 'mislav-will_paginate'
require 'will_paginate'

gem 'thoughtbot-factory_girl','>= 1.2.2'
require 'factory_girl'

gem 'flexmock'
require 'flexmock'


#require all factories
f = File.join(File.dirname(__FILE__), 'factories', '*.rb')
Dir.glob(f).each {|file| require file}

AdminDataConfig.set = {
  :plugin_dir => File.join(File.dirname(__FILE__),'..'),
  :will_paginate_per_page => 50,
  :view_security_check => lambda {|controller| return true },
  :update_security_check => lambda {|controller| return false },
}

class Test::Unit::TestCase

  def revoke_read_only_access 
    AdminDataConfig.set=({:view_security_check => Proc.new { |controller| false } })
  end

  def grant_read_only_access 
    AdminDataConfig.set=({:view_security_check => Proc.new { |controller| true } })
  end

  def grant_update_access
    AdminDataConfig.set=({:update_security_check => Proc.new { |controller| true } })
  end

  def revoke_update_access
    AdminDataConfig.set=({:update_security_check => Proc.new { |controller| false } })
  end

end

# to test helper tests
require 'action_view/test_case' 
