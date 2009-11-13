module AdminData::Chelper

  def constantize_klass(klass_name)
    # for models like app/models/foo/bar/baz.rb
    klass_name.split('::').inject(Object) do |klass, part|
      klass.const_get(part)
    end
  end

  def per_page
    AdminDataConfig.setting[:will_paginate_per_page]
  end

  def admin_data_is_allowed_to_view_model?
    AdminDataConfig.setting[:is_allowed_to_view_model].call(self)
  end

  def admin_data_is_allowed_to_update?
    return true if Rails.env.development? || AdminDataConfig.setting[:is_allowed_to_update].call(self)
    false
  end

  def admin_data_is_allowed_to_update_model?
    return true if Rails.env.development? || AdminDataConfig.setting[:is_allowed_to_update_model].call(self)
    false
  end

end
