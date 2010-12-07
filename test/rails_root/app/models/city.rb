class City < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :populate_data

  serialize :data

  def to_param
    self.name
  end

  private

  def populate_data
    self.data = {:population => 5000}
  end



end
