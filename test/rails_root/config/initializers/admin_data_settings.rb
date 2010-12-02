if Rails.env.production?
  AdminData::Config.set = {
    :is_allowed_to_view => lambda {|controller| return true  },
    :is_allowed_to_update => lambda {|controller| return false },
    :will_paginate_per_page => 20
  }
else
  AdminData::Config.set = {
    :is_allowed_to_view => lambda {|controller| return true  },
    :is_allowed_to_update => lambda {|controller| return true },
    :feed_authentication_user_id => 'admin_data',
    :feed_authentication_password => 'welcome',
    :will_paginate_per_page => 2
  }

end
