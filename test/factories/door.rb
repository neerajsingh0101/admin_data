Factory.define :door, :class => Vehicle::Door do |f|
  f.color 'black'
  f.car { |u| u.association(:car) }
end
