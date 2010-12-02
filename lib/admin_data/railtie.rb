require 'admin_data_date_validation'
require 'admin_data/config'
require 'admin_data/helpers'
require 'admin_data/util'
require 'admin_data/chelper'

module AdminData
  class Engine < Rails::Engine

    initializer "admin_data.setup" do
      AdminData::Config.set = { :adapter_name =>  ActiveRecord::Base.connection.adapter_name }
    end

    rake_tasks do
      #
    end
  end
end
