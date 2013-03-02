namespace :db do

  desc 'populate cars'
  task :sample_cars => :environment do
    Car.delete_all

    (1..400).to_a.each_with_index do |i, e|
      i.times do 
        car = Car.new(:name => "car-#{i}")
        puts i
        car.created_at = i.send(:days).send(:ago)
        car.save!
      end
    end
  end


end
