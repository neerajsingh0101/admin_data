# do not raise exception if will_paginate is missing because running. rake gems:install will never complete
def load_will_paginate
  begin
    require 'will_paginate'
    true
  rescue LoadError => e
    $stderr.puts %(
    *************************************************************************************************
    *                                                                                               *
    * gem will_paginate is missing                                                                  *
    * plugin admin_data depends on will_paginate                                                    *
    * Please install will_paginate by adding following line to Gemfile                              *
    * gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3' *
    *                                                                                               *
    *************************************************************************************************
    )
    false
  end
end

if load_will_paginate

  require 'admin_data_date_validation'

  #if Rails.version < "3.0.0"
    #raise %( This version of plugin admin_data only works with Rails 3.0.0 or higher)
  #end

  ActionView::Base.send :include, AdminData::Helpers

  require File.join(Rails.root, 'vendor', 'plugins', 'admin_data', 'lib', 'admin_data', 'compatibility.rb')

  require File.join(Rails.root, 'vendor', 'plugins', 'admin_data', 'lib', 'admin_data', 'settings.rb')
  AdminData::Config.initialize_defaults

  require File.join(Rails.root, 'vendor', 'plugins', 'admin_data', 'lib', 'admin_data','util.rb')
end
