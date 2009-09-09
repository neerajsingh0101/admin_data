class Vehicle::Car < ActiveRecord::Base
  has_many :doors, :class_name => 'Vehicle::Door', :dependent => :destroy
  has_one :engine, :class_name => 'Vehicle::Engine', :dependent => :destroy
end
