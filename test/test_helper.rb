pwd = File.dirname(__FILE__)

$:.unshift File.join(pwd + '..', 'lib')
$:.unshift File.join(pwd + '..', 'app')
$:.unshift File.join(pwd + '..', 'app', 'controllers')
$:.unshift File.join(pwd + '..', 'app', 'controllers', 'admin_data')

ENV['RAILS_ENV'] = 'test'

rails_root = File.join(pwd , 'rails_root')

# start rails
require "#{rails_root}/config/environment.rb"

require 'admin_data'
Dir[File.join(pwd, '..', 'app', 'controllers', 'admin_data', '*.rb')].each {|f| require f}
require "#{rails_root}/../../config/routes.rb"

require 'test/unit'
require 'rails/test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# for helper tests
require 'action_view/test_case'

Dir[File.join(pwd, 'factories', '*.rb')].each { |f| require File.expand_path(f) }

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

