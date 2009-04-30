require 'rubygems'

def load_will_paginate
  begin
    require 'will_paginate' 
  rescue LoadError => e
      $stderr.puts %(
      ***********************************************
      * gem will_paginate is missing                *
      * Please install will_paginate by executing   * 
      * sudo gem install will_paginate              *
      ***********************************************
      )
      raise e
    end
end

load_will_paginate
  
require 'routing'
require 'admin_data_date_validation'