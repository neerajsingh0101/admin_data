require 'rubygems'

def load_will_paginate
  begin
    require 'will_paginate' 
  rescue LoadError => e
      $stderr.puts %(
      ***********************************************
      * gem will_paginate is missing                *
      * Please install will_paginate by executing   * 
      * gem sources -a http://gems.github.com       *
      * sudo gem install mislav-will_paginate       *
      ***********************************************
      )
      raise e
    end
end

load_will_paginate
  
require 'admin_data_date_validation'
require 'admin_data_helpers'

if Rails.version < "2.2.0"
  raise %( plugin admin_data only works with Rails 2.2 and higher)
elsif Rails.version > '2.2.0' && Rails.version < '2.3.0'
  raise %( This version of plugin admin_data only works with Rails 2.3 and higher. You are using Rails 2.2 . Please read README on how to use this plugin with Rails 2.2'   )
end
