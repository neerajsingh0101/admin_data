class AdminDataConfig

  cattr_accessor :setting

  def self.set=(input = {})
    valid_keys =
    %w(
    find_conditions
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
    use_google_hosting_for_jquery
    rake_options
    drop_down_for_associations
    ignore_column_limit
    ).collect(&:intern)

    extra_keys = input.keys - valid_keys
    raise "Following options are not supported. #{extra_keys.inspect}" unless extra_keys.empty?

    self.setting ||= {}
    self.setting.merge!(input)

    self.setting.merge!(:adapter_name =>  ActiveRecord::Base.connection.adapter_name)

    unless self.setting[:rake_options].blank?
      env = self.setting[:rake_options][:env]
      if env.blank? || env.include?(Rails.env.intern)
        self.setting[:rake_command] = self.setting[:rake_options][:command]
      end
    end

  end

  def self.initialize_defaults
    self.setting = {

      :plugin_dir                   => File.expand_path(File.join(File.dirname(__FILE__), '..', '..')),

      :will_paginate_per_page       => 50,

      :is_allowed_to_view           => lambda {|controller| return true if Rails.env.development? },

      :is_allowed_to_update         => lambda {|controller| return true if Rails.env.development? },

      :is_allowed_to_view_model     => lambda {|controller| return true  },

      :is_allowed_to_update_model   => lambda {|controller| return true  },

      :find_conditions              => nil,

      :use_google_hosting_for_jquery => true,

      :rake_command                 => 'rake',

      :drop_down_for_associations   => true,

      :ignore_column_limit          => false,

      :columns_order                => nil

    }
  end

end
