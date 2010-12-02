Then /^(.*)verify that user "(.*)" is "(.*)"$/ do |async, attribute, input|
  wait_until { page.evaluate_script("jQuery.active === 0") } unless async.blank?

  page.has_xpath?("//table[@id='view_table']")
  table =  page.find(:xpath, "//table[@id='view_table']")

  counter = attribute == 'first_name' ? 2 : 3
  regex = Regexp.new(input)

  if async.blank?
    table.find(:xpath, "./tr/td[#{counter}]", :text => regex )
  else
    table.find(:xpath, "./tbody/tr/td[#{counter}]", :text => regex )
  end
end

Then /^I should see following tabular attributes:$/ do |expected_cukes_table|
  expected_cukes_table.diff!(tableish('table.table tr', 'td,th'))
end

Then /^first id of table should be of "(.*)"$/ do |first_name|
  page.should have_css("#view_table tr td a", :text => User.find_by_first_name(first_name).id.to_s)
end
