module AdminData::Chelper

  def per_page
    AdminDataConfig.setting[:will_paginate_per_page]
  end

  def admin_data_is_allowed_to_update?
    return true if Rails.env.development? || AdminDataConfig.setting[:update_security_check].call(self)
    false
  end

end
