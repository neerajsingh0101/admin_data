module AdminData::Chelper

  def per_page
    AdminDataConfig.setting[:will_paginate_per_page]
  end

  def admin_data_is_allowed_to_view?
    return true if Rails.env.development?
    AdminDataConfig.setting[:is_allowed_to_view].call(self)
  end

  def admin_data_is_allowed_to_view_model?
    return true if Rails.env.development?
    AdminDataConfig.setting[:is_allowed_to_view_model].call(self)
  end

  def admin_data_is_allowed_to_update?
    return true if Rails.env.development?
    AdminDataConfig.setting[:is_allowed_to_update].call(self)
  end

  def admin_data_is_allowed_to_update_model?
    return true if Rails.env.development?
    AdminDataConfig.setting[:is_allowed_to_update_model].call(self)
  end

  def admin_data_invalid_record_link(klassu, id, error)
    record = klassu.camelize.constantize.send(:find, id)
    tmp = admin_data_on_k_path(:klass => klasss.underscore, :id => record)
    a = []
    a << link_to(klasss, tmp, :target => '_blank')
    a << id
    a << error
    a.join(' | ')
  end

end
