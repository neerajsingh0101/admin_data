module AdminData
end

ENV['RAILS_ENV'] = 'test'

rails_root = File.join(File.dirname(__FILE__) , 'rails_root')

# start rails
require "#{rails_root}/config/environment.rb"

#require all the lib items plugin needs
Dir[File.join(File.dirname(__FILE__), '..', 'lib', 'admin_data', '*.rb')].each {|f| require f}


#require all the controllers plugins needs
Dir[File.join(File.dirname(__FILE__), '..', 'app', 'controllers', 'admin_data', '*.rb')].each {|f| require f}

# make sure that plugin views have access to helpers
ActionView::Base.send :include, AdminData::Helpers

#require plugin routes
require "#{rails_root}/../../config/routes.rb"


require 'test_help'
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
Dir[File.join(File.dirname(__FILE__), 'factories', '*.rb')].each {|f| require f}

AdminDataConfig.set = {
  :plugin_dir => File.join(File.dirname(__FILE__),'..'),
  :will_paginate_per_page => 50,
  :view_security_check => lambda {|controller| return true },
  :update_security_check => lambda {|controller| return false },
}

class ActiveSupport::TestCase

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

  def show_response
    Dir.mkdir(File.join(RAILS_ROOT, 'tmp')) unless File.directory?(File.join(RAILS_ROOT,'tmp'))
    response_html = File.join(RAILS_ROOT, 'tmp', 'response.html')
    File.open(response_html,'w') { |f| f.write(@response.body) }
    system 'open ' + File.expand_path(response_html) rescue nil
  end

end

# to test helper tests
require 'action_view/test_case' 
require 'phocus' 
