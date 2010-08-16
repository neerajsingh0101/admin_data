test_dir = File.dirname(__FILE__)

$:.unshift File.expand_path("../..", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)
$:.unshift File.expand_path("../../app", __FILE__)
$:.unshift File.expand_path("../../app/controllers", __FILE__)
$:.unshift File.expand_path("../../app/controllers/admin_data", __FILE__)

$:.unshift File.expand_path("../../test/support", __FILE__)


ENV['RAILS_ENV'] = 'test'

rails_root = File.join(test_dir , 'rails_root')

# start rails
require "#{rails_root}/config/environment.rb"

require 'admin_data'
AdminData::Config.initialize_defaults
ActionView::Base.send :include, AdminData::Helpers

Dir[File.join(test_dir, '..', 'app', 'controllers', 'admin_data', '*.rb')].each {|f| require f}
require "#{rails_root}/../../config/routes.rb"

require 'test/unit'
require 'rails/test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# for helper tests
require 'action_view/test_case'

Dir[File.join(test_dir, 'factories', '*.rb')].each { |f| require File.expand_path(f) }

class ActiveSupport::TestCase

  def revoke_read_only_access_for_feed
    AdminData::Config.set = ({:is_allowed_to_view_feed => Proc.new { |controller| false } })
  end

  def grant_read_only_access_for_feed
    AdminData::Config.set = ({:is_allowed_to_view_feed => Proc.new { |controller| true } })
  end

  def revoke_read_only_access
    AdminData::Config.set = ({:is_allowed_to_view => Proc.new { |controller| false } })
  end

  def grant_read_only_access
    AdminData::Config.set = ({:is_allowed_to_view => Proc.new { |controller| true } })
  end

  def grant_update_access
    AdminData::Config.set = ({:is_allowed_to_update => Proc.new { |controller| true } })
  end

  def revoke_update_access
    AdminData::Config.set = ({:is_allowed_to_update => Proc.new { |controller| false } })
  end

  def show_response
    Dir.mkdir(File.join(Rails.root, 'tmp')) unless File.directory?(File.join(Rails.root, 'tmp'))
    response_html = File.join(Rails.root, 'tmp', 'response.html')
    File.open(response_html, 'w') { |f| f.write(@response.body) }
    system 'open ' + File.expand_path(response_html) rescue nil
  end

end

require 'assertions'
