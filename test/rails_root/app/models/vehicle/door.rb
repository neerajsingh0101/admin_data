class Vehicle::Door < ActiveRecord::Base
  belongs_to :car, :class_name => 'Vehicle::Car'
end
