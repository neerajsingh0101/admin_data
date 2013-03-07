Then /^I should see crud show tabular attributes$/ do
  data = tableish('table.table tr', 'td,th').flatten
  data[0].should == "id"
  data[2].should == "first_name"
  data[3].should == "Mary"
  data[4].should == "last_name"
  data[5].should == "Jane"
  data[6].should == "age"
  data[7].should == "21"
  data[8].should == "data"
  data[9].should == "nil"
  data[10].should == "active"
  data[11].should == "false"
  data[12].should == "description"
  data[13].should == ""
  data[14].should == "born_at"
  data[15].should =~ /30-August-2010/
end

Then /^I should find value "(.*)" for "(.*)"$/ do |text, column|
  index = (column == 'created_at') ? 9 : 10
  page.should have_xpath( "//form//div[@class='data'][#{index}]", :text => Regexp.new(text) )
end

Then /^I should notice id of the last person$/ do
  page.should have_content("ID #{User.last.id}")
end

Then /^I should notice id of website of the last person$/ do
  page.should have_content("ID #{User.last.website.id}")
end

Given /^user owns two clubs "sun-shine" and "rise-n-shine"$/ do
  u = User.last
  u.clubs.create(:name => 'sun-shine')
  u.clubs.create(:name => 'rise-n-shine')
end
