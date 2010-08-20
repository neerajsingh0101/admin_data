class AdminData::Config

  cattr_accessor :setting

  def self.set=(input = {})
    valid_keys =
    %w(
    adapter_name
    find_conditions
    plugin_dir
    will_paginate_per_page
    
    is_allowed_to_view
    is_allowed_to_view_klass
    is_allowed_to_update
    is_allowed_to_update_klass

    is_allowed_to_view_feed
    feed_authentication_user_id
    feed_authentication_password
    column_settings
    columns_order
    use_google_hosting_for_jquery
    drop_down_for_associations
    ignore_column_limit
    ).collect(&:intern)

    extra_keys = input.keys - valid_keys
    raise "Following options are not supported. #{extra_keys.inspect}" unless extra_keys.empty?

    self.setting ||= {}
    self.setting.merge!(input)

  end

  def self.initialize_defaults
    self.setting = {

      :plugin_dir                   => File.expand_path(File.join(File.dirname(__FILE__), '..', '..')),

      :will_paginate_per_page       => 50,

      :is_allowed_to_view           => lambda {|controller| return true if Rails.env.development? },

      :is_allowed_to_update         => lambda {|controller| return true if Rails.env.development? },

      :is_allowed_to_view_klass     => lambda {|controller| return true  },

      :is_allowed_to_update_klass   => lambda {|controller| return true  },

      :find_conditions              => nil,

      :use_google_hosting_for_jquery => true,

      :drop_down_for_associations   => true,

      :ignore_column_limit          => false,

      :columns_order                => nil

    }
  end

end
