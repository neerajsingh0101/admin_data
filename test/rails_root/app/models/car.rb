class Car < ActiveRecord::Base
  belongs_to :user
  has_many :brakes, :foreign_key => 'vehicle_id'
end
