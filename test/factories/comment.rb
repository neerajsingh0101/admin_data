Factory.define :comment do |f|
  f.association(:article) 
  f.body 'this is a dummy body'
  f.author_name 'this is dummy author name'
  f.author_website 'http://www.example.org'
end
