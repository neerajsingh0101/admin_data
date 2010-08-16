# do not raise exception if will_paginate is missing because running
# rake gems:install will never complete
def load_will_paginate
  begin
    require 'will_paginate'
    true
  rescue LoadError => e
    $stderr.puts %(
    ***********************************************
    * gem will_paginate is missing                *
    * plugin admin_data depends on will_paginate  *
    * Please install will_paginate by executing   *
    * sudo gem install will_paginate              *
    ***********************************************
    )
    false
  end
end

module AdminData
end

if load_will_paginate 

  if Rails.version < "2.2.0"
    raise %( admin_data only works with Rails 2.2 and higher)
  elsif Rails.version > '2.2.0' && Rails.version < '2.3.0'
    raise %( This version of admin_data only works with Rails 2.3 and higher. ) << 
          %( You are using Rails 2.2 . Please read README on how to use this plugin with Rails 2.2')
  elsif Rails.version >= '3.0'
    require 'admin_data/railtie'
  else

    require 'admin_data_date_validation'
    require 'admin_data/helpers'
    require 'admin_data/chelper'

    ActionView::Base.send :include, AdminData::Helpers

    require 'admin_data/compatibility'
    require 'admin_data/settings'

    AdminData::Config.initialize_defaults

    require 'admin_data/util'

  end
end
