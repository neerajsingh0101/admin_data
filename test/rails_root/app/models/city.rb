class City < ActiveRecord::Base

  before_create :set_permanent_name

  def to_param
    self.name.parameterize
  end

  private

  def set_permanent_name
    self.permanent_name = self.to_param
  end

end
