Then /^async verify that number of "(.*)" records is "(.*)"$/ do |klass, count|
  wait_until { page.evaluate_script("jQuery.active === 0") }
  klass.constantize.count.should == count.to_i
end

Then /^async click "(.*)"$/ do |text|
  wait_until { page.evaluate_script("jQuery.active === 0") }

  page.evaluate_script('window.confirm = function() { return true; }')
  page.click_link_or_button(text)
end

Then /^asyc I should see "(.*)"$/ do |text|
  wait_until { page.evaluate_script("jQuery.active === 0") }

  page.should have_content(text)
end

