require 'admin_data_date_validation'
require 'admin_data/compatibility'
require 'admin_data/settings'
require 'admin_data/helpers'
require 'admin_data/util'
require 'admin_data/chelper'

module AdminData
  class Engine < Rails::Engine

    initializer "admin_data.setup" do
      AdminData::Config.initialize_defaults
      ActionView::Base.send :include, AdminData::Helpers
    end
    
    rake_tasks do
      load 'tasks/admin_data_tasks.rake'
      load 'tasks/validate_models_bg.rake'
    end
  end
end