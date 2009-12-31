class AdminDataConfig

  cattr_accessor :setting

  def self.set=(input = {})
    valid_keys = %w( find_conditions     
                     plugin_dir            
                     will_paginate_per_page 
                     is_allowed_to_view 
                     feed_authentication_user_id
                     feed_authentication_password
                     is_allowed_to_view_model 
                     is_allowed_to_update
                     is_allowed_to_update_model
                     column_settings    
                     columns_order
                     use_admin_data_layout ).collect(&:intern)
    
    extra_keys = input.keys - valid_keys
    raise "Following options are not supported. #{extra_keys.inspect}" unless extra_keys.empty?
    
    self.setting ||= {} 
    self.setting.merge!(input)

    self.setting.merge!(:adapter_name =>  ActiveRecord::Base.connection.adapter_name)
  end
  
  def self.initialize_defaults
    self.set = {

      :plugin_dir                   => File.expand_path(File.join(File.dirname(__FILE__),'..', '..')),

      :will_paginate_per_page       => 50,
      
      :is_allowed_to_view           => lambda {|controller| 
                                         return true if Rails.env.development? || Rails.env.test?  },
      
      :is_allowed_to_update         => lambda {|controller| 
                                         return true if Rails.env.development? || Rails.env.test? },
      
      :is_allowed_to_view_model     => lambda {|controller| return true },
      
      :is_allowed_to_update_model   => lambda {|controller| return true },
      
      :use_admin_data_layout        => true,

      :find_conditions              => nil,

      :columns_order                => nil
    }
  end

end
