class Vehicle::Engine < ActiveRecord::Base
  belongs_to :car, :class => 'Vehicle::Car'
end
