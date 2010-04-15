Factory.define :engine, :class => Vehicle::Engine do |f|
  f.cylinders 6
  f.car { |u| u.association(:car) }
end
