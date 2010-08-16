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


if Rails.version >= '3.0'
  require 'admin_data/railtie'
else
  raise "Please see documentation at http://neerajdotname.github.com/admin_data to find out how to use this plugin with rails 2.3"
else

require 'admin_data_date_validation'
require 'admin_data/helpers'
require 'admin_data/chelper'
require 'admin_data/compatibility'
require 'admin_data/settings'
require 'admin_data/util'

AdminData::Config.initialize_defaults
ActionView::Base.send :include, AdminData::Helpers
