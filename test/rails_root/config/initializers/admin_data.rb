AdminData.config do |config|

  config.number_of_records_per_page = 2

  config.is_allowed_to_view = lambda {|_| return true}
  config.is_allowed_to_update = lambda {|_| return true}

  config.feed_authentication_user_id = 'admin_data'
  config.feed_authentication_password = 'welcome'

  config.find_conditions = {'City' => lambda { |params| {:conditions => ["name =?", params[:id]] }}}


  config.column_settings = { 'City'  => { :data => lambda { |model| model.send(:data).to_a.flatten.inspect } } }

  config.drop_down_for_associations = { 'PhoneNumber' => false}

  config.columns_order = {'Website' => [:dns_provider, :user_id] }

  config.column_headers = {'City' => {:id => 'ID', :name => 'City Name', :data => 'City Info'}}

end
