class City < ActiveRecord::Base

  before_create :set_permanent_name

  def to_param
    self.permanent_name
  end

  private

  def set_permanent_name
    self.permanent_name = ActiveSupport::SecureRandom.hex(100).to_s
  end

end
