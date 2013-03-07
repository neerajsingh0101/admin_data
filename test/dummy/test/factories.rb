Factory.define :user do |f|
  f.first_name 'Mary'
  f.last_name 'Jane'
  f.age 21
  f.born_at {Time.parse('August 31 2010')}
end

Factory.define :website do |f|
  f.url 'http://example.com'
  f.association :user
end

Factory.define :phone_number do |f|
  f.number '123-456-7890'
  f.association :user
end

Factory.define :club do |f|
  f.name 'sun-shine club'
  f.association :user
end

Factory.define :newspaper do |f|
  f.paper_id 'dc_express'
  f.name 'DC Express'
end

Factory.define :city do |f|
  f.name 'seattle'
end
