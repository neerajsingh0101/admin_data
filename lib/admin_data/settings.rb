class AdminDataConfig

  cattr_accessor :setting

  def self.set=(input = {})
    valid_keys = %w(find_conditions plugin_dir will_paginate_per_page view_security_check update_security_check ).collect(&:intern)
    extra_keys = input.keys - valid_keys
    raise "Following options are not supported. #{extra_keys.inspect}" unless extra_keys.empty?
    self.setting ||= {} 
    self.setting.merge!(input)
  end

end
