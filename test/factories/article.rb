Factory.define :article do |f|
  f.title 'this is a dummy title'
  f.body 'this is a dummy body'
  f.status 'published'
  f.approved false
  f.hits_count 1
  f.published_at
end
