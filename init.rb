AdminData::Version = AdminData::VERSION = '0.0.5'


# not requiring rubygems because of this http://gist.github.com/54177
#require 'rubygems'

# do not want to raise exception if will_paginate is missing because running
# rake gems:install will never complete
# this is the reason why this method returns a boolean value
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
      * gem sources -a http://gems.github.com       *
      * sudo gem install mislav-will_paginate       *
      ***********************************************
      )
      false
   end
end

if load_will_paginate

   require 'admin_data_date_validation'

   if Rails.version < "2.2.0"
      raise %( plugin admin_data only works with Rails 2.2 and higher)
   elsif Rails.version > '2.2.0' && Rails.version < '2.3.0'
      raise %( This version of plugin admin_data only works with Rails 2.3 and higher. You are using Rails 2.2 . Please read README on how to use this plugin with Rails 2.2'   )
   end

end

ActionView::Base.send :include, AdminData::Helpers

require File.join(RAILS_ROOT,'vendor', 'plugins', 'admin_data', 'lib', 'admin_data','settings.rb')
AdminDataConfig.set = {
  :plugin_dir => File.join(RAILS_ROOT,'vendor','plugins','admin_data'),
  :will_paginate_per_page => 50,
  :view_security_check => lambda {|controller| return true if Rails.env.development? },
  :update_security_check => lambda {|controller| return true if Rails.env.development? },
  :use_admin_data_layout => true
}

require File.join(RAILS_ROOT,'vendor', 'plugins', 'admin_data', 'lib', 'admin_data','util.rb')
