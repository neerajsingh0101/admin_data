class AdminDataConfig

  cattr_accessor :setting

  def self.set=(input = {})
    valid_keys = %w(find_conditions     plugin_dir            will_paginate_per_page 
                    view_security_check update_security_check use_admin_data_layout ).collect(&:intern)
    extra_keys = input.keys - valid_keys
    raise "Following options are not supported. #{extra_keys.inspect}" unless extra_keys.empty?
    self.setting ||= {} 
    self.setting.merge!(input)
  end
  
  def self.initialize_defaults
    self.set = {
      :plugin_dir             => File.expand_path(File.join(File.dirname(__FILE__),'..', '..')),
      :will_paginate_per_page => 50,
      :view_security_check    => lambda {|controller| return true if Rails.env.development? || Rails.env.test? },
      :update_security_check  => lambda {|controller| return true if Rails.env.development? || Rails.env.test? },
      :use_admin_data_layout  => true,
      :find_conditions        => nil
    }
  end

end
