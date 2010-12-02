User.all.each {|r| r.destroy }
Club.all.each {|r| r.destroy }


(1..100).to_a.each_with_index do |i,e|
  User.create!(:data => {:year => 1900 + i, :music => 'rock, jazz'},
  :first_name => Faker::Name.first_name,
  :last_name => Faker::Name.last_name,
  :active => true,
  :age => 1 + i,
  :description => Faker::Lorem.paragraph,
  :born_at =>  Time.now)
end

User.find(:all).each do |u|
  2.times do
    u.phone_numbers.create!(:number => Faker::PhoneNumber.phone_number)
  end
  u.create_website(:url => 'http://www.' + Faker::Internet.domain_name)
  u.clubs.create!(:name => Faker::Company.name)
end
