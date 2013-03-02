Then /^async page should have text as current date for "(.*)"$/ do |css_selector|
  wait_until { page.evaluate_script("jQuery.active === 0") }

  page.find(css_selector).value.should == Time.now.strftime('%d-%B-%Y')
end

Given /^first user's value for active is nil$/ do
  User.update_all('active = NULL', "id = #{User.first.id}")
end

Given /^last user's value for active is nil$/ do
  User.update_all('active = NULL', "id = #{User.last.id}")
end
